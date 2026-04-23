# RhythmRun — CLAUDE.md

## 역할별 하네스 (Role-specific Harnesses)

작업하는 역할에 따라 해당 디렉토리에서 Claude를 시작하면 맞춤 컨텍스트가 자동으로 로드됩니다.

| 역할 | 디렉토리 | 특화 내용 |
|------|----------|----------|
| 기획자 | `docs/planning/` | 제품 비전, MVP 범위, 성공 지표, 마일스톤 |
| 디자이너 | `docs/design/` | 색상 토큰, 타이포그래피, 컴포넌트 스펙, Do/Don't |
| iOS 개발자 | `RhythmRun/Features/` | SwiftUI MVVM, 화면 구현, 디자인 토큰 적용 |
| 백엔드 개발자 | `RhythmRun/Core/` | 알고리즘, Service Protocol, 스토리지, 테스트 |

> Claude Code는 현재 디렉토리와 상위 디렉토리의 CLAUDE.md를 모두 읽습니다.
> 역할 디렉토리에서 시작하면 루트 컨텍스트 + 역할 컨텍스트가 합쳐집니다.

---

## 프로젝트 개요

**"달릴 때마다 게임이 된다"** — 러너의 발걸음이 곧 리듬이고, 리듬이 곧 게임플레이.

걸음 BPM을 실시간으로 감지해 오디오 리듬 피드백을 제공하는 iOS 러닝 앱. 리듬게임 요소(콤보, 점수, 등급)를 러닝에 결합해 재방문율 40% 이상을 목표로 한다.

| 항목 | 내용 |
|------|------|
| 플랫폼 | iOS (SwiftUI) |
| 타겟 | 20-35세, 러닝에 재미·동기부여가 필요한 러너 |
| 핵심 차별점 | 가속도계 기반 걸음 BPM → 실시간 오디오 리듬 피드백 |
| MVP 목표 | 재방문율 40% 이상 (첫 세션 완료 후 7일 이내 2회 이상 세션 완료) |

---

## 아키텍처

### 패턴: MVVM + Clean Architecture

```
RhythmRun/
├── App/
│   ├── RhythmRunApp.swift          # @main, 앱 진입점
│   └── AppCoordinator.swift        # 화면 라우팅
│
├── Features/                       # 기능별 모듈 (View + ViewModel)
│   ├── Onboarding/
│   ├── Auth/                       # 로그인 / 회원가입
│   ├── Home/
│   ├── PreRun/                     # 러닝 준비
│   ├── LiveSession/                # 리듬 러닝 세션 (핵심)
│   ├── Results/
│   └── Profile/
│
├── Core/                           # 플랫폼 독립 비즈니스 로직
│   ├── Models/                     # 도메인 모델 (Session, BPMSample 등)
│   ├── Services/
│   │   ├── MotionService.swift     # CMMotionManager 래핑 (걸음 감지)
│   │   ├── AudioService.swift      # AVAudioEngine 리듬 피드백
│   │   ├── BPMEngine.swift         # 실시간 BPM 계산
│   │   └── SessionStore.swift      # SQLite 로컬 저장
│   └── Utils/
│       ├── DistanceCalculator.swift
│       └── CalorieCalculator.swift
│
└── DesignSystem/                   # 디자인 토큰 + 공통 컴포넌트
    ├── Colors.swift
    ├── Typography.swift
    └── Components/
```

### 의존성 방향

```
View → ViewModel → Service/Repository → Model
```

ViewModel은 Service를 직접 호출. Service는 Model만 알고 View를 모른다.

---

## 핵심 알고리즘

### BPM 계산

가속도계 Z축 피크 감지 → 보간 + 이동 평균으로 안정화.

```swift
// 10초 슬라이딩 윈도우, 이상치 제거 후 평균
BPM = (step_count_in_window / window_seconds) * 60
```

유효 범위: 60~200 BPM. 범위 밖은 노이즈로 폐기.

### 보폭 계산

| 구분 | 계수 | 적용 BPM |
|------|------|----------|
| 걷기 | 신장(cm) × 0.413 | ≤ 140 BPM |
| 러닝 | 신장(cm) × 0.46 | ≥ 141 BPM |

신장 미입력 시 기본값: **170cm**

### 칼로리 계산 (MET 공식)

```
kcal = MET × 체중(kg) × 운동시간(h)
```

| BPM 구간 | MET |
|----------|-----|
| ≤ 140 | 3.5 |
| 141~160 | 7.0 |
| ≥ 161 | 9.8 |

체중 미입력 시 기본값: **65kg**. 결과 화면에 "약 OOO kcal (추정값)" 표기 필수.

### 리듬 등급

| 등급 | 비트 정확도 | 경계값 포함 원칙 |
|------|------------|----------------|
| S | ≥ 90% | 90% → S |
| A | 75~89% | 75% → A |
| B | 60~74% | 60% → B |
| C | < 60% | |

---

## 7개 화면 구조

```
[스플래시]
    │
    ├─ 최초 → [온보딩] → [로그인/회원가입] → [홈]
    └─ 재방문 (토큰 유효) → [홈]
              (토큰 만료) → [로그인]

[홈] ←──────────────────────────── [결과]
  │                                    ▲
  ├── [프로필/목표설정]                 │
  └── [러닝 준비] ──────────────► [리듬 러닝 세션]
```

| 화면 | 핵심 역할 |
|------|----------|
| 홈 | 최근 기록, 주간 리듬 점수, CTA |
| 러닝 준비 | 세션별 BPM·거리·모드 설정 |
| 리듬 러닝 세션 | BPM 실시간 표시, 파형, 콤보, 스코어 |
| 결과 | 등급, 요약, BPM 그래프, 공유 |
| 프로필 | 닉네임, 신장, 체중, 목표 BPM, 보폭 |
| 온보딩 | 신체정보 입력 + 권한 요청 |
| 로그인/회원가입 | 이메일 / Google / Apple 로그인 |

---

## MVP IN / OUT

### MVP IN (Priority 1)
- 가속도계 기반 걸음 감지 + 실시간 BPM 계산
- BPM 연동 오디오 리듬 피드백 (비트가이드 / 자유런)
- 기본 트래킹: 시간, 거리, 페이스
- 결과 화면: 리듬 점수, 등급, BPM 그래프
- 소셜 공유: OS 기본 Share Sheet (이미지 카드)
- 사용자 계정: 이메일 + Google + Apple 로그인

### MVP OUT (V2 이후)
- GPS 트래킹, 코스 추천
- 친구 팔로우 / 소셜 피드
- 챌린지 시스템
- 음악 커스터마이징
- 심박수 연동 칼로리

---

## 로컬 스토리지

SQLite (또는 동등 수준). 최근 100개 세션 보존.

```
Session {
  id, timestamp, difficulty, duration_sec,
  total_score, max_combo, grade,
  avg_bpm, bpm_timeline (JSON, 10초 샘플링)
}
```

---

## 권한

| 권한 | 필요 이유 | 거부 처리 |
|------|----------|----------|
| Motion (CMMotion) | 걸음 감지 (필수) | 제한 모드 안내 후 재요청 |
| Microphone | 오디오 피드백 (필수) | 제한 모드 안내 후 재요청 |

iOS: 거부 후 앱 내 재요청 1회 → 이후 시스템 설정 유도.

---

## 디자인 시스템

Shopify 다크 테마 영감. **다크 퍼스트**.

### 색상

```swift
// 배경 계층
Color("Void")       // #000000 — 루트 배경
Color("DeepTeal")   // #02090A — 카드 표면
Color("DarkForest") // #061A1C — 섹션 배경
Color("Forest")     // #102620 — 상승 표면

// 텍스트
Color("White")      // #FFFFFF — 기본 텍스트
Color("MutedText")  // #A1A1AA — 보조 텍스트

// 액센트
Color("NeonGreen")  // #36F4A4 — 포커스 링, 핵심 강조 (소량만 사용)

// 보더
Color("DarkCardBorder") // #1E2C31
```

### 타이포그래피 (iOS 대응)

| 역할 | 크기 | 폰트 | 비고 |
|------|------|------|------|
| 디스플레이 | 34pt | SF Pro / 커스텀 light | 홈 헤드라인 |
| 제목 | 24pt | SF Pro Semibold | 섹션 타이틀 |
| 본문 | 17pt | SF Pro Regular | 기본 텍스트 |
| 캡션 | 13pt | SF Pro Regular | 메타 정보 |

> NeueHaasGrotesk는 iOS 시스템 폰트가 아님. SF Pro Display를 사용하되, 디자인 정신(극도로 가벼운 weight)을 유지.

### 버튼

- Primary: 흰 배경, 검정 텍스트, `Capsule()` (full pill)
- Secondary: 투명 배경, 흰 보더, `Capsule()`
- Focus ring: NeonGreen (#36F4A4) 2px

### 컴포넌트 원칙
- 카드: DeepTeal 배경, 1px DarkCardBorder, `cornerRadius(12)`
- 인풋: DarkForest 배경, NeonGreen 포커스 보더
- 그림자: 다층 (0.1 alpha, 1/2/4/8px 스택)

---

## 개발 워크플로

### 브랜치 전략

```
main          — 배포 기준
develop       — 통합 브랜치
feature/*     — 기능 개발
claude/*      — AI 작업 브랜치
```

### 커밋 컨벤션

```
feat: 새 기능
fix: 버그 수정
refactor: 리팩토링
test: 테스트
chore: 빌드/설정
```

### CI (GitHub Actions)

- 트리거: `main`, `develop`, `claude/**`, PR
- macOS runner에서 빌드 + 단위 테스트 + SwiftLint
- 시뮬레이터: iPhone 16

---

## 테스트 전략

| 레이어 | 도구 | 대상 |
|--------|------|------|
| Unit | XCTest | BPMEngine, 거리/칼로리 계산, 등급 로직 |
| Integration | XCTest | SessionStore (SQLite 읽기/쓰기) |
| UI | XCUITest | 핵심 플로우 (홈 → 세션 → 결과) |

**우선순위**: BPMEngine 단위 테스트 > 계산기 단위 테스트 > UI 테스트.

mock은 Protocol + 구현체 분리로. `MotionServiceProtocol`, `AudioServiceProtocol` 등.

---

## 마일스톤

| 주차 | 목표 |
|------|------|
| 1 | 하네스 셋업, 아키텍처 스캐폴딩, 기술 검토 |
| 2-3 | 핵심: BPMEngine, MotionService, AudioService |
| 3-4 | 7개 화면 UI 구현 |
| 4-5 | QA, 엣지케이스, 성능 최적화 |
| 6 | TestFlight 베타 배포 |

---

## 주요 iOS API

| API | 용도 |
|-----|------|
| `CMMotionManager` | 가속도계 걸음 감지 |
| `CMPedometer` | 보조 걸음 수 검증 |
| `AVAudioEngine` | 리듬 오디오 피드백 |
| `UIActivityViewController` | SNS 공유 Share Sheet |
| `SQLite` / CoreData / GRDB | 세션 로컬 저장 |
| `AuthenticationServices` | Apple 로그인 |

---

## 주의사항

- **BPM 범위**: 60~200 BPM만 유효. 범위 밖은 노이즈로 처리.
- **보폭 계수**: BPM 140/141 경계에서 switchover. 경계값은 낮은 쪽(≤140 = 걷기) 포함.
- **등급 경계값**: 90%, 75%, 60% 모두 해당 등급 하한에 포함 (inclusive lower bound).
- **칼로리**: 반드시 "(추정값)" 표기.
- **신장/체중 미입력**: 기본값 자동 적용 후 프로필에서 수정 유도.
- **권한 재요청**: iOS는 거부 후 1회만 앱 내 재요청 가능, 이후 시스템 설정 유도.
