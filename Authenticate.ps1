#!/usr/bin/pwsh -Command
# OAuth2 credentials should be stored in the same folder you are running the script from, in a file named creds.txt, with Client ID on the first line, and Client Secret on the second line
$clientId = (Get-Content -Path ./creds.txt -TotalCount 2)[0]
$clientSecret = (Get-Content -Path ./creds.txt -TotalCount 2)[1]
Request-FalconToken -ClientId $clientId -ClientSecret $clientSecret
if ((Test-FalconToken).Token){
  Write-Host "Authentication token request was successful"
}
else{
  Write-Host "Error getting an authentication token, please check credentials and try again"
}
