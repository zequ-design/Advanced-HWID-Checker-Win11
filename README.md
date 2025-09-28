# Advanced-HWID-Checker-Win11

**Advanced Interactive HWID Checker for Windows 11** – a visual and interactive PowerShell tool that collects detailed hardware information and generates a unique HWID (SHA-256). Designed to run in a console with colors and structured sections. All collected data can be saved to TXT or JSON files, and the HWID is automatically copyable to the clipboard.

---

## Features

- Fully interactive menu:
  - Show Full Hardware Info
  - Show HWID Only
  - Save to TXT file
  - Save to TXT + JSON file
  - Copy HWID to Clipboard
  - Exit
- Collects detailed hardware info:
  - CPU, GPU, RAM, BIOS, Motherboard
  - Network info (MAC & IP addresses)
  - Windows OS details (name, version, architecture, build)
- Generates a secure HWID (SHA-256) based on system identifiers.
- Animated loader during hardware info collection.
- Color-coded, visually structured console output.
- Works specifically on **Windows 11**.
- Saves info to `hwid.txt` and optionally `hwid.json`.

---

## Requirements

- Windows 11
- PowerShell 5.1 or higher
- Administrator privileges recommended

---

## Installation & Usage

1. **Download the script** `./Get-HWID.ps1` into a folder.  
2. **Open PowerShell as Administrator**.  
3. **Allow script execution** (if blocked by default policy):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
