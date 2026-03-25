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
   Or flash `Spacewar_NOS3.2_KernelSU-Next_v*.zip` via custom recovery, or with a kernel manager app (Franco Kernel Manager, SmartPack) if already rooted.

   > **Need temporary root?** Grab a Magisk-patched boot.img for your NOS version from the
   > [XDA Nothing Phone 1 repo](https://xdaforums.com/t/nothing-phone-1-repo-nos-ota-img-guide-root.4464039/#post-87101175) — make sure to pick the correct firmware version.
3. Install [KernelSU-Next Manager](https://github.com/KernelSU-Next/KernelSU-Next/releases) (v3.1.0 or later, spoofed or non-spoofed both work)

## Root Hiding Setup

After flashing the kernel and installing the KernelSU-Next manager, install modules **in this order** (reboot after each):

### 1. SUSFS for KSU

Download from [sidex15/susfs4ksu](https://github.com/sidex15/susfs4ksu) — branch `1.5.2+`, use the `release-1.5.2+` artifact.

Install via KernelSU-Next manager → Modules → Install from storage.

**Reboot.**

### 2. ReZygisk

Download the latest release from [PerformanC/ReZygisk](https://github.com/PerformanC/ReZygisk/releases).

Install via KernelSU-Next manager → Modules → Install from storage.

**Reboot.**

### 3. LSPosed (IT)

> **Important:** Use specifically **LSPosed IT v1.9.2 (7455)** from [liviafontes/LSPosed](https://github.com/liviafontes/LSPosed/releases). Other versions may not work correctly.

Install via KernelSU-Next manager → Modules → Install from storage.

**Reboot.**

### 4. HMA-OSS (Hide My Applist)

Install HMA-OSS on your device. Then activate it:

1. Open the KernelSU-Next manager
2. Go to **Superuser** → grant root to **Shell** (if not already)
3. Open a terminal (Termux or adb shell) and run:
   ```
   su -c 'am start -n org.lsposed.manager/.activity.MainActivity'
   ```
   This opens the LSPosed manager.
4. Go to **Modules** → tap on **HMA-OSS**
5. Enable the module and check **System Framework** in the scope
6. **Reboot.**

HMA-OSS should now show "Module Activated" and "System service running".

### 5. Configure HMA-OSS

You can either restore a config backup or set it up manually per app.

**Option A — Restore a config backup:**

1. Open HMA-OSS → tap **Restore config** at the bottom
2. Select a previously exported `.json` config file from your downloads

**Option B — Manual per-app setup:**

1. Open HMA-OSS → tap **Manage apps**
2. Select the app you want to hide root from (e.g. a banking app, Duck Detector, etc.)
3. Toggle **Enable hide** ON
4. Tap **Template config** → select a template (e.g. "HIDE MY CUSTOM APP")
5. Go back and tap **Using X presets** → check all relevant categories:
   - Custom ROM apps
   - Detector/Checker apps
   - Root managers/Rooted apps
   - Shizuku/Dhizuku apps
   - Suspicious apps
   - LSPosed/Xposed modules
6. Tap **Using X settings presets** → check:
   - Accessibility
   - Developer options
   - Input method

Repeat for each app you want to hide root from. No reboot needed after configuring apps — changes take effect immediately.

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
