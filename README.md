# Nothing Phone (1) Kernel Builder

Automated kernel builder for Nothing Phone (1) **Spacewar** with KernelSU-Next root and SUSFS.

> [!WARNING]
> **Flash at your own risk.** This is a custom kernel — flashing it can brick your device, cause boot loops, or break functionality. Make sure you have a backup of your stock boot image before proceeding.

## Features

- KernelSU-Next with SUSFS v2.0.0 (hide root from apps)
- Built against official NothingOSS kernel source for NOS 3.2
- Automated CI builds with GitHub Actions — every push creates a release
- Vendor kernel modules included (audio, camera, display, BT, etc.)

## Download

Grab the latest release from the [Releases](https://github.com/dracediax/Spacewar-KernelSU-Next/releases) page.

## Install

1. **Unlock bootloader** (if not already)
2. Flash `boot.img`:
   ```
   fastboot flash boot boot.img
   ```
   Or flash `Spacewar_NOS3.2_KernelSU-Next_v*.zip` via custom recovery.
3. Install [KernelSU-Next Manager](https://github.com/rifsxd/KernelSU-Next/releases)

## Build Locally

```bash
git clone https://github.com/dracediax/Spacewar-KernelSU-Next.git
cd Spacewar-KernelSU-Next
chmod +x UpdateAndRelease.sh
./UpdateAndRelease.sh
```

The script auto-downloads all dependencies (Clang toolchain, kernel source, KernelSU-Next, boot tools) on first run. Output lands in `output/`.

## Sources

| Component | Repository | Branch |
|---|---|---|
| Kernel | [NothingOSS/android_kernel_msm-5.4_nothing_sm7325](https://github.com/NothingOSS/android_kernel_msm-5.4_nothing_sm7325) | `sm7325/v/mr` |
| KernelSU-Next | [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) | `legacy_susfs` |
| SUSFS | Patched into kernel at build time | v2.0.0 |
| AnyKernel3 | [zerofrip/AnyKernel3](https://github.com/zerofrip/AnyKernel3) | `spacewar_nos3.0` |
| Stock boot images | [spike0en/nothing_archive](https://github.com/spike0en/nothing_archive) | — |

## Why `legacy_susfs`?

The official KernelSU-Next `dev` branch dropped support for kernel 5.4. The `legacy_susfs` branch retains native 5.4 compatibility with SELinux policy patching and seccomp support built in.

## Credits

- **NothingOSS** — Official kernel source
- **KernelSU-Next** — Root framework
- **simonpunk** — SUSFS
- **zerofrip** — AnyKernel3 config for Spacewar
- **spike0en** — Stock boot image archive
