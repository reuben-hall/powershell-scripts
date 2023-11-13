# Script to remove GCPW-generated profiles and registry keys.
# Version 2
# 2022-11-14
# Reuben Hall

# Get list of profiles, match to regex pattern for pupil USO accounts format and store to variable
$GCPWProfiles = Get-CimInstance -Class Win32_UserProfile | Where-Object { 
    
    $_.LocalPath -match '(\w+\d{3}.\d{3}_\w+)' 
    
    }

# Function to remove GCPW registry keys if they exist
function Remove-GCPWReg {
    Push-Location
    Set-Location HKLM:\SOFTWARE\Google\GCPW

    if (Test-Path Users) {
        Remove-Item Users -Recurse
        Write-Host "Deleted HKLM:\SOFTWARE\Google\GCPW\Users key."
    } else {
        Write-Host "Key does not exist."
    }

Pop-Location
}

# Loop through matched profiles, deleting verbose

$counter = 0

foreach ($Profiles in $GCPWProfiles) {

    Write-Host "Deleting profile", $Profiles.LocalPath
    Remove-CimInstance -InputObject $Profiles
    $counter++

}

# Finally, remove registry keys
Remove-GCPWReg

Write-Host "Deleted $($counter) profiles."