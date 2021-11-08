param(
	[Parameter()]
	[string]$value
)

Set-Variable "javaPath" ([Environment]::GetEnvironmentVariable("JAVA_HOME", "User"));
Set-Variable "changeValue" (($javaPath -replace "(java)([\d]+)", '$1')+$value);

[Environment]::SetEnvironmentVariable("JAVA_HOME", $changeValue, "User");
[Environment]::SetEnvironmentVariable("JAVA_HOME", $changeValue, "Process");

echo ("Java Path was " + $javaPath);
echo ("Java Path now " + [Environment]::GetEnvironmentVariable("JAVA_HOME", "User"));