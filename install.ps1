$ErrorActionPreference = "Stop"
$downloadFolderPath = "$HOME\Downloads"
$lineSeparator = "----------------------------------"


Write-Host "Starting Installation" -ForegroundColor Yellow -BackgroundColor Black
Write-Host $lineSeparator

Write-Host "Checking priviledges"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host "This script must be run with administrator priviledges." -ForegroundColor Red -BackgroundColor Black
    exit
}

$aacsKeyDbArchiveName = "aacs_keydb.tar.bz2"
$aacsKeyDbFolder = "C:\ProgramData\aacs"
$keyDbFileName = "keydb.cfg"
Write-Host "Downloading aacs_keydb file"

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("http://fvonline-db.bplaced.net/fv_download.php?lang=eng", "$downloadFolderPath\$aacsKeyDbArchiveName")

Write-Host "Download done"

Write-Host "Unpacking aacs_keydb archive"
# x Extract, v Verbose, j bzip2, f Location
tar -xvjf $downloadFolderPath\$aacsKeyDbArchiveName -C $downloadFolderPath

Remove-Item -Path $downloadFolderPath\$aacsKeyDbArchiveName
Write-Host "Moving aacs_keydb file"

if (!(Test-Path -Path $aacsKeyDbFolder)) {
    New-Item -Path $aacsKeyDbFolder -ItemType Directory
}
Move-Item -Path $downloadFolderPath\$keyDbFileName -Destination $aacsKeyDbFolder\$keyDbFileName -Force

Write-Host "Installing codec library" -ForegroundColor Yellow -BackgroundColor Black
$libaacsFileName = "libaacs.dll"

$WebClient.DownloadFile("https://vlc-bluray.whoknowsmy.name/files/win64/libaacs.dll", "$downloadFolderPath\$libaacsFileName")

Move-Item -Path "$downloadFolderPath\$libaacsFileName" -Destination "C:\Program Files\VideoLAN\VLC\$libaacsFileName" -Force

Write-Host $lineSeparator
if ($Error) {
    Write-Host "Installation failed" -ForegroundColor Red -BackgroundColor Black
    Write-Error $_.Exception.GetType().FullName
    Write-Host $_.Exception.Message
    return
}
Write-Host "Installation done" -ForegroundColor Green -BackgroundColor Black
Write-Host "Next steps: Start VLC and enjoy your BluRay"
