#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/taglib"
OUT="$ROOT/build-xcframework"
INSTALL="$OUT/install"
XCFRAMEWORK="$ROOT/TagLib.xcframework"

ARCHS=("arm64" "x86_64")
DEPLOY_TARGET="${DEPLOY_TARGET:-12.0}"

echo "Building TagLib xcframework into $XCFRAMEWORK"
rm -rf "$OUT"
mkdir -p "$OUT"

for ARCH in "${ARCHS[@]}"; do
  BUILD_DIR="$OUT/$ARCH"
  PREFIX="$INSTALL/$ARCH"
  echo "==> Configuring for $ARCH"
  cmake -S "$SRC" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOY_TARGET" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_BINDINGS=OFF \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

  echo "==> Building & installing for $ARCH"
  cmake --build "$BUILD_DIR" --config Release --target install
done

LIB_ARGS=()
UNIVERSAL="$OUT/universal"
UNIVERSAL_LIB="$UNIVERSAL/libtag.a"
UNIVERSAL_HEADERS="$INSTALL/arm64/include"
mkdir -p "$UNIVERSAL"

echo "==> Creating universal lib"
lipo -create \
  "$INSTALL/arm64/lib/libtag.a" \
  "$INSTALL/x86_64/lib/libtag.a" \
  -output "$UNIVERSAL_LIB"

echo "==> Creating xcframework"
rm -rf "$XCFRAMEWORK"
xcodebuild -create-xcframework \
  -library "$UNIVERSAL_LIB" \
  -headers "$UNIVERSAL_HEADERS" \
  -output "$XCFRAMEWORK"

echo "Done: $XCFRAMEWORK"
