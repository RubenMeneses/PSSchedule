#This Script simplifies the creation scheduled tasks for powershell scripts
#



#region Support mods
function Get-ScriptDirectory 
{  
    if($hostinvocation -ne $null) 
    { 
        Split-Path $hostinvocation.MyCommand.path 
    } 
    else 
    { 
        Split-Path $script:MyInvocation.MyCommand.Path 
    } 
}


$SCRIPT_PARENT   = Get-ScriptDirectory  

$global:ThisScriptFullPath = $MyInvocation.MyCommand.Definition

#Module import
Import-Module "$SCRIPT_PARENT\Modules\Test-Admin.psm1"
Import-Module "$SCRIPT_PARENT\Modules\Elevate.psm1"

#endregion 
 



#Input Vars:

#Powershell Command path
$PSCommand ="$SCRIPT_PARENT\CountSecs.ps1" 

#Reoccuring number of minutes
$intervalMInutes=1

#Executoin minutes seconds
$execMaxMinutes=77

#Task Name
$TaskName = "Anon WatchList"

#Runlevel Highest or Limited
$RunLevelHigh = $false

#run as constant options
$RunAsLogedOnUser =0;$RunAsSystemUser =1;$RunAsOtherUser =2;

#Chose who to run as
$JobRunAs =$RunAsLogedOnUser   






#Do not edit past this point

#Dynamic vars

#interval to repete at.
$RepInterval=(New-TimeSpan -Minutes $intervalMInutes)

#interval to repete at.
$maxExecInterval=(New-TimeSpan -Minutes $execMaxMinutes)

#it can be any previous date or curent date, will do.
$triggerDate=Get-Date  

#create trigger(s)
$triggers = @()
#$triggers += New-ScheduledTaskTrigger -RepetitionInterval $RepInterval -Daily -At $triggerDate

$triggers += New-ScheduledTaskTrigger -Once -RepetitionInterval $RepInterval -At $triggerDate

#Starts the job next time is available,
#this is in case the device is unavailable, 
#it will run when it is next available
$taskSettings=New-ScheduledTaskSettingsSet

$taskSettings.DisallowStartIfOnBatteries=$false

$taskSettings.ExecutionTimeLimit="PT"+$execMaxMinutes+"M"

$taskSettings.StartWhenAvailable=$true






#region Main code
if(!(Test-Admin)) {
    Elevate
}
else
{
    $taskResults = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
    if(-not [System.String]::IsNullOrEmpty($taskResults))
    {$taskExists=$true}
    else 
    {$taskExists=$false}


    #Test if task excist
    if($taskExists) {
       # Do whatever 
        write-host -nonewline "Task excist, Continue to overwrite ? (Y/N) "
        $response = read-host
        if ( $response -ne "Y" ) { exit }
    } 


    #Format Command to correct format
    $PSCommandReformated = """&$PSCommand"""      # format  to "&C:\Somefolder\somefile.ps1"
    $PSCommandReformated = $PSCommandReformated -replace ' ','` '   #Format to escape spaces


    #Action for task
    #$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -command $PSCommandReformated"
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-WindowStyle Maximized -command $PSCommandReformated"


    #clear any default params
    $null=$PSDefaultParameterValues.Clear()

    #Run High level
    if ($RunLevelHigh)
    { $PSDefaultParameterValues.Add(“Register-ScheduledTask:RunLevel”,"Highest")      }


    #define creds
    if ($JobRunAs -eq $RunAsSystemUser)
    {
        $Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount 
        $PSDefaultParameterValues.Add(“Register-ScheduledTask:Principal”,$Principal) 
    }
    elseif($JobRunAs -eq $RunAsLogedOnUser)
    {
        $UserName = "$env:USERDOMAIN\$env:USERNAME"
        $Passrd = Read-Host -assecurestring "Please enter the password for user $UserName"
        $Passrd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Passrd ))
        $PSDefaultParameterValues.Add(“Register-ScheduledTask:User”,$UserName) 
        $PSDefaultParameterValues.Add(“Register-ScheduledTask:Password”,$Passrd) 

    }
    elseif($JobRunAs -eq $RunAsOtherUser)
    {
        $UserName = Read-Host "Please enter a User for task "
        $Passrd = Read-Host -assecurestring "Please enter the password for user $UserName"
        $Passrd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Passrd ))    
        $PSDefaultParameterValues.Add(“Register-ScheduledTask:User”,$UserName) 
        $PSDefaultParameterValues.Add(“Register-ScheduledTask:Password”,$Passrd) 
    }



    #create task
    $TaskResult =Register-ScheduledTask -Action $action -Trigger $triggers -TaskName $TaskName -Force -Settings $taskSettings



    Write-Host "-----------------------------"

    if (!$TaskResult)
    {
        write-host "Task was NOT created!!!"
    }
    else{
    Write-Host "The Task with the following details was successfully created"
    Write-Host "`tTaskResult.TaskName:`t`t`t $($TaskResult.TaskName)"
    Write-Host "`tTaskResult.State:`t`t`t`t $($TaskResult.State)"
    Write-Host "`tTaskResult.State:`t`t`t`t $($TaskResult.State)"
    Write-Host "`tTaskResult.Actions.Execute:`t`t $($TaskResult.Actions.Execute)"
    Write-Host "`tTaskResult.Actions.Arguments:`t $($TaskResult.Actions.Arguments)"
    Write-Host "`tTaskResult.Principal.UserId:`t $($TaskResult.Principal.UserId)"
    Write-Host "`tTaskResult.Principal.RunLevel:`t $($TaskResult.Principal.RunLevel)"
    Write-Host "`tTaskResult.Principal.LogonType:`t $($TaskResult.Principal.LogonType)"
    }


}
#endregion

