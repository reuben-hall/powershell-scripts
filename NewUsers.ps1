#Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

#Store the data from ADUsers.csv in the $ADUsers variable
$Users = Import-csv '.\NewUsers.csv'

#Loop through each row containing user details in the CSV file 
foreach ($User in $Users) {
    # Read user data from each field in each row
    # the username is used more often, so to prevent typing, save that in a variable
   $Username       = $User.SamAccountName

    # Check to see if the user already exists in AD
    if (Get-ADUser -F {SamAccountName -eq $Username}) {
         #If user does exist, give a warning
         Write-Warning "A user account with username $Username already exist in Active Directory."
    }
    else {
        # User does not exist then proceed to create the new user account

        # create a hashtable for splatting the parameters
        $userProps = @{
            SamAccountName             = $User.SamAccountName                   
            Path                       = $User.path      
            GivenName                  = $User.GivenName 
            Surname                    = $User.Surname
            Name                       = $User.Name
            DisplayName                = $User.DisplayName
            UserPrincipalName          = $user.UserPrincipalName
            emailAddress               = $user.emailAddress 
            AccountPassword            = (ConvertTo-SecureString $User.password -AsPlainText -Force) 
            Enabled                    = $true
            ChangePasswordAtLogon      = $false
        }   #end userprops   

         New-ADUser @userProps
         Write-Host "The user account $($User.UserPrincipalName) is created." -ForegroundColor Cyan

         # Add user to group
        Add-ADGroupMember -Identity $User.Group -Members $User.samAccountName
        Write-Host "Added $($User.samAccountName) to $($User.Group)"
   

    } #end else
   
}

Read-Host "Press Enter to finish"