param(
	[Parameter()]
	[switch]$mvn,

	[Parameter()]
	[switch]$notest,
	
	[Parameter()]
	[switch]$logs,
	
	[Parameter()]
	[String]$only,
	
	[Parameter()]
	[String]$attach,
	
	[Parameter()]
	[switch]$nobuild,
	
	[Parameter()]
	[switch]$norun,
	
	[Parameter()]
	[switch]$usecache
)


### MAVEN BUILD

$mvnCmd = "mvn clean package"
if($notest.isPresent){
	$mvnCmd += " '-Dmaven.test.skip=true'"
}
if($mvn.isPresent){
	echoc "###`nRunning ${mvnCmd}`n###" Yellow -newline
	$folder = (Get-Item -Path './' -Verbose).Name
	cd ..
	iex $mvnCmd
	cd $folder
}

### ---

### DOCKER COMPOSE PREPARATIONS
docker compose stop

docker_clean -containers -dandling -logs -volumes

### ---

### DOCKER COMPOSE BUILD
$buildCmd = "docker compose build --force-rm"
if(!$usecache.isPresent) {
	$buildCmd += " --no-cache"
}

if(!$nobuild.isPresent){
	echoc "###`nRunning ${buildCmd}`n###" Yellow -newline
	iex $buildCmd
}

### ---

### DOCKER COMPOSE UP

$runCmd = "docker compose up "

if($only){
	$runCmd += "${only} "
}

$runCmd += "--remove-orphans --force-recreate"

if(!$logs.isPresent) {
	$runCmd += " --detach"
}

if(!$norun.isPresent){
	echoc "###`nRunning ${runCmd}`n###" Yellow -newline
	iex $runCmd
}


### ---
if($attach -and !$logs.isPresent) {
	docker_attach $attach
}