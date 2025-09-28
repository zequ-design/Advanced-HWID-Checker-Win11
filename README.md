# Advanced-HWID-Checker-Win11

**Advanced HWID Checker for Windows 11** – a visual and interactive PowerShell tool that collects detailed hardware information and generates a unique HWID (SHA-256). Displayed in a structured, colorful console interface, all collected data is also saved to a text file, and the HWID is automatically copied to the clipboard for easy use.

---

## Features

- Collects full hardware info:
  - CPU, GPU, RAM, BIOS, motherboard
  - Network info (MAC addresses, IP addresses)
  - Windows OS details (name, version, build, architecture)
- Generates a secure HWID (SHA-256) based on key system identifiers.
- Color-coded, visually structured console output.
- Saves all information to `hwid.txt`.
- Copies HWID to clipboard for quick use.
- Specifically tested and optimized for **Windows 11**.

---

## Requirements

- Windows 11
- PowerShell 5.1 or higher (comes with Windows 11)
- Administrator privileges recommended

---

## Usage

1. Open PowerShell as Administrator.
2. Allow script execution if blocked:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
