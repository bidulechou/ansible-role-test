# README #
  
This project is not an application but a set of examples for ansible roles testing tutorial live demo.  
Its first goal has been to serve as running example when I tried to build a CI pipeline dedicated to test ansible roles and playbooks.  

### Testing Ansible Roles ###

* Set of runnable examples using [rolespec](https://github.com/nickjj/rolespec) as test library framework to perform unit tests of Ansible roles.
* Version: 0.1
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### First Steps in Ansible Roles Unit Testing ###

### Prerequisites  

What you need:  

* first to clone *rolespec* in your favorite tool's place, it will help you create your first role test (even on Windows)
* to clone this repository in your own workspace
* a Linux shell, *Git Bash* is a good candidate but with a little restriction which needs a fix
* a Docker Machine, for windows platforms, see: [Docker Toolbox Overview](https://docs.docker.com/toolbox/overview/)
* a customized Ansible docker image which will run tests automatically at runtime
* perhaps a Gradle docker image which will help automating customized docker image build and running tests on change (usefull if you do not have Gradle and Java installed on your workstation)
  
  
### Clone Rolespec and Ansible Role Test Git Repositories  
Extract both repositories in the same location, your testing project folder.  
If you wan to begin from scratch, just clone _rolespec git repository_ as show in the sample below:  
  
```shell

	$ mkdir -p /<your-path-to/your-testing-project>
	$ cd /<your-path-to/your-testing-project>
	$ git clone https://github.com/nickjj/rolespec.git
	Cloning into 'rolespec'...
	remote: Counting objects: 316, done.
	remote: Total 316 (delta 0), reused 0 (delta 0), pack-reused 316
	Receiving objects: 100% (316/316), 78.54 KiB | 0 bytes/s, done.
	Resolving deltas: 100% (161/161), done.
	Checking connectivity... done.

```
  
If you do not want to begin from scratch you can also clone the _ansible-role-test_ git repository as shown bellow:  
  
```shell

	$ git clone https://bedule-conseil@bitbucket.org/bedule-conseil/docker-ansible-test-roles.git
	Cloning into 'docker-ansible-test-roles'...
	remote: Counting objects: 13, done.
	remote: Compressing objects: 100% (12/12), done.
	remote: Total 13 (delta 2), reused 0 (delta 0)
	Unpacking objects: 100% (13/13), done.
	Checking connectivity... done.

```
  
  
### Configure Environment  
  
Because on Windows platform, even if you use _Git Bash_, the `make install` command does not work as expected we must enfoce manuel setup as you see next. The bellow code sample will I hope will convince you that normal setup as described in the [Rolespec Documentation](https://github.com/nickjj/rolespec#write-your-first-test-case) _Write Your First Test Case_ section not work on Windows 7 platform:  
  
```shell

	$ cd /<my-path-to/my-testing-projects>/rolespec
	$ make install
	Installing RoleSpec scripts in /usr/local/bin ...
	Installing RoleSpec libs in /usr/local/lib/rolespec ...
	
	$ cd ../ansible-role-test
	
	$ rolespec -i ${PWD}
	bash: rolespec: command not found
	
	$ echo $PATH
	~/bin:/mingw64/bin:/usr/local/bin:/usr/bin:/bin:[...]:/usr/bin/vendor_perl:/usr/bin/core_perl
	
	$ ll /usr/local/bin
	ls: cannot access '/usr/local/bin': No such file or directory
	
	$ ll /usr/
	total 104
	drwxr-xr-x 1 bidule 197121 0 oct.   7 23:25 bin/
	drwxr-xr-x 1 bidule 197121 0 oct.   7 23:25 lib/
	drwxr-xr-x 1 bidule 197121 0 oct.   7 23:24 libexec/
	drwxr-xr-x 1 bidule 197121 0 oct.   7 23:25 share/
	drwxr-xr-x 1 bidule 197121 0 oct.   7 23:25 ssl/

	$ 

```
As you can see above, there is no `local` sub-folder in `/usr` folder. But as you can also see the `make install` command has not produced errors. I have also tried to create `/usr/local/bin` and `/usr/local/lib` folders and run again `make install` command without more success. 
  
Then configuring the environment for running rolespec bin script `rolespec*` on Windows platform needs to be made manually (or by script). You first need to set your path to point to the rolespec's binary sub-folder and some other rolespec's environment variable as shown in the sample bellow:  
  
```shell

	$ export ROLESPEC_HOME=/<your-path-to/your-testing-projects>/rolespec
	$ export PATH=${PATH}:${ROLESPEC_HOME}/bin
	$ export ROLESPEC_LIB=${ROLESPEC_HOME}/lib
	$

```
  
But before running the script for the first time you need to fix the `VERSION` file location and if you want to run it on Windows platform you also need to fix the `hostname` command issue, as described in the next section.  
  
For running tests automation it is also usefull to set the _rolespec runtime_ environment variable as you will see later in the documentation. To set this environment variable proceed as shown in the sample bellow:  

```shell

	$ cd /<your-path-to/your-testing-projects>/ansible-role-test
	$ export ROLESPEC_RUNTIME=${PWD}
	$ echo ${ROLESPEC_RUNTIME}
	/<your-path-to/your-testing-projects>/ansible-role-test
	$

```
In addition to this environment variable if you want to run your `test` script without automation when writing your role you also need to set the `ROLESPEC_LIB` variable environment (see previous section). The orther environment variables that we also need during the running stage can be set by `setenv` scripts sourced directly by test scripts as you will see in *Building Test* section.
  
> We assume using in the rest of the documentation _rolespec environment variables_ when focusing on location of files.
  
  
### Fix Rolespec before using it  
  
* __Mandatory Fix__  

If you want to use, as described in the documentation, the *rolespec* script you need to fix the location of **VERSION** file because the *lib/config* file does not search it at the right place. You just have to ceate a link to the file into the *lib* folder as shown in the code sample below:  
  
```shell

	$ ll ${ROLESPEC_HOME}/lib
	total 32
	-rwxr-xr-x 1 bidule 197121 1680 nov.  29 23:03 cli*
	-rwxr-xr-x 1 bidule 197121 2310 nov.  29 23:22 config*
	-rw-r--r-- 1 bidule 197121  187 nov.  29 23:03 config-centos
	-rw-r--r-- 1 bidule 197121  262 nov.  29 23:03 config-debian
	drwxr-xr-x 1 bidule 197121    0 nov.  29 23:03 dsl/
	-rwxr-xr-x 1 bidule 197121  422 nov.  29 23:03 init*
	-rwxr-xr-x 1 bidule 197121 4194 nov.  29 23:03 lint*
	-rwxr-xr-x 1 bidule 197121  221 nov.  29 23:03 main*
	-rwxr-xr-x 1 bidule 197121 1225 nov.  29 23:03 new-test*
	-rwxr-xr-x 1 bidule 197121 3730 nov.  29 23:03 setup-env*
	-rwxr-xr-x 1 bidule 197121  873 nov.  29 23:03 ui*

	$ ln -s ${ROLESPEC_HOME}/VERSION ${ROLESPEC_LIB}/VERSION

	$ ll ${ROLESPEC_LIB}
	total 33
	-rwxr-xr-x 1 bidule 197121 1680 nov.  29 23:03 cli*
	-rwxr-xr-x 1 bidule 197121 2310 nov.  29 23:22 config*
 	-rw-r--r-- 1 bidule 197121  187 nov.  29 23:03 config-centos
	-rw-r--r-- 1 bidule 197121  262 nov.  29 23:03 config-debian
	drwxr-xr-x 1 bidule 197121    0 nov.  29 23:03 dsl/
	-rwxr-xr-x 1 bidule 197121  422 nov.  29 23:03 init*
	-rwxr-xr-x 1 bidule 197121 4194 nov.  29 23:03 lint*
	-rwxr-xr-x 1 bidule 197121  221 nov.  29 23:03 main*
	-rwxr-xr-x 1 bidule 197121 1225 nov.  29 23:03 new-test*
	-rwxr-xr-x 1 bidule 197121 3730 nov.  29 23:03 setup-env*
	-rwxr-xr-x 1 bidule 197121  873 nov.  29 23:03 ui*
	-rw-r--r-- 1 bidule 197121    7 nov.  29 23:03 VERSION

```
  
This fix is valid on every platform.  
  
* __Optional Fix__ (Windows platform only)  
  
On Windows platform and particularly with **MinGW64**, the `gitbash` shell, there is an issue with the command `hostname`, because Windows and MinGW implementations of `hostname` command does not support any argument except `help` and `version` for *MinGW*. For that reason if you want to use *rolespec* command script you need to apply the following modification to the file `/<your-path-to/your-testing-project>/rolespec/lib/config`:  
  
```bash

	# Information
	37 ROLESPEC_RELEASE_NAME="$(lsb_release -a 2>/dev/null | grep Codename | awk '{print $2}')"
	38 ROLESPEC_DISTRIBUTION_NAME=$(guess_distribution)
	 + if [[ `env | grep MINGW64` == "MSYSTEM=MINGW64" ]] || [[ `env | grep OS=` == "OS=Windows_NT" ]]; then
	 + 	ROLESPEC_FQDN="$(hostname)"
	 + else
	39 	ROLESPEC_FQDN="$(hostname -f)"
	 + fi

```
I have'nt tried with `CygWin` because I have not installed it on my Windows workstation and I do not want to install it except if it's absolutly necessary. If anybody could try it under `CygWin` and let us know the result to complete the fix, thank you in advence.  
  
  
### Ansible Repository Structure
  
As described in [Ansible Best Pratices] (http://docs.ansible.com/ansible/latest/playbooks_best_practices.html#alternative-directory-layout) _Alternative Directory Layout_ section we use simplefied Ansible folder structure layout:  
  
```

ansible-role-test/
	inentory/
		hosts
		group_vars/
			all/
				vars.yml ## could be also named 'commons.yml' (place for all group common variables)
			group-1/
				...
			...
			group-n/
				...
		host_vars/
			host-1/
				main.yml
			...
			host-x/
				...
	filter_plugins/
	library/
	module_utils/
	roles/
		role-1/
			tasks/
				main.yml
		role-2/
			...
		...
		role-x/
			...
	playbook-1.yml
	...
	playbooks-x.yml

```
As you could see, actually the planned folder structure layout is not ocmplete, in your extracted _ansible-role-test_ git repository it lakes some folder, i.e. `inventory/host_vars` or `filter_plugins` or `library` or `modules`. For the 3 last ones this is the place for storing home developed custom filter plugins or libraries or modules. You could also use those places to test new module or filter or library's features that will take place in the next release of Ansible in advence to adapt your roles and playbooks.
  
In addition to this simplefied folder structure we have added the role's unit test folder structure to complete configuration steps, see bellow:  
  
```

ansible-role-test/
	...
	tests/
		roles/
			role-1/
			...
			role-x/

```
The Ansible role unit test folder structure will be discuss in more details in next sections. You can also see wiki page: [My First Test Case From Scratch](https://bitbucket.org/beduleconseil/ansible-role-test/wiki/my-first-test-from-scratch) for further information on how developing tests and role code in _TDD_ approach manner.  
  
We will focus now on how to execute tests locally in a customized Ansible docker image or remotely if you use a remote docker machine.  
  
  
### Running Tests  
  
We will not explain here how we have customized an Ansible docker image, we assume you have read first the [Docker Ansible Test Roles](https://bitbucket.org/bedule-conseil/docker-ansible-test-roles/src) project `README.md` file if you need to understand more deeply how we have done it.
  
  
You can see in the output sample bellow the tests ran in an automated manner against a customized Ansible docker image:  
  
```bash

	$ docker run -i --name test-ansible b25202b723ed
	Cloning into 'rolespec'...
	/
	
	TEST: [Run playbook syntax check]
	
	playbook: playbook.yml
	
	TEST: [Run playbook]
	
	PLAY [all] *********************************************************************
	
	TASK [Gathering Facts] *********************************************************
	ok: [localhost]
	
	TASK [ping] ********************************************************************
	ok: [localhost]
	
	TASK [debug] *******************************************************************
	ok: [localhost] => {
		"ping_result": {
			"changed": false,
			"failed": false,
			"ping": "pong"
		}
	}
	
	PLAY RECAP *********************************************************************
	localhost                  : ok=3    changed=0    unreachable=0    failed=0
	
	
	TEST: [Re-run playbook]
	
	TEST: [In output | PASS]
	found:
	changed=0.*unreachable=0.*failed=0
	
	in output:
	localhost                  : ok=3    changed=0    unreachable=0    failed=0
	
	/workspace/ansible-playbooks/tests
	
	TEST: [Run playbook syntax check]
	
	playbook: playbooks/test.yml
	
	TEST: [Run playbook]
	
	PLAY [localhost] ***************************************************************
	
	TASK [Gathering Facts] *********************************************************
	ok: [localhost]
	
	TASK [install-rancher-cli : stat] **********************************************
	ok: [localhost]
	
	TASK [install-rancher-cli : debug] *********************************************
	ok: [localhost] => {
		"file_presence.stat.exists": false
	}
	
	TASK [install-rancher-cli : Download file if needed] ***************************
	changed: [localhost]
	
	TASK [install-rancher-cli : Unarchive zipped tar ball file] ********************
	changed: [localhost]
	
	TASK [install-rancher-cli : Create link into /usr/local/bin] *******************
	changed: [localhost]
	
	PLAY RECAP *********************************************************************
	localhost                  : ok=6    changed=3    unreachable=0    failed=0
	
	
	TEST: [Re-run playbook]
	
	TEST: [In output | PASS]
	found:
	changed=0.*unreachable=0.*failed=0
	
	in output:
	localhost                  : ok=5    changed=0    unreachable=0    failed=0
	
	
	TEST: [File '/opt/rancher-v0.6.5' exists | PASS]
	
	
	TEST: [In output | PASS]
	found:
	755
	
	in output:
	755 ?
	
	
	TEST: [File '/usr/local/bin/rancher' exists | PASS]
	
	/workspace/ansible-playbooks/tests
	
	$

```
  
  
* * *
  
### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact