param(
	[Parameter(Mandatory)]
	[string]$ancestor,
	
	[Parameter()]
	[string]$console = '/bin/bash'
)

docker ps -f ancestor=$ancestor -q | % { docker exec -it $_ $console }