cls
Import-Module activedirectory
$Users = (Get-ADUser -Filter * | Where-Object {($_.samaccountname -ne "Guest") -and ($_.samaccountname -ne "krbtgt") -and ($_.samaccountname -ne "administrator") }).samaccountname

foreach ($user in $Users)
{
   if((Test-Path -Path "C:\Profiles\$user") -eq $false)
   {
        New-Item -ItemType directory -Path "C:\Profiles\$user" | Out-Null
   }
}
