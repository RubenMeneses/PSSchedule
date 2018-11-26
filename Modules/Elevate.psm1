function Elevate 
{
    Write-Host "Not running with administrative rights. Attempting to elevate..."
    $command = "-ExecutionPolicy bypass -noexit -command &'$ThisScriptFullPath'"
    Start-Process powershell -verb runas -argumentlist $command
    Exit
}