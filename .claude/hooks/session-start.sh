#!/bin/bash
set -euo pipefail

# Claude Code on the web 환경에서만 실행
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "=== RhythmRun 개발 환경 초기화 ==="

# 1. 프로젝트 구조 검증
echo ""
echo "📁 프로젝트 구조 확인 중..."
REQUIRED_DIRS=(
  "RhythmRun/App"
  "RhythmRun/Core/Services"
  "RhythmRun/Core/Models"
  "RhythmRun/DesignSystem"
  "RhythmRunTests/Unit"
  ".github/workflows"
)
ALL_OK=true
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$CLAUDE_PROJECT_DIR/$dir" ]; then
    echo "  ✅ $dir"
  else
    echo "  ❌ $dir (없음)"
    ALL_OK=false
  fi
done

if [ "$ALL_OK" = false ]; then
  echo "⚠️  일부 디렉토리가 없습니다. 프로젝트 구조를 확인하세요."
fi

# 2. SwiftLint 설치 (Swift 런타임 없이는 실행 불가 — 설치만)
SWIFTLINT_VERSION="0.57.1"
INSTALL_DIR="$CLAUDE_PROJECT_DIR/.claude/bin"
SWIFTLINT_BIN="$INSTALL_DIR/swiftlint"

if [ -x "$SWIFTLINT_BIN" ] && "$SWIFTLINT_BIN" version 2>/dev/null | grep -q "$SWIFTLINT_VERSION"; then
  echo ""
  echo "✅ SwiftLint $SWIFTLINT_VERSION 설치 확인"
else
  echo ""
  echo "⬇️  SwiftLint $SWIFTLINT_VERSION 설치 중..."
  mkdir -p "$INSTALL_DIR"
  TMPZIP=$(mktemp /tmp/swiftlint_XXXXXX.zip)
  if curl -fsSL --max-time 60 \
    "https://github.com/realm/SwiftLint/releases/download/${SWIFTLINT_VERSION}/swiftlint_linux.zip" \
    -o "$TMPZIP" 2>/dev/null; then
    unzip -o "$TMPZIP" swiftlint -d "$INSTALL_DIR" > /dev/null 2>&1
    chmod +x "$SWIFTLINT_BIN"
    rm -f "$TMPZIP"
    echo "  ✅ SwiftLint 설치 완료"
  else
    echo "  ⚠️  SwiftLint 다운로드 실패 — CI(macOS)에서 lint가 실행됩니다"
  fi
fi

# PATH 등록
echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$CLAUDE_ENV_FILE"

# 3. 주요 정보 출력
echo ""
echo "ℹ️  참고 사항:"
echo "  - SwiftLint는 Swift 런타임이 필요해 웹 환경에서 직접 실행 불가"
echo "  - 린트/빌드/테스트는 GitHub Actions CI (macOS runner)에서 자동 실행"
echo "  - CI 트리거: main, develop, claude/**, feature/** 브랜치 push 및 PR"
echo ""
echo "=== 초기화 완료 ==="
