#!/bin/bash

if [[ -n "${TRACE}" ]]; then
  set +x
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
  OLD_RUNTIME=${ROLESPEC_RUNTIME}
  ./test
  unset ROLESPEC_RUNTIME
  ROLESPEC_RUNTIME=${OLD_RUNTIME}
  cd -
done
