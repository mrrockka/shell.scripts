param(	
	[Parameter(mandatory)]
	[string]$repo,
	
	[Parameter()]
	[string]$path = 'C:\Work\docomo\repos',
	
	[Parameter()]
	[Switch]$open
	
)

$url = ($repo -replace "git clone ", "")
echoc "Tryind cloning repo from $url to $path" Blue -newline
git -C $path clone $url

if($open.isPresent){
	$repo_name = [regex]::match($url, "\/(.*)\.git").Groups[1].Value;
	run_idea $env:Repos/$repo_name
}