<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/nothing_logo_white.png">
    <source media="(prefers-color-scheme: light)" srcset="https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Nothing.svg/200px-Nothing.svg.png">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Nothing.svg/200px-Nothing.svg.png" width="140" alt="Nothing">
  </picture>
</p>

<h1 align="center">Phone (1) — Kernel Builder</h1>

<p align="center">
  <strong>Automatic & custom kernel builds with KernelSU-Next · SUSFS · full root hiding</strong>
</p>

<p align="center">
  <a href="https://github.com/dracediax/Spacewar-KernelSU-Next/releases"><img src="https://img.shields.io/github/v/release/dracediax/Spacewar-KernelSU-Next?style=for-the-badge&color=blue&label=Download" alt="Download"></a>
  <img src="https://img.shields.io/badge/NOS-3.2-white?style=for-the-badge" alt="NOS 3.2">
  <img src="https://img.shields.io/badge/Kernel-5.4.289-grey?style=for-the-badge" alt="Kernel">
  <img src="https://img.shields.io/badge/KernelSU--Next-v3.1.0-green?style=for-the-badge" alt="KernelSU-Next">
  <img src="https://img.shields.io/badge/SUSFS-v2.0.0-orange?style=for-the-badge" alt="SUSFS">
</p>

---

<p align="center">
  <a href="#-quick-start"><b>📦 Quick Start</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#-root-hiding-setup"><b>🔒 Root Hiding</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#%EF%B8%8F-pass-strong-play-integrity"><b>🛡️ Play Integrity</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#%EF%B8%8F-custom-build-from-source"><b>🛠️ Custom Build</b></a>
</p>

---

> [!WARNING]
> **Flash at your own risk.** Always keep a backup of your stock boot image.

## ⚡ What You Get

<table>
<tr><td>🔓</td><td><strong>KernelSU-Next</strong></td><td>Modern kernel-based root</td></tr>
<tr><td>🛡️</td><td><strong>SUSFS v2.0.0</strong></td><td>Kernel-level root hiding</td></tr>
<tr><td>🏦</td><td><strong>Root hiding stack</strong></td><td>Pass banking apps, Play Integrity, root detectors</td></tr>
<tr><td>📦</td><td><strong>Vendor modules</strong></td><td>Audio, camera, display, BT — all included</td></tr>
<tr><td>🔐</td><td><strong>vbmeta.img</strong></td><td>Pre-patched stock vbmeta — disables dm-verity so partition props don't need spoofing</td></tr>
</table>

---

## 🚀 Quick Start

### Flash the Kernel

> [!NOTE]
> **Always flash `vbmeta.img` alongside the kernel.** This disables dm-verity at the bootloader level so the `partition.system.verified` / `partition.vendor.verified` props report correctly on their own — no spoof module needed. Without it those props expose the custom kernel to detection apps and banking apps.

<details>
<summary><strong>Option A — Fastboot (recommended)</strong></summary>

```
fastboot flash boot boot.img
fastboot flash vbmeta_a vbmeta.img
fastboot flash vbmeta_b vbmeta.img
fastboot reboot
```

</details>

<details>
<summary><strong>Option B — Already rooted (AnyKernel3 zip)</strong></summary>

Flash `Spacewar_NOS3.2_KernelSU-Next_*.zip` via recovery or a kernel manager app, then from fastboot:

```
fastboot flash vbmeta_a vbmeta.img
fastboot flash vbmeta_b vbmeta.img
fastboot reboot
```

</details>

<details>
<summary><strong>Need temporary root first?</strong></summary>

Grab a Magisk-patched boot.img for your NOS version from the
[XDA Nothing Phone 1 repo](https://xdaforums.com/t/nothing-phone-1-repo-nos-ota-img-guide-root.4464039/#post-87101175).

</details>

Then install [**KernelSU-Next Manager**](https://github.com/KernelSU-Next/KernelSU-Next/releases) (v3.1.0+).

---

## 🔒 Root Hiding Setup

Install modules **in order** through the KernelSU-Next manager.<br>
**⟳ Reboot after each one.**

| Step | Module | Download |
|:----:|--------|----------|
| **1** | SUSFS for KSU | [📥 Latest release](https://github.com/sidex15/susfs4ksu-module/releases) |
| **2** | ReZygisk | [📥 Latest release](https://github.com/PerformanC/ReZygisk/releases) |
| **3** | DM-Verity Props Spoof | [📥 v1.1](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/latest/download/dmverity-props-spoof-v1.1.zip) — **skip if you flashed `vbmeta.img`** |
| **4** | LSPosed IT | [📥 v1.9.2-7455](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/latest/download/LSPosed-v1.9.2-it-7455-release.zip) ⚠️ **Only this version works** |

### Configure SUSFS

Open the **susfs4ksu** module settings (KSU manager → Modules → susfs4ksu → action button) and enable:

- ✅ Hide sus mounts for all non-su processes
- ✅ Auto try umount (userspace)
- ✅ Spoof cmdline
- ✅ Hide KSU loop
- ✅ AVC log spoofing
- ✅ Spoof kernel version → set to `5.4.289-qgki-g0297a1324ba1`
- ✅ Spoof kernel build → tap **Set Stock Kernel Build Date**
- ✅ Spoof on boot / Execute on post-fs-data

Then tap **Make it sus** and reboot.

> The kernel version string is printed after every build. Use it for the spoof value.

### Activate HMA-OSS

> Install the [HMA-OSS](https://github.com/frknkrc44/HMA-OSS/releases) app first.

1. KernelSU-Next manager → **Modules** → **LSPosed** → tap the **action button**
2. In LSPosed → **Modules** → **HMA-OSS** → enable → check **System Framework**
3. **⟳ Reboot**

### Import HMA-OSS Config

> Download [`HMA-OSS_config.json`](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/latest/download/HMA-OSS_config.json) to your phone.

1. Open HMA-OSS — confirm **"Module Activated"** and **"System service running"**
2. Tap **Restore config** → select the downloaded file

✅ **Done** — root is hidden from common detection apps.

<details>
<summary><strong>Manually hide a specific app</strong></summary>

<br>

If an app isn't covered by the config, you can add it manually:

1. Open HMA-OSS → **Manage apps**
2. Find and tap the app you want to hide root from
3. Toggle **Enable hide** ON
4. **Template config** → enable **HIDE MY CUSTOM APP**
5. **Using presets** → check all 6:
   - Custom ROM apps · Detector/Checker apps · Root managers/Rooted apps
   - Shizuku/Dhizuku apps · Suspicious apps · LSPosed/Xposed modules
6. **Settings presets** → check all 3:
   - Accessibility · Developer options · Input method

</details>

---

## 🛡️ Pass Strong Play Integrity

Want to pass **MEETS_STRONG_INTEGRITY**? Install these modules after completing the root hiding setup above.

Install **in order** through the KernelSU-Next manager. **⟳ Reboot after each one.**

| Step | Module | Download |
|:----:|--------|----------|
| **1** | Play Integrity Fix | [📥 Latest release](https://github.com/KOWX712/PlayIntegrityFix/releases) |
| **2** | TrickyStore | [📥 Latest release](https://github.com/KernelSU-Modules-Repo/tricky_store/releases) |
| **3** | Tricky Addon | [📥 Latest release](https://github.com/KOWX712/Tricky-Addon-Update-Target-List/releases) |
| **4** | YuriKey | [📥 Latest release](https://github.com/Yurii0307/yurikey/releases) |

### Get Your Keybox

After installing all 4 modules and rebooting:

1. KernelSU-Next manager → **Modules** → **YuriKey** → tap the **action button**
2. YuriKey fetches a valid keybox automatically — no manual setup needed

> **Keeping it working:** When YuriKey gets an update, install the new version, then press the action button again to refresh the keybox.

✅ **Done** — your device now passes Strong Play Integrity.

---

## 🛠️ Custom Build From Source

```bash
git clone https://github.com/dracediax/Spacewar-KernelSU-Next.git
cd Spacewar-KernelSU-Next && chmod +x SpacewarKernelBuilder.sh && ./SpacewarKernelBuilder.sh
```

The builder runs in **interactive mode** — it walks you through picking your NOS version, firmware build, and KernelSU version. Just follow the prompts.

Everything downloads automatically on first run. Output goes to `output/`.

<details>
<summary><strong>🎛️ Advanced — CLI options for scripting</strong></summary>

<br>

```bash
# Skip interactive menu, build with defaults
./SpacewarKernelBuilder.sh --auto

# Build for a specific firmware + KSU version
./SpacewarKernelBuilder.sh --stock-tag Spacewar_V3.2-260206-1016 --ksu-tag v3.1.0-legacy-susfs

# Build for NOS 2.6
./SpacewarKernelBuilder.sh --kernel-branch sm7325/u/mr --stock-tag Spacewar_U2.6-241031-1818

# Clean build
./SpacewarKernelBuilder.sh --clean
```

Run `./SpacewarKernelBuilder.sh --help` for all options.

</details>

<details>
<summary>Sources</summary>

| Component | Repository | Branch |
|---|---|---|
| Kernel | [NothingOSS/android_kernel_msm-5.4_nothing_sm7325](https://github.com/NothingOSS/android_kernel_msm-5.4_nothing_sm7325) | `sm7325/v/mr` |
| KernelSU-Next | [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) | `legacy_susfs` |
| SUSFS | Patched into kernel at build time | v2.0.0 |
| AnyKernel3 | [zerofrip/AnyKernel3](https://github.com/zerofrip/AnyKernel3) | `spacewar_nos3.0` |
| Stock boot | [spike0en/nothing_archive](https://github.com/spike0en/nothing_archive) | — |

</details>

<details>
<summary>Why <code>legacy_susfs</code>?</summary>

The official KernelSU-Next `dev` branch dropped kernel 5.4 support. The `legacy_susfs` branch keeps native 5.4 compatibility with SELinux and seccomp support.

</details>

---

<p align="center">
  <strong>Credits:</strong> NothingOSS · KernelSU-Next · simonpunk (SUSFS) · zerofrip (AK3) · spike0en (boot images)
</p>
