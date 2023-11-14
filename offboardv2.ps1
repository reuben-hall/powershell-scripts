# offboardv1.ps1
# Reuben Hall
# Automates removal of user accounts in Leaving container. 
# Deletes home folders and roaming profiles, and moves disabled user to Disabled container.

Import-module ActiveDirectory

function Disable-ADAccounts {
  
    if ($_.Enabled -eq "True") {
        Disable-ADAccount $_
        Write-Host "Disabled $AccountFullName"
    } elseif ($_.Enabled -eq "False") {
        Write-Host "$AccountFullName already disabled"
    }
}

Start-Transcript -Append -Path ~\Documents\OffboardedUsers.txt

# Starts a counter
$counter = 0

# Get security permissions
$NewACL = Get-Acl '.\User Shares'

## Search OU for accounts. Get properties to test for enabled, home directory, and roaming profile.
## Start loop
Get-ADUser -Filter * -SearchBase "OU=Test,DC=Test,DC=Test" -Properties samAccountName, Enabled, homedirectory, profilepath, MemberOf | ForEach-Object {

    # Set name and username to variable for use in console log
    $AccountFullName = "$($_.samAccountName) ($($_.Name))"

    # Create random 24 character alphanumeric password
    $randompassword = -join (((48..57)+(65..90)+(97..122)) * 80 | Get-Random -Count 24 | ForEach-Object {[char]$_})

    # Set password for user
    Set-ADAccountPassword -Identity $_ -NewPassword (ConvertTo-SecureString $randompassword -AsPlainText -Force)

    # If home directory exists, take ownership
    if (Test-Path -Path $_.homedirectory) {

        Push-Location $_.homedirectory
        Set-Location ..
        Write-Host "Taking ownership of $AccountFullName's home directory..."
        Set-Acl -Path $_.homedirectory -AclObject $NewACL
        takeown.exe /F $_.homedirectory /A /R /D Y
        Write-Host "Deleting $AccountFullName's home directory..."
        Remove-Item -Path $_.homedirectory -Force -Recurse
        Pop-Location

    } else {
        Write-Host "Home directory for $AccountFullName does not exist."
    }

    # Delete profile if exists
    # Roaming profile not used, commented out
    # Set-ADUser -Identity $_ -Clear profilepath

    # Remove user from all AD groups (doesn't remove from Domain Users)
    foreach ($group in $_.MemberOf) {
        Write-Host "Removing $AccountFullName from $($group)..."
        Remove-ADGroupMember -Identity $group -Members $_ -Confirm:$false
    }

    # Get today's date and time, store to variable
    $DateToday = Get-Date -Format "dddd yyyy/MM/dd HH:mm"

    if (Test-Path -Path $_.homedirectory) {
        Set-ADUser -Identity $_ -Description "Home folder not removed properly."
        Write-Host "Home folder for $AccountFullName not removed properly. Keeping account in Leaving container for now."
        Disable-ADAccounts
    } else {
        # Disable AD account if not disabled
        Disable-ADAccounts

        # Write the time of offboarding to the user description
        Set-ADUser -Identity $_ -Description "Account disabled on $DateToday"

        # Move user to Disabled container
        Move-ADObject -Identity $_ -TargetPath "OU=Disabled,OU=Users,OU=HPS,DC=Hargrave,DC=Internal"
        Write-Host "Moved $AccountFullName to Disabled container" 
    }

    # Increment counter
    Write-Host "................................................"
    $counter++
} # End loop

if ($counter -eq 1) {
    Write-Host "Completed operations on $counter user account."
    } else {
    Write-Host "Completed operations on $counter user accounts."
}

Read-Host "Press Enter to finish"