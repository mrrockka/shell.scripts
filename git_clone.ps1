param(	
	[Parameter(mandatory)]
	[string]$repo,
	
	[Parameter()]
	[string]$path = 'C:\Work\docomo\repos',
	
	[Parameter()]
	[Switch]$noopen
	
)

$url = ($repo -replace "git clone ", "")
echoc "Tryind cloning repo from $url to $path" Blue -newline
git -C $path clone $url

if(!$noopen.isPresent){
	$repo_name = [regex]::match($url, "\/(.*)\.git").Groups[1].Value;
	run_idea $env:Repos/$repo_name
}