<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="MiscData/nothing_logo_white.png">
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
  <a href="#-quick-start"><b>📦 Quick Start</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#-root-hiding-setup"><b>🔒 Root Hiding</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#%EF%B8%8F-build-from-source"><b>🛠️ Build From Source</b></a>
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
</table>

---

## 🚀 Quick Start

### Flash the Kernel

<details>
<summary><strong>Option A — Fastboot (recommended)</strong></summary>

```
fastboot flash boot boot.img
```

</details>

<details>
<summary><strong>Option B — Already rooted</strong></summary>

Flash the `Spacewar_NOS3.2_KernelSU-Next_*.zip` via recovery or a kernel manager app.

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
| **3** | LSPosed IT | [📥 v1.9.2-7455](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/download/v1.0.1/LSPosed-v1.9.2-it-7455-release.zip) ⚠️ **Only this version works** |

### Activate HMA-OSS

> Install the [HMA-OSS](https://github.com/AgeloVito/HMA-OSS) app first.

1. KernelSU-Next manager → **Modules** → **LSPosed** → tap the **action button**
2. In LSPosed → **Modules** → **HMA-OSS** → enable → check **System Framework**
3. **⟳ Reboot**

### Import Config

> Download [`HMA-OSS_config.json`](https://github.com/dracediax/Spacewar-KernelSU-Next/releases/download/v1.0.1/HMA-OSS_config.json) to your phone.

1. Open HMA-OSS — confirm **"Module Activated"** and **"System service running"**
2. Tap **Restore config** → select the downloaded file

✅ **Done** — root is hidden.

---

## 🛠️ Build From Source

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
