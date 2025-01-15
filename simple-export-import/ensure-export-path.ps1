function Ensure-Export-Path {
    param (
        [string]$ExportPath
    )

    if (-not (Test-Path -Path $ExportPath)) {
        Write-Host "Creating export path: $ExportPath"
        New-Item -ItemType Directory -Path $ExportPath
    }
}