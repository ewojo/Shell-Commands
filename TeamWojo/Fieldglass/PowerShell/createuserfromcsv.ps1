﻿# Import active directory module for running AD cmdlets
Import-Module activedirectory

    # Allow user to enter location of file
    # Write-Host "Please enter the location of your file: "
    # $CSVLocation = Read-Host

# Import CSV from location given
# C:\Users\i842548\Desktop\adusers.csv
$ADUsers = Import-csv C:\Users\i842548\Desktop\adusers.csv

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers)
{
    # Read user data from each field in each row and assign the data to a variable as below

    $Username  = $User.username
    $Password  = $User.password
    $Firstname = $User.firstname
    $Lastname  = $User.lastname
    $OU        = $User.ou # This field refers to the OU the user account is to be created in

    # *** We also need to add additional fields (description/job title) in the bulk CSV upload if
    # we want to be able to do this all in one script/module ***

    # Check to see if the user already exists in AD
    if (Get-ADUser -F {sAMAccountName -eq $Username})
    {
        # If user does exist, give a warning
        Write-Warning "A user account with $Username already exists in Active Directory"
    }
    else
    {
        # User does not exist then proceed to create the new user account

        # Account will be create in the OU provided by the $OU variable read from the CSV file
        New-ADUser `
            -sAMAccountName $Username `
            -UserPrincipalName $Username@fgdevopslab.local `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Firstname $Lastname" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)
    }
    # Make user create password at first logon
Set-ADUser -Identity $username -ChangePasswordAtLogon $true

# *** From here, we add a check to look at the description/job title (have to add) and 
# then add the user to those groups we have specified. ***
}