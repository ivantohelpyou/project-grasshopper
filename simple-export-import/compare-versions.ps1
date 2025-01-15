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

function Compare-Versions {
    param (
        [PSCustomObject]$Version1,
        [PSCustomObject]$Version2
    )

    # Validate that the custom objects have the expected properties
    foreach ($version in @($Version1, $Version2)) {
        if (-not ($version.PSObject.Properties.Match("Major") -and $version.PSObject.Properties.Match("Minor") -and $version.PSObject.Properties.Match("Build") -and $version.PSObject.Properties.Match("Revision"))) {
            throw "Invalid version object. Expected properties: Major, Minor, Build, Revision."
        }
    }

    if (Is-GreaterVersionThan -Version1 $Version1 -Version2 $Version2) {
        return "gt"
    } elseif (Is-GreaterVersionThan -Version1 $Version2 -Version2 $Version1) {
        return "lt"
    } else {
        return "eq"
    }
}