function Authenticate {
    param (
        [string]$EnvironmentUrl
    )

    if ($env:ACC_CLOUD) {
        Write-Host "Running in Cloud Shell. Skipping authentication for environment: $EnvironmentUrl"
    } else {
        Write-Host "Authenticating with environment: $EnvironmentUrl"
        pac auth create --environment $EnvironmentUrl
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to authenticate with environment $EnvironmentUrl"
            exit $LASTEXITCODE
        }
    }
}