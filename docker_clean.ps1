param(
	[Parameter()]
	[switch]$all,
	
	[Parameter()]
	[switch]$containers,
	
	[Parameter()]
	[switch]$images,
	
	[Parameter()]
	[switch]$dandling,
	
	[Parameter()]
	[switch]$volumes,
	
	[Parameter()]
	[switch]$logs
)


### CLEARS CONTAINERS AND IMAGES FROM PREVIOUS VERSION OF IMAGE
echoc "###`nStarting to clear`n###" Blue -newline
if($dandling.isPresent){
	docker images -f "dangling=true" -q | Set-Variable "dangling"
	$dangling | % {docker ps -a -f ancestor=$_ -q} | %{docker stop $_; docker rm $_}
	$dangling | % { docker rmi $_ }
}

if($containers.isPresent -or $all.isPresent){
	docker ps -a -q | %{docker stop $_; docker rm $_}
}

if($images.isPresent -or $all.isPresent){
	docker images -a -q | %{docker rmi -f $_}
}

if($volumes.isPresent -or $all.isPresent){
	docker volume ls -q | %{ docker volume rm $_ }
}

if($logs.isPresent -or $all.isPresent){
	
	$logFolder = $PWD.Path + "\..\logs"

	if(Test-Path -Path $logFolder){
		Remove-Item -Path $logFolder -Recurse
	}
}


echoc "###`nClear is Done`n###" Blue -newline