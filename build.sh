#!/bin/bash
# Сборка LiveWall.app (нужны только Command Line Tools; SwiftPM не используется)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
FILES=()
while IFS= read -r f; do FILES+=("$f"); done < <(find Sources -name '*.swift')
# В SDK macOS 27 SwiftUI-свойство @State стало макросом, а его плагин SwiftUIMacros
# есть только в Xcode. С одними Command Line Tools берём самый новый SDK до 27.
if [ -z "${SDKROOT:-}" ] && [ "$(xcode-select -p 2>/dev/null)" = "/Library/Developer/CommandLineTools" ]; then
  SDK_MAJOR=$(xcrun --show-sdk-version 2>/dev/null | cut -d. -f1)
  if [ "${SDK_MAJOR:-0}" -ge 27 ]; then
    FALLBACK_SDK=$(ls -d /Library/Developer/CommandLineTools/SDKs/MacOSX*.sdk 2>/dev/null \
      | sed -nE 's#^(.*/MacOSX([0-9]+)(\.[0-9]+)*\.sdk)$#\2 \1#p' | awk '$1 < 27' | sort -n -k1,1 | tail -1 | cut -d' ' -f2)
    if [ -n "$FALLBACK_SDK" ]; then
      export SDKROOT="$FALLBACK_SDK"
      echo "Command Line Tools без плагина SwiftUIMacros — сборка на SDK: ${SDKROOT}"
    else
      echo "Нужен Xcode или SDK macOS 26 в Command Line Tools: SDK ${SDK_MAJOR} без Xcode не собирает @State" >&2
    fi
  fi
fi
echo "Компиляция ${#FILES[@]} файлов…"
swiftc -swift-version 5 -target arm64-apple-macosx14.0 -O -parse-as-library \
  -module-name LiveWall "${FILES[@]}" -o build/LiveWall
APP="build/LiveWall.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp build/LiveWall "$APP/Contents/MacOS/LiveWall"
cp Info.plist "$APP/Contents/Info.plist"
if [ -f AppIcon.icns ]; then cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"; fi
# Постоянная подпись: macOS запоминает разрешения (звук, календарь) по сертификату,
# а не по отпечатку сборки — они не сбрасываются после пересборки и обновлений.
IDENTITY="${LIVEWALL_SIGN_IDENTITY:-LiveWall Code Signing}"
if security find-identity -p codesigning 2>/dev/null | grep -q "$IDENTITY"; then
  codesign --force --deep --sign "$IDENTITY" "$APP" >/dev/null 2>&1 && echo "Подписано: $IDENTITY"
else
  echo "Сертификат «${IDENTITY}» не найден — подпись ad-hoc (разрешения macOS будут сбрасываться при пересборке)"
  codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true
fi
echo "Готово: $(pwd)/$APP"
