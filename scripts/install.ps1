# This script is for installing the latest version of Kriti CLI on your Windows machine.
# Run using
# powershell -Command "& {Invoke-WebRequest -UseBasicParsing -MaximumRedirection 5 'https://kriti.blog/downloads/kriti-cli/latest?os=windows' | Invoke-Expression}"

# Function to probe the architecture
function Probe-Arch {
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    switch ($arch) {
        "AMD64" { return "x86_64" }
        "ARM64" { return "arm64" }
        default { Write-Host "Architecture $arch is not supported"; exit 1 }
    }
}

# Function to update the PATH
function Update-PathEnvironment {
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$INSTALL_DIRECTORY*") {
        $newPath = "$currentPath;$INSTALL_DIRECTORY"
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "Updated PATH environment variable."
    }
    else {
        Write-Host "PATH already contains the Kriti directory."
    }
}

# Function to update the PATH
function Update-PathEnvironment {
    param(
        [string]$versionDir
    )
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    
    # Remove any existing Kriti paths from PATH
    $pathParts = $currentPath -split ';' | Where-Object { $_ -notlike "*$BASE_DIRECTORY*" }
    $newPath = ($pathParts + $versionDir) -join ';'
    
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "Updated PATH environment variable to use version $version."
}

# Function to install Kriti CLI
function Install-KritiCLI {
    param(
        [string]$version
    )
    
    $urlPrefix = "https://github.com/vinaygaykar/kriti-cli-archive/releases/download"
    $target = "windows_$ARCH"
    $versionDir = Join-Path $BASE_DIRECTORY "v$version"

    Write-Host "Downloading version $version for $target..."

    $url = "$urlPrefix/$version/kriti_$target.zip"
    $downloadFile = [System.IO.Path]::GetTempFileName()

    Invoke-WebRequest -Uri $url -OutFile "$downloadFile.zip" -UseBasicParsing

    Write-Host "Installing to $versionDir"
    New-Item -ItemType Directory -Force -Path $versionDir | Out-Null
    Expand-Archive -Path "$downloadFile.zip" -DestinationPath $versionDir -Force
    Remove-Item -Path "$downloadFile.zip" -Force

    return $versionDir
}

# Main execution
Write-Host "Welcome to the Kriti installer!"

$ARCH = Probe-Arch
$BASE_DIRECTORY = "$env:LocalAppData\Programs\kriti"
$version = Get-LatestVersion

$versionDir = Install-KritiCLI -version $version
Update-PathEnvironment -versionDir $versionDir

Write-Host "Kriti CLI version $version installed!"
Write-Host "To get started, open a new PowerShell window and run 'kriti'."
