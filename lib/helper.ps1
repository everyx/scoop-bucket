function render($template, $tokens) {
    return [regex]::Replace($template, '\$(?<token>\w+)\$',
        { param($match) $tokens[$match.Groups['token'].Value] })
}

function updateReadme {
    param (
        [string] $dir = "../bucket",
        [switch] $push
    )

    # update readme
    $readme_template = '# scoop-bucket

my bucket for [scoop](https://github.com/lukesampson/scoop)

``````powershell
scoop bucket add everyx https://github.com/everyx/scoop-bucket
``````

if you get a `Automatic merge failed` error, please reinstall this bucket.

```powershell
scoop bucket rm everyx
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
    if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }

    . "$env:SCOOP_HOME/lib/manifest.ps1"

    $apps_list = @()
    $fonts_list = @()

    Get-ChildItem -Path "$dir" -Filter "*.json" | Foreach-Object {
        $name = $_.BaseName

        $json = parse_json $_.FullName

        $url = $json.homepage
        $description = $json.description
        $version = $json.version

        $list_item = "| [$name]($url) | $description | ``$version`` | ``scoop install $name`` |"

        if ($json.installer -and $json.installer.script -and $($json.installer.script | Out-String) -Match 'ttf|otf') {
            $fonts_list += $list_item
        }
        else {
            $apps_list += $list_item
        }
    }

    $apps_list = $apps_list -join "`r`n" | Out-String;
    $fonts_list = $($fonts_list -join "`r`n" | Out-String);

    $ExecutionContext.InvokeCommand.ExpandString($readme_template) > "$psscriptroot/../README.md"

    if (!$push) {
        return
    }
    git add README.md
    git commit -m "update README"
    git push
}
