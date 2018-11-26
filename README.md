# PSSchedule
This PowerShell script simplifies the creation of scheduled tasks to run other PowerShell scripts.

It is common for IT Admins to need to run scripts at a regular intervals.
This scripts takes a number of parameters that need to run every x minutes.
The script will create the command in the correct format to run a PowerShell script

Edit the following input vars before running.


$PSCommand ="$SCRIPT_PARENT\calc.ps1"   #Powershell Command path

$intervalMInutes=1                      #Reoccuring number of minutes

$execMaxMinutes=60                      #Max execution time in minutes

$TaskName = "Anon WatchList"            #Task Name

$RunLevelHigh = $false                  #Runlevel Highest or Limited

$JobRunAs =$RunAsLogedOnUser            #Task identity
