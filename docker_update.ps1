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
	[switch]$noclean,
	
	[Parameter()]
	[string]$file,
	
	[Parameter()]
	[string]$args = ''
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
}, 
[PSCustomObject]@{
	Name = "norun" 
	Value = $norun
}

$break = $temp = 0; $params | % {$temp += [int]$_.Value.isPresent; echo [int]$_.Value}; echo $temp; if($temp -gt 1) { $true } else { $false }

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


if($args){
	$buildParams += "--build-arg ${args}"	
}

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

if(!$noclean.isPresent){
	docker_clean -dandling
}
### DOCKER RUN
$runParams = @()

#Configuring ports of container
$debugPort = $port
if ($port -eq '80'){
	$debugPort = '005'
}

$runParams += "-p ${port}:8080" 
$runParams += "-p 5${debugPort}:5005"

#Agregating run options
$runCmd = "docker run --rm"
$runParams | % { $runCmd += ' ' + $_ }; $runCmd += " ${imageName}"

if($dbg.isPresent) {
	$runCmd = "docker run -it ${imageName}"
	echoc "###`nRunning ${runCmd}`n###" Yellow -newline
	iex $runCmd
} 

if(!$norun.isPresent -and !$dbg.isPresent){
	echoc "###`nRunning ${runCmd}`n###" Yellow -newline
	iex $runCmd | Set-Variable "token"
	echo "Container token " $token
}

### ---

###ATTACH TO CONTAINER LOGS
if ($logs.isPresent) {
	docker logs -f $token
}

###ATTACH WITH SHELL TO CONTAINER
if ($attach.isPresent) {
	docker_attach $imageName
}

