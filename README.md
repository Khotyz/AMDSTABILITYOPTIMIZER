# AMD STABILITY OPTIMIZER

A lightweight, fully modular PowerShell utility featuring a modern **Windows 11 dark-themed graphical interface (WPF)** designed to maximize stability, performance, and reliability on AMD Radeon Graphics setups. It combines nine targeted optimizations—covering power management, driver responsiveness, display protection, background telemetry, hardware acceleration, and system performance—behind a safe, intelligent interface.

---

## ✨ Key Features

* **Modern Windows 11 WPF Dark UI**: Sleek, responsive, dark-themed UI built with native WPF—no external dependencies, frameworks, or installation required.
* **9 Independent Optimization Modules**:
1. **ULPS (Ultra Low Power State)**: Prevents the GPU from entering unstable low-power states on multi-GPU or hybrid setups.
2. **MPO (Multi-Plane Overlay)**: Disables MPO to eliminate flickering, stuttering, and black-screen issues in games and desktop apps.
3. **TDR Delay**: Increases driver timeout thresholds to prevent Windows from prematurely resetting an unresponsive GPU during heavy loads.
4. **Fast Startup & Hibernation**: Disables Fast Startup and Hibernation to prevent driver state corruption across system shutdowns and reboots.
5. **AMD Crash Defender**: Disables the AMD Crash Defender service, preventing it from masking underlying GPU driver crashes with automated recoveries.
6. **HDCP (High-bandwidth Digital Content Protection)**: Disables HDCP in the AMD driver to resolve display disconnects, black screens, and signal dropouts on incompatible monitors/cables.
7. **AMD Telemetry**: Disables AMD background telemetry services (*External Events* and *User Experience*), reducing idle background processes and CPU overhead.
8. **Hardware Acceleration Fix (Browsers/Electron)**: Fixes crashes, black screens, and flickering in Chromium browsers (Chrome, Edge) and Electron applications (Discord, Spotify) by enforcing ANGLE OpenGL rendering and HAGS tuning.
9. **Ultimate Performance Power Plan**: Unlocks and activates Windows' hidden *Ultimate Performance* power plan, minimizing CPU and PCIe power-state switching latencies.


* **Automated Safety & Backups**: Automatically attempts to create a **System Restore Point** and exports `.reg` backups of all targeted registry subkeys before applying any modifications.
* **Auto Admin Elevation**: Automatically detects execution privileges and elevates to Administrator rights via standard UAC prompt or Base64-encoded online launch sequence.
* **Multi-Language Support & Auto-Detection**: Native, encoding-safe UI translations for **English (en-US)**, **Portuguese (pt-BR)**, **Spanish (es-ES)**, and **Simplified Chinese (zh-CN)**, automatically selecting your OS language with manual switching available.
* **Zero-Installation Direct Launch**: Can be downloaded and executed on-the-fly directly from PowerShell.

---

## 🚀 One-Line Execution Command

Open **PowerShell** (as Administrator or regular user) and run:

```powershell
iwr -useb "https://raw.githubusercontent.com/Khotyz/AMDSTABILITYOPTIMIZER/main/AMD-Stability-Optimizer.ps1" | iex

```

> **Note**: This fetches and launches the latest script directly in memory. If not already running elevated, it will automatically prompt for Administrator privileges and re-launch.

---

## 🛠️ Manual Usage

1. Download [`AMD-Stability-Optimizer.ps1`](https://www.google.com/search?q=https://github.com/Khotyz/AMDSTABILITYOPTIMIZER/blob/main/AMD-Stability-Optimizer.ps1).
2. Right-click the `.ps1` file and select **Run with PowerShell**.
3. Accept the Administrator UAC prompt if requested.
4. Use the interface to toggle individual modules or click **Apply All Fixes** / **Revert All (Restore Defaults)**.

---

## ⚙️ How the Modules Work

| Module | Technical Mechanism |
| --- | --- |
| **ULPS** | Modifies `EnableUlps` and `EnableUlps_NA` keys across GPU device class instances (`HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}`). |
| **MPO** | Sets `OverlayTestMode = 5` under `HKLM:\SOFTWARE\Microsoft\Windows\Dwm`. |
| **TDR Delay** | Sets `TdrDelay = 10` and `TdrDdiDelay = 10` under `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`. |
| **Fast Startup** | Disables hibernation via `powercfg /h off` and sets `HiberbootEnabled = 0` under `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power`. |
| **Crash Defender** | Dynamically locates the AMD Crash Defender service, stops it, and sets its startup type to Disabled (`Start = 4`). |
| **HDCP** | Sets `DAL2_DisableHDCP = 1` across all active AMD GPU device registry instances. |
| **Telemetry** | Stops and disables `AMD External Events` and `AMD User Experience` services (`Start = 4`). |
| **Hardware Accel** | Sets ANGLE graphics backend policy (`UseAngle = opengl`) for Chrome and Edge while adjusting hardware scheduling parameters. |
| **Ultimate Power** | Unlocks duplicate scheme `e9a42b02-d5df-448d-aa00-03f14749eb61` and sets it as the active Windows power plan. |

---

## ⚠️ Requirements & Notes

* **System Requirements**: Windows 10 / 11, PowerShell 5.1+, Administrator privileges.
* **System Restart**: A restart is recommended after applying changes for driver and registry modifications to take full effect.
* **Safety & Recovery**: Backups are stored under `%ProgramData%\AMD-Stability-Optimizer\Backups`. If System Protection is disabled, the Restore Point step completes with a warning and registry backups are preserved.

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.
