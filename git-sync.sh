#!/bin/sh

# function below is from https://stackoverflow.com/a/22690437
function conf_get_val() {
    awk -v section="$2" -v variable="$3" '
		$0 == "[" section "]" { in_section = 1; next }
		in_section && $1 == variable {
			$1=""
			$2=""
			sub(/^[[:space:]]+/, "")
			print
			exit
		}
		in_section && $1 == "" {
			# we are at a blank line without finding the var in the section
			#print "not found" > "/dev/stderr"
			exit 1
		}
    ' "$1"
}

function do_sync() {
    local local_dir="$1" directory="$2" repository="$3" upstream="$4"
    local repo_dir="$local_dir/${directories[$i]}"
    local GIT_DIR_OPT="--git-dir=$repo_dir/.git --work-tree=$local_dir/${directories[$i]}"
    
    if [ -d "$local_dir/${directories[$i]}" ]; then
        git $GIT_DIR_OPT fetch upstream
        git $GIT_DIR_OPT fetch --tags --prune upstream
    else
        git clone --origin upstream "$upstream" "$local_dir/${directories[$i]}"
        if [ $? -eq 0 ]; then
            git $GIT_DIR_OPT remote add origin "$repository"
        fi
    fi
    if [ $? -eq 0 ] ;then
        git $GIT_DIR_OPT checkout --quiet --detach
    else
        return 1
    fi
    
    local upstream_branches=($(git $GIT_DIR_OPT ls-remote --heads upstream | awk '{print $2}' | sed 's/^refs\/heads\///'))
    local local_branches=($(git $GIT_DIR_OPT ls-remote --heads "$repo_dir" | awk '{print $2}' | sed 's/^refs\/heads\///'))
    
    local ub lb
    for ub in ${upstream_branches[@]}; do
        for lb in ${local_branches[@]}; do
            if [ $lb = $ub ]; then
                git $GIT_DIR_OPT fetch upstream $ub:$lb
                continue 2
            fi
        done
        git $GIT_DIR_OPT branch --no-track $ub remotes/upstream/$ub
    done
    
    for lb in ${local_branches[@]}; do
        for ub in ${upstream_branches[@]}; do
            if [ $ub = $lb ]; then
                continue 2
            fi
        done
        git $GIT_DIR_OPT branch -D $lb
    done
    
    git $GIT_CONF_OPT $GIT_DIR_OPT push --all --force --prune origin
    git $GIT_CONF_OPT $GIT_DIR_OPT push --tags --force --prune origin
}


SYNC_CONFIG="/etc/git-sync.conf"

function git_sync() {
    GIT_CONF_OPT=""
    if [ ! -z "$GIT_USER_NAME" ]; then
        GIT_CONF_OPT="$GIT_CONF_OPT -c user.name=$GIT_USER_NAME"
    fi
    if [ ! -z "$GIT_USER_EMAIL" ]; then
        GIT_CONF_OPT="$GIT_CONF_OPT -c user.email=$GIT_USER_EMAIL"
    fi
    if [ ! -z "$GIT_PUSH_DEFAULT" ]; then
        GIT_CONF_OPT="$GIT_CONF_OPT -c push.default=$GIT_PUSH_DEFAULT"
    fi
    
    if [ -z "$LOCAL_DIR" ]; then
        LOCAL_DIR="/tmp/git-sync"
    fi
    
    directories=($(grep '^\s*\[.*\]\s*$' "$SYNC_CONFIG" | while read s; do echo ${s:1:-1}; done))
    for ((i=0; i<${#directories[@]}; ++i)); do
        mkdir -p $(dirname "$LOCAL_DIR/${directories[$i]}")
        local repository=$(conf_get_val "$SYNC_CONFIG" "${directories[$i]}" 'repository')
        local upstream=$(conf_get_val "$SYNC_CONFIG" "${directories[$i]}" 'upstream')
        do_sync "$LOCAL_DIR" "${directories[$i]}" "$repository" "$upstream"
    done
}

git_sync
