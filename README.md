# Nothing Phone (1) — Custom Kernel with Root & Root Hiding

Ready-to-flash kernel for **Nothing Phone (1) Spacewar** on **NOS 3.2** with full root and root hiding out of the box.

> [!WARNING]
> **Flash at your own risk.** Always keep a backup of your stock boot image.

---

## What You Get

- **KernelSU-Next** — modern kernel-based root
- **SUSFS v2.0.0** — hide root at the kernel level
- **Full root hiding stack** — pass banking apps, Google Play Integrity, and root detectors

---

## Quick Start

### Step 1 — Flash the Kernel

Download from the [Releases](https://github.com/dracediax/Spacewar-KernelSU-Next/releases) page.

**Option A — Fastboot (recommended):**
```
fastboot flash boot boot.img
```

**Option B — Already rooted:**
Flash the `Spacewar_NOS3.2_KernelSU-Next_*.zip` via recovery or a kernel manager app.

> **Need temporary root first?** Get a Magisk-patched boot.img from the
> [XDA Nothing Phone 1 repo](https://xdaforums.com/t/nothing-phone-1-repo-nos-ota-img-guide-root.4464039/#post-87101175).

### Step 2 — Install the Manager

Install [KernelSU-Next Manager](https://github.com/KernelSU-Next/KernelSU-Next/releases) (v3.1.0+, spoofed or non-spoofed).

---

## Root Hiding Setup

Install these modules **in order** through the KernelSU-Next manager (Modules → Install from storage). **Reboot after each one.**

| # | Module | Download |
|---|--------|----------|
| 1 | **SUSFS for KSU** | [Latest release](https://github.com/sidex15/susfs4ksu-module/releases) |
| 2 | **ReZygisk** | [Latest release](https://github.com/PerformanC/ReZygisk/releases) |
| 3 | **LSPosed IT** | [`LSPosed-v1.9.2-it-7455`](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/download/v1.0.1/LSPosed-v1.9.2-it-7455-release.zip) ⚠️ **Only this version works** |

### Activate HMA-OSS

After all modules are installed and you've rebooted:

1. Install the **HMA-OSS** app on your phone
2. Open the KernelSU-Next manager → **Modules** → find **LSPosed** → tap the **action button** to open LSPosed
3. In LSPosed → **Modules** → tap **HMA-OSS** → enable it → check **System Framework**
4. **Reboot**

### Import the Config

Download [`HMA-OSS_config.json`](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/download/v1.0.1/HMA-OSS_config.json) to your phone, then:

1. Open HMA-OSS — verify it shows **"Module Activated"** and **"System service running"**
2. Tap **Restore config** at the bottom
3. Select the downloaded `HMA-OSS_config.json`

Done — root is now hidden from detection apps, banking apps, and Play Integrity checks.

---

## Build From Source

```bash
git clone https://github.com/dracediax/Spacewar-KernelSU-Next.git
cd Spacewar-KernelSU-Next
chmod +x UpdateAndRelease.sh
./UpdateAndRelease.sh
```

Everything downloads automatically on first run. Output goes to `output/`.

## Sources

| Component | Repository | Branch |
|---|---|---|
| Kernel | [NothingOSS/android_kernel_msm-5.4_nothing_sm7325](https://github.com/NothingOSS/android_kernel_msm-5.4_nothing_sm7325) | `sm7325/v/mr` |
| KernelSU-Next | [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) | `legacy_susfs` |
| SUSFS | Patched into kernel at build time | v2.0.0 |
| AnyKernel3 | [zerofrip/AnyKernel3](https://github.com/zerofrip/AnyKernel3) | `spacewar_nos3.0` |
| Stock boot images | [spike0en/nothing_archive](https://github.com/spike0en/nothing_archive) | — |

## Credits

- **NothingOSS** — Official kernel source
- **KernelSU-Next** — Root framework
- **simonpunk** — SUSFS
- **zerofrip** — AnyKernel3 config for Spacewar
- **spike0en** — Stock boot image archive
