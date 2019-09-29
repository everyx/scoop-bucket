git pull

# check update
if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
$formatjson = "$env:SCOOP_HOME/bin/formatjson.ps1"

$bucket = "$psscriptroot/../bucket" # checks the parent dir

Invoke-Expression -Command "$checkver -dir $bucket * -u"
Invoke-Expression -Command "$formatjson -dir $bucket"

# generate fonts
$rootdir = "$psscriptroot/.."

$version = (Get-Content -Raw -Path "$rootdir/bucket/CascadiaCode-NF.json" | ConvertFrom-Json).version
Invoke-WebRequest `
    -Uri "https://github.com/microsoft/cascadia-code/releases/download/v$version/Cascadia.ttf" `
    -OutFile "$rootdir/fonts/Cascadia.ttf"

docker-compose -f "$psscriptroot/docker-compose.yml" up --build

del "$rootdir/fonts/Cascadia.ttf"
mv "$rootdir/fonts/Cascadia Code Nerd Font Windows Compatible.ttf" "$rootdir/fonts/Cascadia-NF.ttf"

docker-compose -f "$psscriptroot/docker-compose.yml" down

# push
git add .
git commit -m "Updated apps"
git push
