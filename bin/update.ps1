if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
$formatjson = "$env:SCOOP_HOME/bin/formatjson.ps1"

$bucket = "$psscriptroot/../bucket" # checks the parent dir

Invoke-Expression -Command "$checkver -dir $bucket * -u"
Invoke-Expression -Command "$formatjson -path $bucket"

git pull
git add .
git commit -m "Updated apps"
git push
