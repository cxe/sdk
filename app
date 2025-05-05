#!/usr/bin/env bash

# initial setup:    curl -s https://raw.githubusercontent.com/cxe/sdk/latest/run 2>/dev/null >app; ./app setup

declare -gxA app=(
    [sdk]=0.1.0
    [path]="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd "$(dirname "$(readlink "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")" && pwd)"
)

# todo: (config vars)  GIT_URL GIT_BRANCH GIT_COMMIT WORKSPACE WORKDIR
# todo: (signal proxy)

# load env if available
test -s "${app[path]}/.env" && source "$_"

# ensure git command exists
if ! command -v git > /dev/null 2>&1 || [ ! -d "${app[path]}/.git" ]; then
  git() {
    echo -e "\e[31;2m$*\e[0m" >&2
  }
fi

[ "${app[repository.url]}" ] || app[repository.url]="${GIT_URL:-$(git config --get remote.origin.url)}"
[ "${app[repository.branch]}" ] || app[repository.branch]="${GIT_BRANCH:-$(git symbolic-ref --short -q HEAD)}"
[ "${app[repository.commit]}" ] || app[repository.commit]="${GIT_COMMIT:-$(git rev-parse --short HEAD)}"


app_help(){
    local fn
    echo -n "Usage ./run [help"
    for fn in $(declare -F); do
        fn="${fn##* }"
        if [[ $fn != app_help ]] && [[ $fn == app_* ]]; then
            echo -n "|${fn:4}"
        fi
    done
    echo "]"
}

app_setup(){
    [ "${app[setup.date]}" ] && { app_help; return 1; } # don't overwrite existing setup
    [[ "${app["repository.url"]}" == *cxe/sdk* ]] && return 2; # prevent running setup on source repo

    # write env
	cat <<-EOF > "${app[path]}/.env"
	app[setup.date]="$(date +%Y-%m-%dT%H:%M:%S%:z)"
	app[setup.user]="$USERNAME"
	app[setup.host]="$HOSTNAME"
	app[setup.path]="${app[path]}"
	EOF

    # verify gitignore
    file="${app[path]}/.gitignore"
    test -s "$file" || touch "$file"
    grep -Fxq ".env" "$file" 2>/dev/null || echo >> "$file"

    # make ./app readonly
    chmod a-w,a+x "$0"
}

# execute if not sourced
if [ "$0" == "${BASH_SOURCE[0]}" ]; then
    if [ "$1" ]; then
        if [ "${app['$1']}" ]; then
            echo "${app[$1]}"
        else
            app_$1 "${@:2}" || app_help
        fi
    else
        app_setup
    fi
fi
