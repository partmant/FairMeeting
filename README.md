# fair_back


SKHU CAPSTONE DESIGN

## 프로젝트 개요
- 사용자 인증 및 정보 관리  
- 중간 지점 계산 알고리즘(ODsay API, Station Midpoint) 제공  
- 캘린더 일정 CRUD API 제공  
- 카카오 장소 자동완성·카테고리 검색·지오코딩·좌표 검색 연동

## 기술 스택
- **언어 & 프레임워크**: Java + Spring Boot
- **DB & ORM**: MySQL (JDBC + MyBatis) + Neo4j (GDS)
- **외부 API**:  
  - Kakao REST API (장소 자동완성, 카테고리 검색, 지오코딩)  
  - ODsay API (대중교통 경로)  
- **컨테이너 & 배포**: Docker, Docker Compose, GitHub Actions → EC2 배포  
- **빌드 도구**: Maven  

## 서버
- EC2 + RDS
  - 그래프 DB 사용을 위해, EC2에 Docker로 Neo4j 사용 중
 
 
Fair Meeting Backend

