# RhythmRun — 디자이너 하네스

> 이 디렉토리는 디자인 시스템 및 UI 스펙 작업용입니다.
> Claude는 디자이너 관점에서 컴포넌트 설계, 색상/타이포 적용, 화면 스펙 작업을 도와줍니다.

---

## 내 역할 컨텍스트

- Shopify 다크 테마 영감의 디자인 시스템을 iOS에 맞게 적용한다
- 컴포넌트가 디자인 토큰을 일관되게 사용하도록 관리한다
- SwiftUI 구현 가능성을 고려해 스펙을 정의한다

---

## 디자인 원칙

- **다크 퍼스트**: 라이트 모드는 MVP OUT. 모든 화면은 어두운 배경 기준
- **NeonGreen은 희소하게**: 포커스·강조에만 소량 사용, 대면적 절대 금지
- **Full Pill 버튼**: Primary·Secondary 모두 `Capsule()` (radius 9999px)
- **다층 그림자**: 단층 shadow 금지, 1/2/4/8px 스택으로

---

## 색상 토큰

### 배경 계층 (어두운 순)

| 토큰 | Hex | iOS 변수명 | 용도 |
|------|-----|-----------|------|
| Void | `#000000` | `Color.rrVoid` | 루트 배경 |
| DeepTeal | `#02090A` | `Color.rrDeepTeal` | 카드 표면 |
| DarkForest | `#061A1C` | `Color.rrDarkForest` | 섹션 배경, 인풋 배경 |
| Forest | `#102620` | `Color.rrForest` | 상승 표면 |

### 텍스트

| 토큰 | Hex | iOS 변수명 | 용도 |
|------|-----|-----------|------|
| White | `#FFFFFF` | `Color.rrWhite` | 기본 텍스트 |
| MutedText | `#A1A1AA` | `Color.rrMuted` | 보조 텍스트, 메타 정보 |
| Shade50 | `#71717A` | `Color.rrShade50` | 비활성 텍스트 |

### 액센트 & 보더

| 토큰 | Hex | iOS 변수명 | 용도 |
|------|-----|-----------|------|
| NeonGreen | `#36F4A4` | `Color.rrNeonGreen` | 포커스 링, 핵심 강조 |
| DarkCardBorder | `#1E2C31` | `Color.rrCardBorder` | 카드 보더 |

---

## 타이포그래피

> iOS 시스템 폰트(SF Pro) 사용. NeueHaasGrotesk는 웹 전용.
> SF Pro의 `.thin` weight으로 Shopify의 "극도로 가벼운" 디자인 정신 유지.

| 역할 | 크기 | Weight | iOS 코드 |
|------|------|--------|---------|
| Display | 34pt | Thin | `Font.rrDisplay` |
| Title | 24pt | Semibold | `Font.rrTitle` |
| Body | 17pt | Regular | `Font.rrBody` |
| Caption | 13pt | Regular | `Font.rrCaption` |
| Label | 12pt | Regular | `Font.rrLabel` |

---

## 컴포넌트 스펙

### 버튼

**Primary Button**
```
배경: White (#FFFFFF)
텍스트: Void (#000000)
Shape: Capsule() — full pill
패딩: vertical 14pt, horizontal max
포커스: NeonGreen 2px ring
```

**Secondary Button**
```
배경: 투명
텍스트: White (#FFFFFF)
보더: White 2px, Capsule()
패딩: vertical 14pt, horizontal max
```

### 카드

```
배경: DeepTeal (#02090A)
보더: DarkCardBorder (#1E2C31) 1px
cornerRadius: 12
그림자 (다층):
  - rgba(0,0,0,0.1) 0px 0px 0px 1px
  - rgba(0,0,0,0.1) 0px 2px 2px
  - rgba(0,0,0,0.1) 0px 4px 4px
  - rgba(0,0,0,0.1) 0px 8px 8px
  + inset rgba(255,255,255,0.03) 0px 1px 0px
```

### 인풋 필드

```
배경: DarkForest (#061A1C)
텍스트: White (#FFFFFF)
Placeholder: Shade50 (#71717A)
보더 기본: DarkCardBorder (#1E2C31) 1px
보더 포커스: NeonGreen (#36F4A4) 2px
cornerRadius: 8
패딩: 14pt
```

---

## 스페이싱 시스템

기본 단위: **8pt**

| 토큰 | 값 | 용도 |
|------|-----|------|
| xs | 4pt | 아이콘 내부 간격 |
| sm | 8pt | 기본 단위 |
| md | 16pt | 표준 패딩 |
| lg | 24pt | 카드 내부 |
| xl | 32pt | 섹션 구분 |
| 2xl | 48pt | 화면 상단 여백 |

---

## 화면별 주요 컴포넌트

| 화면 | 핵심 컴포넌트 |
|------|-------------|
| 홈 | 리듬 점수 프로그레스 바, 기록 카드, Primary CTA |
| 러닝 준비 | BPM 슬라이더, 모드 토글(세그먼트), 거리 선택 칩 |
| 리듬 러닝 세션 | BPM 디스플레이(NeonGreen), 파형 애니메이션, 콤보 카운터 |
| 결과 | 등급 배지, BPM 라인 차트, 공유 카드 |

---

## Do / Don't

### Do ✅
- 배경 계층은 항상 Void → DeepTeal → DarkForest → Forest 순서 사용
- NeonGreen은 BPM 숫자, 포커스 상태, 등급 강조에만
- 모든 인터랙티브 요소에 rounded corners (최소 8pt)
- 버튼은 반드시 Capsule (9999px)

### Don't ❌
- 밝은 배경 사용 금지 (MVP에서 라이트 모드 없음)
- NeonGreen을 배경·대면적에 사용 금지
- 단층 shadow 사용 금지
- SF Pro 이외 폰트 임의 추가 금지

---

## 디자인 작업 가이드

Claude에게 요청할 수 있는 것:
- "이 화면의 SwiftUI 레이아웃 스펙 작성해줘"
- "디자인 토큰 기준으로 컴포넌트 코드 리뷰해줘"
- "새 컴포넌트가 디자인시스템과 일치하는지 확인해줘"
- "BPM 파형 애니메이션 구현 방법 알려줘"
- "결과 공유 이미지 카드 레이아웃 잡아줘"
