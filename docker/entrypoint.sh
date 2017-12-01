#!/bin/bash


if [ ! -d "/workspace/rolespec" ]; then
	cd /workspace
	git clone https://github.com/nickjj/rolespec.git
	cd -
fi

## for debug only...
#ls -l /workspace

export ROLESPEC_HOME=/workspace/rolespec
export ROLESPEC_RUNTIME=/workspace/ansible-playbooks
export ROLESPEC_ANSIBLE_CONFIG=${ROLESPEC_RUNTIME}/ansible.cfg

## for debug only...
if [[ -n "${DEBUG}" ]]; then
	echo -e '\n' "rolespec home: ${ROLESPEC_HOME}"
	echo -e "rolespec runtime: ${ROLESPEC_RUNTIME}" '\n'
fi


cd ${ROLESPEC_RUNTIME}/tests
./TestSuite.sh
