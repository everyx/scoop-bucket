<#
.SYNOPSIS
    Check if ALL urls inside manifest have correct hashes.
.PARAMETER App
    Manifest to be checked.
    Wildcard is supported.
.PARAMETER Update
    When there are mismatched hashes, manifest will be updated.
.PARAMETER ForceUpdate
    Manifest will be updated all the time. Not only when there are mismatched hashes.
.PARAMETER SkipCorrect
    Manifests without mismatch will not be shown.
.PARAMETER UseCache
    Downloaded files will not be deleted after script finish.
    Should not be used, because check should be used for downloading actual version of file (as normal user, not finding in some document from vendors, which could be damaged / wrong (Example: Slack@3.3.1 lukesampson/scoop-extras#1192)), not some previously downloaded.
.EXAMPLE
    PS BUCKETROOT> .\bin\checkhashes.ps1
    Check all manifests for hash mismatch.
.EXAMPLE
    PS BUCKETROOT> .\bin\checkhashes.ps1 MANIFEST -Update
    Check MANIFEST and Update if there are some wrong hashes.
#>

$ErrorActionPreference = "Stop"

if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }
$checkhashes = "$env:SCOOP_HOME/bin/checkhashes.ps1"

$dir = "$psscriptroot/../bucket" # checks the parent dir

Invoke-Expression -command "& '$checkhashes' -Dir '$dir' -Update $($args | ForEach-Object { "$_ " })"
