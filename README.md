# 국내 주식 관심종목 앱

이든크루 Flutter 신입 개발자 과제 — 과제 1 제출물입니다.

## 실행 방법

- Flutter `3.47.4` (stable channel), Dart `3.13.3`
- 실행 명령
  ```bash
  flutter pub get
  flutter run
  ```
- 확인한 플랫폼: **Windows 데스크톱** (`flutter run -d windows`, Visual Studio C++ 데스크톱 워크로드 설치 후 실제 앱을 띄워 인터랙션까지 확인했습니다). 안드로이드 실기기 / 에뮬레이터, 브라우저(Chrome)는 이 작업 환경에 준비돼 있지 않아 확인하지 못했습니다. 393×852 비율에 맞춰 창 크기를 좁혀서 Figma와 비교했습니다.
  - 브라우저는 과제 안내대로 CORS 때문에 Naver 요청이 막혀 애초에 대상에서 제외했습니다.
  - 바텀시트 애니메이션, 토스트처럼 실제 창에서 타이밍 맞춰 캡처하기 번거로운 상태는 `flutter test` + `RenderRepaintBoundary.toImage()`로 위젯 트리를 그대로 렌더링해 PNG로 저장하는 임시 스크립트를 보조로 써서 픽셀 단위로 확인했습니다 (커밋에는 포함하지 않았습니다).
- 폰트는 기본 제공된 `NotoSansKR` (`assets/fonts/`, `pubspec.yaml` 등록)을 그대로 사용했습니다. 바꾸지 않았습니다.
- 정적 분석: `flutter analyze` → **No issues found!**
- 테스트: `flutter test` → **14개 전부 통과** (포맷터 단위 테스트 6개, Naver 데이터 계층 파싱/캐싱 테스트 5개 — `MockClient`로 `assets/mock/naver/`의 실제 응답 샘플을 재생, 로컬 저장 테스트 2개, 스모크 위젯 테스트 1개)

## 구현 범위

### 필수 — 전부 구현했습니다

- **관심 화면**: 종목명 / `코드 · 시장` / 현재가 / 등락액·등락률, 상승·하락·보합 3색 처리, 새로고침, 하단 탭(`navActive`/`navInactive`), 시세 미수신 행 스켈레톤, 빈 상태, 정렬(현재가순 · 등락률순 · 가나다순) 바텀시트 + 헤더 칩.
- **검색 화면**: 검색창 + 지우기, 검색어 하이라이트(`searchHighlight`), 관심 등록 별 아이콘(`favoriteActive`/`favoriteInactive`) 즉시 반영 + 등록/해제 토스트, 상세 이동, 초기 상태 / 결과 없음 상태.
- **종목상세 화면**: 헤더(뒤로가기 · 이름 · 코드·시장 · 관심버튼), 현재가 + 등락 + 방향 아이콘, 기간 탭 4종(`accentDefault`/`accentBg`), 캔들 차트, 요약 카드(시가·고가·저가·거래량·시가총액을 3+2 그리드 박스로 구분, 축약 표기), 일별 시세 표(날짜 `MM.DD` · 종가 · 등락 · 거래량).
- **상태 동기화**: 관심 / 검색 / 상세 세 화면이 `FavoritesController` 하나를 공유해서 별 아이콘이 항상 같이 바뀝니다.
- Naver 4개 endpoint 모두 요청 · 파싱 · DTO · 모델 연결을 직접 구현했습니다 (아래 "기술 선택" 참고).

### 선택 — 구현한 것 / 안 한 것

구현함:
- 관심 화면 Pull to refresh
- (기본 위젯이 제공하는) 토스트 등장/퇴장 애니메이션 — `SnackBar` 기본 트랜지션
- 관심 목록 재실행 후 유지(로컬 저장) — `shared_preferences`로 관심 심볼 목록을 저장/복원

구현하지 않음 (시간 관계상 필수를 우선했습니다):
- 관심종목 스와이프 삭제
- 정렬 기준 로컬 저장 유지
- 검색 디바운스 / 검색 중 로딩 표시 (요청 순번으로 오래된 응답을 무시하는 안전장치는 넣었지만, 타이핑마다 요청은 나갑니다)
- 최근 검색어
- 차트 축 라벨 · 거래량 바 · 영역 채우기 · 크로스헤어/툴팁 · 전환 애니메이션
- 일별 시세 표 무한 스크롤 (기간별 최대 245행을 한 번에 그립니다)

## 기술 선택과 이유

- **상태관리 — `provider` + `ChangeNotifier`.** 화면이 3개뿐이라 Riverpod/Bloc 같은 코드젠 기반 도구는 과했습니다. 관심 등록 상태를 `FavoritesController` 하나로 앱 루트에서 공유해 세 화면 동기화 요구사항을 자연스럽게 풀었습니다.
- **폴더 구조 — feature-first.**
  ```
  lib/
    theme/                 (기존 디자인 토큰)
    core/
      network/              Naver 공통 HTTP 클라이언트
      format/                가격 · 숫자 · 날짜 포맷터
      widgets/               화면 간 공용 위젯(토스트)
    data/
      models/                Stock/Quote/DailyPrice 등 도메인 모델
      naver/                 endpoint별 API 클래스 (검색/시세/메타/일별)
      stock_repository.dart  4개 API를 감싸는 파사드 + 메타데이터 캐시
    app/
      favorites_controller.dart  관심 상태 단일 진실 공급원
      app_shell.dart              하단 탭 네비게이션
    features/
      watchlist/ · search/ · detail/   화면별 controller + screen + widgets
  ```
- **네트워킹 — `http`.** Dart 팀이 유지보수하는 가장 표준적인 선택입니다.
- **HTML 파싱 — `html` 패키지 + `cp949_codec`.** 일별 시세는 JSON이 아니라 EUC-KR(정확히는 상위 호환인 CP949) 인코딩 HTML이라 `http`의 기본 UTF-8 디코딩을 쓸 수 없습니다. `NaverApiClient.getBytes`로 원본 바이트를 받고 `cp949.decode(bytes)`로 직접 디코딩한 뒤 `html` 패키지로 테이블을 파싱했습니다. (처음엔 `euc` 패키지를 추가했는데, 이름과 달리 EUC-**JP**용이라 한글이 깨졌습니다. `cp949_codec`으로 바꿔서 해결했습니다 — 아래 "막혔던 지점" 참고.)
- **차트 — 패키지 없이 `CustomPainter`.** 과제 문서에 "캔들 차트를 지원하면서 토큰 색과 Figma 여백까지 맞추기 쉬운 패키지는 많지 않다"고 명시돼 있고, 차트 내부 렌더링은 감점 대상이 아니라고 해서 의존성 없이 완전히 제어 가능한 방식을 택했습니다. 상승/하락 색상(`chartLineUp`/`chartLineDown`)만 토큰에 맞췄습니다.
- **일별 시세 페이지 캐싱.** `NaverDailyPriceApi`가 심볼별로 `{page: List<DailyPrice>}` 캐시와 `lastPage`를 들고 있어서, 기간 탭을 1개월→3개월→1개월로 바꿔도 이미 받은 페이지는 다시 요청하지 않습니다. `lastPage`보다 큰 페이지도 요청하지 않습니다. (`test/data/naver/naver_daily_price_api_test.dart`에서 재요청하지 않는지 검증했습니다.)
- **메타데이터 캐시.** `StockRepository`가 심볼별 `StockSummary`를 캐싱합니다. 검색 결과는 이미 이름·시장 정보를 담고 있어서 `cacheMeta`로 바로 채워 넣고, 관심 화면 시드 종목처럼 캐시에 없는 경우에만 메타데이터 endpoint를 호출합니다.
- **디자인 토큰 추가 안 함.** 기존 토큰으로 충분해서 `AppColors`/`AppDimens`에 새 필드를 추가하지 않았습니다.
- **관심 목록 로컬 저장 — `shared_preferences`.** 심볼 집합을 `FavoritesStorage`로 감싸서 `FavoritesController`가 등록/해제할 때마다 저장하고, 앱 시작 시(`main.dart`) 저장된 값이 있으면 그걸로, 없으면(첫 실행) 기존 시드 종목으로 초기화합니다.
- **초기 관심종목 시드.** 로컬에 저장된 관심 목록이 아직 없을 때(첫 실행)만 빈 화면 대신 삼성전자(`005930`) · SK하이닉스(`000660`) · NAVER(`035420`)를 기본 관심종목으로 심어둡니다 (`main.dart`). 이후에는 저장된 사용자 목록을 그대로 씁니다.

## 직접 판단한 부분과 이유

- **토스트 노출 시간/사라지는 방식**: Figma에 정의가 없어 2초 노출 후 자동으로 사라지는 `SnackBar`(`floating`, 토큰 색상 적용)로 구현했습니다.
- **로딩 상태**: 관심 화면의 시세 미수신 행, 상세 화면의 현재가·등락과 요약 카드는 `feedbackSkeleton` 톤의 펄스 애니메이션 스켈레톤(`core/widgets/skeleton_bar.dart`로 공용화)으로, 차트 영역만 스피너로 표시했습니다.
- **네트워크 에러**: 관심/상세 화면 상단에 `priceDownBg`/`priceDownText` 톤의 배너로 노출하고, 새로고침(관심은 버튼+Pull to refresh, 상세는 Pull to refresh)으로 재시도할 수 있게 했습니다. 검색은 결과 영역에 동일한 방식으로 처리합니다.
- **긴 종목명 오버플로**: 모든 이름 텍스트에 `maxLines: 1` + `TextOverflow.ellipsis`를 적용했습니다.
- **시세를 못 받은 행의 정렬**: `현재가순`/`등락률순`에서 스켈레톤 행(시세 없음)은 항상 맨 아래로 보냅니다. 어느 쪽에도 정답이 없어 "아직 비교할 값이 없다"는 쪽으로 판단했습니다.
- **검색 결과가 항상 favorite 상태와 함께 옴**: `SearchResultRow`가 `FavoritesController`를 직접 구독해서 검색 직후에도 최신 관심 상태가 별 아이콘에 반영됩니다.
- **Figma와 다르게 구현한 부분**: 정확한 여백/폰트 크기 수치는 Figma 파일을 직접 열어 확인하는 대신 `lib/theme/README.md`의 토큰 대응표와 과제 문서의 서술(예: 등락 색상, 토스트 구성 요소)을 기준으로 구현했습니다. 픽셀 단위로 어긋난 부분이 있을 수 있습니다.
- **관심 화면 행 탭 시 상세 이동**: 문서에는 검색 화면에서만 명시돼 있지만, 관심 화면 행도 상세로 이동하도록 만들었습니다. 관심종목을 눌러도 상세를 볼 수 있는 편이 자연스러운 흐름이라고 판단했습니다.

## 막혔던 지점과 어떻게 접근했는지

- **EUC-KR 디코딩 패키지 선택 실수**: 처음 추가한 `euc` 패키지가 실제로는 EUC-**JP**(일본어) 전용이라 한글 표에서 문자가 깨졌습니다. `flutter test`로 실제 HTML 샘플을 파싱하는 테스트를 먼저 작성해뒀던 덕분에 바로 발견했고, `cp949_codec` 패키지(EUC-KR을 포함하는 CP949 지원)로 교체해 해결했습니다.
- **이 작업 환경에 Flutter SDK / Android SDK / Visual Studio(Windows 데스크톱 빌드용 C++ 워크로드)가 전혀 없었습니다.** Flutter SDK와 Visual Studio C++ 워크로드는 새로 설치해 Windows 데스크톱으로 실제 앱을 띄워 확인했습니다. Android SDK까지 설치하는 건 시간 대비 효율이 낮다고 판단해 생략했습니다. 실제 창에서 타이밍을 맞추기 번거로운 상태(바텀시트 애니메이션, 토스트 등장/퇴장 등)는 `flutter test`가 플랫폼 툴체인 없이 Dart VM에서 바로 실행된다는 점을 이용해 `RenderRepaintBoundary.toImage()`로 화면을 PNG로 저장하는 임시 스크립트를 보조로 써서 검증했습니다. 최종 제출 전 안드로이드 실기기/에뮬레이터에서 한 번 더 확인하는 것을 권장합니다.
- **와일드카드 응답 필드명 불일치**: 실시간 시세 응답이 `cv`(등락액), `cr`(등락률) 필드를 이미 제공하지만, 문서가 요구하는 대로 `nv - pcv`, `(nv - pcv) / pcv`를 직접 계산하도록 구현했습니다. Naver가 내부적으로 반올림/부호 처리를 다르게 할 수 있어 직접 계산 쪽이 더 명확했습니다.

---

## 과제 2 — Lucy Studio `목표가 알림`

Lucy Studio는 GUI 전용 데스크톱 툴이라 이 대화에서 직접 조작할 수 없었습니다. 별도로 `docs.edencrew.com` 문서를 바탕으로 위젯 구성과 스크립트(`$form`, `setProperty`/`getProperty`) 가이드를 정리해 전달드렸습니다. 페이지 이름은 `targetAlert`로 만들고, 완료 후 `cloneProject/assets`를 압축해 제출해 주세요.
