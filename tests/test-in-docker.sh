#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION="--sudo"

ANSIBLE_VAR=""
ANSIBLE_INVENTORY="tests/test-inventory"
ANSIBLE_PLAYBOOk="tests/test.yml"
ANSIBLE_LOG_LEVEL="-vvv"

# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi

ANSIBLE_EXTRA_VARS=""
if [ "${ANSIBLE_VAR}x" == "x" ];then
    ANSIBLE_EXTRA_VARS=" -e \"${ANSIBLE_VAR}\" "
fi


cd $RDIR/..
printf "[defaults]\nroles_path = /WunderMachina/playbook/roles" > ansible.cfg

yum install python-setuptools python-devel gcc
easy_install pip
pip install ansible

function test_playbook_syntax(){

    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check || (echo "ansible playbook syntax check was failed" && exit 2 )
}

function test_playbook(){
    # first run
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} || ( echo "first run was failed" && exit 2 )

    # Run the role/playbook again, checking to make sure it's idempotent.
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' ) || (echo 'Idempotence test: fail' && exit 1)
}

set -e
function main(){
    test_playbook_syntax
    test_playbook

}

################ run #########################
main