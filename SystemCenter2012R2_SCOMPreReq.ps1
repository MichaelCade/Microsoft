# The script will install all prerequisites for all SCOM 2012 SP1 roles on Windows Server 2012.
# Author: Nickolaj Andersen
# Version: 1.0.3
# Date: 2013-03-21

param(
[parameter(Mandatory=$true)]
$Role)

function infoText {
Write-Host "##########################################################################"
Write-Host ""
Write-Host "This will install all prerequisites for a SCOM 2012 SP1 Management Server."
Write-Host "Once the installation is complete, the server will automaticall reboot."
Write-Host ""
Write-Host "##########################################################################"
Write-Host ""
Pause
Write-Host ""
}

function InstalldotNet35 {
Write-Host "Installing: .NET Framework 3.5"
Add-WindowsFeature NET-Framework-Core | Out-Null
}

function InstallWCFeatures {
Import-Module ServerManager
$components = @("NET-Framework-Core","AS-HTTP-Activation","Web-Static-Content","Web-Default-Doc","Web-Dir-Browsing","Web-Http-Errors","Web-Http-Logging","Web-Request-Monitor","Web-Filtering","Web-Stat-Compression","AS-Web-Support","Web-Metabase","Web-Asp-Net","Web-Windows-Auth")
$components | % {
Write-Host "Installing:" $_
Add-WindowsFeature $_ | Out-Null
}
}

function InstallReportViewer {
$dlfolder = "C:\Install"
if (!(Test-Path -path $dlfolder)) {
Write-Host $dlfolder "not found, creating it."
New-Item $dlfolder -type directory
}
$object = New-Object Net.WebClient
$RPUrl = 'http://download.microsoft.com/download/E/A/1/EA1BF9E8-D164-4354-8959-F96843DD8F46/ReportViewer.exe'
Write-Host "Downloading: ReportViewer.exe"
$object.DownloadFile($RPUrl, "$dlfolder\ReportViewer.exe")
Write-Host "Installing: Report Viewer 2010"
Start-Process -FilePath "$dlfolder\ReportViewer.exe" -ArgumentList /q -Wait
}

$ProgressPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

if (($Role -eq "ManagementServer") -OR ($Role -eq "OperationsConsole")) {
infoText
InstallReportViewer
InstalldotNet35
}
elseif ($Role -eq "WebConsole") {
infoText
InstallReportViewer
InstallWCFeatures
}
elseif ($Role -eq "AllRoles") {
infoText
InstallReportViewer
InstallWCFeatures
}
else {
Write-Host "Wrong Role selected."
}

Write-Host ""
Write-Host "Prerequisites installation complete, restarting server."
$ProgressPreference = "Continue"
$WarningPreference = "Continue"
shutdown /r /t 1 | Out-Null