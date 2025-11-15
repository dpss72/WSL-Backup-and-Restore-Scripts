# WSL Backup and Restore Scripts

A collection of Windows batch and PowerShell scripts to easily backup, restore, and manage WSL (Windows Subsystem for Linux) distributions.

## 📁 Files

- **wsl_backup.bat** - Backs up all installed WSL distributions
- **wsl_restore.bat** - Restores WSL distributions from backups
- **wsl_remove_all.bat** - Wrapper script for PowerShell removal script
- **wsl_remove_all.ps1** - Removes all installed WSL distributions

## 🚀 Quick Start

1. Download all four scripts to a folder of your choice (e.g., `C:\WSL-Scripts\`)
2. Double-click the script you want to run
3. Follow the on-screen prompts

## 📖 Detailed Usage

### 1. Backing Up WSL Distributions

**Script:** `wsl_backup.bat`

**What it does:**
- Automatically detects all installed WSL distributions
- Creates timestamped backup files (`.tar` format)
- Saves backups to a `Backup` subfolder in the same directory as the script
- Stops running distributions before backup to ensure consistency

**How to use:**
1. Double-click `wsl_backup.bat`
2. Wait for the backup to complete
3. Backup files will be in the `Backup` folder with names like `Ubuntu_20251115_090007.tar`

**Example output:**
```
========================================
WSL Backup Script - All Distributions
========================================
Backup Location: C:\WSL-Scripts\Backup
Started: 15.11.2025 09:00:07
========================================

Detecting WSL distributions...

----------------------------------------
Distribution: Ubuntu
----------------------------------------
Stopping Ubuntu if running...
Creating backup: Ubuntu_20251115_090007.tar
Please wait, this may take several minutes...
SUCCESS: Backup completed - 3594 MB

========================================
Backup Summary
========================================
Total distributions: 1
Successful backups: 1
Failed backups: 0
Completed: 15.11.2025 09:02:30
========================================
```

**Notes:**
- Each backup can be several GB in size
- Older backups are kept automatically (you can manually delete old ones)
- Ensure you have enough disk space before backing up

---

### 2. Restoring WSL Distributions

**Script:** `wsl_restore.bat`

**What it does:**
- Scans the `Backup` folder for backup files
- Automatically selects the **latest backup** for each distribution
- Restores distributions to subfolders in the script directory
- Prompts before overwriting existing distributions

**How to use:**
1. Double-click `wsl_restore.bat`
2. Review the list of available backups
3. If a distribution already exists, you'll be asked whether to overwrite it
4. Type `yes` or `no` and press Enter
5. Wait for the restore to complete

**Example output:**
```
========================================
WSL Restore Script - All Distributions
========================================
Backup Location: C:\WSL-Scripts\Backup
Install Location: C:\WSL-Scripts\
========================================

Scanning for backups...

Available backups:
Ubuntu_20251115_090007.tar
Ubuntu_20251115_085841.tar
Ubuntu_20251115_085635.tar

----------------------------------------
Distribution: Ubuntu
----------------------------------------
Backup file: Ubuntu_20251115_090007.tar
Target directory: C:\WSL-Scripts\Ubuntu
Creating directory...
Directory ready: C:\WSL-Scripts\Ubuntu
Backup size: 3594.24 MB

Restoring Ubuntu...
Please wait, this may take several minutes...

SUCCESS: Ubuntu has been restored
Location: C:\WSL-Scripts\Ubuntu

========================================
Restore Summary
========================================
Total restored: 1
Already exists (skipped): 0
Failed: 0
Completed: 15.11.2025 09:19:06
========================================
```

**Notes:**
- The script automatically uses the **newest** backup for each distribution
- Restored distributions are placed in subfolders (e.g., `Ubuntu`, `Debian`)
- You can have backups and restored distributions in the same location

---

### 3. Removing All WSL Distributions

**Scripts:** `wsl_remove_all.bat` and `wsl_remove_all.ps1`

**What it does:**
- Detects all installed WSL distributions using Windows Registry
- Permanently removes all distributions after confirmation
- Shows a summary of removed and failed distributions

**How to use:**
1. Double-click `wsl_remove_all.bat`
2. Review the list of distributions that will be removed
3. Type `yes` and press Enter to confirm
4. Wait for the removal to complete

**Example output:**
```
========================================
WSL Distribution Removal Script
========================================
WARNING: This will PERMANENTLY DELETE all WSL distributions!
Make sure you have backups before proceeding.
========================================

Current WSL distributions:
  NAME      STATE           VERSION
* Ubuntu    Stopped         2

Found: Ubuntu

Total distributions found: 1

Are you sure you want to remove ALL WSL distributions? (yes/no): yes

========================================
Starting removal process...
========================================

----------------------------------------
Removing: Ubuntu
----------------------------------------
SUCCESS: Ubuntu has been removed

========================================
Removal Summary
========================================
Total removed: 1
Failed: 0
Completed: 15.11.2025 09:31:21
========================================
```

**⚠️ WARNING:**
- This action is **PERMANENT** and **CANNOT BE UNDONE**
- Make sure you have backups before removing distributions
- All data in the distributions will be deleted

---

## 📋 Common Workflows

### Complete Backup and Restore Workflow

1. **Backup your current WSL setup:**
```
   Run: wsl_backup.bat
   Result: Backups saved to .\Backup\
```

2. **Remove all distributions (optional):**
```
   Run: wsl_remove_all.bat
   Result: All WSL distributions removed
```

3. **Restore from backup:**
```
   Run: wsl_restore.bat
   Result: Distributions restored from .\Backup\
```

### Migration to a New Computer

1. **On old computer:**
   - Run `wsl_backup.bat`
   - Copy the entire script folder (including `Backup` subfolder) to external drive

2. **On new computer:**
   - Install WSL: `wsl --install`
   - Copy the script folder to the new computer
   - Run `wsl_restore.bat`

### Regular Backup Schedule

Create a scheduled task to run `wsl_backup.bat` automatically:
1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (e.g., Weekly)
4. Action: Start a program
5. Program: `C:\WSL-Scripts\wsl_backup.bat`

---

## 🔧 Troubleshooting

### "No WSL distributions installed" but I have distributions

**Solution:** Run `wsl_backup.bat` as Administrator

### "Cannot find the path specified" during restore

**Cause:** The distribution folder name conflicts with an existing file

**Solution:** 
1. Check if there's a file (not folder) with the distribution name in the script directory
2. Delete the file manually
3. Run `wsl_restore.bat` again

### Backup files are very large

**This is normal.** WSL distributions include the entire Linux filesystem and can be several GB.

**Tips to reduce size:**
- Clean up your WSL distribution before backup:
```bash
  sudo apt autoremove
  sudo apt clean
```

### "Invalid number" error during backup/restore

**This is a cosmetic issue** and doesn't affect functionality. The backup/restore still works correctly.

---

## 📝 File Naming Convention

Backup files follow this pattern:
```
{DistributionName}_{YYYYMMDD}_{HHMMSS}.tar
```

Examples:
- `Ubuntu_20251115_090007.tar`
- `Debian_20251115_143022.tar`
- `Ubuntu-22.04_20251115_150000.tar`

---

## 💾 Storage Requirements

**Backup folder size:**
- Each distribution backup = size of your WSL installation
- Multiple backups are kept (manual cleanup required)
- Typical Ubuntu distribution: 2-5 GB
- With Docker Desktop: 10-20 GB+

**Recommendations:**
- Keep backups on a separate drive
- Delete old backups periodically
- Use compression tools if needed

---

## ⚙️ System Requirements

- Windows 10/11 with WSL2 installed
- PowerShell 5.0 or higher (included in Windows 10/11)
- Sufficient disk space for backups
- Administrator privileges (recommended but not always required)

---

## 🆘 Support

If you encounter issues:

1. **Check WSL status:**
```
   wsl --status
   wsl -l -v
```

2. **Try running as Administrator:**
   - Right-click script → "Run as administrator"

3. **Verify PowerShell execution policy:**
```powershell
   Get-ExecutionPolicy
```
   If needed: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

## 📄 License

These scripts are provided as-is for personal and commercial use.

---

## ⚠️ Important Notes

- Always test restore process before relying on backups
- Keep multiple backup copies in different locations
- Backups do NOT include Windows files or settings
- WSL version (WSL1 vs WSL2) is not preserved in backups
- Default distribution settings are not preserved

---

## 🔄 Version History

**v1.0 (2025-11-15)**
- Initial release
- Backup, restore, and remove functionality
- Relative path support
- Automatic latest backup selection