param(
	[Parameter()]
	[switch]$mvn,

	[Parameter()]
	[switch]$skipTests,
	
	[Parameter()]
	[switch]$logs,
	
	[Parameter()]
	[switch]$recreate,
		
	[Parameter()]
	[switch]$attach,
	
	[Parameter()]
	[switch]$nocache
)


### MAVEN BUILD

$mvnCmd = "mvn clean package"
if($skipTests.isPresent){
	$mvnCmd += " '-Dmaven.test.skip=true'"
}
if($mvn.isPresent){
	echoc "###`nRunning ${mvnCmd}`n###" Yellow -newline
	iex $mvnCmd
}

### ---

### DOCKER COMPOSE PREPARATIONS
docker compose stop

$logFolder = $PWD.Path + "\logs"

if(Test-Path -Path $logFolder){
	Remove-Item -Path $logFolder -Recurse
}

docker_clean -images -containers

### ---

### DOCKER COMPOSE BUILD
$buildCmd = "docker compose build"
if($nocache.isPresent) {
	$buildCmd += " --no-cache"
}

if($recreate.isPresent) {
	$buildCmd += " --force-rm"
}

echoc "###`nRunning ${buildCmd}`n###" Yellow -newline
iex $buildCmd

### ---

### DOCKER COMPOSE UP

$runCmd = 'docker compose up --remove-orphans'
if(!$logs.isPresent) {
	$runCmd += " --detach"
}

if($recreate.isPresent) {
	$runCmd += " --force-recreate"
}

echoc "###`nRunning ${runCmd}`n###" Yellow -newline
iex $runCmd

### ---

if($attach.isPresent) {
	docker_attach (docker compose ps --services)
}

