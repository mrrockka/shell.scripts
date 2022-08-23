param(
	[Parameter()]
	[string]$path = ".",
	
	[Parameter()]
	[switch]$nopar
)

echoc "Opening $path in idea" Blue -newline

$cmd = "idea64 $path"

if (!$nopar.isPresent) {
	$cmd = "Start-Job -ScriptBlock { $cmd }"
}

iex $cmd