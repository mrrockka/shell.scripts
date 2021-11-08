param(
	[Parameter()]
	[string]$imageName = (Get-Item -Path '.\' -Verbose).Name,
	
	[Parameter()]
	[string]$port = '80',

	[Parameter()]
	[switch]$logs,

	[Parameter()]
	[switch]$mvn,

	[Parameter()]
	[switch]$skipTests,

	[Parameter()]
	[switch]$nocache,

	[Parameter()]
	[switch]$attach,
	
	[Parameter()]
	[string]$file
)

$DOCKER_BUILDKIT=1

Set-Variable "mvnCommand" "mvn clean package "
if($skipTests.isPresent){
	$mvnCommand += "'-Dmaven.test.skip=true'"
}

if($mvn.isPresent){
	iex $mvnCommand
}

Set-Variable "debugPort" $port
if ($port -eq '80'){
	$debugPort = '005'
}


docker ps -a -f ancestor=$imageName -q | Set-Variable "containers"
if ($containers -ne $null) {
	$containers | % { docker stop $_ }
}

$buildParam = @()
if ($imageName -ne $null) {
	$buildParam += "-t " + $imageName.trim()
}

if ($nocache.isPresent) {
	$buildParam += "--no-cache"
}

if ($file -ne $null) {
	$buildParam += "-f " + $file.trim()
}

$buildCmd = "docker build"
$buildParam | % { $buildCmd += ' ' + $_ } 

$buildCmd += ' --ssh default="$ENV:USERPROFILE\.ssh\dd.bitbucket" .'
echo 'Final cmd is ' $buildCmd

iex $buildCmd

docker run --rm -d -p "${port}:8080" -p "5${debugPort}:5005" $imageName | % { Set-Variable "token" $_ }; docker images --filter "dangling=true" -q | % { docker rmi $_ }

echo $token

if ($logs.isPresent) {
	docker logs -f $token
}

if ($attach.isPresent) {
	docker_attach $imageName
}

