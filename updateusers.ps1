# import CSV with email addresses and Display Names updated

 $users = Import-Csv -Path \\RPS-SR-002\NETLOGON\users.csv

 foreach ($user in $users) {
    # Search in AD and update existing attributes
    Write-Host "Updating $($user.SamAccountName)..."
    Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'" -Properties * | Set-ADUser -EmailAddress $user.EmailAddress -DisplayName $user.DisplayName
 }