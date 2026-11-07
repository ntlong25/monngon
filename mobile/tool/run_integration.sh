#!/usr/bin/env bash
# Chạy integration test luồng chính trên emulator/thiết bị Android với API thật.
# Mỗi dòng "[it] ảnh: <tên>" test in ra → script chụp màn hình thiết bị (adb screencap) vào docs/dev/screens/<tên>.png.
# Dùng: tool/run_integration.sh [device-id] [api-url] [test-file]   (mặc định emulator-5554, http://10.0.2.2:5096, integration_test/main_flow_test.dart)
# Test in `[it] adb: wakefulness*` → script ghi trạng thái nguồn màn hình của thiết bị (`dumpsys power`) ra màn hình chạy (TC-3-10).
# Cần API đang chạy: dotnet run --project backend/MonNgon.Api --no-launch-profile --urls http://0.0.0.0:5096
# Cần `adb` trong PATH (hoặc đặt biến ADB).
set -uo pipefail
cd "$(dirname "$0")/.."
DEV=${1:-emulator-5554}
API=${2:-http://10.0.2.2:5096}
TEST=${3:-integration_test/main_flow_test.dart}
ADB=${ADB:-adb}
OUT=../docs/dev/screens
mkdir -p "$OUT"
status=$(mktemp)

# Emulator dev ít dung lượng: gỡ bản app còn lại từ lần chạy trước (bản debug ~130 MB) để cài lại không báo INSUFFICIENT_STORAGE.
"$ADB" -s "$DEV" uninstall vn.fitpro.fitpro_mamdu >/dev/null 2>&1 || true

# Emulator ít RAM hay đứng hình khi nhiều tiến trình nền: dọn tiến trình nền (không động tới app đang chạy) trước khi chạy.
"$ADB" -s "$DEV" shell am kill-all >/dev/null 2>&1 || true

flutter test "$TEST" -d "$DEV" --dart-define=API_BASE_URL="$API" 2>&1 |
  while IFS= read -r line; do
    case "$line" in
      *Choreographer*|*hiddenapi*|*HWUI*|*nativeloader*) ;;
      *) printf '%s\n' "$line" ;;
    esac
    if [[ "$line" =~ \[it\]\ ảnh:\ (it-[A-Za-z0-9_-]+) ]]; then
      "$ADB" -s "$DEV" exec-out screencap -p > "$OUT/${BASH_REMATCH[1]}.png"
    fi
    if [[ "$line" =~ \[it\]\ adb:\ (wakefulness[A-Za-z0-9_-]*) ]]; then
      echo "[adb] ${BASH_REMATCH[1]}: $("$ADB" -s "$DEV" shell dumpsys power 2>/dev/null | grep -E 'mWakefulness=|Display Power: state=' | tr -d '
' | tr '
' ' ')"
    fi
    if [[ "$line" == *"All tests passed"* ]]; then echo ok > "$status"; fi
  done

if [[ -s "$status" ]]; then rm -f "$status"; echo "KẾT QUẢ: XANH"; exit 0; fi
rm -f "$status"; echo "KẾT QUẢ: LỖI"; exit 1
