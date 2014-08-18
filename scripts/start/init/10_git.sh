#!/bin/bash

info "Setup user specific environment..."

export LOGIN=${LOGIN:-0}
export GIT_USERNAME=${GIT_USERNAME:-0}
export GIT_EMAIL=${GIT_EMAIL:-0}

[ `git config --list | grep user | wc -l` -eq 2 ]
GIT_IS_CONFIGURED=$?

set -e

if [[ $GIT_IS_CONFIGURED -ne 0 ]]; then
    info "Configure GIT account"

    if [[ -n $GIT_USERNAME ]] && [[ -n $GIT_EMAIL ]]; then
        function git_config () {
            git_command="git config --global $1 \"$2\""
            sudo su $USERNAME -c "$git_command"
        }

        info "Setup git with user \"$GIT_USERNAME <$GIT_EMAIL>\""

        git_config user.name "${GIT_USERNAME}"
        git_config user.email "${GIT_EMAIL}"
        git_config diff.mnemonicprefix "true"
        git_config diff.renames "copies"
        git_config core.fileMode "false"

    else
        error "Please set GIT_USERNAME and GIT_EMAIL environment variables, it's required to configure GIT."
        die
    fi
fi
if [[ $IS_ONLINE -eq 0 ]]; then
    set +e
    ssh-keyscan -H gitlab.trobz.com >> $USER_HOME/.ssh/known_hosts 2>/dev/null
    ssh -T git@gitlab.trobz.com &> /dev/null
    GITLAB_ACCESS=0
    set -e
    if [[ $GITLAB_ACCESS -ne 0 ]]; then
        key=$(cat $USER_HOME/.ssh/id_rsa.pub)
        warn "Please add your default public SSH key to your Gitlab account."
        warn "- go to https://gitlab.trobz.com/profile/keys"
        warn "- add this SSH key:"
        warn "$key"
        die
    fi
else
    warn "You are not online, failed to test Gitlab connection..."
fi


success "Git successfully configured"



