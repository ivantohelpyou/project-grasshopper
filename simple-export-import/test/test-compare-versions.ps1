# Import the Compare-Versions function
. ../compare-versions.ps1

# Define test cases
$testCases = @(
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 0 }
        Version2 = [PSCustomObject]@{ Major = 2; Minor = 0; Build = 0; Revision = 0 }
        Expected = "lt"
        Description = "Version2 is newer (major)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 2; Minor = 0; Build = 0; Revision = 0 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 0 }
        Expected = "gt"
        Description = "Version1 is newer (major)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 1; Build = 0; Revision = 0 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 2; Build = 0; Revision = 0 }
        Expected = "lt"
        Description = "Version2 is newer (minor)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 2; Build = 0; Revision = 0 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 1; Build = 0; Revision = 0 }
        Expected = "gt"
        Description = "Version1 is newer (minor)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 1; Revision = 0 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 2; Revision = 0 }
        Expected = "lt"
        Description = "Version2 is newer (build)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 2; Revision = 0 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 1; Revision = 0 }
        Expected = "gt"
        Description = "Version1 is newer (build)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 1 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 2 }
        Expected = "lt"
        Description = "Version2 is newer (revision)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 2 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 1 }
        Expected = "gt"
        Description = "Version1 is newer (revision)"
    },
    [PSCustomObject]@{
        Version1 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 1 }
        Version2 = [PSCustomObject]@{ Major = 1; Minor = 0; Build = 0; Revision = 1 }
        Expected = "eq"
        Description = "Versions are equal"
    }
)

# Run test cases
foreach ($testCase in $testCases) {
    $result = Compare-Versions -Version1 $testCase.Version1 -Version2 $testCase.Version2
    if ($result -eq $testCase.Expected) {
        Write-Host "PASS: $($testCase.Description)"
    } else {
        Write-Host "FAIL: $($testCase.Description) - Expected $($testCase.Expected), got $result"
    }
}