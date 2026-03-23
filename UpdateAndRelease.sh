#!/bin/bash
#
# UpdateAndRelease.sh — Automated Kernel Builder
# Nothing Phone (1) Spacewar — KernelSU-Next + SUSFS
#
# Uses ONLY official upstream sources:
#   Kernel:      NothingOSS/android_kernel_msm-5.4_nothing_sm7325 (sm7325/v/mr)
#   KernelSU:    KernelSU-Next/KernelSU-Next (legacy_susfs branch — has native 5.4 support)
#   SUSFS:       simonpunk/susfs4ksu (gki-android12-5.10)
#   Boot images: spike0en/nothing_archive
#
# Layout:
#   <this-repo>/
#     UpdateAndRelease.sh
#     android_kernel_msm-5.4_nothing_sm7325/   ← cloned on first run
#       KernelSU-Next/                          ← cloned on first run
#       drivers/kernelsu → ../KernelSU-Next/kernel
#     tc/                                       ← toolchains (auto-downloaded)
#     output/                                   ← build artifacts
#

set -euo pipefail

# ╔══════════════════════════════════════════════════════╗
# ║                   CONFIGURATION                      ║
# ╚══════════════════════════════════════════════════════╝
KERNEL_REPO="https://github.com/NothingOSS/android_kernel_msm-5.4_nothing_sm7325.git"
KERNEL_BRANCH="sm7325/v/mr"
KERNEL_DIR="android_kernel_msm-5.4_nothing_sm7325"

KSU_REPO="https://github.com/KernelSU-Next/KernelSU-Next.git"
KSU_BRANCH="legacy_susfs"    # Native 5.4 SELinux + seccomp support

AK3_REPO="https://github.com/zerofrip/AnyKernel3"
AK3_BRANCH="spacewar_nos3.0"

DEFCONFIG="spacewar_defconfig"

# ══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TC_DIR="$SCRIPT_DIR/tc"
CLANG_DIR="$TC_DIR/r383902b1"
BOOT_EDITOR_DIR="$TC_DIR/Android_boot_image_editor"
KERNEL_ROOT="$SCRIPT_DIR/$KERNEL_DIR"
OUTPUT_DIR="$SCRIPT_DIR/output"
RAW_DIR="$OUTPUT_DIR/rawfiles"

SECONDS=0

# ── Helper ───────────────────────────────────────────────
die() { echo "❌ $*"; exit 1; }

# ── 0. Dependencies ─────────────────────────────────────
echo "🔍 Checking dependencies..."

declare -A CMD_PKG=( [flex]=flex [bison]=bison [bc]=bc [curl]=curl [7z]=p7zip-full
    [python3]=python3 [jq]=jq [zip]=zip [make]=make [git]=git [patch]=patch [rsync]=rsync )
declare -A LIB_PKG=( [libssl-dev]=libssl-dev [libelf-dev]=libelf-dev )

MISSING=()
for cmd in "${!CMD_PKG[@]}"; do command -v "$cmd" &>/dev/null || MISSING+=("${CMD_PKG[$cmd]}"); done
for lib in "${!LIB_PKG[@]}"; do dpkg-query -W -f='${Status}' "$lib" 2>/dev/null | grep -q "install ok installed" || MISSING+=("${LIB_PKG[$lib]}"); done

if [ ${#MISSING[@]} -gt 0 ]; then
    MISSING=($(printf '%s\n' "${MISSING[@]}" | sort -u))
    die "Missing packages: ${MISSING[*]}\n   Fix: apt-get install -y ${MISSING[*]}"
fi
echo "   ✅ All dependencies satisfied."

# JDK 17+ for Gradle
JAVA_VER=$(java -version 2>&1 | awk -F'"' '/version/{print $2}' | cut -d. -f1)
if [ -z "$JAVA_VER" ] || [ "$JAVA_VER" -lt 17 ]; then
    echo "   ⚠️  JDK <17 — installing openjdk-17..."
    apt-get install -y openjdk-17-jdk-headless 2>/dev/null || die "Install JDK 17 manually"
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# ── 1. Toolchains ───────────────────────────────────────
echo "🔧 Checking toolchains..."

if [ ! -f "$CLANG_DIR/bin/clang" ]; then
    echo "   Downloading Clang r383902b1..."
    mkdir -p "$CLANG_DIR"
    curl -L "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android11-qpr2-release/clang-r383902b1.tar.gz" \
        | tar -xz -C "$CLANG_DIR"
    [ -f "$CLANG_DIR/bin/clang" ] || die "Clang download failed"
    echo "   ✅ Clang downloaded."
else
    echo "   ✅ Clang found."
fi

if [ ! -d "$BOOT_EDITOR_DIR" ]; then
    echo "   Cloning Android_boot_image_editor..."
    git clone --depth 1 https://github.com/cfig/Android_boot_image_editor.git "$BOOT_EDITOR_DIR"
fi
echo "   ✅ Toolchains ready."

export PATH="$CLANG_DIR/bin:$PATH"

# ── 2. Kernel Source ────────────────────────────────────
echo "📦 Setting up kernel source..."

if [ ! -d "$KERNEL_ROOT/.git" ]; then
    echo "   Cloning NothingOSS kernel ($KERNEL_BRANCH)..."
    git clone --depth 1 -b "$KERNEL_BRANCH" "$KERNEL_REPO" "$KERNEL_ROOT"
else
    echo "   ✅ Kernel source exists."
fi

cd "$KERNEL_ROOT"
[ -f "Kbuild" ] || die "Kbuild not found in $KERNEL_ROOT"

# Copy spacewar_defconfig into kernel tree
echo "   Copying spacewar_defconfig..."
cp "$SCRIPT_DIR/configs/spacewar_defconfig" "$KERNEL_ROOT/arch/arm64/configs/spacewar_defconfig"
echo "   ✅ spacewar_defconfig copied."

# ── 3. KernelSU-Next (legacy_susfs) ────────────────────
echo "💉 Setting up KernelSU-Next ($KSU_BRANCH)..."

if [ ! -d "KernelSU-Next/.git" ]; then
    echo "   Cloning KernelSU-Next ($KSU_BRANCH branch)..."
    git clone -b "$KSU_BRANCH" "$KSU_REPO" KernelSU-Next
else
    echo "   Updating KernelSU-Next..."
    pushd KernelSU-Next > /dev/null
    git fetch origin "$KSU_BRANCH"
    git reset --hard "origin/$KSU_BRANCH"
    git clean -fd
    popd > /dev/null
fi

# Unshallow for correct version computation (KSU_VERSION = 30000 + commit count)
pushd KernelSU-Next > /dev/null
if git rev-parse --is-shallow-repository 2>/dev/null | grep -q true; then
    echo "   Unshallowing for version computation..."
    git fetch --unshallow 2>/dev/null || true
fi
KSU_COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "1")
echo "   KSU commit count: $KSU_COMMIT_COUNT → KSU_VERSION=$(( 30000 + KSU_COMMIT_COUNT ))"
popd > /dev/null

# Set up driver symlink (same as setup.sh)
if [ ! -L "drivers/kernelsu" ]; then
    echo "   Creating drivers/kernelsu symlink..."
    ln -sf "../KernelSU-Next/kernel" "drivers/kernelsu"
fi

# Ensure Makefile and Kconfig include kernelsu
grep -q "kernelsu" drivers/Makefile 2>/dev/null || \
    printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> drivers/Makefile

grep -q 'source "drivers/kernelsu/Kconfig"' drivers/Kconfig 2>/dev/null || \
    sed -i '/endmenu/i\source "drivers/kernelsu/Kconfig"' drivers/Kconfig

echo "   ✅ KernelSU-Next integrated."

# ── 4. Bypass signature check ──────────────────────────
# The legacy_susfs branch validates the manager APK via a baked-in hash.
# Bypass this so any compatible KSU-Next manager works.
echo "🔓 Bypassing manager signature check..."
if grep -q "return check_v2_signature" KernelSU-Next/kernel/apk_sign.c; then
    sed -i 's/return check_v2_signature(path, EXPECTED_MANAGER_SIZE, EXPECTED_MANAGER_HASH);/return true;/g' \
        KernelSU-Next/kernel/apk_sign.c
    echo "   ✅ Signature check bypassed."
else
    echo "   ℹ️  Already patched."
fi

# ── 5. SUSFS ────────────────────────────────────────────
echo "📥 Setting up SUSFS..."

# Copy pre-patched SUSFS v2.0.0 files (from zerofrip's working 5.4 kernel,
# with try_umount stub for KernelSU-Next legacy_susfs compat)
cp -v "$SCRIPT_DIR/configs/susfs/susfs.c" fs/susfs.c
cp -v "$SCRIPT_DIR/configs/susfs/include/linux/susfs.h" include/linux/susfs.h
cp -v "$SCRIPT_DIR/configs/susfs/include/linux/susfs_def.h" include/linux/susfs_def.h

echo "   ✅ SUSFS v2.0.0 installed."

# Fix pinctrl-utils.h include path for audio techpack
sed -i '/ifdef CONFIG_PINCTRL_WCD/a\\tINCS += -I$(srctree)/drivers/pinctrl' \
    techpack/audio/soc/Kbuild
echo "   ✅ pinctrl include path fixed."

# ── 6. Build Kernel ─────────────────────────────────────
echo ""
echo "🏗️  Building kernel..."

VERSION=$(cat VERSION | tr -d '\n')
PATCHLEVEL=$(cat PATCHLEVEL 2>/dev/null | tr -d '\n' || echo "0")
FULL_VERSION="v${VERSION}.${PATCHLEVEL}"
echo "   Kernel version: $FULL_VERSION"

if command -v ccache &>/dev/null; then
    echo "   ccache found — enabling."
    export CCACHE_COMPRESS=1 CCACHE_DIR="${HOME}/.ccache" CCACHE_MAXSIZE="50G"
    CC_CMD="ccache clang"
else
    CC_CMD="clang"
fi

MAKE_PARAMS=(
    O="$RAW_DIR"
    ARCH=arm64
    CC="$CC_CMD"
    CLANG_TRIPLE=aarch64-linux-gnu-
    LLVM=1
    LLVM_IAS=1
    CROSS_COMPILE="$CLANG_DIR/bin/llvm-"
    LOCALVERSION="-qgki"
)

mkdir -p "$OUTPUT_DIR" "$RAW_DIR"

echo "   Generating defconfig..."
make "${MAKE_PARAMS[@]}" "$DEFCONFIG" || die "Defconfig failed"

echo "   Building with $(nproc --all) threads..."
make -j$(nproc --all) "${MAKE_PARAMS[@]}" || die "Kernel build failed"

echo "✅ Kernel build complete."

# ── 7. Repack boot.img ──────────────────────────────────
echo ""
echo "📦 Repacking boot.img..."

LATEST_TAG=$(curl -sf https://api.github.com/repos/spike0en/nothing_archive/releases \
    | grep -oP '"tag_name": "\KSpacewar_[^"]+' | head -n 1)
[ -z "$LATEST_TAG" ] && LATEST_TAG="Spacewar_V3.2-251219-1652"

echo "   Stock boot tag: $LATEST_TAG"
DOWNLOAD_URL="https://github.com/spike0en/nothing_archive/releases/download/${LATEST_TAG}/${LATEST_TAG}-image-boot.7z"
curl -L "$DOWNLOAD_URL" -o image-boot.7z || true

if [ ! -s "image-boot.7z" ]; then
    LATEST_TAG="Spacewar_V3.2-251219-1652"
    curl -L "https://github.com/spike0en/nothing_archive/releases/download/${LATEST_TAG}/${LATEST_TAG}-image-boot.7z" -o image-boot.7z
fi
[ -s "image-boot.7z" ] || die "Could not download stock boot image"

7z x -y image-boot.7z
EXTRACTED_BOOT=$(find . -maxdepth 2 -name "boot.img" ! -path "./AnyKernel3/*" | head -1)
rm -f image-boot.7z

cp "$EXTRACTED_BOOT" "$BOOT_EDITOR_DIR/boot.img"
pushd "$BOOT_EDITOR_DIR" > /dev/null
./gradlew unpack
cp "$RAW_DIR/arch/arm64/boot/Image" build/unzip_boot/kernel
./gradlew pack
[ -f boot.img.signed ] && cp boot.img.signed "$OUTPUT_DIR/boot.img" \
    || cp boot.img "$OUTPUT_DIR/boot.img" 2>/dev/null \
    || die "No repacked image found"
popd > /dev/null

echo "✅ boot.img repacked."

# ── 8. Package AnyKernel3 ZIP ────────────────────────────
echo ""
echo "📁 Packaging..."

DATE=$(date +'%Y%m%d%H%M')
ZIP_NAME="Uo_Spacewar_Kernel_${FULL_VERSION}_${DATE}.zip"

[ -d "AnyKernel3" ] || git clone "$AK3_REPO" -b "$AK3_BRANCH" AnyKernel3

cp "$RAW_DIR/arch/arm64/boot/Image" AnyKernel3/
if ls "$RAW_DIR/arch/arm64/boot/dts/vendor/qcom/"*.dtb &>/dev/null; then
    cat "$RAW_DIR/arch/arm64/boot/dts/vendor/qcom/"*.dtb > AnyKernel3/dtb
fi
if ls "$RAW_DIR/arch/arm64/boot/dts/vendor/qcom/"*.dtbo &>/dev/null; then
    python3 scripts/mkdtboimg.py create AnyKernel3/dtbo.img \
        --page_size=4096 "$RAW_DIR/arch/arm64/boot/dts/vendor/qcom/"*.dtbo
fi

cd AnyKernel3
zip -r9 "$OUTPUT_DIR/$ZIP_NAME" ./* -x .git README.md '*placeholder*'
cd "$KERNEL_ROOT"

# ── 9. Metadata ──────────────────────────────────────────
DATE_DISPLAY=$(date +'%Y-%m-%d %H:%M')
{
    echo "Unofficial Spacewar Kernel ${FULL_VERSION}"
    echo "Date: ${DATE_DISPLAY}"
    echo "- KernelSU-Next (${KSU_BRANCH}) + SUSFS v2.0.0"
    echo "- Built against stock: ${LATEST_TAG}"
    echo ""
    cat ChangeLog.txt 2>/dev/null || true
} > ChangeLog.txt.new
mv ChangeLog.txt.new ChangeLog.txt

if [ -f "kernel-downloads.json" ] && command -v jq &>/dev/null; then
    ZIP_SHA1=$(sha1sum "$OUTPUT_DIR/$ZIP_NAME" | awk '{print $1}')
    jq --arg date "$(date +'%Y-%m-%d')" --arg version "5.4.289-${FULL_VERSION}" --arg sha1 "$ZIP_SHA1" \
        '.kernel.date = $date | .kernel.version = $version | .kernel.sha1 = $sha1' \
        kernel-downloads.json > temp.json && mv temp.json kernel-downloads.json
fi

# ── Done ─────────────────────────────────────────────────
echo ""
echo "✅ DONE! Build completed in $((SECONDS / 60))m $((SECONDS % 60))s"
echo ""
echo "Artifacts in $OUTPUT_DIR/:"
echo "  - $ZIP_NAME"
echo "  - boot.img"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ⚠️  boot.img built against stock: $LATEST_TAG"
echo "     Only flash on a device running that firmware."
echo ""
echo "  📱 Install a KernelSU-Next manager (spoofed recommended):"
echo "     https://github.com/rifsxd/KernelSU-Next/releases"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
