# PSSchedule
This script simplifies the creation of scheduled tasks for powershell scripts that need to run every x minutes.

Edit the following input vars before running.
#Powershell Command path
$PSCommand ="$SCRIPT_PARENT\calc.ps1" 

#Reoccuring number of minutes
$intervalMInutes=1

#Max execution time in minutes
$execMaxMinutes=60

#Task Name
$TaskName = "Anon WatchList"

#Runlevel Highest or Limited
$RunLevelHigh = $false

#Chose who to run as
$JobRunAs =$RunAsLogedOnUser   
