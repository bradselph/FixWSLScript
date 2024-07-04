# FixWSLScript

This repository contains a PowerShell script to fix issues with the Windows Subsystem for Linux (WSL). The script automates the process of removing existing WSL packages, downloading and installing the WSL update package, installing the Ubuntu distribution, and verifying the WSL status. If issues persist, it performs additional clean-up steps.

## Usage

### Prerequisites

- Windows 10 or Windows 11 with WSL enabled
- PowerShell running as Administrator

### Steps

1. Clone this repository:
   ```sh
   git clone https://github.com/bradselph/FixWSLScript.git
   cd FixWSLScript
   ```

2. Open PowerShell as Administrator and navigate to the repository directory.

3. Run the script:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\FixWSL.ps1
   ```

## Script Overview

The script performs the following steps:

1. **Remove Existing WSL Package:**
   - Lists and removes existing WSL packages.

2. **Install WSL Update:**
   - Downloads and installs the latest WSL update package.

3. **Install Ubuntu Distribution:**
   - Downloads and installs the Ubuntu distribution.

4. **Verify WSL Status:**
   - Checks the status of WSL distributions.

5. **Clean Up Previous Installations (if needed):**
   - Unregisters existing distributions, removes WSL-related folders and registry entries, and prompts a system restart.

## Troubleshooting

If the script encounters any errors, it will provide details and perform clean-up steps to help resolve the issues. After the clean-up, restart your computer and re-run the script if necessary.

## Contributing

Feel free to submit issues or pull requests if you have improvements or find bugs.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.