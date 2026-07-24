# ULPSDISABLER

A lightweight, fully modular PowerShell utility designed to detect and disable AMD **ULPS** (*Ultra Low Power State*). ULPS is an AMD driver power-saving feature that can frequently cause system stutters, black screens, long boot times, or secondary GPU responsiveness issues.

---

## ✨ Key Features

* **Automatic Language Detection**: Native support for **English**, **Portuguese (pt-BR)**, **Spanish**, and **Simplified Chinese**. Defaults to English if the system culture isn't matched.
* **Auto Admin Elevation**: Automatically detects privilege levels and re-launches with Administrator rights if needed.
* **Registry Safety Verification**: Safely checks for valid AMD GPU registry paths (`EnableUlps` / `EnableUlps_NA`) before making any modifications.
* **Interactive Prompts**: Gives you full control by confirming before changing registry values and before performing a system reboot.
* **Zero-Installation Web Execution**: Can be run directly from the PowerShell terminal without saving local files.

---

## 🚀 One-Line Execution Command

Open **PowerShell** and run:

```powershell
iwr -useb "[https://raw.githubusercontent.com/Khotyz/ULPSDISABLER/main/Disable-ULPS.ps1](https://raw.githubusercontent.com/Khotyz/ULPSDISABLER/main/Disable-ULPS.ps1)" | iex
