$ErrorActionPreference = "Stop"

if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }

# update manifest
$autopr = "$env:SCOOP_HOME/bin/auto-pr.ps1"

[String]$upstream = "everyx/scoop-bucket:master"
$dir = "$psscriptroot/../bucket" # checks the parent dir

Invoke-Expression -command "& '$autopr' -dir '$dir' -upstream $upstream $($args | ForEach-Object { "$_ " })"

# update readme
. $psscriptroot/../lib/helper.ps1
Invoke-Expression -command "& 'updateReadme' -dir '$dir' $($args | ForEach-Object { "$_ " })"
