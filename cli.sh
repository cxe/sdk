#!/usr/bin/env bash
# Software Development Kit

readonly CXE_NAME="${CXE_NAME:-cxe}"
readonly CXE_ABBR="$(echo "$CXE_NAME" | tr [:lower:] [:upper:])"
readonly CXE_VERSION="0.1.0"
readonly CXE_COMMAND="/usr/local/bin/${CXE_NAME}"
readonly CXE_PROFILE="${HOME:-~}/.${CXE_NAME}_profile"

# determine if a statement or command is executable/exists on the system
function _executable() {
    [ -x "$(command -v "$@")" ] && echo "$1"
}

# return the current branch name
function _gitBranch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# convert string to lowercase
function _lowercase() {
    echo "$*" | tr '[:upper:]' '[:lower:]'
}

# convert string to uppercase
function _uppercase() {
    echo "$*" | tr '[:lower:]' '[:upper:]'
}

function --version() {
    echo "$CXE_VERSION"
}

function --help() {
    local functionNames="$(declare -F)"
    IFS=$'\n' read -rd '' -a functionNames <<<"${functionNames//declare -f /}"

    text=(
        "$(echo -e "\033[34;1m")"
        "${CXE_ABBR} Software Development Kit v${CXE_VERSION}"
        "$(echo -e "\033[0;34m")"
        "Usage: $(echo -e "\033[36m" "$CXE_NAME <COMMAND> <ARGS>" "\033[34m")"
        ''
        'COMMAND: any of'
    )
    for functionName in ${functionNames[@]}; do
        [[ "${functionName:0:1}" != "_" ]] && text+=("• $functionName")
    done

    text+=("$(echo -e "\033[0m")")
    local IFS=$'\n'
    echo "${text[*]}"
}

# install the command
function --install() {
    if [[ -d "$CXE_DIR" ]] && [[ -f "$CXE_DIR/cli.sh" ]] && [[ -L "$CXE_COMMAND" ]]; then
        echo -n "already "
    else
        # reuse existing profile for some settings
        if [[ -f "$CXE_PROFILE" ]]; then
            source "$CXE_PROFILE"
        fi

        # regenerate and save profile
        data=(
            "export CXE_DIR='$PWD'"
            "export CXE_DEFAULT_AUTHOR='${CXE_DEFAULT_AUTHOR:-USER}'"
            'export PATH="$CXE_DIR:$PATH"'
        )
        local IFS=$'\n'
        echo "${data[*]}" >$CXE_PROFILE

        # add to bash-profile if not already there
        if ! grep -q "$(basename $CXE_PROFILE)" ~/.bash_profile; then
            echo "source '$CXE_PROFILE'" >>~/.bash_profile
        fi

        # load the newly generated profile (also modifies PATH)
        source $CXE_PROFILE

        # expose command
        if [[ ! -f "$CXE_COMMAND" ]] && [[ ! -L "$CXE_COMMAND" ]]; then
            ln -s "$CXE_DIR/cli.sh" "$CXE_COMMAND"
        else
            echo "'$CXE_COMMAND' already exits. Aborting."
            exit 1
        fi
    fi
    echo "installed $CXE_VERSION: $CXE_COMMAND"
}

# uninstall the command
function --uninstall() {
    [[ -L "$CXE_COMMAND" ]] && unlink "$CXE_COMMAND"
    [[ -f "$CXE_PROFILE" ]] && unlink "$CXE_PROFILE"
    export PATH="$(echo "${PATH//$CXE_DIR:/}")"
    export CXE_DIR=
    hash -r
    echo "uninstalled $CXE_NAME"
}

[[ "${1:0:1}" == "_" ]] && echo "illegal command '${1}'" && exit 1
"${1:---help}" "$@"
