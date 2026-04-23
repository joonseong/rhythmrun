# RhythmRun — 백엔드 개발자 하네스

> 이 디렉토리는 Core 레이어(비즈니스 로직, 서비스, 모델) 작업용입니다.
> Claude는 백엔드 개발자 관점에서 알고리즘 구현, 서비스 설계, 데이터 저장을 도와줍니다.

---

## 내 역할 컨텍스트

- View와 무관한 순수 비즈니스 로직을 구현한다
- 모든 Service는 Protocol로 추상화해 테스트 가능하게 만든다
- 알고리즘(BPM, 거리, 칼로리)의 정확성과 엣지케이스를 책임진다

---

## Core 레이어 구조

```
Core/
├── Models/
│   ├── Session.swift          # RunSession, BPMSample, Grade
│   └── UserProfile.swift      # 사용자 프로필 + 기본값
├── Services/
│   ├── BPMEngine.swift        # 실시간 BPM 계산 (핵심 알고리즘)
│   ├── MotionService.swift    # CMMotionManager 래핑
│   ├── AudioService.swift     # AVAudioEngine 리듬 피드백
│   └── SessionStore.swift     # 로컬 스토리지 (TODO)
└── Utils/
    ├── DistanceCalculator.swift   # 보폭 기반 거리 계산
    └── CalorieCalculator.swift    # MET 공식 칼로리 계산
```

---

## 핵심 알고리즘

### BPM 계산 (BPMEngine)

```swift
// 10초 슬라이딩 윈도우
// 유효 범위: 60~200 BPM (범위 밖 = 노이즈, 이전 값 유지)
BPM = (window_step_count / 10.0) * 60
```

**구현 규칙:**
- 유효 범위 밖의 raw BPM은 `currentBPM`을 변경하지 않음 (노이즈 폐기)
- 윈도우 슬라이딩: 현재 시각 기준 -10초 이전 타임스탬프 제거
- 피크 감지: Z축 가속도 임계값(0.3g) + 최소 보폭 간격(0.25초) cooldown

### 거리 계산 (DistanceCalculator)

| 구분 | 계수 | 경계값 |
|------|------|--------|
| 걷기 | `신장(cm) × 0.413` | BPM ≤ 140 |
| 러닝 | `신장(cm) × 0.46` | BPM ≥ 141 |

```swift
// 경계값 140은 걷기(낮은 쪽)에 포함
// 신장 미입력 시 기본값 170cm 적용
let distance = steps * strideLength / 100  // cm → m
```

### 칼로리 계산 (CalorieCalculator)

```swift
// MET 공식: kcal = MET × 체중(kg) × 시간(h)
// BPM ≤ 140 → MET 3.5
// 141 ≤ BPM ≤ 160 → MET 7.0
// BPM ≥ 161 → MET 9.8
// 체중 미입력 시 기본값 65kg 적용
// 결과 표기: "약 OOO kcal (추정값)" — 필수
```

### 리듬 등급 (RunSession.Grade)

```swift
// 경계값은 해당 등급 하한에 포함 (inclusive lower bound)
// 90% → S, 75% → A, 60% → B
static func from(accuracy: Double) -> Grade {
    switch accuracy {
    case 0.90...: return .s  // ≥ 90%
    case 0.75...: return .a  // 75~89%
    case 0.60...: return .b  // 60~74%
    default:      return .c  // < 60%
    }
}
```

---

## 도메인 모델

### RunSession

```swift
struct RunSession: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let difficulty: Difficulty     // walk / run / sprint
    let durationSeconds: Int
    let totalScore: Int
    let maxCombo: Int
    let grade: Grade               // S / A / B / C
    let avgBPM: Int
    let bpmTimeline: [BPMSample]   // 10초 샘플링
}
```

### UserProfile

```swift
struct UserProfile: Codable {
    var nickname: String
    var heightCM: Double           // 기본값: 170cm
    var weightKG: Double           // 기본값: 65kg
    var goalBPM: Int
    var strideCM: Double?          // nil이면 신장 × 계수로 자동 계산
}
```

---

## Service Protocol 설계

모든 Service는 Protocol을 통해 추상화. ViewModel은 Protocol만 알고 구현체를 모름.

```swift
protocol BPMEngineProtocol {
    var currentBPM: Int { get }
    func recordStep(at timestamp: Date)
    func reset()
}

protocol MotionServiceProtocol {
    func startDetection(onStep: @escaping (Date) -> Void)
    func stopDetection()
}

protocol AudioServiceProtocol {
    func startBeat(bpm: Int)
    func stopBeat()
}

protocol SessionStoreProtocol {
    func save(_ session: RunSession) throws
    func fetchAll() throws -> [RunSession]
    func fetchRecent(limit: Int) throws -> [RunSession]
}
```

---

## SessionStore — 구현 TODO

로컬 스토리지: **SQLite** (GRDB.swift 권장) 또는 CoreData

```swift
// 저장 스펙
// - 최근 100개 세션 보존 (초과 시 오래된 것 삭제)
// - bpmTimeline: JSON 직렬화 후 TEXT 컬럼 저장
// - 비동기 저장: async/await 사용

// 테이블 스키마
// sessions (id TEXT PK, timestamp REAL, difficulty TEXT,
//           duration_sec INT, total_score INT, max_combo INT,
//           grade TEXT, avg_bpm INT, bpm_timeline TEXT)
```

---

## 주요 iOS API

| API | 파일 | 용도 |
|-----|------|------|
| `CMMotionManager` | MotionService.swift | 가속도계 50Hz 폴링 |
| `CMPedometer` | MotionService.swift | 보조 걸음 수 검증 |
| `AVAudioEngine` | AudioService.swift | 리듬 클릭 사운드 |
| `AVAudioSession` | AudioService.swift | 백그라운드 오디오 |
| `AuthenticationServices` | (별도) | Apple 로그인 |

### 백그라운드 실행 (중요)

러닝 중 앱이 백그라운드로 전환되어도 BPM 감지와 오디오 피드백이 유지되어야 함.

```
Info.plist:
  UIBackgroundModes: [audio, processing]
  NSMotionUsageDescription: "걸음 BPM 감지에 사용합니다"
  NSMicrophoneUsageDescription: "리듬 오디오 피드백에 사용합니다"
```

---

## 테스트 전략

**우선순위**: BPMEngine > 계산기 유틸 > SessionStore > MotionService

```swift
// 엣지케이스 필수 커버
// BPMEngine: 유효 범위 경계값(60, 200), 노이즈 폐기, 윈도우 슬라이딩
// DistanceCalculator: BPM 140/141 경계값 보폭 전환
// CalorieCalculator: BPM 구간 경계값(140, 141, 160, 161)
// Grade: 90%, 75%, 60% 정확히 해당 등급 하한에 속함
```

---

## 백엔드 작업 가이드

Claude에게 요청할 수 있는 것:
- "BPMEngine 알고리즘 엣지케이스 찾아줘"
- "SessionStore SQLite 스키마 설계해줘"
- "MotionService 백그라운드 실행 설정해줘"
- "AudioService AVAudioEngine으로 클릭 사운드 구현해줘"
- "CalorieCalculator 단위 테스트 추가해줘"

Claude가 하지 않을 것:
- 알고리즘 계수(0.413, 0.46, MET 값)를 임의로 변경
- BPM 유효 범위(60~200) 확장
- 등급 경계값(90/75/60) 수정
- View 레이어 코드를 Core에 추가
