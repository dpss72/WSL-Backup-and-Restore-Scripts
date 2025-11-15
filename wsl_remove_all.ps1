# WSL Distribution Removal Script
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Red
Write-Host "WSL Distribution Removal Script" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host "WARNING: This will PERMANENTLY DELETE all WSL distributions!" -ForegroundColor Yellow
Write-Host "Make sure you have backups before proceeding." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Red

# Show current distributions
Write-Host "Current WSL distributions:" -ForegroundColor Cyan
wsl -l -v
Write-Host ""

# Get distribution list from registry (most reliable)
$distributions = @()
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"

if (Test-Path $regPath) {
    $lxssGuids = Get-ChildItem $regPath
    foreach ($guid in $lxssGuids) {
        $distroName = (Get-ItemProperty -Path $guid.PSPath -Name DistributionName -ErrorAction SilentlyContinue).DistributionName
        if ($distroName) {
            $distributions += $distroName
            Write-Host "Found: $distroName" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

if ($distributions.Count -eq 0) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "No WSL distributions installed." -ForegroundColor Yellow
    Write-Host "Nothing to remove." -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "Total distributions found: $($distributions.Count)`n" -ForegroundColor Green

# Ask for confirmation
$confirm = Read-Host "Are you sure you want to remove ALL WSL distributions? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "`nOperation cancelled." -ForegroundColor Green
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "Starting removal process..." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

$totalRemoved = 0
$totalFailed = 0

foreach ($distro in $distributions) {
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "Removing: $distro" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    
    # Use simple command execution
    try {
        $output = wsl --unregister $distro 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: $distro has been removed`n" -ForegroundColor Green
            $totalRemoved++
        } else {
            Write-Host "ERROR: Failed to remove $distro (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "Output: $output`n" -ForegroundColor Red
            $totalFailed++
        }
    } catch {
        Write-Host "ERROR: Exception while removing $distro" -ForegroundColor Red
        Write-Host "Exception: $_`n" -ForegroundColor Red
        $totalFailed++
    }
    
    Start-Sleep -Seconds 1
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Removal Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Total removed: $totalRemoved"
Write-Host "Failed: $totalFailed"
Write-Host "Completed: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')"
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Remaining WSL distributions:" -ForegroundColor Cyan
wsl -l -v

Write-Host "`nPress Enter to continue..."
Read-Host