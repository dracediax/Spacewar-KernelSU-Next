> [!CAUTION]
> **CURRENTLY BROKEN — DO NOT FLASH — WORK IN PROGRESS**
>
> This kernel is under active development and is not yet stable. Do not flash it on your device.

# Nothing Phone (1) Kernel Builder

Automated kernel builder for Nothing Phone (1) **Spacewar** with KernelSU-Next root and SUSFS.

> [!WARNING]
> **Flash at your own risk.** This is a custom kernel — flashing it can brick your device, cause boot loops, or break functionality. You must know what you are doing. Make sure you have a backup of your stock boot image before proceeding. **I take no responsibility for any damage, bricked devices, or broken phones.**

## Sources

| Component | Repository | Branch |
|---|---|---|
| Kernel | [zerofrip/Spacewar_NOS3.0_Kernel](https://github.com/zerofrip/Spacewar_NOS3.0_Kernel) | `sm7325/v/mr` |
| KernelSU-Next | [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) | `legacy_susfs` |
| SUSFS | Built into kernel source | v2.0.0 |
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
- `Spacewar_NOS*_KernelSU-Next_*.zip` — Flash via kernel manager (Franco, SmartPack)

## Manager

Install a KernelSU-Next manager APK after flashing the kernel:
- [rifsxd/KernelSU-Next releases](https://github.com/rifsxd/KernelSU-Next/releases) (spoofed builds recommended)

## Why `legacy_susfs`?

The official `dev` branch dropped support for kernel 5.4 (SELinux policy patching and seccomp disabling). The `legacy_susfs` branch retains native 5.4 compatibility — no compat hacks needed.

## Credits

- **zerofrip** — Spacewar kernel source with SUSFS patches & AnyKernel3 config
- **NothingOSS** — Original kernel source
- **KernelSU-Next** — Root framework
- **simonpunk** — SUSFS
- **spike0en** — Stock boot image archive
