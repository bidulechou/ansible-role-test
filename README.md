# README #
  
This project is not an application but a set of examples for ansible roles testing tutorial live demo.  
Its first goal has been to serve as running example when I tried to build a CI pipeline dedicated to test ansible roles and playbooks.  

### Testing Ansible Roles ###

* Set of runnable examples using [rolespec](https://github.com/nickjj/rolespec) as test library framework to perform unit tests of Ansible roles.
* Version: 0.1
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### First Steps in Ansible Roles Unit Testing ###

#### Prerequisites ####
What you need:  
  
* first to clone *rolespec* in your favorite tool's place, it will help you create your first role test (even on Windows)
* to clone this repository in your own workspace
* a Linux shell, *Git Bash* is a good candidate but with a little restriction which needs a fix
* a Docker Machine, for windows platforms, see: [Docker Toolbox Overview](https://docs.docker.com/toolbox/overview/)
* a customized Ansible docker image which will run tests automatically at runtime
  
  
#### Clone Rolespec and Ansible Role Test Git Repositories ####  
Extract both repositories in the same location, your testing project folder, as show in the example below:  
  
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

	$ git clone https://bedule-conseil@bitbucket.org/bedule-conseil/docker-ansible-test-roles.git
	Cloning into 'docker-ansible-test-roles'...
	remote: Counting objects: 13, done.
	remote: Compressing objects: 100% (12/12), done.
	remote: Total 13 (delta 2), reused 0 (delta 0)
	Unpacking objects: 100% (13/13), done.
	Checking connectivity... done.

```
  
  
#### Configure Environment ####  
Configuring the environment for running rolespec bin script `rolespec*`, you just need to set your path to point to the rolespec's binary sub-folder and some rolespec's environment variable as show bellow:  
  
```bash

	$ export ROLESPEC_HOME=/<your-path-to/your-testing-project>/rolespec
	$ export PATH=${PATH}/${ROLESPEC_HOME}/bin
	$ export ROLESPEC_LIB=${ROLESPEC_HOME}/lib
	$

```
  
But before running the script for the first time you need to fix the `VERSION` file location and if you want to run it on Windows platform you also need to fix the `hostname` command issue, as described in the next section.  
  
  
#### Fix Rolespec before using it ####  
If you want to use, as described in the documentation, the *rolespec* script you need to fix the location of **VERSION** file because the *lib/config* file does not search it at the right place. You just have to ceate a link to the file into the *lib* folder as shown in the code sample below:  
  
```shell

	$ ll ${ROLESPEC_HOME}/lib
	total 32
	-rwxr-xr-x 1 jmd 197121 1680 nov.  29 23:03 cli*
	-rwxr-xr-x 1 jmd 197121 2310 nov.  29 23:22 config*
	-rw-r--r-- 1 jmd 197121  187 nov.  29 23:03 config-centos
	-rw-r--r-- 1 jmd 197121  262 nov.  29 23:03 config-debian
	drwxr-xr-x 1 jmd 197121    0 nov.  29 23:03 dsl/
	-rwxr-xr-x 1 jmd 197121  422 nov.  29 23:03 init*
	-rwxr-xr-x 1 jmd 197121 4194 nov.  29 23:03 lint*
	-rwxr-xr-x 1 jmd 197121  221 nov.  29 23:03 main*
	-rwxr-xr-x 1 jmd 197121 1225 nov.  29 23:03 new-test*
	-rwxr-xr-x 1 jmd 197121 3730 nov.  29 23:03 setup-env*
	-rwxr-xr-x 1 jmd 197121  873 nov.  29 23:03 ui*


	$ ln -s ${ROLESPEC_HOME}/VERSION ${ROLESPEC_LIB}/VERSION


	$ ll ${ROLESPEC_LIB}
	total 33
	-rwxr-xr-x 1 jmd 197121 1680 nov.  29 23:03 cli*
	-rwxr-xr-x 1 jmd 197121 2310 nov.  29 23:22 config*
 	-rw-r--r-- 1 jmd 197121  187 nov.  29 23:03 config-centos
	-rw-r--r-- 1 jmd 197121  262 nov.  29 23:03 config-debian
	drwxr-xr-x 1 jmd 197121    0 nov.  29 23:03 dsl/
	-rwxr-xr-x 1 jmd 197121  422 nov.  29 23:03 init*
	-rwxr-xr-x 1 jmd 197121 4194 nov.  29 23:03 lint*
	-rwxr-xr-x 1 jmd 197121  221 nov.  29 23:03 main*
	-rwxr-xr-x 1 jmd 197121 1225 nov.  29 23:03 new-test*
	-rwxr-xr-x 1 jmd 197121 3730 nov.  29 23:03 setup-env*
	-rwxr-xr-x 1 jmd 197121  873 nov.  29 23:03 ui*
	-rw-r--r-- 1 jmd 197121    7 nov.  29 23:03 VERSION

```
  
This fix is valid on every platform.  
  
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
  
  
### How do I get set up? ###

* Summary of set up
* Configuration
s* Dependencies
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