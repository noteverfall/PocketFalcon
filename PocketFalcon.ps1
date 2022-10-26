# PocketFalcon v0

function Pocket-Menu{
""
Write-Host "====" -NoNewline
Write-Host " Pocket Falcon Main Menu " -ForegroundColor Red -NoNewline
Write-Host "===="
Write-Host "[1] " -ForegroundColor Yellow -NoNewline; Write-Host "Add tags to host" -ForegroundColor Green
Write-Host "[2] " -ForegroundColor Yellow -NoNewline; Write-Host "Network contain a host" -ForegroundColor Green
Write-Host "[3] " -ForegroundColor Yellow -NoNewline; Write-Host "Find aid for a specific hostname" -ForegroundColor Green
Write-Host "[4] " -ForegroundColor Yellow -NoNewline; Write-Host "Get full Detection details from a DetectID" -ForegroundColor Green
Write-Host "[5] " -ForegroundColor Yellow -NoNewline; Write-Host "Lift network containment on a host" -ForegroundColor Green
Write-Host "[6] " -ForegroundColor Yellow -NoNewline; Write-Host "Generate popup message on host for active users" -ForegroundColor Green
Write-Host "[7] " -ForegroundColor Yellow -NoNewline; Write-Host "Read current tags on a host" -ForegroundColor Green
Write-Host "[8] " -ForegroundColor Yellow -NoNewline; Write-Host "Update a Detection (status, assignee, or comment)" -ForegroundColor Green
Write-Host "[Q] " -ForegroundColor Yellow -NoNewline; Write-Host "Type q to quit" -ForegroundColor Red
}

function Pocket-FullAuth{
# OAuth2 credentials should be stored in the same folder you are running the script from, in a file named creds.txt, with Client ID on the first line, and Client Secret on the second line
$clientId = (Get-Content -Path ./creds.txt -TotalCount 2)[0]
$clientSecret = (Get-Content -Path ./creds.txt -TotalCount 2)[1]
Request-FalconToken -ClientId $clientId -ClientSecret $clientSecret
if ((Test-FalconToken).Token){
  Write-Host "Authentication token request was successful!"
}
else{
  Write-Host "Error getting an authentication token, please check credentials and try again"
  Exit
}
}

function Pocket-CheckAuth{
if (-not (Test-FalconToken).Token) {
  Write-Host "Token has expired, getting a new one..."
  Pocket-FullAuth
}
}

function Pocket-AddTags{
Pocket-CheckAuth
$aid = Read-Host "Enter the aid of the host to add a tag to"
$tag = Read-Host "Enter the tag you would like to add (no spaces allowed)"
$result = (Add-FalconGroupingTag -Ids $aid -Tags FalconGroupingTags/$tag)
if ($result.updated -eq "True"){
  Write-Host "Tag was successfully added!"
}
else{
  Write-Host "Something went wrong, try again"
}
""
Pause
}

function Pocket-ContainHost{
Pocket-CheckAuth
$aid = Read-Host "Enter the host agent id (aid) to network contain"
$result = (Invoke-FalconHostAction -Name contain -Ids $aid)
if ($result.id -eq $aid){
  Write-Host "Device successfully network contained!"
}
else{
  $hostStatus = (Get-FalconHost -Ids $aid).status
  Write-Host "Something went wrong, check aid.`nCurrent host status is: $hostStatus"
}
""
Pause
}

function Pocket-FindAid{
Pocket-CheckAuth
$name = Read-Host "Enter the exact hostname to search for (case sensitive)"
$result = Find-FalconHostname -Array $name
Write-Host ($result | Format-Table | Out-String)
Pause
}

function Pocket-DetectDetails{
$detection = Read-Host "Enter the detection ID to get full details on (in format ldt:abc123:123)"
$result = Get-FalconDetection -Ids $detection
echo $result
""
Pause
}

function Pocket-LiftContainment{
$aid = Read-Host "Enter the host agent id (aid) to lift containment on"
$result = (Invoke-FalconHostAction -Name lift_containment -Ids $aid)
if ($result.id -eq $aid){
  Write-Host "Successfully lifted network containment!"
}
else{
  $hostStatus = (Get-FalconHost -Ids $aid).status
  Write-Host "Something went wrong, check aid.`nCurrent host status is: $hostStatus"
}
""
Pause
}

function Pocket-PopupMessage{
Pocket-CheckAuth
$aid = Read-Host "Enter the aid of the target host"
$message = Read-Host "Enter the message to popup remotely"
$result = Invoke-FalconRtr -Command runscript -Argument "-Raw='msg * /server:localhost $message'" -HostIds $aid
if ($result.complete -ne $null){
  Write-Host "Success!"
}
else{
  Write-Host "Error, host might be offline or AID might be wrong"
}
""
Pause
}

function Pocket-ReadTags{
$aid = Read-Host "Enter the aid of the host to read tags from"
$result = (Get-FalconHost -Ids $aid)
if ($result.device_id -ne $null){
  Write-Host "Current tags are:"
  echo $result.tags
}
else{
  Write-Host "Something went wrong, try again"
}
""
Pause
}

function Pocket-UpdateDetection{
$detection = Read-Host "Enter the detection ID to update (in format ldt:abc123:123)"
$choice = Read-Host "Which field do you want to update?`n[1] Status`n[2] Assigned To`n[3] Add a comment`n"
if ($choice -eq 1){
  $currentStatus = (Get-FalconDetection -Id $detection).status
  Write-Host "Current status is " -NoNewline
  Write-Host $currentStatus -ForegroundColor Green
  $choice2 = Read-Host "Which status would you like to set it to?`n[1] New`n[2] In Progress`n[3] True Positive`n[4] False Positive`n[5] Ignored`n[6] Closed`n[7] Reopened`n"
  $newStatus = switch ($choice2) {
    1 {"new"}
    2 {"in_progress"}
    3 {"true_positive"}
    4 {"false_positive"}
    5 {"ignored"}
    6 {"closed"}
    7 {"reopened"}
  }
  $result = Edit-FalconDetection -Id $detection -Status $newStatus
  Write-Host "Detection status updated."
}
elseif ($choice -eq 2){
  Write-Host "Available user list:"
  $result = Get-FalconUser -Detailed
  echo $result
  $assignee = Read-Host -Prompt "Enter the uuid to assign the Detection to"
  $result = Edit-FalconDetection -Id $detection -AssignedToUuid $assignee
  Write-Host "Detection assignment updated."
}
elseif ($choice -eq 3){
  $currentStatus = (Get-FalconDetection -Id $detection).status
  $comment = Read-Host "Enter a comment to add to the Detection"
  $result = Edit-FalconDetection -Id $detection -Status $currentStatus  -Comment $comment
  Write-Host "Detection updated with comment."
}
""
Pause
}

# MAIN
Write-Host "Welcome to Pocket Falcon!"
Write-Host "Authenticating..."
Pocket-FullAuth
do{
Pocket-Menu
$menuSelection = Read-Host "Please select an option"
switch ($menuSelection){
'1'{Pocket-AddTags}
'2'{Pocket-ContainHost}
'3'{Pocket-FindAid}
'4'{Pocket-DetectDetails}
'5'{Pocket-LiftContainment}
'6'{Pocket-PopupMessage}
'7'{Pocket-ReadTags}
'8'{Pocket-UpdateDetection}
}
} until ($menuSelection -eq 'q')
Exit
