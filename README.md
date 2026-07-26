# AMD STABILITY OPTIMIZER

A lightweight, fully modular PowerShell utility with a modern **Windows 11 style graphical interface** designed to improve stability on AMD Radeon GPUs (RDNA2 and newer). It brings together four proven registry and power tweaks — **ULPS**, **MPO**, **TDR Delay**, and **Fast Startup/Hibernation** — behind a single, safe, one-click toggle for each fix.

---

## ✨ Key Features

* **Modern Dark UI**: Clean, Windows 11 inspired interface built with native WPF — no third-party dependencies, no installation required.
* **4 Independent Optimization Modules**:
  * **ULPS (Ultra Low Power State)** — prevents the GPU from dropping into an unstable low-power state on multi-GPU or hybrid setups.
  * **MPO (Multi-Plane Overlay)** — disables Multi-Plane Overlay, fixing flickering and black-screen issues in some games and apps.
  * **TDR Delay** — extends the driver timeout before Windows resets a GPU that appears unresponsive.
  * **Fast Startup & Hibernation** — disables Fast Startup and Hibernation, avoiding driver state corruption after shutdown.
* **One-Click Apply / Revert**: Each module detects its current state automatically and lets you apply or revert it individually, or apply/revert everything at once.
* **Automatic Language Detection**: Native support for **English**, **Portuguese (pt-BR)**, **Spanish**, and **Simplified Chinese**. Defaults to English if the system culture isn't matched, with a manual language switcher always available.
* **Auto Admin Elevation**: Automatically detects privilege levels and re-launches with Administrator rights if needed.
* **Built-in Safety Backup**: Before any change, the tool attempts to create a **System Restore Point** and always exports `.reg` backups of every affected registry key.
* **Zero-Installation Web Execution**: Can be run directly from the PowerShell terminal without saving local files.

---

## 🚀 One-Line Execution Command

Open **PowerShell** and run:

```powershell
iwr -useb "https://raw.githubusercontent.com/Khotyz/AMDSTABILITYOPTIMIZER/main/AMD-Stability-Optimizer.ps1" | iex
```

This downloads and launches the tool directly in memory — no files are saved to disk, and the app will prompt for Administrator rights automatically if needed.

---

## 🛠️ Manual Usage

1. Download [`AMD-Stability-Optimizer.ps1`](https://github.com/Khotyz/AMDSTABILITYOPTIMIZER/blob/main/AMD-Stability-Optimizer.ps1).
2. Right-click the file and select **Run with PowerShell**.
3. Approve the User Account Control (UAC) prompt to allow Administrator access.
4. Use the interface to apply or revert each optimization, or use **Apply All Fixes** / **Revert All** for a one-click setup.

---

## ⚠️ Notes

* A system restart is recommended after applying changes for them to take full effect.
* If System Protection is disabled, the Restore Point step is skipped automatically and the tool falls back to registry-only backups, so your original settings are always recoverable.

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.
