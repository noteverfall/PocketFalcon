#!/usr/bin/pwsh -Command
if (-not (Test-FalconToken).Token) {
  Write-Host "No valid token, please re-authenticate first! Quitting script."
  Exit
}
$aid = Read-Host -Prompt "Enter the host agent id (aid) to lift containment on"
if ((Invoke-FalconHostAction -Name lift_containment -Ids $aid).id -eq $aid){
  Write-Host "Successfully lifted network containment!"
}
else{
  $hostStatus = (Get-FalconHost -Ids $aid).status
  Write-Host "Something went wrong, check aid.`nCurrent host status is: $hostStatus"
}
