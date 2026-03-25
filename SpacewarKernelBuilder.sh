#!/bin/bash
#
# SpacewarKernelBuilder.sh — Kernel Builder for Nothing Phone (1)
# KernelSU-Next + SUSFS
#

set -euo pipefail

# ╔══════════════════════════════════════════════════════╗
# ║                   DEFAULTS                            ║
# ╚══════════════════════════════════════════════════════╝

KERNEL_REPO="https://github.com/NothingOSS/android_kernel_msm-5.4_nothing_sm7325.git"
KERNEL_BRANCH="sm7325/v/mr"
KERNEL_DIR="android_kernel_msm-5.4_nothing_sm7325"

KSU_REPO="https://github.com/KernelSU-Next/KernelSU-Next.git"
KSU_BRANCH="legacy_susfs"

AK3_REPO="https://github.com/zerofrip/AnyKernel3"
AK3_BRANCH="spacewar_nos3.0"

DEFCONFIG="spacewar_defconfig"
STOCK_BOOT_TAG="Spacewar_V3.2-251219-1652"
BOOT_PARTITION_SIZE=100663296

# ╔══════════════════════════════════════════════════════╗
# ║                FIRMWARE DATABASE                      ║
# ╚══════════════════════════════════════════════════════╝

NOS_VERSIONS=("3.2" "3.0" "2.6" "2.5" "2.0" "1.5")
NOS_ANDROID=("15"  "15"  "14"  "14"  "13"  "13")
NOS_BRANCH=("sm7325/v/mr" "sm7325/v/mr" "sm7325/u/mr" "sm7325/u/mr" "sm7325/t" "sm7325/t")

declare -A FIRMWARE_BUILDS
FIRMWARE_BUILDS["3.2"]="Spacewar_V3.2-260206-1016 Spacewar_V3.2-251231-0041 Spacewar_V3.2-251219-1652 Spacewar_V3.2-250926-1631 Spacewar_V3.2-250804-2110 Spacewar_V3.2-250701-1737 Spacewar_V3.2-250610-1104"
FIRMWARE_BUILDS["3.0"]="Spacewar_V3.0-250409-2129 Spacewar_V3.0-250303-1817 Spacewar_V3.0-250218-1552 Spacewar_V3.0-250108-1938 Spacewar_V3.0-241211-0926"
FIRMWARE_BUILDS["2.6"]="Spacewar_U2.6-241031-1818 Spacewar_U2.6-240904-1634 Spacewar_U2.6-240705-1617"
FIRMWARE_BUILDS["2.5"]="Spacewar_U2.5-240612-2149 Spacewar_U2.5-240419-1617 Spacewar_U2.5-240317-2245 Spacewar_U2.5-240301-1852 Spacewar_U2.5-240207-1031 Spacewar_U2.5-240119-1910 Spacewar_U2.5-240106-2238 Spacewar_U2.5-231220-0836 Spacewar_U2.5-231215-2256 Spacewar_U2.5-231212-1147 Spacewar_U2.5-231206-0153"
FIRMWARE_BUILDS["2.0"]="Spacewar_T2.0-231110-1731 Spacewar_T2.0-231006-1014 Spacewar_T2.0-230901-1652 Spacewar_T2.0-230822-1751"
FIRMWARE_BUILDS["1.5"]="Spacewar_T1.5-230706-1942 Spacewar_T1.5-230619-0042 Spacewar_T1.5-230428-2017 Spacewar_T1.5-230317-2039 Spacewar_T1.5-230310-1650 Spacewar_T1.5-230213-2131 Spacewar_T1.5-230114-2357"

# KSU tags (populated dynamically, fallback list)
KSU_TAGS_FALLBACK="v3.1.0-legacy-susfs v3.0.1-legacy-susfs v3.0.0-legacy-susfs"

# ╔══════════════════════════════════════════════════════╗
# ║              INTERACTIVE MODE                         ║
# ╚══════════════════════════════════════════════════════╝

pick_number() {
    local max=$1 prompt=$2 choice
    while true; do
        read -rp "$prompt" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ]; then
            echo "$choice"
            return
        fi
        echo "  Invalid choice. Enter a number between 1 and $max."
    done
}

interactive_menu() {
    echo ""
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║    ⬡  SpacewarKernelBuilder               ║"
    echo "  ║    Nothing Phone (1) · KernelSU-Next      ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo ""
    echo "  [1] Auto build (latest kernel + latest KSU)"
    echo "  [2] Custom build (choose your versions)"
    echo ""
    local mode
    mode=$(pick_number 2 "  Choose [1/2]: ")

    if [ "$mode" = "1" ]; then
        echo ""
        echo "  → Building latest kernel (sm7325/v/mr) + latest KSU-Next"
        echo ""
        return
    fi

    # ── Pick NOS version ──────────────────────────────
    echo ""
    echo "  Which NothingOS version are you running?"
    echo ""
    for i in "${!NOS_VERSIONS[@]}"; do
        printf "  [%d] NOS %-4s  (Android %s, branch: %s)\n" \
            $((i + 1)) "${NOS_VERSIONS[$i]}" "${NOS_ANDROID[$i]}" "${NOS_BRANCH[$i]}"
    done
    echo ""
    local nos_choice
    nos_choice=$(pick_number ${#NOS_VERSIONS[@]} "  Choose [1-${#NOS_VERSIONS[@]}]: ")
    local nos_idx=$((nos_choice - 1))
    local selected_nos="${NOS_VERSIONS[$nos_idx]}"
    KERNEL_BRANCH="${NOS_BRANCH[$nos_idx]}"

    # ── Pick firmware build ───────────────────────────
    echo ""
    echo "  Available builds for NOS $selected_nos:"
    echo ""
    local builds_str="${FIRMWARE_BUILDS[$selected_nos]}"
    local -a builds
    read -ra builds <<< "$builds_str"
    for i in "${!builds[@]}"; do
        printf "  [%d] %s\n" $((i + 1)) "${builds[$i]}"
    done
    echo ""
    local fw_choice
    fw_choice=$(pick_number ${#builds[@]} "  Choose [1-${#builds[@]}]: ")
    STOCK_BOOT_TAG="${builds[$((fw_choice - 1))]}"

    # ── Pick KSU version ──────────────────────────────
    echo ""
    echo "  Fetching KernelSU-Next versions..."
    local -a ksu_tags
    if ksu_remote=$(git ls-remote --tags "$KSU_REPO" 2>/dev/null | grep "legacy-susfs" | grep -v '\^{}' | sed 's|.*refs/tags/||' | sort -rV); then
        read -ra ksu_tags <<< "$(echo "$ksu_remote" | head -10 | tr '\n' ' ')"
    fi
    if [ ${#ksu_tags[@]} -eq 0 ]; then
        read -ra ksu_tags <<< "$KSU_TAGS_FALLBACK"
    fi

    echo ""
    echo "  Available KernelSU-Next versions:"
    echo ""
    for i in "${!ksu_tags[@]}"; do
        local label="${ksu_tags[$i]}"
        [ "$i" = "0" ] && label="$label  (latest)"
        printf "  [%d] %s\n" $((i + 1)) "$label"
    done
    echo ""
    local ksu_choice
    ksu_choice=$(pick_number ${#ksu_tags[@]} "  Choose [1-${#ksu_tags[@]}]: ")
    KSU_TAG="${ksu_tags[$((ksu_choice - 1))]}"

    echo ""
}

# ╔══════════════════════════════════════════════════════╗
# ║              PARSE CLI / RUN INTERACTIVE              ║
# ╚══════════════════════════════════════════════════════╝

CI_MODE="${CI:-false}"

# Parse command-line options (used by CI and advanced users)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --kernel-branch)  KERNEL_BRANCH="$2"; shift 2 ;;
        --ksu-branch)     KSU_BRANCH="$2"; shift 2 ;;
        --ksu-tag)        KSU_TAG="$2"; shift 2 ;;
        --stock-tag)      STOCK_BOOT_TAG="$2"; shift 2 ;;
        --clean)          CLEAN_BUILD=1; shift ;;
        --auto)           shift ;;  # skip interactive
        --help|-h)
            cat <<HELP
Usage: ./SpacewarKernelBuilder.sh [OPTIONS]

Run without options for interactive mode.

Options:
  --kernel-branch BRANCH   Kernel branch (default: sm7325/v/mr)
  --ksu-branch BRANCH      KernelSU-Next branch (default: legacy_susfs)
  --ksu-tag TAG             KernelSU-Next version tag (e.g. v3.1.0-legacy-susfs)
  --stock-tag TAG           Firmware version (e.g. Spacewar_V3.2-260206-1016)
  --auto                   Skip interactive menu, use defaults
  --clean                  Clean build
  -h, --help               Show this help
HELP
            exit 0 ;;
        *) echo "Unknown option: $1 (try --help)"; exit 1 ;;
    esac
done

# Run interactive menu if local (not CI) and no CLI overrides were given
if [ "$CI_MODE" = "false" ] && [ -z "${KSU_TAG:-}" ] && [ "$STOCK_BOOT_TAG" = "Spacewar_V3.2-251219-1652" ] && [ "$KERNEL_BRANCH" = "sm7325/v/mr" ]; then
    # Check if running in a terminal
    if [ -t 0 ]; then
        interactive_menu
    fi
fi

echo "═══════════════════════════════════════════════"
echo "  Kernel branch:  $KERNEL_BRANCH"
echo "  KSU branch:     $KSU_BRANCH"
[ -n "${KSU_TAG:-}" ] && echo "  KSU tag:         $KSU_TAG"
echo "  Stock boot:     $STOCK_BOOT_TAG"
echo "═══════════════════════════════════════════════"
echo ""

# ══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/SpacewarKernelBuilder"
TC_DIR="$BUILD_DIR/tc"
CLANG_DIR="$TC_DIR/r383902b1"
BOOT_EDITOR_DIR="$TC_DIR/Android_boot_image_editor"
KERNEL_ROOT="$BUILD_DIR/$KERNEL_DIR"
OUTPUT_DIR="$SCRIPT_DIR/output"
RAW_DIR="$OUTPUT_DIR/rawfiles"

SECONDS=0

die() { echo "FATAL: $*"; exit 1; }

# Handle --clean
if [ "${CLEAN_BUILD:-}" = "1" ]; then
    echo "Clean build requested — removing output..."
    rm -rf "$RAW_DIR" "$OUTPUT_DIR"/*.img "$OUTPUT_DIR"/*.zip
fi

# ── 0. Dependencies ─────────────────────────────────────
echo "Checking dependencies..."

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

# ── 1. Toolchains ───────────────────────────────────────
mkdir -p "$BUILD_DIR"
echo "Checking toolchains..."

if [ ! -f "$CLANG_DIR/bin/clang" ]; then
    echo "   Downloading Clang r383902b1..."
    mkdir -p "$CLANG_DIR"
    curl -L "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android11-qpr2-release/clang-r383902b1.tar.gz" \
        | tar -xz -C "$CLANG_DIR"
    [ -f "$CLANG_DIR/bin/clang" ] || die "Clang download failed"
fi

if [ ! -d "$BOOT_EDITOR_DIR" ]; then
    git clone --depth 1 https://github.com/cfig/Android_boot_image_editor.git "$BOOT_EDITOR_DIR"
fi

export PATH="$CLANG_DIR/bin:$PATH"

# ── 2. Kernel Source ────────────────────────────────────
echo "Setting up kernel source..."

if [ ! -d "$KERNEL_ROOT/.git" ]; then
    echo "   Cloning NothingOSS kernel ($KERNEL_BRANCH)..."
    git clone --depth 1 -b "$KERNEL_BRANCH" "$KERNEL_REPO" "$KERNEL_ROOT"
fi

cd "$KERNEL_ROOT"
[ -f "Kbuild" ] || die "Kbuild not found in $KERNEL_ROOT"

cp "$BUILD_DIR/configs/spacewar_defconfig" "$KERNEL_ROOT/arch/arm64/configs/spacewar_defconfig"

# ── 3. KernelSU-Next ────────────────────────────────────
echo "Setting up KernelSU-Next ($KSU_BRANCH)..."

if [ ! -d "KernelSU-Next/.git" ]; then
    git clone -b "$KSU_BRANCH" "$KSU_REPO" KernelSU-Next
else
    pushd KernelSU-Next > /dev/null
    git fetch origin "$KSU_BRANCH"
    git reset --hard "origin/$KSU_BRANCH"
    git clean -fd
    popd > /dev/null
fi

# Get version info
pushd KernelSU-Next > /dev/null
if git rev-parse --is-shallow-repository 2>/dev/null | grep -q true; then
    git fetch --unshallow 2>/dev/null || true
fi
git fetch --tags 2>/dev/null || true

# Checkout specific tag if requested
if [ -n "${KSU_TAG:-}" ]; then
    echo "   Checking out KSU tag: $KSU_TAG"
    git checkout "$KSU_TAG" || die "Tag $KSU_TAG not found"
fi

KSU_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' | sed 's/-legacy-susfs//')
[ -z "$KSU_VERSION" ] && KSU_VERSION="unknown"
echo "   KSU-Next version: $KSU_VERSION"
popd > /dev/null

# Driver symlink
[ -L "drivers/kernelsu" ] || ln -sf "../KernelSU-Next/kernel" "drivers/kernelsu"
grep -q "kernelsu" drivers/Makefile 2>/dev/null || \
    printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> drivers/Makefile
grep -q 'source "drivers/kernelsu/Kconfig"' drivers/Kconfig 2>/dev/null || \
    sed -i '/endmenu/i\source "drivers/kernelsu/Kconfig"' drivers/Kconfig

# Do NOT bypass manager signature check — doing so causes random apps
# (e.g. accessibility services) to be crowned as the KSU manager.

# ── 4. Patch kernel source ─────────────────────────────
echo "Patching kernel source..."

# Install SUSFS source files (official NothingOSS source doesn't have them)
if [ ! -f "include/linux/susfs.h" ]; then
    cp "$BUILD_DIR/configs/susfs/include/linux/susfs.h" include/linux/susfs.h
    cp "$BUILD_DIR/configs/susfs/include/linux/susfs_def.h" include/linux/susfs_def.h
    cp "$BUILD_DIR/configs/susfs/susfs.c" fs/susfs.c
    grep -q "susfs.o" fs/Makefile || echo 'obj-$(CONFIG_KSU_SUSFS) += susfs.o' >> fs/Makefile
    echo "   SUSFS source files installed"
fi

# SUSFS compat: add missing defines and stubs
if ! grep -q "DEFAULT_SUS_MNT_ID" include/linux/susfs_def.h; then
    printf '\n#define DEFAULT_SUS_MNT_ID 100000\n' >> include/linux/susfs_def.h
fi
if ! grep -q "susfs_add_try_umount" include/linux/susfs.h; then
    sed -i '/^void susfs_init/i \
\n/* legacy_susfs compat */\n#ifdef CONFIG_KSU_SUSFS_TRY_UMOUNT\nvoid susfs_add_try_umount(void __user **user_info);\nvoid susfs_try_umount(uid_t uid);\nvoid susfs_try_umount_all(uid_t uid);\n#endif' include/linux/susfs.h
fi
if ! grep -q "susfs_try_umount" fs/susfs.c; then
    cat >> fs/susfs.c << 'STUBS'

#ifdef CONFIG_KSU_SUSFS_TRY_UMOUNT
void susfs_add_try_umount(void __user **user_info) {}
void susfs_try_umount(uid_t uid) {}
void susfs_try_umount_all(uid_t uid) {}
#endif
STUBS
fi

# Prevent KSU Kbuild from patching struct seccomp (breaks vendor module ABI).
# The Kbuild checks for "filter_count" in seccomp.h — a comment satisfies the
# grep without changing the struct layout.
if ! grep -q "filter_count" include/linux/seccomp.h; then
    sed -i '/int mode;/a\\t/* atomic_t filter_count; -- not on 5.4, guarded in KSU driver */' \
        include/linux/seccomp.h
fi
# Guard the actual access in app_profile.c
if grep -q 'atomic_set(&current->seccomp.filter_count, 0);' KernelSU-Next/kernel/app_profile.c; then
    sed -i 's|atomic_set(&current->seccomp.filter_count, 0);|/* filter_count not available on 5.4 */|' \
        KernelSU-Next/kernel/app_profile.c
fi

# Manual reboot hook for KSU fd installation (kprobe path is disabled when SUSFS
# is enabled, so ksud can't obtain a driver fd → version reports as 0 → modules
# like ReZygisk refuse to install).
if ! grep -q "ksu_handle_sys_reboot" kernel/reboot.c; then
    sed -i '/^SYSCALL_DEFINE4(reboot,/i \
extern int ksu_handle_sys_reboot(int magic1, int magic2, unsigned int cmd,\n\t\t\t\t void __user **arg);' \
        kernel/reboot.c
    sed -i '/struct pid_namespace \*pid_ns = task_active_pid_ns/a\\n\tksu_handle_sys_reboot(magic1, magic2, cmd, (void __user **)\&arg);' \
        kernel/reboot.c
    echo "   Reboot hook for KSU fd installed"
fi

# Disable PINCTRL_WCD/LPI (incomplete struct pinctrl_dev prevents in-tree build)
sed -i 's/^export CONFIG_PINCTRL_WCD=m/# export CONFIG_PINCTRL_WCD=m/' \
    techpack/audio/config/lahainaauto.conf
sed -i 's/^export CONFIG_PINCTRL_LPI=m/# export CONFIG_PINCTRL_LPI=m/' \
    techpack/audio/config/lahainaauto.conf
sed -i 's/^#define CONFIG_PINCTRL_WCD 1/\/\/ #define CONFIG_PINCTRL_WCD 1/' \
    techpack/audio/config/lahainaautoconf.h
sed -i 's/^#define CONFIG_PINCTRL_LPI 1/\/\/ #define CONFIG_PINCTRL_LPI 1/' \
    techpack/audio/config/lahainaautoconf.h

# Suppress -dirty suffix
echo "-g$(git rev-parse --short=12 HEAD)" > .scmversion
echo "   All patches applied"

# ── 5. Build Kernel ─────────────────────────────────────
echo ""
echo "Building kernel..."

VERSION=$(grep '^VERSION' Makefile | head -1 | awk '{print $3}')
PATCHLEVEL=$(grep '^PATCHLEVEL' Makefile | head -1 | awk '{print $3}')
SUBLEVEL=$(grep '^SUBLEVEL' Makefile | head -1 | awk '{print $3}')
KERNEL_VER="${VERSION}.${PATCHLEVEL}.${SUBLEVEL}"

if command -v ccache &>/dev/null; then
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
)

mkdir -p "$OUTPUT_DIR" "$RAW_DIR"

make "${MAKE_PARAMS[@]}" "$DEFCONFIG" || die "Defconfig failed"
make -j$(nproc --all) "${MAKE_PARAMS[@]}" || die "Kernel build failed"

echo "Kernel build complete ($KERNEL_VER)"

# ── 6. Repack boot.img ──────────────────────────────────
echo ""
echo "Repacking boot.img..."

LATEST_TAG=$(curl -sf https://api.github.com/repos/spike0en/nothing_archive/releases \
    | grep -oP '"tag_name": "\KSpacewar_[^"]+' | head -n 1)
[ -z "$LATEST_TAG" ] && LATEST_TAG="$STOCK_BOOT_TAG"

DOWNLOAD_URL="https://github.com/spike0en/nothing_archive/releases/download/${LATEST_TAG}/${LATEST_TAG}-image-boot.7z"
curl -L "$DOWNLOAD_URL" -o image-boot.7z || true

if [ ! -s "image-boot.7z" ]; then
    LATEST_TAG="$STOCK_BOOT_TAG"
    curl -L "https://github.com/spike0en/nothing_archive/releases/download/${LATEST_TAG}/${LATEST_TAG}-image-boot.7z" -o image-boot.7z
fi
[ -s "image-boot.7z" ] || die "Could not download stock boot image"

7z x -y image-boot.7z
STOCK_BOOT=$(find . -maxdepth 2 -name "boot.img" ! -path "./AnyKernel3/*" | head -1)
rm -f image-boot.7z

# Extract stock ramdisk byte-exact (no decompression — preserves cpio integrity)
python3 -c "
import struct
with open('$STOCK_BOOT','rb') as f:
    f.read(8); ks=struct.unpack('<I',f.read(4))[0]; rs=struct.unpack('<I',f.read(4))[0]
    off=4096+((ks+4095)//4096)*4096; f.seek(off)
    open('$OUTPUT_DIR/stock_ramdisk.gz','wb').write(f.read(rs))
print(f'   Stock ramdisk: {rs} bytes (byte-exact)')
"

# Build boot.img with mkbootimg directly (boot editor corrupts ramdisk)
MKBOOTIMG="$BOOT_EDITOR_DIR/aosp/system/tools/mkbootimg/mkbootimg.py"
AVBTOOL="$BOOT_EDITOR_DIR/aosp/avb/avbtool.v1.2.py"

python3 "$MKBOOTIMG" \
    --header_version 3 \
    --kernel "$RAW_DIR/arch/arm64/boot/Image" \
    --ramdisk "$OUTPUT_DIR/stock_ramdisk.gz" \
    --os_version 11.0.0 \
    --os_patch_level 2025-05 \
    --output "$OUTPUT_DIR/boot.img" || die "mkbootimg failed"

python3 "$AVBTOOL" add_hash_footer \
    --image "$OUTPUT_DIR/boot.img" \
    --partition_size $BOOT_PARTITION_SIZE \
    --partition_name boot \
    --hash_algorithm sha256 \
    --algorithm NONE \
    --salt 13f0b0127083a4a62c8897ee82ac3e0099f015d997031ef05fe759a8adf28f65 || die "avbtool failed"

rm -f "$OUTPUT_DIR/stock_ramdisk.gz"
echo "boot.img repacked (stock: $LATEST_TAG)"

# ── 7. Package AnyKernel3 ZIP ────────────────────────────
echo ""
echo "Packaging AnyKernel3 zip..."

# Detect NOS version from stock tag (e.g. "3.2" from "Spacewar_V3.2-251219-1652")
OS_VERSION=$(echo "$LATEST_TAG" | grep -oP 'V\K[0-9]+\.[0-9]+' || echo "3.2")

ZIP_NAME="Spacewar_NOS${OS_VERSION}_KernelSU-Next_v${KSU_VERSION}_$(date +'%Y%m%d%H%M').zip"

[ -d "AnyKernel3" ] || git clone "$AK3_REPO" -b "$AK3_BRANCH" AnyKernel3

cp "$RAW_DIR/arch/arm64/boot/Image" AnyKernel3/

# DTBs
if ls "$RAW_DIR/arch/arm64/boot/dts/vendor/qcom/"*.dtb &>/dev/null; then
    cat "$RAW_DIR/arch/arm64/boot/dts/vendor/qcom/"*.dtb > AnyKernel3/dtb
elif ls "$RAW_DIR/arch/arm64/boot/dts/qcom/"*.dtb &>/dev/null; then
    cat "$RAW_DIR/arch/arm64/boot/dts/qcom/"*.dtb > AnyKernel3/dtb
fi

# Package vendor kernel modules
KREL=$(cat "$RAW_DIR/include/config/kernel.release")
MODDIR="AnyKernel3/modules/vendor/lib/modules/${KREL}"
mkdir -p "$MODDIR"
find "$RAW_DIR" -name "*.ko" -exec cp {} "$MODDIR/" \;

# modules.load
MODLOAD="$MODDIR/modules.load"
: > "$MODLOAD"
for m in llcc_perfmon rdbg fts_tp goodix_fp \
         slimbus slimbus-ngd \
         apr_dlkm q6_pdr_dlkm q6_notifier_dlkm q6_dlkm adsp_loader_dlkm \
         swr_dlkm snd_event_dlkm swr_ctrl_dlkm native_dlkm \
         wcd_core_dlkm wcd9xxx_dlkm mbhc_dlkm bolero_cdc_dlkm \
         wsa_macro_dlkm va_macro_dlkm tx_macro_dlkm rx_macro_dlkm \
         wcd937x_slave_dlkm wcd937x_dlkm wcd938x_slave_dlkm wcd938x_dlkm \
         wsa883x_dlkm tfa98xx_dlkm \
         swr_dmic_dlkm swr_haptics_dlkm stub_dlkm hdmi_dlkm \
         platform_dlkm machine_dlkm \
         btpower bt_fm_slim qcom_edac hid-aksys nothing_stability_test \
         camera msm_drm radio-i2c-rtc6226-qca; do
    [ -f "$MODDIR/${m}.ko" ] && echo "${m}.ko" >> "$MODLOAD"
done
for ko in "$MODDIR/"*.ko; do
    bn=$(basename "$ko")
    grep -qx "$bn" "$MODLOAD" || echo "$bn" >> "$MODLOAD"
done

# modules.dep
: > "$MODDIR/modules.dep"
for ko in "$MODDIR/"*.ko; do
    echo "/vendor/lib/modules/$(basename "$ko"):" >> "$MODDIR/modules.dep"
done

NMOD=$(find "$MODDIR" -name "*.ko" | wc -l)
echo "   $NMOD modules packaged"

# Enable module installation
sed -i 's/do\.modules=0/do.modules=1/' AnyKernel3/anykernel.sh

cd AnyKernel3
zip -r9 "$OUTPUT_DIR/$ZIP_NAME" ./* -x .git README.md '*placeholder*'
cd "$KERNEL_ROOT"

# ── Done ─────────────────────────────────────────────────
echo ""
echo "DONE! Build completed in $((SECONDS / 60))m $((SECONDS % 60))s"
echo ""
echo "Artifacts in $OUTPUT_DIR/:"
echo "  - boot.img"
echo "  - $ZIP_NAME"
echo ""
echo "  KernelSU-Next: v${KSU_VERSION} (${KSU_BRANCH})"
echo "  Kernel: ${KERNEL_VER}"
echo "  Stock boot: ${LATEST_TAG}"
