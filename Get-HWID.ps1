# =================================================
# Interactive Advanced HWID Checker for Windows 11 (PS 5.1 compatible)
# =================================================

function Get-SHA256Hex {
    param([string]$InputString)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha.ComputeHash($bytes)
    return ($hash | ForEach-Object { $_.ToString("x2") }) -join ""
}

function Show-Loader {
    Write-Host "Collecting hardware info" -NoNewline
    for ($i=0; $i -lt 3; $i++) {
        Start-Sleep -Milliseconds 300
        Write-Host "." -NoNewline
    }
    Write-Host ""
}

function Collect-HardwareInfo {
    # --- Collect hardware info ---
    $computer = Get-CimInstance Win32_ComputerSystem
    $smbios = (Get-CimInstance Win32_ComputerSystemProduct).UUID
    $motherboard = (Get-CimInstance Win32_BaseBoard).Manufacturer + " " + (Get-CimInstance Win32_BaseBoard).Product

    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $cpuName = $cpu.Name
    $cpuId = $cpu.ProcessorId
    $cpuCores = $cpu.NumberOfCores
    $cpuLogical = $cpu.NumberOfLogicalProcessors

    $gpuObjects = Get-CimInstance Win32_VideoController
    $gpuNamesArray = $gpuObjects | ForEach-Object { $_.Name }
    $gpuNames = $gpuNamesArray -join ', '
    $gpuTypesArray = $gpuObjects | ForEach-Object { if ($_.AdapterRAM -gt 0) {"Discrete"} else {"Integrated"} }
    $gpuTypes = $gpuTypesArray -join ', '

    $ramObjects = Get-CimInstance Win32_PhysicalMemory
    $ramSerialsArray = $ramObjects | ForEach-Object { $_.SerialNumber }
    $ramSerials = $ramSerialsArray -join ', '
    $totalRAM = ($ramObjects | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $totalRAM = [math]::Round($totalRAM,2)

    $biosSN = (Get-CimInstance Win32_BIOS).SerialNumber

    $macsArray = (Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.MACAddress -ne $null }).MACAddress
    $macs = $macsArray -join ', '

    $ipObjects = (Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null })
    $ipArray = @()
    foreach ($obj in $ipObjects) {
        $ipArray += $obj.IPAddress
    }
    $ips = $ipArray -join ', '

    $os = Get-CimInstance Win32_OperatingSystem
    $osCaption = $os.Caption
    $osVersion = $os.Version
    $osArchitecture = $os.OSArchitecture
    $osBuild = $os.BuildNumber
    $osNameFull = "$osCaption $osVersion [$osArchitecture] Build: $osBuild"

    # --- Combine data for HWID ---
    $allParts = @($smbios, $cpuId, $macs, $biosSN)
    $allData = ($allParts | Where-Object { $_ -and $_ -ne "" }) -join "|"
    $hwid = Get-SHA256Hex $allData

    # --- Prepare sections ---
    $sections = @(
        @{ Title="SYSTEM"; Content=@(
            "SMBIOS UUID : $smbios",
            "Manufacturer : $computer.Manufacturer",
            "Model : $computer.Model",
            "Motherboard : $motherboard"
        )},
        @{ Title="CPU"; Content=@(
            "Name : $cpuName",
            "ID : $cpuId",
            "Cores : $cpuCores",
            "Logical Processors : $cpuLogical"
        )},
        @{ Title="GPU"; Content=@(
            "Name(s) : $gpuNames",
            "Type(s) : $gpuTypes"
        )},
        @{ Title="RAM"; Content=@(
            "Serial(s) : $ramSerials",
            "Total RAM (GB) : $totalRAM"
        )},
        @{ Title="BIOS"; Content=@(
            "Serial Number : $biosSN"
        )},
        @{ Title="NETWORK"; Content=@(
            "MAC Address(es) : $macs",
            "IP Address(es) : $ips"
        )},
        @{ Title="OS"; Content=@(
            "OS Name: $osCaption",
            "Full Info : $osNameFull"
        )},
        @{ Title="HWID"; Content=@(
            "HWID (SHA256) : $hwid"
        )}
    )
    return $sections, $hwid
}

# --- Main loop ---
Show-Loader
$sections, $hwid = Collect-HardwareInfo

do {
    Write-Host ""
    Write-Host "=================== Advanced HWID Checker ===================" -ForegroundColor Cyan
    Write-Host "Select an option:" -ForegroundColor Cyan
    Write-Host "1. Show Full Info" -ForegroundColor Yellow
    Write-Host "2. Show HWID Only" -ForegroundColor Yellow
    Write-Host "3. Save to TXT" -ForegroundColor Yellow
    Write-Host "4. Save to TXT + JSON" -ForegroundColor Yellow
    Write-Host "5. Copy HWID to Clipboard" -ForegroundColor Yellow
    Write-Host "6. Exit" -ForegroundColor Yellow

    $choice = Read-Host "Enter number (1-6)"

    switch ($choice) {
        1 {
            Clear-Host
            Write-Host ("="*80) -ForegroundColor Cyan
            $header = "ADVANCED HWID CHECKER"
            $padding = [math]::Floor((80 - $header.Length)/2)
            Write-Host (" " * $padding + $header) -ForegroundColor Cyan
            Write-Host ("="*80) -ForegroundColor Cyan
            Write-Host ""
            foreach ($section in $sections) {
                Write-Host ("-- " + $section.Title + " --") -ForegroundColor Green
                foreach ($line in $section.Content) {
                    Write-Host ("  " + $line) -ForegroundColor Yellow
                }
                Write-Host ""
            }
            Write-Host ("="*80) -ForegroundColor Cyan
        }
        2 {
            Write-Host "HWID (SHA256): $hwid" -ForegroundColor Magenta
        }
        3 {
            $hwidFile = Join-Path -Path $PSScriptRoot -ChildPath "hwid.txt"
            $txtOutput = @()
            foreach ($section in $sections) {
                $txtOutput += "-- $($section.Title) --"
                $txtOutput += $section.Content
                $txtOutput += ""
            }
            $txtOutput | Out-File -FilePath $hwidFile -Encoding UTF8
            Write-Host "HWID and info saved to file: $hwidFile" -ForegroundColor Green
        }
        4 {
            # Save TXT
            $hwidFile = Join-Path -Path $PSScriptRoot -ChildPath "hwid.txt"
            $txtOutput = @()
            foreach ($section in $sections) {
                $txtOutput += "-- $($section.Title) --"
                $txtOutput += $section.Content
                $txtOutput += ""
            }
            $txtOutput | Out-File -FilePath $hwidFile -Encoding UTF8

            # Save JSON
            $jsonFile = Join-Path -Path $PSScriptRoot -ChildPath "hwid.json"
            $jsonOutput = @{}
            foreach ($section in $sections) {
                $jsonOutput[$section.Title] = $section.Content
            }
            $jsonOutput | ConvertTo-Json | Out-File -FilePath $jsonFile -Encoding UTF8

            Write-Host "HWID saved to TXT: $hwidFile" -ForegroundColor Green
            Write-Host "HWID saved to JSON: $jsonFile" -ForegroundColor Green
        }
        5 {
            $hwid | Set-Clipboard
            Write-Host "HWID copied to clipboard!" -ForegroundColor Magenta
        }
        6 {
            Write-Host "Exiting..." -ForegroundColor Cyan
            break
        }
        default {
            Write-Host "Invalid choice! Please select 1-6." -ForegroundColor Red
        }
    }
} while ($true)
