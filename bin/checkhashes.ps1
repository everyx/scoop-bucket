$ErrorActionPreference = "Stop"

if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }
$checkhashes = "$env:SCOOP_HOME/bin/checkhashes.ps1"

$dir = "$psscriptroot/../bucket" # checks the parent dir

Invoke-Expression -command "& '$checkhashes' -dir '$dir' $($args | ForEach-Object { "$_ " })"
