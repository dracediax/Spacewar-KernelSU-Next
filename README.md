# Nothing Phone (1) Kernel Builder

Automated kernel builder for Nothing Phone (1) **Spacewar** with KernelSU-Next root and SUSFS.

## Sources

| Component | Repository | Branch |
|---|---|---|
| Kernel | [NothingOSS/android_kernel_msm-5.4_nothing_sm7325](https://github.com/NothingOSS/android_kernel_msm-5.4_nothing_sm7325) | `sm7325/v/mr` |
| KernelSU-Next | [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) | `legacy_susfs` |
| SUSFS | [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) | `gki-android12-5.10` |
| AnyKernel3 | [zerofrip/AnyKernel3](https://github.com/zerofrip/AnyKernel3) | `spacewar_nos3.0` |
| Stock boot images | [spike0en/nothing_archive](https://github.com/spike0en/nothing_archive) | — |

## Quick Start

```bash
git clone https://github.com/dracediax/Spacewar-KernelSU-Next.git
cd Spacewar-KernelSU-Next
chmod +x UpdateAndRelease.sh
./UpdateAndRelease.sh
```

The script auto-downloads all dependencies (Clang toolchain, boot image editor, kernel source, KernelSU-Next) on first run.

## Output

After a successful build, `output/` contains:

- `boot.img` — Flash via `fastboot flash boot boot.img`
- `Uo_Spacewar_Kernel_*.zip` — Flash via kernel manager (Franco, SmartPack)

## Manager

Install a KernelSU-Next manager APK after flashing the kernel:
- [rifsxd/KernelSU-Next releases](https://github.com/rifsxd/KernelSU-Next/releases) (spoofed builds recommended)

## Why `legacy_susfs`?

The official `dev` branch dropped support for kernel 5.4 (SELinux policy patching and seccomp disabling). The `legacy_susfs` branch retains native 5.4 compatibility — no compat hacks needed.

## Credits

- **NothingOSS** — Kernel source
- **KernelSU-Next** — Root framework
- **simonpunk** — SUSFS
- **zerofrip** — Original Spacewar kernel builder & AnyKernel3 config
- **spike0en** — Stock boot image archive
