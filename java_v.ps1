param(
	[Parameter()]
	[string]$value
)

$newHome = (([Environment]::GetEnvironmentVariable("JAVA_HOME", "User")) -replace "([\d]+)", $value);
[Environment]::SetEnvironmentVariable("JAVA_HOME", $newHome, "User");
[Environment]::SetEnvironmentVariable("JAVA_HOME", $newHome, "Process");


$arr = path_tool;
$newPath = ((path_tool "java([\d]+)") -replace "([\d]+)", $value);

for ( $index = 0; $index -lt $arr.count; $index++)
{
	if($arr[$index] -match "java([\d]+)"){
		$arr[$index] = $newPath;
	}
	
}

[Environment]::SetEnvironmentVariable("Path", $($arr -join ';'), "User");
[Environment]::SetEnvironmentVariable("Path", $($arr -join ';'), "Process");


echo ("Java Path now " + [Environment]::GetEnvironmentVariable("JAVA_HOME", "User"));