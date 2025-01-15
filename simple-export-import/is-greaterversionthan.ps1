function Is-GreaterVersionThan {
    param (
        [PSCustomObject]$Version1,
        [PSCustomObject]$Version2
    )

    if ($Version1.Major -gt $Version2.Major) {
        return $true
    } elseif ($Version1.Major -lt $Version2.Major) {
        return $false
    } elseif ($Version1.Minor -gt $Version2.Minor) {
        return $true
    } elseif ($Version1.Minor -lt $Version2.Minor) {
        return $false
    } elseif ($Version1.Build -gt $Version2.Build) {
        return $true
    } elseif ($Version1.Build -lt $Version2.Build) {
        return $false
    } elseif ($Version1.Revision -gt $Version2.Revision) {
        return $true
    } elseif ($Version1.Revision -lt $Version2.Revision) {
        return $false
    } else {
        return $false
    }
}