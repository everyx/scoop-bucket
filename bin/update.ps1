$ErrorActionPreference = "Stop"
$bucketDir = "$psscriptroot/../bucket"
if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }

git pull

# check update
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
Invoke-Expression -Command "$checkver -Dir $bucketDir -Update"

# generate fonts
$rootdir = "$psscriptroot/.."

$version = (Get-Content -Raw -Path "$rootdir/bucket/CascadiaCode-NF.json" | ConvertFrom-Json).version
Invoke-WebRequest `
    -Uri "https://github.com/microsoft/cascadia-code/releases/download/v$version/Cascadia.ttf" `
    -OutFile "$rootdir/fonts/Cascadia.ttf"

docker-compose -f "$psscriptroot/docker-compose.yml" up --build

del "$rootdir/fonts/Cascadia.ttf"
Move-Item -Force `
    -Path "$rootdir/fonts/Cascadia Code Nerd Font Windows Compatible.ttf" `
    -Destination "$rootdir/fonts/Cascadia-NF.ttf"

docker-compose -f "$psscriptroot/docker-compose.yml" down

# push fonts
git add fonts
git commit -m "update fonts."
git push

# update hash and format json
$formatjson = "$env:SCOOP_HOME/bin/formatjson.ps1"
$checkhashes = "$env:SCOOP_HOME/bin/checkhashes.ps1"
$manifest = "CascadiaCode-NF"

Invoke-Expression -Command "$checkhashes -Dir $bucketDir $manifest -Update"
Invoke-Expression -Command "$formatjson -Dir $bucketDir"

# push
git add .
git commit -m "Updated apps"
git push
