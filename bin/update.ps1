$ErrorActionPreference = "Stop"

$bucketDir = "$psscriptroot/../bucket"
if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }

git pull

# check update
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
Invoke-Expression -Command "$checkver -Dir $bucketDir -Update"

# CascadiaCode-NF font
$manifest = "CascadiaCode-NF"
$fontsDir = "$psscriptroot/../fonts"
$version = (Get-Content -Raw -Path "$bucketDir/$manifest.json" | ConvertFrom-Json).version
$fontFile = "$fontsDir/Cascadia-NF_$version.ttf"

if (![System.IO.File]::Exists($fontFile)) {
    Invoke-WebRequest `
        -Uri "https://github.com/microsoft/cascadia-code/releases/download/v$version/Cascadia.ttf" `
        -OutFile "$fontsDir/Cascadia.ttf"

    docker-compose -f "$psscriptroot/docker-compose.yml" up --build

    Remove-Item "$fontsDir/Cascadia.ttf"

    Move-Item -Force `
        -Path "$fontsDir/Cascadia Code Nerd Font Windows Compatible.ttf" `
        -Destination "$fontFile"

    Remove-Item "$fontsDir/Cascadia-NF_*.ttf" -Exclude "Cascadia-NF_$version.ttf"

    docker-compose -f "$psscriptroot/docker-compose.yml" down

    # push fonts
    git add "$fontsDir"
    git commit -m "update CascadiaCode-NF to v$version"
    git push

    $checkhashes = "$env:SCOOP_HOME/bin/checkhashes.ps1"
    Invoke-Expression -Command "$checkhashes -Dir $bucketDir $manifest -Update"
}

# format json
$formatjson = "$env:SCOOP_HOME/bin/formatjson.ps1"
Invoke-Expression -Command "$formatjson -Dir $bucketDir"

# push
git add .
git commit -m "Updated apps"
git push
