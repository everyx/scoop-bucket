$fonts_dir = "$psscriptroot/../fonts"

function FontPatcher {
    param (
        [string] $font
    )

    docker run --rm `
        -v ${fonts_dir}/input/${font}:/input `
        -v ${fonts_dir}/output:/output rfvgyhn/nerd-font-patcher `
        --powerline `
        --mono `
        --adjust-line-height `
        --windows `
        --careful `
        -ext ttf
}

FontPatcher "Microsoft YaHei Mono.ttf"
