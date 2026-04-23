# RhythmRun — 프론트엔드(iOS) 개발자 하네스

> 이 디렉토리는 SwiftUI Features 모듈 작업용입니다.
> Claude는 iOS 개발자 관점에서 화면 구현, ViewModel 설계, 디자인 시스템 적용을 도와줍니다.

---

## 내 역할 컨텍스트

- SwiftUI + MVVM으로 7개 화면을 구현한다
- 디자인 토큰(`DesignSystem/`)을 정확하게 적용한다
- Core 레이어(Service/Model)를 ViewModel에서 주입받아 사용한다

---

## 아키텍처 패턴

```
View (SwiftUI)
  └─ @StateObject ViewModel: ObservableObject
       └─ Service (Protocol 주입)
            └─ Model (순수 데이터)
```

### 규칙

- View는 비즈니스 로직 없음. 오직 `@Published` 바인딩만
- ViewModel은 Service를 `Protocol`로 받음 → 테스트 시 Mock 주입
- Service는 View를 절대 참조하지 않음
- `@StateObject` vs `@ObservedObject`: 소유 여부로 구분

---

## 모듈 구조

```
Features/
├── Auth/
│   └── AuthView.swift               # 로그인/회원가입
├── Home/
│   ├── HomeView.swift               # 홈 화면
│   └── HomeViewModel.swift
├── Onboarding/
│   └── OnboardingView.swift         # 신체정보 + 권한요청
├── PreRun/
│   ├── PreRunView.swift             # 러닝 준비
│   └── PreRunViewModel.swift
├── LiveSession/
│   ├── LiveSessionView.swift        # 리듬 러닝 세션 (핵심)
│   └── LiveSessionViewModel.swift
├── Results/
│   └── ResultsView.swift            # 결과 화면
└── Profile/
    ├── ProfileView.swift            # 프로필/목표설정
    └── ProfileViewModel.swift
```

---

## 디자인 시스템 사용법

```swift
// 색상 — Color extension 사용
.background(Color.rrVoid)          // 루트 배경
.foregroundColor(.rrNeonGreen)     // BPM 숫자
.foregroundColor(.rrMuted)         // 보조 텍스트

// 타이포그래피
.font(.rrDisplay)   // 34pt thin — BPM 큰 숫자
.font(.rrTitle)     // 24pt semibold — 섹션 제목
.font(.rrBody)      // 17pt regular — 본문
.font(.rrCaption)   // 13pt — 메타정보

// 공통 버튼
RRPrimaryButton(title: "🏃 출발!") { vm.start() }
RRSecondaryButton(title: "✕ 종료") { vm.end() }

// 카드 컨테이너
.background(Color.rrDeepTeal)
.cornerRadius(12)
.overlay(RoundedRectangle(cornerRadius: 12)
    .stroke(Color.rrCardBorder, lineWidth: 1))
```

---

## 화면별 구현 포인트

### LiveSessionView (최우선)

- `LiveSessionViewModel`이 `MotionServiceProtocol`, `AudioServiceProtocol`, `BPMEngineProtocol`을 주입받아 사용
- BPM 수치는 `Color.rrNeonGreen`으로 크게 표시 (`Font.rrDisplay`)
- 파형 애니메이션: `TimelineView` + `Canvas` 또는 커스텀 Shape
- 콤보 증가 시 햅틱 피드백 (`UIImpactFeedbackGenerator`)
- 세션 종료 시 `ResultsView`로 데이터 전달

### HomeView

- `NavigationStack` 루트
- 최근 세션 카드: `LazyVStack` + `ForEach`
- 주간 리듬 점수: `ProgressView` 커스텀 스타일

### PreRunView

- BPM 슬라이더: `Slider` + 커스텀 스타일 (NeonGreen 썸)
- 거리 선택: `HStack` 칩 버튼 (3km / 5km / 10km / 직접입력)
- 모드 토글: `Picker(.segmented)` 또는 커스텀 토글

---

## 화면 네비게이션

```swift
// AppCoordinator에서 관리
// NavigationStack + navigationDestination 사용
// 시트/풀스크린은 .sheet / .fullScreenCover

NavigationLink(destination: PreRunView()) { ... }
.navigationDestination(isPresented: $vm.navigateToSession) {
    LiveSessionView(config: vm.sessionConfig)
}
```

---

## 권한 처리

| 권한 | 요청 시점 | 거부 시 |
|------|----------|--------|
| Motion | 온보딩 화면 | 제한 모드 안내 + 재요청 1회 → 시스템 설정 유도 |
| Microphone | 온보딩 화면 | 제한 모드 안내 + 재요청 1회 → 시스템 설정 유도 |

```swift
// 권한 재요청 패턴
// 1회 거부: AVAudioSession.sharedInstance().requestRecordPermission { ... }
// 이후: UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
```

---

## 테스트 패턴

```swift
// Protocol Mock 주입
final class MockMotionService: MotionServiceProtocol {
    var onStepCalled = false
    func startDetection(onStep: @escaping (Date) -> Void) { onStepCalled = true }
    func stopDetection() {}
}

// ViewModel 테스트
let vm = LiveSessionViewModel(
    config: .init(),
    motionService: MockMotionService(),
    audioService: MockAudioService(),
    bpmEngine: MockBPMEngine()
)
```

---

## 프론트엔드 작업 가이드

Claude에게 요청할 수 있는 것:
- "LiveSessionView의 BPM 파형 애니메이션 구현해줘"
- "이 View가 MVVM 패턴을 올바르게 따르는지 검토해줘"
- "디자인 토큰 적용이 맞는지 확인해줘"
- "PreRunView BPM 슬라이더 커스텀 스타일 만들어줘"
- "Mock 주입으로 LiveSessionViewModel 테스트 작성해줘"

Claude가 하지 않을 것:
- View에 비즈니스 로직 추가
- 디자인 토큰 무시하고 하드코딩된 색상 사용
- MVP OUT 화면 임의 추가
