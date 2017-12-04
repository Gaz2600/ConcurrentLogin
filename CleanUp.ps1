#$files = Get-ChildItem -Path "C:\Profiles" -Filter *.txt -Recurse 
#$files | Remove-Item -Force

$Pivot = 1
    DO {
        Get-ChildItem -Path "C:\Profiles" -Filter *.txt -Recurse | Remove-Item -Force
        Start-Sleep -s 300 #5min
    }
    while ($Pivot -ne 0)
