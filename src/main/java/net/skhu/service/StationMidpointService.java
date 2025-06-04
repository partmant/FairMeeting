 package net.skhu.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Record;
import org.neo4j.driver.Result;
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

    /**
     * 여러 출발역 리스트에 대해 최적 중간역 하나를 계산하여 DTO로 반환.
     * Neo4j GDS의 Bellman–Ford single-source 스트림 프로시저를 사용합니다.
     * 수행시간을 콘솔에 출력합니다.
     */
    public StationMidpointResponse findMidStation(List<String> sourceNames) {
        long start = System.currentTimeMillis();
        try (Session session = driver.session()) {
            // 1) 모든 역의 nodeId ↔ name 맵 생성
            Map<Long, String> idToName = new HashMap<>();
            Result allStations = session.run(
                "MATCH (n:Station) RETURN id(n) AS id, n.name AS name"
            );
            while (allStations.hasNext()) {
                Record rec = allStations.next();
                idToName.put(rec.get("id").asLong(), rec.get("name").asString());
            }

            // 2) 출발역별 Bellman–Ford single-source 최단경로 → nodeId(targetNode)별 소요시간(totalCost) 누적
            Map<Long, List<Double>> timesByNode = new HashMap<>();
            // 다익스트라 변경 시, 초기 진입에 사용되는 메모리 과다로 컨테이너 소실되는 이슈
            String bellmanFordCypher = """
                CALL gds.bellmanFord.stream('subwayGraph', {
                  sourceNode: $srcId,
                  relationshipWeightProperty: 'time'
                })
                YIELD targetNode, totalCost
                """;

            for (String source : sourceNames) {
                long srcId = session.run(
                        "MATCH (s:Station {name: $source}) RETURN id(s) AS id",
                        Map.of("source", source)
                    )
                    .single()
                    .get("id")
                    .asLong();

                Result costs = session.run(bellmanFordCypher, Map.of("srcId", srcId));
                while (costs.hasNext()) {
                    Record r    = costs.next();
                    long nodeId = r.get("targetNode").asLong();
                    double cost = r.get("totalCost").asDouble();
                    timesByNode
                        .computeIfAbsent(nodeId, k -> new ArrayList<>())
                        .add(cost);
                }
            }

            // 3) nodeId별 비용 차이(diff) 계산 → 최소 diff인 nodeId 선택
            double minDiff = Double.MAX_VALUE;
            long bestNodeId = -1;
            Map<String, Double> bestTimes = new HashMap<>();

            for (var entry : timesByNode.entrySet()) {
                List<Double> costs = entry.getValue();
                if (costs.size() != sourceNames.size()) {
                    // 일부 출발역 미도달 스킵
                    continue;
                }
                double max = Collections.max(costs);
                double min = Collections.min(costs);
                double diff = max - min;
                if (diff < minDiff) {
                    minDiff = diff;
                    bestNodeId = entry.getKey();
                    bestTimes.clear();
                    for (int i = 0; i < sourceNames.size(); i++) {
                        bestTimes.put(sourceNames.get(i), costs.get(i));
                    }
                }
            }

            return new StationMidpointResponse(
                sourceNames,
                idToName.get(bestNodeId),
                bestTimes,
                minDiff
            );
        } finally {
            long end = System.currentTimeMillis();
            System.out.println("StationMidpointService.findBestMidpoint 수행시간: "
                + (end - start) + " ms");
        }
    }
}