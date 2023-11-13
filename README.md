# powershell-scripts
Custom PowerShell scripts for various AD functions.

## NewUsers.ps1

NewUsers.ps1 bulk adds AD accounts from a CSV spreadsheet. 
The script checks if a user exists in AD. If not, it creates a user based on the props. 

### Note:

- *path* is the full path of the OU the user will be created in.
- *group* needs to be the full path of the distinguishedName of the group.

## gcpw_fix2.ps1

This script removes GCPW-generated profiles in bulk from a misconfigured domain. This particular script matches patterns for LGfL USO pupil accounts, and removes the profile.
To run it, copy the script to a PC with misconfigured profiles and run it. The command line will return a number of profiles removed.

### Note:

Run this script at your own risk.
