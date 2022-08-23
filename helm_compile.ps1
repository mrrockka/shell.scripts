param(
	[Parameter()]
	[switch]$noupd,
	
	[Parameter()]
	[switch]$noclean,
	
	[Parameter()]
	[string]$output = 'target'
)

if(!$noclean.isPresent){
	if(Test-Path -Path $output){
		echoc "Removing ${output} dir" Blue -newline
		Remove-Item -Path $output -Recurse
		echoc "Removed" Blue -newline
	}
}

if(!$noupd.isPresent){
	helm dependency update
}

helm template . --output-dir $output --debug