param(
	[Parameter()]
	[string]$find,
	
	[Parameter()]
	[switch]$noarray
)

$pathStr = $env:Path;

if ( $noarray.isPresent ) {
	return $pathStr;
}

$pathArr = $pathStr -split ";";

if( $find ) {
	return $pathArr -match "$find";
} else { 
	return $pathArr;
}
