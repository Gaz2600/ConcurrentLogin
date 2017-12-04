# ConcurrentLogin
Limit users to login to one computer at a time (Windows)


# Requirements (Tested with Server 2012R2 and Windows 10)
File Server/VM or location to host profile files
"This file server will be the repository for our flag files. However, keep in mind that, it is possible to use the DC itself instead of a separate file server, but since the ‘CleanUp’ process will run every second as a scheduled task, it is better to not involve your domain controllers because it can cause some performance lags depending on the size of your environment." -Mahdi Tehrani

Access to Group Policy
Powershell WinRM turned on

# Implementation
Implementing this solution will be done in several steps:
	1. Creating a GPO for logon script
	2. Create user folders
  3. Cleanup process
  
# 1. Creating a GPO for logon script
"This step will cover the GPO part of this solution. If you remember, we talked about creating a flag time for the first time the user gets authenticated. The best way to implement the creation of this flag file is through a group policy.
This GPO will configure a logon script and using this script, each time the user logs on, it creates the flag file in user’s folder in file server. Before using the script you need to customize it for your environment. You need to change some part of the script to apply in your environment. The red parts in the scripts should be changed:" -Mahdi Tehrani

In the LogonScript there are multiple variables you will need to modify to fit your environment. 

    #############################################################
    # Edit to fit your environment
     #Enter the location of where you want the user file to be stored
     $UserFileLocation = "\\concurrentlogin\Profiles2$\$env:username\1.txt"
    #------------------------------------------------------------
     $computer = get-content $UserFileLocation #Do not edit
    #------------------------------------------------------------
     #Enter the location of the personalized logo, max height should be 65px and max width should be 380px
     $LogoLocation = "\\eastmont206.local\NETLOGON\Limit2.0\smallvector.png"
    #------------------------------------------------------------
     #Enter the txt you want to appear in the Window title bar
     $MainFormTitle = "Eastmont IT Security Policy Violation"
    #------------------------------------------------------------
     #Enter the txt you want to appear in the window header
     $WindowTitleMsg = "WARNING: You Are Logged Into Multiple Locations"
    #------------------------------------------------------------
     #Enter the txt you wan to appear in the window body line 320
     $Body = "District IT security policy allows users to log onto one workstation at a time.  You are already logged onto workstation $computer; therefore, you will be automatically logged off this workstation in 60 seconds.  

    If you need additional assistance please have your teacher contact the Helpdesk."
    #------------------------------------------------------------
     #Enter the total time in seconds befor auto logoff, keep in mind the total time it takes for a new user to login and for windows to     create the profile.
     $TimeSec = 60 
    #
    #############################################################


After applying the required changes, follow the steps below to create the GPO:"  -Mahdi Tehrani

"Create a new GPO “LimitLogin and navigate to "User Configuration\Windows Settings\Scripts (Logon/Logoff)" and open "Logon"

Select the "PowerShell Scripts" tab and click on ‘Show Files’.

Copy the "LogonSCript.ps1" to the folder which pops up on the screen.

Now you have copied the file, click on the ‘Add’ button, click browse and select the "LogonScript.ps1" script and click "open" to add it to the window. Next in "Script Parameters" enter "-ExecutionPolicy Bypass" click ‘OK’.

Under "For this GPO,run scripts in the following order" select "Run Windows Powershell scripts first"


# Create user folders
"This is the step where you actually create folders for each user. This folder will be used to hold flag file for each user. Since we want to use the path in a logon script later and we want to make sure that each user can touch its own flag file, we will name these folder to user ‘samaccountname’.
The only problem is that there might be users who are added to Active Directory every hour and we do not want to spend time on creating user folders. As a result, this script will search the path for missing user folders and will create them immediately.
Since we will need to edit this script to make it applicable in our environment, make sure that the paths below are correctly set in the "FolderCreation.ps1" script:"  -Mahdi Tehrani

    if((Test-Path -Path "C:\Profiles\$user") -eq $false)
    {
    New-Item -ItemType directory -Path "C:\Profiles\$user" | Out-Null

"Now we can move to the next part of scheduling user folder creation.
Firstly we need to install AD PowerShell module feature on your server. So open a PowerShell console and typeInstall-WindowsFeature RSAT-AD-PowerShell and hit enter." -Mahdi Tehrani

Open Task Scheduler and ‘Create task’.
On the ‘General’ tab, make sure that the ‘Run whether user is logged on or not’ is selected.
On the ‘Triggers’ tab, click on ‘New’.
At the ‘New Trigger’ windows, configure the task repetition to every 15 minutes, and click ‘Ok’.
At the next tab which is ‘Action’, we should add the script which does the Folder Creation. Click on ‘New’ and add the script.
And for the final part, at ‘Settings’ tab, configure the task to get stopped if it was running for more than an hour.


# Cleanup process
During our solution, we understood that we can utilize a simple txt file in order to limit the number of logins a user can have and so far we have talked about how this process will happen. As you may guess, during the time we need to make sure there are no Phantom text files in a user folder because if there are the user will not be able to login because of a text file which points to no one.
In order to fix that, we need to delete text file for each user in a short scheduled time. What we will do is to create a task which deletes all the next files in a folder for every single user account. You may ask, if we delete the text files, how the logon script will work in absence of these files? The answer is simple! The logon script actually overwrite text file every 10 seconds. Let’s make this clear with an example:
	• User A logs on.
	• Text file is created.
	• Clean Up script will delete all text files.
	• Text file for user A is again created.
	• The clean up process repeats.
	• Text file for user A is again created.
	• User A logs off.
	• The logoff script will delete the text file.
	• Since the user has logged off, the logon script no longer applies any more and the user folder remains empty.
After all the explanation, we need to create our cleanup process. But before that, do not forget to change the script just like the previous steps:

            Get-ChildItem -Path "C:\Profiles" -Filter *.txt -Recurse | Remove-Item -Force 

-- more instructions coming soon
