<#
.SYNOPSIS
Set Logon Workstations for specified account(s).

.DESCRIPTION
Set Logon Workstations for specified account(s). This script will OVERWRITE any current Logon Workstations that are set, with the workstation names provided in the target .CSV file.

.NOTES
Written by: Jeremy DeWitt aka JBear
Date: 4/21/2017
#>

function Set-LogOnComputers {

Param(
    
   #Default value is set for $Import, change filepath to desired file; **Set-ADUser cmdlet will only accept multiple entries for LogonWorkstations if array is in a single string
    [String] $ImportCSV = (Import-Csv "\\SERVER01\Testing-Workstations.csv").Computer -join ",",

   #Default value is set for $Users; will accept pipeline input
   [parameter(ValueFromPipeline=$true)]
    [string[]] $Users
)

Try {

    Import-Module ActiveDirectory -ErrorAction Stop
}

Catch {

    Write-Host -ForegroundColor Yellow "`nNotice: Unable to load Active Directory Module, it is required to run this script. Please, install RSAT and configure this server properly."
    Break
}

$i=0
$j=0

foreach ($Item in $ImportCSV) {

    $Computernames += "," +$Item
}

    foreach ($User in $Users) {

        Write-Progress -Activity "Setting Logon Workstations for $User..." -Status ("Percent Complete:" + "{0:N0}" -f ((($i++) / $Users.count) * 100) + "%") -CurrentOperation "Processing $($User)..." -PercentComplete ((($j++) / $User.count) * 100)

        Try {

            #Set specified user to specified logon workstation(s)
            Set-ADUser -Identity $User -LogonWorkstations $Computernames

            Write-Host -ForegroundColor Green "`nSuccess: [$User] Logon Workstations updated successfully."
        }

        Catch {
        
            Write-Host -ForegroundColor Red "`nError: [$User] unable to update Logon workstations. Please try again."        
        }       
    }
}

#Call main functions
Set-LogOnComputers
