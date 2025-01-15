function Load-Config {
    param (
        [string]$ConfigPath
    )

    Write-Host "Loading configuration from JSON file..."
    try {
        $config = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
        Write-Host "Configuration loaded successfully."
        return $config
    } catch {
        Write-Error "Failed to load configuration from JSON file."
        throw $_
    }
}