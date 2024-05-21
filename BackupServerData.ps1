#Cut to me and matt making out.
#On the server, you can make a scheduled task to run this powershell script every friday or whatever.

# Define the source directories and the destination directory
#What are the folders you want copied?  Put them here.
$sourceDirs = @(
    "C:\ServerData1",  # Replace with your first server data directory
    "C:\ServerData2",  # Replace with your second server data directory
    "C:\ServerData3"   # Replace with your third server data directory
)
#This is destination folder they will be copied to with an added timpstamp.
$destDir = "\\NASDrive\Backup"  # Replace with your NAS drive location

# Create a timestamp for the backup folder
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupRootDir = Join-Path -Path $destDir -ChildPath "Backup_$timestamp"

# Create the root backup directory on the NAS drive
#This will create the back folderon the NAS with a timestamp so you can tell the date of the backup.
New-Item -ItemType Directory -Path $backupRootDir

# Loop through each source directory and back it up
foreach ($sourceDir in $sourceDirs) {
    # Create a subdirectory in the backup folder for each source directory
    $folderName = Split-Path -Path $sourceDir -Leaf
    $backupDir = Join-Path -Path $backupRootDir -ChildPath $folderName

    # Create the backup subdirectory on the NAS drive
    New-Item -ItemType Directory -Path $backupDir

    # Perform the backup using Robocopy
    # /MIR: Mirror the source directory to the destination (deletes files in the destination that no longer exist in the source)
    # /E: Copy subdirectories, including empty ones
    # /R:3: Retry 3 times on failed copies
    # /W:5: Wait 5 seconds between retries
    robocopy $sourceDir $backupDir /MIR /E /R:3 /W:5

    # Check if the backup was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Backup of $sourceDir completed successfully."
    } else {
        Write-Output "Backup of $sourceDir failed with exit code $LASTEXITCODE."
    }
}

Write-Output "All backups completed."
Explanation:
