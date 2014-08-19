#!/bin/bash
#
# OpenERP fullstack docker installed
#

########################################
# Common logging functions
########################################

#TODO: switch to color.sh
if [ ${libout_color:-1} -eq 1 ]; then
  DEF_COLOR="\x1b[0m"
  BLUE="\x1b[34;01m"
  CYAN="\x1b[36;01m"
  GREEN="\x1b[32;01m"
  RED="\x1b[31;01m"
  GRAY="\x1b[37;01m"
  YELLOW="\x1b[33;01m"
  ORANGE="\x1b[1;33;01m"
fi


function log(){
    if [ -n "$INIT_LOG" ]; then
        if [[ ! -f "$INIT_LOG" ]]; then
            mkdir -p ${INIT_LOG%/*}
        fi
        echo $(date +%Y-%m-%d:%H:%M:%S) - "$@" >> "$INIT_LOG"
    fi
}


debug() {
  if [ ${LOG_LEVEL:-0} -gt 3 ]; then
    level=$(printf '%7s:' "DEBUG")
    echo -e "$CYAN${level}$DEF_COLOR $@"
    log "$level" "$@"
  fi
}

success() {
  if [ ${LOG_LEVEL:-0} -gt 2 ]; then
    level=$(printf '%7s:' "SUCCESS")
    echo -e "$GREEN${level}$DEF_COLOR $@"
    log "$level" "$@"
  fi
}

warn() {
  if [ ${LOG_LEVEL:-0} -gt 1 ]; then
    level=$(printf '%7s:' "WARN")
    echo -e "$YELLOW${level}$DEF_COLOR $@"
    log "$level" "$@"
  fi
}

info() {
  if [ ${LOG_LEVEL:-0} -gt 0 ]; then
    level=$(printf '%7s:' "INFO")
    echo -e "$GRAY${level}$DEF_COLOR $@"
    log "$level" "$@"
  fi
}

error() {
  level=$(printf '%7s:' "ERROR")
  echo -e "$RED${level}$DEF_COLOR $@"
  log "$level" "$@"
}

prompt() {
  val=""
  def_val=${!1:-""}

  while [[ -z "$val" ]]; do
    level=$(printf '%7s:' "INPUT")
    printf "$BLUE${level}$DEF_COLOR ${@:2:${#@}}"
    read val
    if [[ -n "$def_val" ]]; then
        break
    fi
  done

  if [[ -n "$val" ]]; then
    eval "$1=\"$val\""
  fi
}



trobz () {
    printf "$ORANGE"
    cat <<END
.:                  ::
:::.                ::
::    :::. :::::::: :::::::: IIIIII
::   ::   .:      ::::      ::  II
::   ::   ::       :::      :: II
 ::  ::   ::      :: :      : II
  :::::     ::::::.   :::::: IIIIIII
END
    printf "$DEF_COLOR"
    echo
    echo
}

line () {
    printf "$BLUE"
    for n in `seq 1 $1`; do printf '#'; done
    echo -e "$DEF_COLOR"
}

title () {
    echo
    line ${#1}
    echo -e "${BLUE}$1${DEF_COLOR}"
    line ${#1}
    echo
}

die () {
  error "EXIT with status 1"
  exit 1
}

function timeout () {
    set +e
	declare -i TIMEOUT=${2:-6} # 20min timeout
	declare -i SLEEP_TIME=2
	declare -i COUNT=0
	declare -i STATUS=0
	declare -i CURRENT_TIME=$(expr $SLEEP_TIME \* $COUNT)
	while [[ $TIMEOUT -gt $CURRENT_TIME ]]; do
	    COUNT=$(expr $COUNT \+ 1)
	    CURRENT_TIME=$(expr $SLEEP_TIME \* $COUNT)
	    eval "$1"
	    STATUS=$?
	    if [[ $STATUS -eq 0 ]]; then
		    return 0
		    set -e
	    fi
	    sleep $SLEEP_TIME
	done
	return 1
	set -e
}

########################################
# General functions / vars
########################################

USER_HOME=$(eval echo ~${SUDO_USER})
USER_UID=`id -u $(whoami)`
USER_GID=`id -g $(whoami)`

check_cpu_archi () {
    grep flags /proc/cpuinfo | grep " lm " &>/dev/null
    ret=$?
    if [ $ret -ne 0 ]; then arch_cpu="32 bit"; else arch_cpu="64 bit"; fi;
    echo $arch_cpu
}


check_archi () {
    uname -a | grep 64 &>/dev/null;
    ret=$?
    if [ $ret -ne 0 ]; then arch_os="32 bit"; else arch_os="64 bit"; fi;
    echo $arch_os
}

check_os () {
    os=`lsb_release -a 2>/dev/null | grep Desc | sed 's/.*\:\t*//'`
    echo $os
}



########################################
# Code
########################################


LOG_LEVEL=${1:-3}

clear

trobz

title "OpenERP fullstack installer for Docker"
##########################################

info "check system configuration..."

cpu=`check_cpu_archi`
archi=`check_archi`
os=`check_os`

shopt -s nocasematch;



if [[ $USER_UID -eq 0 ]]; then
    error "This script can't be run by the root user"
    die
fi

if [[ $os =~ ubuntu.*14 ]]; then
    if [[ $archi == '64 bit' ]]; then
        success "Your OS is compatible with Docker !"
    elif [[ $cpu == '64 bit' ]]; then
        error "Your have a 32 bit Ubuntu version, you have to reinstall Ubuntu 14.04 64 bit to support Docker"
        die
    else
        error "Your laptop doesn't support Docker"
        die
    fi
else
    error "This script has been made to be used on Ubuntu 14.x, not on $os"
    die
fi

title "Get user specific info"
##########################################


confirm () {
    info "Your container will be configured with these infos:"
    info "- name:  $USER_NAME"
    info "- login: $USER_LOGIN"
    info "- email: $USER_EMAIL"
    info "- container space: $CONTAINER_SPACE"
    info "- source code: $CODE_SOURCE"

    if [[ -n $DEBUG_PATH ]]; then
        info "- IDE remote debugger lib: $DEBUG_PATH"
    fi

    local answer="y"
    prompt answer "Please, confirm these infos [Y/n]"
    if [[ $answer =~ n ]]; then
        questions
    else
        success "All user info geathered !"
    fi
}


check_source () {
    list=`ls $1 2>/dev/null`
    has_folder=$?
    count=`ls $1 2>/dev/null | wc -l`

    if [[ $has_folder -ne 0 ]]; then
        echo 2
    elif [[ $count -gt 0 ]]; then
        echo 0
    else
        echo 1
    fi
}

get_source () {
    CODE_SOURCE="$USER_HOME/code/openerp"
    prompt CODE_SOURCE  "Where do you store Trobz source code [$CODE_SOURCE] ? "

    local has_source=`check_source $CODE_SOURCE`

    if [[ $has_source -eq 2 ]]; then
        warn "$CODE_SOURCE doesn't exists, please retry..."
        get_source
    elif [[ $has_source -eq 1 ]]; then
        warn "$CODE_SOURCE is empty"

        local answer="y"
        prompt answer "Do you want to create the folder [Y/n] ? "
        if [[ $answer =~ n ]]; then
            get_source
        else
            mkdir -p $CODE_SOURCE
        fi
    fi
}

questions () {


    prompt USER_NAME    "What's your full name ? "
    prompt USER_LOGIN   "What's your login ? "

    USER_EMAIL="$USER_LOGIN@trobz.com"
    prompt USER_EMAIL   "What's your email address [$USER_EMAIL] ? "

    get_source

    CONTAINER_SPACE="$USER_HOME/openerp"
    prompt CONTAINER_SPACE  "Where do you want to run your container [$CONTAINER_SPACE] ? "


    # detect IDE

    detect_ide () {
        aptana_path=`find $1 -maxdepth 3 -type f -name "AptanaStudio*" 2>/dev/null | head -n 1 `
        HAS_APTANA=`[ -z $aptana_path ] && echo 0 || echo 1`
        eclipse_path=`find $1 -maxdepth 3 -type f -name "eclipse*" 2>/dev/null | head -n 1`
        HAS_ECLIPSE=`[ -z $eclipse_path ] && echo 0 || echo 1`
        pycharm_path=`find $1 -maxdepth 3 -type f -name "pycharm-debug*" 2>/dev/null | head -n 1`
        HAS_PYCHARM=`[ -z $pycharm_path ] && echo 0 || echo 1`
        HAS_IDE=`expr $HAS_APTANA + $HAS_ECLIPSE + $HAS_PYCHARM`
    }

    detect_ide $USER_HOME

    # ask for the IDE path
    if [[ $HAS_IDE -eq 0 ]]; then
        prompt ide_path  "Where have you installed your IDE ? "
        detect_ide $ide_path
    fi

    if [[ $HAS_IDE -eq 0 ]]; then
        warn "no IDE detected, you will have to configure the remote debugging manually..."
    elif [[ $HAS_IDE -gt 1 ]]; then
        warn "multiple IDE detected, only one will be automatically configured, see next info:"
    fi

    DEBUG_PATH=""
    DEBUG_MAP=""
    if [[ $HAS_APTANA -eq 1 ]]; then
        ide_path=$(dirname ${aptana_path})
        debug "Aptana found in $ide_path, looking for remote debug libraries..."
        DEBUG_PATH=`find $ide_path -maxdepth 4 -name "pysrc" 2>/dev/null`
        DEBUG_MAP="    - $DEBUG_PATH:/opt/openerp/lib/pydevd"
    elif [[ $HAS_ECLIPSE -eq 1 ]]; then
        ide_path=$(dirname ${eclipse_path})
        debug "Eclipse found in $ide_path, looking for remote debug libraries..."
        DEBUG_PATH=`find $ide_path -maxdepth 4 -name "pysrc" 2>/dev/null`
        DEBUG_MAP="    - $DEBUG_PATH:/opt/openerp/lib/pydevd"
    elif [[ $HAS_PYCHARM -eq 1 ]]; then
        echo $pycharm_path
        ide_path=$(dirname ${pycharm_path})
        debug "PyCharm found in $ide_path, looking for remote debug libraries..."
        DEBUG_PATH=`find $ide_path -maxdepth 4 -name "pycharm-debug.egg" 2>/dev/null`
        DEBUG_MAP="    - $DEBUG_PATH:/opt/openerp/lib/pydevd/pycharm-debug.egg"
    fi

    confirm
}


questions


title "Install all dependencies"
##########################################


curl --version &>/dev/null
if [[ $? -ne 0 ]]; then
    info "Install curl lib..."
    sudo apt-get install -y curl
fi

docker --version &>/dev/null
if [[ $? -ne 0 ]]; then
    info "Install docker..."
    curl -sSL https://get.docker.io/ubuntu/ | sudo sh
fi

fig --version &>/dev/null
if [[ $? -ne 0 ]]; then
    info "Install fig..."
    curl -L https://github.com/orchardup/fig/releases/download/0.5.2/linux 2>/dev/null | sudo tee /usr/local/bin/fig &>/dev/null
    sudo chmod +x /usr/local/bin/fig
fi

success "All dependencies are installed"



title "Setup OpenERP fullstack container"
##########################################

set -e

info "Setup container folder in $CONTAINER_SPACE"
mkdir -p $CONTAINER_SPACE

info "Generate default fig.yml configuration in $CONTAINER_SPACE/fig.yml"

cat << EOF > $CONTAINER_SPACE/fig.yml
container:

  image: trobz/openerp-fullstack:7.0

  environment:
    - LOGIN=$USER_LOGIN
    - GIT_USERNAME=$USER_NAME
    - GIT_EMAIL=$USER_EMAIL
    - OPENERP_SOURCE=$CODE_SOURCE
    - USER_UID=$USER_UID
    - USER_GID=$USER_GID

  ports:
    - "8069:8069"   # openerp
    - "1122:22"     # ssh
    - "5432:5432"   # pstgresql
    - "8011:8011"   # supervisord service monitor


  volumes:

    # SSH personal keys
    - $USER_HOME/.ssh:/usr/local/ssh

    # postgres shared config files
    - postgres/data:/etc/postgresql/docker/data
    - postgres/config:/etc/postgresql/docker/config
    - postgres/log:/etc/postgresql/docker/log

    # openerp sources
    - $CODE_SOURCE:/opt/openerp/code

    # eclipse debug libs (of any)
$DEBUG_MAP


  mem_limit: 500000000
  hostname: openerp.dev
  domainname: openerp.dev
EOF

info "Add upstart config for OpenERP fullstack"

cat << EOF | sudo tee /etc/init/openerp-container.conf &>/dev/null
description "OpenERP 7.0 container"
author "Michel Meyer <mmeyer@trobz.com>"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  /usr/bin/docker start -a openerp_container_1
end script
EOF

# disable docker container auto start feature (manage it with upstart instead)
sudo sed -i 's/ -r=false//g' /etc/default/docker
sudo sed -i -r 's/DOCKER_OPTS="(.*)"/DOCKER_OPTS="\1 -r=false"/' /etc/default/docker


info "Pull OpenERP fullstack image from hub.docker.com"

sudo docker pull trobz/openerp-fullstack:7.0

info "Start OpenERP fullstack"

cd "$CONTAINER_SPACE"
sudo fig stop container &>/dev/null
sudo fig rm --force container &>/dev/null
sudo fig up container &

check_fig () {
    debug "Check if the port localhost:1122 is open..."
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q -p 1122 openerp@localhost exit
    NC_STATUS=$?
    return $NC_STATUS
}

# fig is checking if a service is listening on localhost:1122, checking timeout=6s, retry=200,
# so test will run during 20min
timeout 'check_fig' 1200
RETRY_STATUS=$?

if [[ $RETRY_STATUS -eq 0 ]]; then
    info "Stop the container and restart it in background"
    sudo fig stop &>/dev/null
    sudo fig up -d
else
    error "Timeout, unable to connect to the container SSH port after 20min..."
    error "Please, try to start the container manually with the command:"
    error "cd $CONTAINER_SPACE ; sudo fig up"
    die
fi

timeout 'check_fig' 1200
RETRY_STATUS=$?

if [[ $RETRY_STATUS -eq 0 ]]; then
    success "OpenERP fullstack setup finished !"
    success "you can access to the container by: 'ssh -p 1122 openerp@localhost'"
    success "Enjoy young trobzer !"
else
    error "Timeout, unable to connect to the container SSH port after 20min..."
    error "Please, try to start the container manually with the command:"
    error "cd $CONTAINER_SPACE ; sudo fig up"
    die
fi
