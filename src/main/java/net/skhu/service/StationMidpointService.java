package net.skhu.service;

import java.util.List;
import java.util.Map;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Session;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import net.skhu.dto.StationMidpointResponse;

@Service
public class StationMidpointService {

    private final Driver driver;

    public StationMidpointService(
            @Value("${spring.neo4j.uri}") String uri,
            @Value("${spring.neo4j.authentication.username}") String username,
            @Value("${spring.neo4j.authentication.password}") String password
    ) {
        this.driver = GraphDatabase.driver(uri, AuthTokens.basic(username, password));
    }

    public StationMidpointResponse findMidpoint(String sourceName, String targetName) {
        try (Session session = driver.session()) {

            String pathQuery = """
                MATCH (source:Station {name: $sourceName}), (target:Station {name: $targetName})
                CALL gds.shortestPath.dijkstra.stream('subwayGraph', {
                  sourceNode: id(source),
                  targetNode: id(target),
                  relationshipWeightProperty: 'time'
                })
                YIELD nodeIds
                RETURN nodeIds
                LIMIT 1
            """;

            List<Object> nodeIds = session.run(pathQuery, Map.of(
                    "sourceName", sourceName,
                    "targetName", targetName
            )).single().get("nodeIds").asList();

            String findNameQuery = "MATCH (n) WHERE id(n) = $id RETURN n.name AS name";

            double minDiff = Double.MAX_VALUE;
            String bestMidpointName = null;
            double bestSourceToMid = 0;
            double bestTargetToMid = 0;

            for (Object nodeId : nodeIds) {
                String nodeName = session.run(findNameQuery, Map.of("id", nodeId))
                                         .single().get("name").asString();

                String fromSourceQuery = """
                    MATCH (source:Station {name: $sourceName}), (mid:Station {name: $midName})
                    CALL gds.shortestPath.dijkstra.stream('subwayGraph', {
                      sourceNode: id(source),
                      targetNode: id(mid),
                      relationshipWeightProperty: 'time'
                    }) YIELD totalCost RETURN totalCost
                """;
                double sourceToMid = session.run(fromSourceQuery, Map.of(
                        "sourceName", sourceName,
                        "midName", nodeName)).single().get("totalCost").asDouble();

                String fromTargetQuery = """
                    MATCH (target:Station {name: $targetName}), (mid:Station {name: $midName})
                    CALL gds.shortestPath.dijkstra.stream('subwayGraph', {
                      sourceNode: id(target),
                      targetNode: id(mid),
                      relationshipWeightProperty: 'time'
                    }) YIELD totalCost RETURN totalCost
                """;
                double targetToMid = session.run(fromTargetQuery, Map.of(
                        "targetName", targetName,
                        "midName", nodeName)).single().get("totalCost").asDouble();

                double diff = Math.abs(sourceToMid - targetToMid);

                if (diff < minDiff) {
                    minDiff = diff;
                    bestMidpointName = nodeName;
                    bestSourceToMid = sourceToMid;
                    bestTargetToMid = targetToMid;
                }
            }

            return new StationMidpointResponse(
                    sourceName,
                    targetName,
                    bestMidpointName,
                    bestSourceToMid,
                    bestTargetToMid,
                    minDiff
            );

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
