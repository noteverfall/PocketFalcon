#!/usr/bin/pwsh -Command
if (-not (Test-FalconToken).Token) {
  Write-Host "No valid token, please re-authenticate first! Quitting script."
  Exit
}
$aid = Read-Host -Prompt "Enter the host agent id (aid) to network contain"
if ((Invoke-FalconHostAction -Name contain -Ids $aid).id -eq $aid){
  Write-Host "Device successfully network contained!"
}
else{
  $hostStatus = (Get-FalconHost -Ids $aid).status
  Write-Host "Something went wrong, check aid.`nCurrent host status is: $hostStatus"
}
