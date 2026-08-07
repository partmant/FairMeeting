# FairMeeting

> 참여자들의 출발지에서 후보 장소까지의 대중교통 이동 시간을 비교해, 이동 시간 편차가 가장 작은 지점을 추천하는 모바일 앱입니다.

- **프로젝트 기간**: 2025.03.10 ~ 2025.06.15 (컴퓨터공학 캡스톤디자인)
- **팀 구성**: 3인
- **역할**: 비즈니스 로직 구현 (중간지점 계산 알고리즘, 검색/경로 API, 예외 처리) + 프론트엔드 주요 화면(홈, 결과, 위치 입력) UI 공동 구현
- **시연 영상**: [YouTube에서 보기](https://youtu.be/0NHQ85YaOBU)

> 이 저장소는 3인 팀 프로젝트의 백엔드와 프론트엔드 저장소를 개인 포트폴리오 용도로 통합한
> 저장소입니다. `backend/`, `frontend/` 디렉터리는 `git subtree`로 가져와 각 폴더의 원본 커밋
> 이력을 그대로 유지하고 있습니다.
> - 팀 원본 백엔드 저장소: https://github.com/fairmeeting/fair_back
> - 팀 원본 프론트엔드 저장소: https://github.com/fairmeeting/fair_front

---

## 문제 정의

여러 사람이 약속 장소를 정할 때는 각 출발지의 단순한 지리적 중심을 기준으로 장소를 선택하는 경우가 많습니다. 그러나 지리적으로 가까운 거리라도 노선과 환승 횟수에 따라 실제 이동 시간은 크게 달라질 수 있어 특정 참여자에게 이동 부담이 집중될 수 있습니다.

FairMeeting은 각 출발지에서 후보 지점까지의 대중교통 이동 시간을 비교하고, 참여자 간 이동 시간 편차가 가장 작은 지점을 계산하여 보다 공정한 약속 장소를 추천합니다.

---

## 담당 영역

- 중간지점 계산 알고리즘 — 다중 출발지 다익스트라 알고리즘과 N-1 부분집합 최적화 직접 구현
- 검색·경로 API 연동 — Kakao Local API(장소 검색), Kakao Map SDK(지도), ODsay API(대중교통 경로·소요시간)
- 예외 처리 — 계산이 무의미해지거나 실패할 수 있는 경계 상황 6종 정의 및 처리
- 프론트엔드 UI 공동 구현 — 홈 화면, 결과 화면(카테고리 필터·경로 리스트), 위치 입력 화면 등 주요 화면을 팀원과 함께 구현 (Flutter)

아래 "주요 기능"은 팀 전체 구현 범위이며, 담당자는 "팀원 역할 분담"에 별도로 표시했습니다.

---

## 주요 기능

- **공정한 중간지점 계산** (참여자 간 이동 시간 편차 최소화)
- **카테고리별 장소 추천** (음식점, 카페, 문화시설 등)
- **캘린더 연동 및 일정 저장**
- **약속 24시간 전 로컬 알림**
- **네이버 길찾기 연동**
- **카카오톡 약속 공유**
- **카카오 로그인 및 비회원 모드 지원**

---

## 주요 화면

<p>
  <img src="images/home_screen.jpg" width="25%">
  <img src="images/address_search.jpg" width="25%">
  <img src="images/location_result.jpg" width="25%">
</p>

<p>
  <img src="images/recommendation.jpg" width="25%">
  <img src="images/route_detail.jpg" width="25%">
</p>

<p>
  <img src="images/calendar.jpg" width="25%">
  <img src="images/calendar_edit.jpg" width="25%">
</p>

---

## 기술 스택

### Frontend

- Flutter (Dart)
- Kakao Map SDK (지도 렌더링 및 장소 검색)
- Provider (전역 상태 관리)
- SharedPreferences (로컬 데이터 저장)
- table_calendar (캘린더 UI 구성)
- flutter_local_notifications (약속 시간 기준 로컬 알림 예약 및 실행)
- url_launcher (외부 링크 이동: 네이버 길찾기 등)
- geolocator (GPS 기반 현재 위치 수신)
- kakao_flutter_sdk_user (카카오 로그인 연동)
- flutter_timezone, timezone (시간대 기반 알림 처리)

### Backend

- Java 21, Spring Boot
- REST API
- MyBatis (사용자·일정 CRUD)
- Neo4j Java Driver (Cypher 쿼리로 지하철역·노선 그래프 데이터 조회)
- 인증: Flutter에서 카카오 로그인을 수행하고, 전달받은 카카오 사용자 식별자(kakaoId)를
  기준으로 백엔드에서 사용자 정보를 조회·등록. 별도의 자체 JWT 인증 서버는 구현하지 않음

### Infra & DB

- AWS EC2 (배포 서버)
- AWS RDS (MySQL)
- Neo4j (지하철 경로 탐색용 그래프DB)

### 시스템 구성

| 구분     | 기술                                       |
| -------- | ------------------------------------------ |
| Frontend | Flutter (`frontend/`)                      |
| Backend  | Spring Boot REST API (`backend/`)          |
| DB       | MySQL(AWS RDS), Neo4j(그래프DB)            |
| 외부     | Kakao Local API, Kakao Map SDK, ODsay API  |

---

## 아키텍처 개요

![아키텍처](images/architecture.png)

Flutter 클라이언트는 Spring Boot 서버와 REST API로 통신합니다. 사용자와 일정 데이터는
MySQL에 저장하고, 지하철역과 노선 정보는 그래프 구조에 적합한 Neo4j에 저장했습니다.

중간지점 계산 시 백엔드는 Neo4j에서 역과 노선 데이터를 조회한 뒤, Java로 직접 구현한
다중 출발지 다익스트라 알고리즘을 실행합니다. 각 출발지에서 후보 역까지의 이동 시간을
계산하고, 참여자 간 이동 시간 편차가 가장 작은 역을 최종 중간지점으로 선정합니다.

장소명·주소 검색과 중간지점 주변의 카테고리별 장소 검색에는 Kakao Local API를 사용하며,
지도 표시는 Kakao Map SDK로 처리합니다. 대중교통 경로와 소요시간은 ODsay API를 통해
조회하고, 최종 장소까지의 상세 길찾기는 네이버 지도 외부 링크로 연결합니다.

---

## 핵심 설계 의사결정

**다중 출발지 다익스트라 알고리즘 직접 구현**

여러 출발지에서 후보 역까지의 이동 시간을 계산한 뒤, 이동 시간 편차가 가장 작은 역을
중간지점으로 선정합니다. 지하철 노선 데이터는 Neo4j에 노드와 간선으로 저장하고, 조회한
그래프 데이터를 기반으로 Java에서 **다중 출발지 다익스트라 알고리즘과 N-1 부분집합
최적화**를 직접 구현했습니다.

**경계 상황 6종에 대한 예외 처리**

계산이 무의미해지거나 실패할 수 있는 경계 상황을 정의하고 각각 처리 방식을 구현했습니다.

| # | 경계 상황 | 처리 결과 |
|---|---|---|
| 1 | 출발지가 2개 미만 | 실행 차단 + 안내 메시지 |
| 2 | 출발지가 5개 초과 | 추가 입력 제한 + 안내 메시지 |
| 3 | 출발지 간 거리가 한 정거장 수준으로 근접 | 실행 차단 + 안내 메시지 |
| 4 | 출발지 중 하나가 계산된 중간지점과 동일 | 소요시간 0분으로 정상 처리 (예외 아님) |
| 5 | 서비스 범위(수도권 1~9호선) 밖의 역이 출발지인 경우 | 실행 차단 + 안내 메시지 |
| 6 | 동일 출발지를 여러 번 입력 | 중복 포함하여 정상 계산 |

---

## 실행 방법

### 1. 사전 요구 사항

| 항목    | 버전     |
| ------- | -------- |
| JDK     | 21       |
| Flutter | 3.7+     |
| MySQL   | 8+       |
| Neo4j   | 5.x      |
| Git     | 2.x 이상 |

### 2. 저장소 클론

```bash
git clone https://github.com/partmant/FairMeeting.git
cd FairMeeting
```

### 3. Backend 환경변수

`backend` 폴더에 `.env` 파일을 생성합니다.

```env
DB_URL=jdbc:mysql://localhost:3306/fairmeeting
DB_USERNAME=your_username
DB_PASSWORD=your_password

NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password

KAKAO_API_KEY=your_kakao_rest_api_key
ODSAY_KEY=your_odsay_api_key
```

### 4. Backend 실행 (API 기본 URL: http://localhost:8088)

```bash
cd backend
./mvnw spring-boot:run
```

### Backend 실행 (Docker)

```bash
cd backend
docker compose up -d --build
```

### 5. Frontend 실행

```bash
cd frontend
flutter pub get
flutter run
```

---

## 패키지 구조

```
backend/src/main/java/net/skhu/
├── controller/   # REST API 엔드포인트
├── service/      # 중간지점 계산 등 비즈니스 로직 [담당]
├── mapper/       # MyBatis 매퍼 인터페이스
├── dto/          # 요청/응답 DTO
└── util/         # 공통 유틸리티

backend/src/main/resources/
└── mapper/       # MyBatis SQL 매핑(userMapper.xml, appointmentMapper.xml)

frontend/lib/
├── screens/          # 로그인·위치입력·주소검색·캘린더·결과 등 화면 단위
├── widgets/
│   ├── calendar/, fair_result/, put_location/, search_address/
├── controllers/      # 지도·POI·사용자 컨트롤러
├── services/         # Kakao 로그인/공유, 주소·일정·카테고리 API 연동
├── providers/         # 전역 상태 관리
├── notifiers/, models/, utils/
```

---

## 팀원 역할 분담

| 이름   | 역할 | 담당 |
| ------ | ---- | ---- |
| 홍창희 | BE / FE | 비즈니스 로직 구현 (중간지점 계산 알고리즘, 검색/경로 API, 예외 처리) + 홈·결과·위치 입력 화면 UI 공동 구현 |
| 임채환 | BE / FE | DB & Server + 프론트엔드 UI 공동 구현 |
| 윤찬혁 | FE   | UI 구현 |

---

## 관련 문서

- [Figma 디자인](https://www.figma.com/design/yHoLZvf0cIJbxY7TDWtGf3/%EC%BA%A1%EC%8A%A4%ED%86%A4?node-id=1-4&t=Bd3fprzq6y4rB3VY-0)
