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

Install modules **in order** through the KernelSU-Next manager, then **reboot once** after all are installed.

| Step | Module | Download |
|:----:|--------|----------|
| **1** | SUSFS for KSU | [📥 Latest release](https://github.com/sidex15/susfs4ksu-module/releases) |
| **2** | Vector (LSPosed) | [📥 Latest release](https://github.com/JingMatrix/Vector/releases) |
| **3** | ZygiskNext | [📥 Latest release](https://github.com/Dr-TSNG/ZygiskNext/releases) |
| **4** | TrickyStore | [📥 Latest release](https://github.com/5ec1cff/TrickyStore/releases) |
| **5** | Tricky Addon | [📥 Latest release](https://github.com/KOWX712/Tricky-Addon-Update-Target-List/releases) |
| **6** | YuriKey | [📥 Latest release](https://github.com/Yurii0307/yurikey/releases) |

---

<details>
<summary><strong>Configure SUSFS</strong></summary>

Open the **susfs4ksu** WebUI (KSU manager → Modules → susfs4ksu → WebUI button). Enable the highlighted settings in **Auto Hide Settings**, then tap **Custom SUSFS Settings**.

<img src="assets/susfs_main.png" width="320">

In **Custom SUSFS Settings**, enable the highlighted toggles:

<img src="assets/susfs_custom.png" width="320">

Under **Custom SUS Feature → Custom SUS Path**, paste the paths and tap **Make it Sus**:

<img src="assets/susfs_paths.png" width="320">

```
/proc/*/maps
/proc/*/smaps
/proc/*/status
/proc/*/task/*/status
/sys/fs/selinux
```

</details>

---

<details>
<summary><strong>Spoof Kernel uname (SUSFS)</strong></summary>

In the SUSFS WebUI, scroll to **Kernel uname**. Enable **Spoof on Boot** and **Execute on post-fs-data**, then tap **Set Stock Kernel Build Date** to spoof the kernel build string so detectors can't fingerprint the kernel.

<img src="assets/susfs_uname.png" width="320">

</details>

---

<details>
<summary><strong>Activate Vector (LSPosed)</strong></summary>

> Install the [HMA-OSS](https://github.com/frknkrc44/HMA-OSS/releases) app first.

1. KernelSU-Next manager → **Modules** → **Vector** → tap the **WebUI button**
2. In Vector → **Modules** → **HMA-OSS** → enable → check **System Framework**
3. **⟳ Reboot if LSPosed asks — it may require one after enabling HMA-OSS**

</details>

---

<details>
<summary><strong>Configure ZygiskNext</strong></summary>

KernelSU-Next manager → **Modules** → **ZygiskNext** → **WebUI**. Set the highlighted options:

<img src="assets/zygisknext.png" width="320">

</details>

---

<details>
<summary><strong>Configure YuriKey</strong></summary>

KernelSU-Next manager → **Modules** → **YuriKey** → **WebUI** → **Menu**. Run the highlighted scripts in order:

<img src="assets/yurikey_menu.png" width="320">

Then go to **Menu+** and run the highlighted scripts:

<img src="assets/yurikey_menuplus.png" width="320">

</details>

---

<details>
<summary><strong>Configure TrickyStore</strong></summary>

**Tricky Addon** (installed alongside TrickyStore) manages `target.txt`. Open it and ensure banking apps and detectors are checked, then tap **Save**:

<img src="assets/tricky_addon.png" width="320">

</details>

---

<details>
<summary><strong>Configure HMA-OSS</strong></summary>

#### Initial setup

1. Open **HMA-OSS** → **Settings** → enable **Hide module icon in launcher**
   > To reopen it afterwards: LSPosed → Modules → HMA-OSS → cogwheel icon

#### Hide root from a banking or other app

1. **Manage Apps** → find the app → tap it → enable **Hide**
2. **Template Config** → **Use Templates** → select **Hide My Custom App**
3. Under **Using 0 Presets** — check all
4. Under **Using 0 Settings Presets** — check all

#### Make Google Wallet work

1. **Manage Templates** → **Create** → select **Whitelist** → name it (e.g. `Google Wallet`) → tap **Edit List** under *Apps Visible* → add **Google Wallet** → back out
2. **Manage Apps** → find **Google Wallet** → tap it → enable **Hide**
3. **Template Config**:
   - Enable **Work Mode: Whitelist**
   - Under **Templates** → check your whitelist template

</details>

---

<details>
<summary><strong>FuseFixer (if needed)</strong></summary>

If a detector reports a **FUSE error**, install **FuseFixer** — shared via Telegram. This is the last thing to install.

**⟳ Reboot.**

</details>

✅ **Done** — root is hidden and your device passes Strong Play Integrity.

---

### Detectors

Some detectors may report:

> `TEE: Oversized Challenge, Accepted 256B - 515B - 4096B, pruning 0/18 invalidated`

This is **informational, not a failure**. TrickyStore correctly throws a keystore2 exception for challenges over 128 bytes, which is the expected spec behaviour. Google Pay works normally.

---

## 🔄 Google Pay / GMS Full Reset

To check attestation status:

```sh
# ADB
adb shell dumpsys gservices | grep fails_attestation

# Termux
dumpsys gservices | grep fails_attestation
```

If the result shows `fails_attestation = 1` after setup or after changing your keybox, do a full clean reset:

**From a PC (ADB):**

```sh
# Wipe TrickyStore's persisted keys
adb shell su -c "rm -f /data/adb/tricky_store/persistent_keys/*"

# Clear Google Play Services and Google Wallet data
adb shell pm clear com.google.android.gms
adb shell pm clear com.google.android.apps.walletnfcrel

# Reboot
adb reboot
```

**From Termux (on-device):**

```sh
# Wipe TrickyStore's persisted keys
su -c "rm -f /data/adb/tricky_store/persistent_keys/*"

# Clear Google Play Services and Google Wallet data
su -c "pm clear com.google.android.gms"
su -c "pm clear com.google.android.apps.walletnfcrel"

# Reboot
su -c "reboot"
```

After reboot, **wait at least 60 seconds** for GMS to fully initialise before opening Google Pay. Then add your card fresh — do not re-add a previously cached card.

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
  <strong>Credits:</strong> NothingOSS · KernelSU-Next · simonpunk (SUSFS) · zerofrip (AK3) · spike0en (boot images) · 5ec1cff (TrickyStore)
</p>
