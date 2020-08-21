autoload colors && colors

function _jetbrains-open-print-usage() {
    print 'usage: jetbrains-open [--dry-run | -n] [--verbose | -v] [--help | -h]'
    print
    print 'open a project directory in its corresponding JetBrains IDE'
    print
    print 'options:'
    print '  -n, --dry-run  dry run'
    print '  -v, --verbose  print verbose information'
    print '  -h, --help     display help'
}

function jetbrains-open() {
    local yup="${fg_no_bold[green]}\u2713$reset_color"
    local nope="${fg_no_bold[red]}\u2717$reset_color"
    local files=(
        .ijwb
        build.gradle
        pom.xml
        package.json
        go.mod
        setup.py
    )
    local -A file_languages=(
        .ijwb Bazel
        build.gradle Java
        pom.xml Java
        package.json JavaScript
        go.mod Go
        setup.py Python
    )
    local -A language_commands=(
        Bazel idea
        Java idea
        JavaScript webstorm
        Go goland
        Python pycharm
    )
    local -A language_targets=(
        Bazel .ijwb
        Java $PWD
        JavaScript $PWD
        Go $PWD
        Python $PWD
    )
    local -a verbose help
    local check_format=" %b %-12s ${fg_no_bold[cyan]}%s$reset_color\n"

    zparseopts -D -E -- n=dry_run -dry-run=dry_run v=verbose -verbose=verbose h=help -help=help
    if [[ -n $help ]]; then
        _jetbrains-open-print-usage
        return 0
    fi

    if [[ -n $verbose ]]; then
        print 'Checking for project definition files...'
    fi
    for file in $files; do
        language=$file_languages[$file]
        if [ -f $file ]; then
            if [[ -n $verbose ]]; then
                printf $check_format $yup $file $language
                print
                print 'Checking for IntelliJ command line utilities...'
            fi
            command=$language_commands[$language]
            if [ $command != idea ]; then
                if [ $commands[$command] ]; then
                    if [[ -n $verbose ]]; then
                        printf $check_format $yup $command $language
                    fi
                    target=$language_targets[$language]
                    if [[ -n $dry_run ]]; then
                        print "$ $command $target"
                    else
                        $command $target
                    fi
                    return 0
                else
                    if [[ -n $verbose ]]; then
                        printf $check_format $nope $command $language
                    fi
                fi
            fi
            if [ $commands[idea] ]; then
                if [[ -n $verbose ]]; then
                    printf $check_format $yup idea Any
                fi
                target=$language_targets[$language]
                if [[ -n $target ]]; then
                    target=$PWD
                fi
                if [[ -n $dry_run ]]; then
                    print "$ idea $target"
                else
                    idea $target
                fi
                return 0
            else
                if [[ -n $verbose ]]; then
                    printf $check_format $nope idea Any
                fi
            fi
            if [[ -n $verbose ]]; then
                print
            fi
            print 'No IntelliJ command line utilities found!' >&2
            return 1
        else
            if [[ -n $verbose ]]; then
                printf $check_format $nope $file $language
            fi
        fi
    done
    if [[ -n $verbose ]]; then
        print
    fi
    print 'No project definition files found!' >&2
    return 1
}
