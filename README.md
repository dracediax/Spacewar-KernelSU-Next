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
  <a href="#-quick-start"><b>📦 Quick Start</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#-root-hiding--integrity-setup"><b>🔒 Root Hiding & Integrity</b></a>&nbsp;&nbsp;·&nbsp;&nbsp;<a href="#%EF%B8%8F-custom-build-from-source"><b>🛠️ Custom Build</b></a>
</p>

---

> [!WARNING]
> **Flash at your own risk.** Always keep a backup of your stock boot image.

## ⚡ What You Get

<table>
<tr><td>🔓</td><td><strong>KernelSU-Next</strong></td><td>Modern kernel-based root</td></tr>
<tr><td>🛡️</td><td><strong>SUSFS v2.0.0</strong></td><td>Kernel-level root hiding</td></tr>
<tr><td>🏦</td><td><strong>Root hiding stack</strong></td><td>Pass banking apps, Play Integrity, root detectors</td></tr>
</table>

---

## 🚀 Quick Start

### Flash the Kernel

> [!NOTE]
> **Always flash `vbmeta.img` alongside the kernel.**
>
> ⚠️ **Use [platform-tools r34.0.4](https://dl.google.com/android/repository/platform-tools_r34.0.4-windows.zip)** — newer versions have a bug parsing the vbmeta image and will error with `Failed to find AVB_MAGIC`.

```
fastboot flash boot boot.img
fastboot flash vbmeta_a --disable-verity --disable-verification vbmeta.img
fastboot flash vbmeta_b --disable-verity --disable-verification vbmeta.img
fastboot reboot
```

Then install [**KernelSU-Next Manager**](https://github.com/KernelSU-Next/KernelSU-Next/releases) (v3.1.0+).

---

## 🔒 Root Hiding & Integrity Setup

Install modules **in order** through the KernelSU-Next manager, then reboot.

| Step | Module | Download |
|:----:|--------|----------|
| **1** | SUSFS for KSU | [📥 Latest release](https://github.com/sidex15/susfs4ksu-module/releases) |
| **2** | Vector (LSPosed) | [📥 Latest release](https://github.com/JingMatrix/Vector/releases) |
| **3** | ZygiskNext | [📥 Latest release](https://github.com/Dr-TSNG/ZygiskNext/releases) |
| **4** | TeeSimulator-RS | [📥 Latest release](https://github.com/Enginex0/TEESimulator-RS/releases) |
| **5** | Tricky Addon | [📥 Latest release](https://github.com/KOWX712/Tricky-Addon-Update-Target-List/releases) |
| **6** | YuriKey | [📥 Latest release](https://github.com/Yurii0307/yurikey/releases) |
| **7** | NoHello | [📥 Latest release](https://github.com/MhmRdd/NoHello/releases) |

> Steps 5 and 7 require no configuration — install and continue.

---

### 1 · Configure SUSFS

Open the **susfs4ksu** module settings (KSU manager → Modules → susfs4ksu → action button) and enable:

- ✅ **Auto try unmount (userspace)**
- ✅ **Hide sus_mounts** — for all processes / non-su processes
- ✅ **Turn off after boot-completed**

Under **Custom SUSFS Settings** enable:

- ✅ Spoof cmdline
- ✅ Hide KSU loop
- ✅ AVC log spoofing
- ✅ Hide vendor sepolicy
- ✅ Hide compat matrix

Under **Custom SUS Feature → Custom SUS Path**, paste all paths at once and tap **Make it sus**:

```
/proc/*/maps
/proc/*/smaps
/proc/*/status
/proc/*/task/*/status
/sys/fs/selinux
```

---

### 2 · Activate Vector (LSPosed)

> Install the [HMA-OSS](https://github.com/frknkrc44/HMA-OSS/releases) app first.

1. KernelSU-Next manager → **Modules** → **Vector** → tap the **action button**
2. In Vector → **Modules** → **HMA-OSS** → enable → check **System Framework**
3. **⟳ Reboot if necessary**

---

### 3 · Configure ZygiskNext

1. KernelSU-Next manager → **Modules** → **ZygiskNext** → tap the **action button** to open the WebUI
2. Set **Denylist policy** → **Unmount only**
3. Toggle on:
   - ✅ Use anonymous memory
   - ✅ Use Zygisk Next Linker

---

### 4 · Configure TeeSimulator-RS

1. KernelSU-Next manager → **Modules** → **TeeSimulator-RS** → tap the **action button** to open the WebUI
2. Toggle **on** every app that root needs to be hidden from. Typical apps to hide from:
   - Android System Key Verifier
   - Android System SafetyCore
   - Carrier Services
   - Google Play Services
   - Google Play Store
   - Google Services Framework
   - Google Wallet
3. If you have detector apps installed (e.g. YASNAC, Native Detector, DUCK Detector), toggle those on as well.

---

### 6 · Configure YuriKey

1. KernelSU-Next manager → **Modules** → **YuriKey** → tap the **action button**
2. Go to **Menu** and run these scripts in order:
   - Set up Yuri Keybox
   - Force stop & clear data Play Store
   - Set up target.txt — only set necessary apps
   - Set up security patch
   - Set up verified boot hash
3. Go to **Menu+** and run:
   - Clear all detection traces
   - Set HMA-OSS configs

---

### FuseFixer (if needed)

If a detector reports a **FUSE error**, install **FuseFixer** — shared via Telegram. This is the last thing to install.

**⟳ Reboot.**

✅ **Done** — root is hidden and your device passes Strong Play Integrity.

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
