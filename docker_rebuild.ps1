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
	[switch]$nocache
)


Set-Variable "mvnCommand" "mvn clean package"
if($skipTests.isPresent){
	$mvnCommand += " '-Dmaven.test.skip=true'"
}
if($mvn.isPresent){
	iex $mvnCommand
}

Set-Variable "runCmd" "docker-compose build"
if($nocache.isPResent) {
	$runCmd += " --no-cache"
}

$runCmd += ';docker compose up --remove-orphans'
if(!$logs.isPResent) {
	$runCmd += " --detach"
}

if($recreate.isPResent) {
	$runCmd += " --force-recreate"
}

iex $runCmd

docker images --filter "dangling=true" -q | % { docker rmi $_ }