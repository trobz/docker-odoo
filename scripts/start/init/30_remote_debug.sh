#!/bin/bash

set +e
ls $USER_HOME/lib/pydevd 2>/dev/null | egrep "pydevd|pycharm" &> /dev/null
PYDEVD_AVAILABLE=$?
set -e

if [[ $PYDEVD_AVAILABLE -eq 0 ]]; then
    PYDEVD_MAP_FILE="$USER_HOME/lib/pydevd/pydevd_file_utils.py"
    PYDEVD_MAP_VAR="PATHS_FROM_ECLIPSE_TO_PYTHON"

    set +e
    cat "$PYDEVD_MAP_FILE" 2>/dev/null | grep "$PYDEVD_MAP_VAR = \[\]" &>/dev/null
    HAS_ECLIPSE=$?
    set -e

    if [[ $HAS_ECLIPSE -eq 0 ]]; then
        info "Update pydevd_file_utils.py for Eclipse"

        SOURCE_MAPPING="$PYDEVD_MAP_VAR = [\n(normcase(r'$OPENERP_SOURCE')\, normcase(r'$USER_HOME/code'))\,\n]"
        sudo sed -i "s,$PYDEVD_MAP_VAR = \[\],$SOURCE_MAPPING,g" $PYDEVD_MAP_FILE
    fi

    info "Update user PYTHONPATH to include remote debugging libraries"
    if [[ $HAS_ECLIPSE -eq 0 ]]; then
        echo -e "\n\nexport PYTHONPATH=$PYTHONPATH:$USER_HOME/lib/pydevd" >> $USER_HOME/.bashrc
    else
        echo -e "\n\nexport PYTHONPATH=$PYTHONPATH:$USER_HOME/lib/pydevd/pycharm-debug.egg" >> $USER_HOME/.bashrc
    fi

    success "Remote debug configured"
else
    warn "Debugger libraries not available"
fi
