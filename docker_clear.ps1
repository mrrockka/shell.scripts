### CLEARS CONTAINERS AND IMAGES FROM PREVIOUS VERSION OF IMAGE
docker images -f "dangling=true" -q | Set-Variable "dangling"
$dangling | % {docker ps -a -f ancestor=$_ -q} | %{docker stop $_; docker rm $_}
$dangling | % { docker rmi $_ }

echo "Clear is Done"