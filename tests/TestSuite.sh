#!/bin/bash

if [[ -n "${SHELL_DEBUG}" ]]; then
  set -x
fi

#. /workspace/ansible-playbooks/tests/.setenv
. "${ROLESPEC_RUNTIME}/tests/.setenv"

export ANSIBLE_FORCE_COLOR=true

## for debug only...
if [[ -n "${DEBUG}" ]]; then
  echo -e "'\n'rolespec home:	${ROLESPEC_HOME}" '\n'
  echo "rolespec runtime: ${ROLESPEC_RUNTIME}"
  echo -e "rolespec lib: ${ROLESPEC_LIB}" '\n'
fi

for folder in $(ls ${ROLESPEC_RUNTIME}/tests/roles)
do
  ## for debug only...
  if [[ -n "${DEBUG}" ]]; then
    echo -e "'\n'folder name: ${ROLESPEC_RUNTIME}/tests/roles/${folder}"
  fi
  cd ${ROLESPEC_RUNTIME}/tests/roles/${folder}
  if [ ! -f "roles" ]; then
    ln -s ${ROLESPEC_RUNTIME}/roles ./roles
    ##for debug only...
    if [[ -n "${DEBUG}" ]]; then
      ls -l --color=auto
    fi
  fi
  OLD_RUNTIME=${ROLESPEC_RUNETIME}
  ./test
  unset ROLESPEC_RUNETIME
  ROLESPEC_RUNETIME=${OLD_RUNTIME}
  cd -
done
