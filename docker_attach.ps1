param(
	[Parameter()]
	[string]$ancestor = (Get-Item -Path '.\' -Verbose).Name,
	
	[Parameter()]
	[string]$console = '/bin/bash'
)

docker ps -f ancestor=$ancestor -q | % { docker exec -it $_ $console }