param(
	[Parameter(mandatory)]
	[string]$stg,
	
	[Parameter(mandatory)]
	[string]$color,
	
	[Parameter()]
	[switch]$newline
)

$cmd = "Write-Host '${stg}' -ForegroundColor ${color}"

if(!$newline.isPresent){
	$cmd += " -NoNewline"
}

iex $cmd