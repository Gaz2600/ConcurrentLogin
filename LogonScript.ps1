#############################################################
# Referances - This script was written using ideas from these locations
#
# http://www.scconfigmgr.com/2016/10/03/powershell-gui-reboot-prompt/
# https://social.technet.microsoft.com/wiki/contents/articles/37839.active-directory-limit-concurrent-user-logins.aspx
# https://www.reddit.com/r/PowerShell/comments/7gq6hx/exit_a_form_but_still_run_a_loop/
# https://poshgui.com/#
# https://social.technet.microsoft.com/Forums/Lync/en-US/a5773d51-6b01-4428-802a-21e2c7ac9d5e/handle-close-button-on-wpf-window-with-powershell?forum=ITCG
# https://pastebin.com/
#
#############################################################

#############################################################
# Edit to fit your environment
 #Enter the location of where you want the user file to be stored
 $UserFileLocation = "\\concurrentlogin\Profiles$\$env:username\1.txt"
#------------------------------------------------------------
 $computer = get-content $UserFileLocation #Do not edit
#------------------------------------------------------------
 #Enter the location of the personalized logo, max height should be 65px and max width should be 380px
 $LogoLocation = "\\..\smallvector.png"
#------------------------------------------------------------
 #Enter the txt you want to appear in the Window title bar
 $MainFormTitle = "IT Security Policy Violation"
#------------------------------------------------------------
 #Enter the txt you want to appear in the window header
 $WindowTitleMsg = "WARNING: You Are Logged Into Multiple Locations"
#------------------------------------------------------------
 #Enter the txt you wan to appear in the window body line 320
 $Body = "IT security policy allows users to log onto one workstation at a time.  You are already logged onto workstation $computer; therefore, you will be automatically logged off this workstation in 60 seconds.  

If you need additional assistance please contact the Helpdesk."
#------------------------------------------------------------
 #Enter the total time in seconds befor auto logoff, keep in mind the total time it takes for a new user to login and for windows to create the profile.
 $TimeSec = 60 
#
#############################################################

 if(Test-Path $UserFileLocation)
{

#----------------------------------------------
#region Import Assemblies
#----------------------------------------------
 [void][Reflection.Assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
 [void][Reflection.Assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
 [void][Reflection.Assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

 function Main {

 Param ([String]$Commandline)
 
 if((Call-MainForm_psf) -eq 'OK')
 {
 }
 $global:ExitCode = 0
 }

#region Source: MainForm.psf
 function Call-MainForm_psf
{

 #----------------------------------------------
 #region Import the Assemblies
 #----------------------------------------------
 [void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
 [void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
 [void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

 #----------------------------------------------
 #region Generated Form Objects
 #----------------------------------------------
 Add-Type -AssemblyName System.Windows.Forms

 $MainForm = New-Object 'System.Windows.Forms.Form'
 $panel2 = New-Object 'System.Windows.Forms.Panel'
 #$ButtonCancel = New-Object 'System.Windows.Forms.Button'
 $ButtonLogoffRemote = New-Object 'System.Windows.Forms.Button'
 $ButtonLogoffLocal = New-Object 'System.Windows.Forms.Button'
 $panel1 = New-Object 'System.Windows.Forms.Panel'
 $labelITSystemsMaintenance = New-Object 'System.Windows.Forms.Label'
 $labelSecondsLeftToLogoff = New-Object 'System.Windows.Forms.Label'
 $labelTime = New-Object 'System.Windows.Forms.Label'
 $labelInOrderToApplySecuri = New-Object 'System.Windows.Forms.Label'
 $timerUpdate = New-Object 'System.Windows.Forms.Timer'
 $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
 $Logo = New-Object 'system.windows.Forms.PictureBox'

 #----------------------------------------------
 # User Generated Script
 #----------------------------------------------
 $TotalTime = $TimeSec
 $MainForm_Load={
 $labelTime.Text = "{0:D2}" -f $TotalTime
 $script:StartTime = (Get-Date).AddSeconds($TotalTime)
 $timerUpdate.Start()
 }

 $timerUpdate_Tick={
 [TimeSpan]$span = $script:StartTime - (Get-Date)
 $labelTime.Text = "{0:N0}" -f $span.TotalSeconds
 $timerUpdate.Start()
 if ($span.TotalSeconds -le 0)
 {
 $timerUpdate.Stop()
 Shutdown /l /f
 }
 }

 $ButtonLogoffLocal_Click = {
 Shutdown /l /f
 }

 #----------------------------------------------
 # Log off remote computer
 #----------------------------------------------
 $ButtonLogOffRemote_Click={
 $computer = get-content $UserFileLocation
 $session = ((& quser /server:$computer | ? { $_ -match $env:username }) -split ' +')[2]
 $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
 logoff $session /server:$computer
    Remove-Item $UserFileLocation
    $MainForm.Hide()
    $Pivot = 1
    $hostname = & hostname
        DO {
        New-Item $UserFileLocation -type file -Force | Out-Null
        Add-Content $UserFileLocation $hostname
        Start-Sleep -s 10
        }
    while ($Pivot -ne 0)
}

<#
 $ButtonCancel_Click={
 $MainForm.Close()
 }
 #>

 $labelITSystemsMaintenance_Click={
 }

 $panel2_Paint=[System.Windows.Forms.PaintEventHandler]{
 }

 $labelTime_Click={
 }

 #----------------------------------------------
 #region Generated Events
 #----------------------------------------------
 $Form_StateCorrection_Load=
 {
 $MainForm.WindowState = $InitialFormWindowState
 }

 $Form_StoreValues_Closing=
 {
 }

 $Form_Cleanup_FormClosed=
 {
 try
 {

#$ButtonCancel.remove_Click($buttonCancel_Click)
 $ButtonLogoffRemote.remove_Click($ButtonLogoffRemote_Click)
 $ButtonLogoffLocal.remove_Click($ButtonLogoffLocal_Click)
 $panel2.remove_Paint($panel2_Paint)
 $labelITSystemsMaintenance.remove_Click($labelITSystemsMaintenance_Click)
 $labelTime.remove_Click($labelTime_Click)
 $MainForm.remove_Load($MainForm_Load)
 $timerUpdate.remove_Tick($timerUpdate_Tick)
 $MainForm.remove_Load($Form_StateCorrection_Load)
 $MainForm.remove_Closing($Form_StoreValues_Closing)
 $MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
 }
 catch [Exception]
 { }
 }

 #----------------------------------------------
 #region Generated Form Code
 #----------------------------------------------
 $MainForm.SuspendLayout()
 $panel2.SuspendLayout()
 $panel1.SuspendLayout()
 #
 # MainForm
 #
 $MainForm.Controls.Add($panel2)
 $MainForm.Controls.Add($panel1)
 $MainForm.Controls.Add($labelSecondsLeftToLogoff)
 $MainForm.Controls.Add($labelTime)
 $MainForm.Controls.Add($labelInOrderToApplySecuri)
 $MainForm.AutoScaleDimensions = '6, 13'
 $MainForm.AutoScaleMode = 'Font'
 $MainForm.BackColor = 'White'
 $MainForm.ClientSize = '600, 300'
 $MainForm.MaximizeBox = $False
 $MainForm.MinimizeBox = $False
 $MainForm.Name = 'MainForm'
 $MainForm.ShowIcon = $False
 $MainForm.ShowInTaskbar = $False
 $MainForm.StartPosition = 'CenterScreen'
 $MainForm.Text = $MainFormTitle
 $MainForm.TopMost = $False
 $MainForm.add_Load($MainForm_Load)
 $MainForm.Add_Closing({$_.Cancel = $true})
 #
 # Bottom Panel2 (Grey)
 #
 #$panel2.Controls.Add($ButtonCancel)
 $panel2.Controls.Add($ButtonLogoffRemote)
 $panel2.Controls.Add($ButtonLogoffLocal)
 $panel2.Controls.Add($Logo)
 $panel2.BackColor = 'ScrollBar'
 $panel2.Location = '0, 235'
 $panel2.Name = 'panel2'
 $panel2.Size = '600, 65'
 $panel2.TabIndex = 9
 $panel2.add_Paint($panel2_Paint)
 #
 #Logo
 #
 $Logo.Width = 58
 $Logo.Height = 65
 $Logo.Width = 58
 $Logo.Height = 65
 $Logo.location = new-object system.drawing.point(1,1)
 $Logo.ImageLocation = $LogoLocation
 #
 # ButtonCancel (Disable in live version)
<#
 $ButtonCancel.Location = '70, 12'
 $ButtonCancel.Name = 'ButtonCancel'
 $ButtonCancel.Size = '77, 45'
 $ButtonCancel.TabIndex = 7
 $ButtonCancel.Text = 'Cancel'
 $ButtonCancel.UseVisualStyleBackColor = $True
 $ButtonCancel.add_Click($buttonCancel_Click)
 #>
 # ButtonLogoffRemote
 # 
 $ButtonLogoffRemote.Font = 'Microsoft Sans Serif, 8.25pt, style=Bold'
 $ButtonLogoffRemote.Location = '385, 12'
 $ButtonLogoffRemote.Name = 'ButtonSchedule'
 $ButtonLogoffRemote.Size = '105, 45'
 $ButtonLogoffRemote.TabIndex = 6
 $ButtonLogoffRemote.Text = "Logoff (Remote)"
 $ButtonLogoffRemote.UseVisualStyleBackColor = $True
 $ButtonLogoffRemote.add_Click($ButtonLogOffRemote_Click)
 #
 # ButtonLogoffLocal
 #
 $ButtonLogoffLocal.Font = 'Microsoft Sans Serif, 8.25pt, style=Bold'
 $ButtonLogoffLocal.Location = '500, 12'
 $ButtonLogoffLocal.Name = 'ButtonRestartNow'
 $ButtonLogoffLocal.Size = '95, 45'
 $ButtonLogoffLocal.TabIndex = 0
 $ButtonLogoffLocal.Text = "Logoff (Local)"
 $ButtonLogoffLocal.UseVisualStyleBackColor = $True
 $ButtonLogoffLocal.add_Click($ButtonLogoffLocal_Click)
 #
 # Top Panel1 (Red)
 #
 $panel1.Controls.Add($labelITSystemsMaintenance)
 $panel1.BackColor =   '255, 100, 100'
 $panel1.Location = '0, 0'
 $panel1.Name = 'panel1'
 $panel1.Size = '600, 67'
 $panel1.TabIndex = 8
 #
 # labelITSystemsMaintenance
 #
 $labelITSystemsMaintenance.Font = 'Microsoft Sans Serif, 16pt, style=Bold'
 $labelITSystemsMaintenance.ForeColor = 'White'
 $labelITSystemsMaintenance.Location = '11, 3'
 $labelITSystemsMaintenance.Name = 'labelITSystemsMaintenance'
 $labelITSystemsMaintenance.Size = '600, 60'
 $labelITSystemsMaintenance.TabIndex = 1
 $labelITSystemsMaintenance.Text = $WindowTitleMsg
 $labelITSystemsMaintenance.TextAlign = 'MiddleLeft'
 $labelITSystemsMaintenance.add_Click($labelITSystemsMaintenance_Click)
 #
 # labelSecondsLeftToLogoff
 #
 $labelSecondsLeftToLogoff.AutoSize = $True
 $labelSecondsLeftToLogoff.Font = 'Microsoft Sans Serif, 11pt, style=Bold'
 $labelSecondsLeftToLogoff.Location = '365, 200'
 $labelSecondsLeftToLogoff.Name = 'labelSecondsLeftToRestart'
 $labelSecondsLeftToLogoff.Size = '43, 15'
 $labelSecondsLeftToLogoff.TabIndex = 5
 $labelSecondsLeftToLogoff.Text = 'You will be logged off in:'
 #
 # labelTime
 #
 $labelTime.AutoSize = $True
 $labelTime.Font = 'Microsoft Sans Serif, 18pt, style=Bold'
 $labelTime.ForeColor = '192, 0, 0'
 $labelTime.Location = '545, 191'
 $labelTime.Name = 'labelTime'
 $labelTime.Size = '43, 15'
 $labelTime.TabIndex = 3
 $labelTime.Text = '00:60'
 $labelTime.TextAlign = 'MiddleCenter'
 $labelTime.add_Click($labelTime_Click)
 #
 # labelInOrderToApplySecuri
 # 
 $labelInOrderToApplySecuri.Font = 'Microsoft Sans Serif, 11pt'
 $labelInOrderToApplySecuri.Location = '12, 84'
 $labelInOrderToApplySecuri.Name = 'labelInOrderToApplySecuri'
 $labelInOrderToApplySecuri.Size = '580, 95'
 $labelInOrderToApplySecuri.TabIndex = 2
 $labelInOrderToApplySecuri.Text = $Body
 #
 # timerUpdate
 #
 $timerUpdate.add_Tick($timerUpdate_Tick)
 $panel1.ResumeLayout()
 $panel2.ResumeLayout()
 $MainForm.ResumeLayout()

 #----------------------------------------------

 $InitialFormWindowState = $MainForm.WindowState
 $MainForm.add_Load($Form_StateCorrection_Load)
 $MainForm.add_FormClosed($Form_Cleanup_FormClosed)
 $MainForm.add_Closing($Form_StoreValues_Closing)
 return $MainForm.ShowDialog()
 }
 Main ($CommandLine)
 }

else
{
    $Pivot = 1
    $hostname = & hostname
        DO {
        New-Item $UserFileLocation -type file -Force | Out-Null
        Add-Content $UserFileLocation $hostname
        Start-Sleep -s 10
    }
    while ($Pivot -ne 0)
}

