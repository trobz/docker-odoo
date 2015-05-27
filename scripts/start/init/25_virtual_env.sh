#!/in/bash

info "Create default virtual env for user ${USERNAME}"

export VENV="odoo-7.0"
export VENV_PATH="${USER_HOME}/.local/share/virtualenvs/${VENV}"

sudo -u "$USERNAME" -H pew new odoo-7.0 -d
sudo -u "$USERNAME" -H pew in "$VENV" pip install --use-wheel --no-index --find-links=/tmp/setup/odoo/wheel -r /tmp/setup/odoo/requirements.txt

success "Virtual env $VENV created for ${USERNAME}"
