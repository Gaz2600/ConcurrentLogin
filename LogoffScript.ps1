#############################################################
# Edit to fit your environment
 #Enter the location of where you want the user file to be stored
 $UserFileLocation = "\\concurrentlogin\Profiles\$env:username\1.txt"
#############################################################

Remove-Item $UserFileLocation
