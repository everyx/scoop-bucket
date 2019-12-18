$ErrorActionPreference = "Stop"

if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }

# update manifest
$autopr = "$env:SCOOP_HOME/bin/auto-pr.ps1"

[String]$upstream = "everyx/scoop-bucket:master"
$dir = "$psscriptroot/../bucket" # checks the parent dir

Invoke-Expression -command "& '$autopr' -dir '$dir' -upstream $upstream $($args | ForEach-Object { "$_ " })"

# update readme
$readme_template = '# scoop-bucket

my bucket for [scoop](https://github.com/lukesampson/scoop)

```powershell
scoop bucket add everyx https://github.com/everyx/scoop-bucket
```

## List of package

### Apps

| App | Description | Version | Install Command |
|-----|-------------|---------|-----------------|
$apps_list

### Fonts

| Font | Description | Version | Install Command |
|------|-------------|---------|-----------------|
$fonts_list

'


. "$env:SCOOP_HOME/lib/manifest.ps1"


function render($template, $tokens) {
    return [regex]::Replace($template, '\$(?<token>\w+)\$',
        { param($match) $tokens[$match.Groups['token'].Value] })
}

$apps_list = @()
$fonts_list = @()

Get-ChildItem -Path "$dir" -Filter "*.json" | Foreach-Object {
    $name = $_.BaseName

    $json = parse_json $_.FullName

    $url = $json.homepage
    $description = $json.description
    $version = $json.version

    $list_item = "| [$name]($url) | $description | ``$version`` | ``scoop install $name`` |"

    if ($json.installer -and $json.installer.script -and $($json.installer.script | Out-String) -Match 'addFont') {
        $fonts_list += $list_item
    }
    else {
        $apps_list += $list_item
    }
}

$apps_list = $apps_list -join "`r`n" | Out-String;
$fonts_list = $($fonts_list -join "`r`n" | Out-String);

if ($args -contains '-push') {
    $ExecutionContext.InvokeCommand.ExpandString($readme_template) > "$psscriptroot/../README.md"

    git add README.md
    git commit -m "update README"
    git push
}
