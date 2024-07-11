# Define functions for each step

function Remove-ExistingWSLPackage {
    Write-Host "Removing existing WSL package..."
    try {
        $packages = Get-AppxPackage *WindowsSubsystemForLinux* -AllUsers
        if ($packages) {
            $packages | ForEach-Object {
                Write-Host "Removing package: $($_.Name)"
                $confirmation = Read-Host "Are you sure you want to remove this package? (Y/N)"
                if ($confirmation -eq "Y" -or $confirmation -eq "y") {
                    Remove-AppxPackage -Package $_.PackageFullName -AllUsers
                } else {
                    Write-Host "Skipped removal of package: $($_.Name)"
                }
            }
        } else {
            Write-Host "No existing WSL package found."
        }
    } catch {
        Write-Error "Error removing WSL package: $_"
    }
}

function Install-WSLUpdate {
    Write-Host "Downloading and installing WSL update package..."
    try {
        $wslInstallerUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $installerPath = "$env:TEMP\wsl_update_x64.msi"
        Invoke-WebRequest -Uri $wslInstallerUrl -OutFile $installerPath -ErrorAction Stop
        Write-Host "WSL update package downloaded to: $installerPath"

        $confirmation = Read-Host "Ready to install the WSL update package. Continue? (Y/N)"
        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -NoNewWindow -Wait
            Remove-Item -Path $installerPath -Force
            Write-Host "WSL update package installed."
        } else {
            Write-Host "Installation of WSL update package cancelled."
        }
    } catch {
        Write-Error "Error installing WSL update package: $_"
    }
}

function Install-WSL {
    Write-Host "Downloading Windows Subsystem for Linux installation..."
    try {
        $distroUrl = "https://github.com/microsoft/WSL/releases/download/2.2.4/Microsoft.WSL_2.2.4.0_x64_ARM64.msixbundle"
        $distroPath = "$env:TEMP\Microsoft.WSL_2.2.4.0_x64_ARM64.msixbundle"
        Invoke-WebRequest -Uri $distroUrl -OutFile $distroPath -ErrorAction Stop
        Write-Host "Windows Subsystem for Linux installation downloaded to: $distroPath"

        $confirmation = Read-Host "Ready to install Windows Subsystem for Linux. Continue? (Y/N)"
        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            Add-AppxPackage -Path $distroPath
            Write-Host "Windows Subsystem for Linux installed."
        } else {
            Write-Host "Windows Subsystem for Linux installation cancelled."
        }
    } catch {
        Write-Error "Error installing Windows Subsystem for Linux: $_"
    }
}

function VerifyWSLStatus {
    Write-Host "Verifying Windows Subsystem for Linux status..."
    try {
        wsl --list --all -v
    } catch {
        Write-Error "Error verifying Windows Subsystem for Linux status: $_"
    }
}

function CleanUpPreviousInstallations {
    Write-Host "Cleaning up previous installations..."
    try {
        # Unregister all existing distributions
        $distributions = wsl --list --all | Select-String -Pattern "^(?<name>.+)\s+\(.*\)$" | ForEach-Object { $_.Matches.Groups["name"].Value }
        foreach ($distro in $distributions) {
            Write-Host "Unregistering distribution: $distro"
            wsl --unregister $distro
        }

        # Remove WSL-related folders
        $packagesPath = "$env:LOCALAPPDATA\Packages"
        Get-ChildItem -Path $packagesPath -Filter "CanonicalGroupLimited.Ubuntu_*" -Recurse | Remove-Item -Recurse -Force

        # Remove WSL-related registry entries
        Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -Recurse -Force
    } catch {
        Write-Error "Error during clean-up: $_"
    }
    Write-Host "Clean-up complete. Please restart your computer."
}

function Select-AvailableWSLDistribution {
    Write-Host "Fetching available WSL distributions..."
    try {
        $wslListUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_list.json"
        $wslList = Invoke-RestMethod -Uri $wslListUrl -ErrorAction Stop

        Write-Host "Available WSL distributions:"
        $wslList | ForEach-Object {
            Write-Host "  $($_.Name)"
        }

        $choice = Read-Host "Enter the name of the distribution to install: "
        $selectedDistro = $wslList | Where-Object { $_.Name -eq $choice }

        if ($selectedDistro) {
            Write-Host "Downloading $($selectedDistro.Name)..."
            $distroUrl = $selectedDistro.Url
            $distroPath = "$env:TEMP\$($selectedDistro.Name).msixbundle"
            Invoke-WebRequest -Uri $distroUrl -OutFile $distroPath -ErrorAction Stop
            Write-Host "$($selectedDistro.Name) downloaded to: $distroPath"

            $confirmation = Read-Host "Ready to install $($selectedDistro.Name). Continue? (Y/N)"
            if ($confirmation -eq "Y" -or $confirmation -eq "y") {
                Write-Host "Installing $($selectedDistro.Name)..."
                Add-AppxPackage -Path $distroPath
                Write-Host "$($selectedDistro.Name) installed."
            } else {
                Write-Host "Installation of $($selectedDistro.Name) cancelled."
            }
        } else {
            Write-Host "Invalid distribution name. Installation cancelled."
        }
    } catch {
        Write-Error "Error fetching or installing WSL distribution: $_"
    }
}

# Main script
Write-Host "Welcome to the Windows Subsystem for Linux Management Script" -ForegroundColor Green

$continue = $true

while ($continue) {
    Write-Host "Please select an action:" -ForegroundColor Green
    Write-Host "  1. Remove existing WSL package"
    Write-Host "  2. Install WSL update"
    Write-Host "  3. Select and Install available Linux Distribution"
    Write-Host "  4. Install Windows Subsystem for Linux"
    Write-Host "  5. Verify WSL status"
    Write-Host "  6. Clean up previous installations"
    Write-Host "  7. Exit"

    $choice = Read-Host "Enter your choice (1-7): "

    switch ($choice) {
        '1' {
            Remove-ExistingWSLPackage
        }
        '2' {
            Install-WSLUpdate
        }
        '3' {
            Select-AvailableWSLDistribution
        }
        '4' {
            Install-WSL
        }
        '5' {
            VerifyWSLStatus
        }
        '6' {
            CleanUpPreviousInstallations
        }
        '7' {
            Write-Host "Exiting script..." -ForegroundColor Yellow
            $continue = $false
        }
        default {
            Write-Host "Invalid choice. Please enter a number from 1 to 7." -ForegroundColor Yellow
        }
    }
}

Write-Host "WSL Management Script completed." -ForegroundColor Green
