# PSSchedule
This PowerShell script simplifies the creation of scheduled tasks to run other PowerShell scripts.

It is common for IT Admins to need to run scripts at a regular intervals.
This scripts takes a number of parameters that need to run every x minutes.
The script will create the command in the correct format to run a PowerShell script

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
