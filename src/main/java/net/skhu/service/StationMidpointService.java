package net.skhu.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.stream.Collectors;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Record;
import org.neo4j.driver.Result;
import org.neo4j.driver.Session;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import net.skhu.dto.StationMidpointResponse;

/*
코드 설명
1. N개 출발역 계산 
- computeMidpoint로 원본 N개 리스트에 대해 최적 중간역(소요 시간 편차 최소)을 구합니다.
- 결과를 fullResp에 저장.
2. N-1개 부분집합 계산 (Outlier 제거 효과)
- 입력된 소스 리스트에서 하나씩 뺀 N개(즉, N-1개) 부분집합을 모두 시도하며, 이 중 시간 편차(timeDifference)가 가장 작은 결과를 bestSubset에 저장합니다.
- 어떤 부분집합도 유효치 않으면 bestSubset은 null이 됩니다.
3. N vs. N-1 결과 비교 : 
- 둘 다 유효하다면, bestSubset.timeDifference < fullResp.timeDifference 인 경우에만 N-1 결과를 택합니다.
- N-1 결과를 택할 때는, 제외된 출발역의 시간을 runFullDijkstra로 보완하여 원래 N개 출발역 전체의 시간 맵(timeFromSourceToMid)을 완성합니다.
4. 최종 반환
- N-1을 택하지 않았다면, fullResp가 있으면 이를 반환하고, 만약 N 계산이 실패했다면 bestSubset(가능한 경우)을 반환합니다.
- 둘 다 없으면 예외를 던집니다.
 */

@Service
public class StationMidpointService {
    private final Driver driver;

    public StationMidpointService(
            @Value("${spring.neo4j.uri}") String uri,
            @Value("${spring.neo4j.authentication.username}") String username,
            @Value("${spring.neo4j.authentication.password}") String password) {
        this.driver = GraphDatabase.driver(uri, AuthTokens.basic(username, password));
    }

    private static class Edge { long target; double time; Edge(long t, double tm) { this.target = t; this.time = tm; }}
    private static class NodeEntry { long nodeId; double cost; int srcIdx; NodeEntry(long n, double c, int i) { this.nodeId = n; this.cost = c; this.srcIdx = i; }}

    private Map<Long, Double> runFullDijkstra(Map<Long, List<Edge>> graph, long srcId) {
        record Entry(long nodeId, double cost) {}
        Map<Long, Double> dist = new HashMap<>();
        PriorityQueue<Entry> pq = new PriorityQueue<>( (a, b) -> Double.compare(a.cost, b.cost) );
        dist.put(srcId, 0.0);
        pq.offer(new Entry(srcId, 0));
        while (!pq.isEmpty()) {
            Entry cur = pq.poll();
            if (cur.cost > dist.get(cur.nodeId)) continue;
            for (Edge e : graph.getOrDefault(cur.nodeId, List.of())) {
                double nc = cur.cost + e.time;
                if (nc < dist.getOrDefault(e.target, Double.POSITIVE_INFINITY)) {
                    dist.put(e.target, nc);
                    pq.offer(new Entry(e.target, nc));
                }
            }
        }
        return dist;
    }

    private StationMidpointResponse computeMidpoint(Session session, List<String> sourceNames,
            Map<Long, String> idToName, Map<Long, List<Edge>> graph) {
        int k = sourceNames.size();
        List<Long> sourceIds = sourceNames.stream()
            .map(name -> session.run("MATCH (s:Station {name:$name}) RETURN id(s) AS id", Map.of("name", name))
                .single().get("id").asLong())
            .toList();

        Map<Long, double[]> distMap = new HashMap<>();
        PriorityQueue<NodeEntry> pq = new PriorityQueue<>( (a, b) -> Double.compare(a.cost, b.cost) );
        for (int i = 0; i < k; i++) {
            long src = sourceIds.get(i);
            double[] arr = new double[k];
            Arrays.fill(arr, Double.POSITIVE_INFINITY);
            arr[i] = 0;
            distMap.put(src, arr);
            pq.offer(new NodeEntry(src, 0, i));
        }

        double bestDiff = Double.MAX_VALUE;
        double bestMaxCost = Double.POSITIVE_INFINITY;
        long bestNodeId = -1;
        double[] bestTimesArr = null;

        while (!pq.isEmpty()) {
            NodeEntry cur = pq.poll();
            double[] curArr = distMap.computeIfAbsent(cur.nodeId, n -> {
                double[] a = new double[k]; Arrays.fill(a, Double.POSITIVE_INFINITY); return a;
            });
            if (cur.cost > curArr[cur.srcIdx]) continue;
            curArr[cur.srcIdx] = cur.cost;

            boolean allVisited = true;
            double min = Double.MAX_VALUE, max = 0;
            for (double d : curArr) {
                if (d == Double.POSITIVE_INFINITY) { allVisited = false; break; }
                min = Math.min(min, d);
                max = Math.max(max, d);
            }
            if (allVisited) {
                double diff = max - min;
                if (diff < bestDiff) {
                    bestDiff = diff;
                    bestMaxCost = max;
                    bestNodeId = cur.nodeId;
                    bestTimesArr = Arrays.copyOf(curArr, k);
                }
            }
            if (bestTimesArr != null && cur.cost > bestMaxCost) break;

            for (Edge e : graph.getOrDefault(cur.nodeId, List.of())) {
                double nc = cur.cost + e.time;
                double[] nbrArr = distMap.computeIfAbsent(e.target, n -> {
                    double[] a = new double[k]; Arrays.fill(a, Double.POSITIVE_INFINITY); return a;
                });
                if (nc < nbrArr[cur.srcIdx]) {
                    nbrArr[cur.srcIdx] = nc;
                    pq.offer(new NodeEntry(e.target, nc, cur.srcIdx));
                }
            }
        }

        if (bestTimesArr == null) {
            List<Map<Long, Double>> fullList = new ArrayList<>();
            for (long srcId : sourceIds) fullList.add(runFullDijkstra(graph, srcId));
            for (Long nodeId : graph.keySet()) {
                boolean reachable = true;
                double min = Double.MAX_VALUE, max = 0;
                double[] times = new double[k];
                for (int i = 0; i < k; i++) {
                    Double d = fullList.get(i).get(nodeId);
                    if (d == null) { reachable = false; break; }
                    times[i] = d;
                    min = Math.min(min, d);
                    max = Math.max(max, d);
                }
                if (!reachable) continue;
                double diff = max - min;
                if (diff < bestDiff) {
                    bestDiff = diff;
                    bestMaxCost = max;
                    bestNodeId = nodeId;
                    bestTimesArr = times;
                }
            }
        }
        if (bestTimesArr == null) return null;

        Map<String, Double> bestTimes = new HashMap<>();
        for (int i = 0; i < k; i++) bestTimes.put(sourceNames.get(i), bestTimesArr[i]);
        return new StationMidpointResponse(sourceNames, idToName.get(bestNodeId), bestTimes, bestDiff);
    }

    public StationMidpointResponse findMidStation(List<String> sourceNames) {
        long startTs = System.currentTimeMillis();
        try (Session session = driver.session()) {
            Map<Long, String> idToName = new HashMap<>();
            Result allStations = session.run("MATCH (n:Station) RETURN id(n) AS id, n.name AS name");
            while (allStations.hasNext()) {
                Record r = allStations.next();
                idToName.put(r.get("id").asLong(), r.get("name").asString());
            }

            Map<Long, List<Edge>> graph = new HashMap<>();
            session.run(
                "MATCH (s:Station)-[r:CONNECTS]->(t:Station) RETURN id(s) AS src, id(t) AS tgt, r.time AS time"
            ).list(r -> {
                long u = r.get("src").asLong();
                long v = r.get("tgt").asLong();
                double w = r.get("time").asDouble();
                graph.computeIfAbsent(u, k -> new ArrayList<>()).add(new Edge(v, w));
                graph.computeIfAbsent(v, k -> new ArrayList<>()).add(new Edge(u, w));
                return null;
            });

            int N = sourceNames.size();
            List<Long> sourceIds = sourceNames.stream()
                .map(name -> session.run(
                    "MATCH (s:Station {name:$name}) RETURN id(s) AS id", Map.of("name", name)
                ).single().get("id").asLong())
                .toList();

            // N개로 계산
            StationMidpointResponse fullResp = computeMidpoint(session, sourceNames, idToName, graph);

            // N-1개로 bestSubset 계산
            StationMidpointResponse bestSubset = null;
            int removedIdx = -1;
            for (int i = 0; i < N; i++) {
                List<String> subset = new ArrayList<>(sourceNames);
                subset.remove(i);
                StationMidpointResponse r = computeMidpoint(session, subset, idToName, graph);
                if (r != null && (bestSubset == null || r.getTimeDifference() < bestSubset.getTimeDifference())) {
                    bestSubset = r;
                    removedIdx = i;
                }
            }

            // 둘 중 편차가 더 작은 쪽을 선택
            if (bestSubset != null && fullResp != null && bestSubset.getTimeDifference() < fullResp.getTimeDifference()) {
                // outlier 보정 후 반환
                Map<String, Long> nameToId = idToName.entrySet().stream()
                    .collect(Collectors.toMap(Map.Entry::getValue, Map.Entry::getKey));
                long midNodeId = nameToId.get(bestSubset.getBalancedMidpoint());
                double removedTime = runFullDijkstra(graph, sourceIds.get(removedIdx))
                    .getOrDefault(midNodeId, Double.POSITIVE_INFINITY);

                Map<String, Double> fullTimes = new HashMap<>();
                List<String> subsetNames = bestSubset.getSources();
                for (int i = 0, si = 0; i < N; i++) {
                    if (i == removedIdx) {
                        fullTimes.put(sourceNames.get(i), removedTime);
                    } else {
                        fullTimes.put(sourceNames.get(i), bestSubset.getTimeFromSourceToMid().get(subsetNames.get(si++)));
                    }
                }
                return new StationMidpointResponse(
                    sourceNames,
                    bestSubset.getBalancedMidpoint(),
                    fullTimes,
                    bestSubset.getTimeDifference()
                );
            }

            // 나머지 경우 fullResp 또는 bestSubset
            if (fullResp != null) {
                return fullResp;
            } else if (bestSubset != null) {
                return bestSubset;
            }

            throw new IllegalStateException("중간역을 찾지 못했습니다.");
        } finally {
            long endTs = System.currentTimeMillis();
            System.out.println("StationMidpointService.findMidStation 수행시간: " + (endTs - startTs) + " ms");
        }
    }
}
