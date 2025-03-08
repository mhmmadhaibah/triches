param (
    [switch]$Protection,
    [switch]$Disconnect,
    [switch]$Touches
)

if (-not ($Protection -or $Disconnect -or $Touches)) {
    Write-Host "No options selected. Verify you provide the appropriate parameters and try again." -ForegroundColor Red
    exit
}

$vars = @(
    "startProtection",
    "startDisconnect",
    "wipeWinExplorer",
    "filterEventLogs",
    "filterWinCaches",
    "deleteDownloads",
    "consentContinue"
)

foreach ($var in $vars) {
    Remove-Item -Path "Env:$var" -ErrorAction SilentlyContinue
}

if ($Protection) {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Set-MpPreference -PerformanceModeStatus Enabled
    # Set-MpPreference -MAPSReporting Advanced
    # Set-MpPreference -SubmitSamplesConsent SendAllSamples
    # Set-MpPreference -DisableTamperProtection $false
    # Set-MpPreference -EnableControlledFolderAccess Enabled
}

if ($Disconnect) {
    Start-Process -FilePath "C:\Windows\System32\warp-upx.exe" -WindowStyle Hidden
}

if ($Touches) {
    Start-Process -FilePath "C:\Windows\System32\feuille.exe" -WindowStyle Hidden
}

Clear-History
