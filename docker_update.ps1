param(
	[Parameter()]
	[string]$imageName = (Get-Item -Path '.\' -Verbose).Name,
	
	[Parameter()]
	[string]$port = '80',

	[Parameter()]
	[switch]$logs,

	[Parameter()]
	[switch]$dbg,

	[Parameter()]
	[switch]$mvn,

	[Parameter()]
	[switch]$skipTests,

	[Parameter()]
	[switch]$nocache,

	[Parameter()]
	[switch]$attach,
	
	[Parameter()]
	[switch]$norun,	
	
	[Parameter()]
	[switch]$nobuild,
	
	[Parameter()]
	[string]$file
)

### PARAMS VALIDATION
$params = [PSCustomObject]@{
	Name = "logs" 
	Value = $logs
}, 
[PSCustomObject]@{
	Name = "attach" 
	Value = $attach
}, 
[PSCustomObject]@{
	Name = "dbg" 
	Value = $dbg
}
$break = $temp; $params | % {$temp += [int]$_.Value.isPresent}; if($temp -gt 1) { $true } else { $false }

if($break){
	$message = ($params | % { $_.Name + ' ' }).trim()
	echoc "SCRIPT ERROR:" Red; echo " Can't attach to container's logs and attach with shell at same time. Remove one of [${message}] flags"
	exit 
}

### MAVEN BUILD
$mvnCmd = "mvn clean package "
if($skipTests.isPresent){
	$mvnCmd += "'-Dmaven.test.skip=true'"
}

if($mvn.isPresent){
	echoc "###`nRunning ${mvnCmd}`n###" Yellow -newline
	iex $mvnCmd
}
### ---

### DOCKER BUILD
$buildParams = @()
if ($imageName -ne $null) {
	$buildParams += "-t " + $imageName.trim()
}

if ($nocache.isPresent) {
	$buildParams += "--no-cache"
}

if ($file) {
	$buildParams += "-f " + $file.trim()
}

#Agregating build options
$buildCmd = "docker build"
$buildParams | % { $buildCmd += ' ' + $_ }; $buildCmd += " ."

if(!$nobuild.isPresent){
	echoc "###`nRunning ${buildCmd}`n###" Yellow -newline
	iex $buildCmd
}

### ---

docker_clear $imageName

### DOCKER RUN
$runParams = @()

#Configuring ports of container
$debugPort = $port
if ($port -eq '80'){
	$debugPort = '005'
}

$runParams += "-p ${port}:8080" 
$runParams += "-p 5${debugPort}:5005"

if(!$logs.isPresent) {
	$runParams += "-d"
}

#Agregating run options
$runCmd = "docker run --rm"
$runParams | % { $runCmd += ' ' + $_ }; $runCmd += " ${imageName}"

if(!$norun.isPresent){
	echoc "###`nRunning ${runCmd}`n###" Yellow -newline
	iex $runCmd | Set-Variable "token"
	echo "Container token " $token
}

### ---

###ATTACH WITH SHELL TO CONTAINER
if ($attach.isPresent) {
	docker_attach $imageName
}

