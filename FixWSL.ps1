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

function Install-UbuntuDistro {
    Write-Host "Downloading and installing Ubuntu distribution..."
    try {
        $distroUrl = "https://github.com/microsoft/WSL/releases/download/2.2.4/Microsoft.WSL_2.2.4.0_x64_ARM64.msixbundle"
        $distroPath = "$env:TEMP\Microsoft.WSL_2.2.4.0_x64_ARM64.msixbundle"
        Invoke-WebRequest -Uri $distroUrl -OutFile $distroPath -ErrorAction Stop
        Write-Host "Ubuntu distribution downloaded to: $distroPath"
        
        $confirmation = Read-Host "Ready to install the Ubuntu distribution. Continue? (Y/N)"
        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            Add-AppxPackage -Path $distroPath
            Write-Host "Ubuntu distribution installed."
        } else {
            Write-Host "Installation of Ubuntu distribution cancelled."
        }
    } catch {
        Write-Error "Error installing Ubuntu distribution: $_"
    }
}

function VerifyWSLStatus {
    Write-Host "Verifying WSL status..."
    try {
        wsl --list --all -v
    } catch {
        Write-Error "Error verifying WSL status: $_"
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

# Main script
Write-Host "Starting WSL fix script..." -ForegroundColor Green

try {
    Remove-ExistingWSLPackage
    Install-WSLUpdate
    Install-UbuntuDistro
    VerifyWSLStatus
} catch {
    Write-Error "An error occurred during the WSL fix process: $_"
    Write-Host "Running clean-up steps..." -ForegroundColor Yellow
    CleanUpPreviousInstallations
    Write-Host "Please restart your computer and re-run the script if necessary."
}

Write-Host "WSL fix script completed." -ForegroundColor Green
