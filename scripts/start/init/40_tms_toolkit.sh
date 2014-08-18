#!/bin/bash

if [[ $IS_ONLINE -eq 0 ]]; then
    info "clone TMS toolkit..."
    sudo su $USERNAME -c "mkdir -p $USER_HOME/utils/openerputils"
    sudo su $USERNAME -c "git clone git@gitlab.trobz.com:openerp-utils/devenvsetup.git $USER_HOME/utils/openerputils/devenvsetup &>/dev/null"
    sudo mv /tmp/tms_admin_config.ini $USER_HOME/utils/openerputils/devenvsetup/conf/config.ini
    replace_env $USER_HOME/utils/openerputils/devenvsetup/conf/config.ini
    sudo chown $USERNAME: $USER_HOME/utils/openerputils -R

    success "TMS toolkit installed"
else
    warn "You are not online, failed to install TMS admin toolkit"
    warn "- Please install it manually (git clone git@gitlab.trobz.com:openerp-utils/devenvsetup.git)"
fi