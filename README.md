  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# ctrlx-postgresql

This respository contains the source code and build instructions to generate the ctrlx-postgresql snap yourself. Shortly speaking, the ctrlx-postgresql packs PostgreSQL 14.0 for Ubuntu 22.04 LTS with amd64 architecture. It targets ctrlX CORE virtual, ctrlX CORE X5 and ctrlX CORE x7 running ctrlX OS 2.xx (base apps running an ubuntu core 22). This application is only supported for amd64 architecture. 

## Author details
<mark>**DISCLAIMER: This is not an official Bosch Rexroth development. This is only a demo example, use at your own risk. There is no support.**</mark> 

Author: Raul Cruz-Oliver \
Main contact email: raul.cruz.oliver@gmail.com \
Date: November 2023 \
License: MIT

## System overview
The following diagram shows how PostgreSQL will be integrated in ctrlX OS. The PostgreSQL runtime is packed in a snap and installed in the CORE, the user can configure where the data will be stored, for example in a external media like the an SD Card. Moreover, via a TCP/IP communication the PostgreSQL running in the ctrlX OS can accept connections from PgAdmin4 (GUI Deskop client application) in a engineering PC to easily visualize and export the data base.

![Alt Text](images/overview.png)

Please visit [PostgreSQL in ctrlX CORE OS](https://developer.community.boschrexroth.com/t5/forums/editpage/board-id/dcdev_community-dev-blog/message-id/969), where the functionalities of this app are explained in detail. 


## Easy start-up

### 0. Clone this respository
This example is designed for Ubuntu Jammy Jellyfish 22.04 x86_64 Desktop.

Open a terminal, it will be started in your home directory. This is the best place to clone this repository. Simply enter:

```bash
sudo apt install git # if you do not have git install in your system

git clone https://github.com/rcruzoliver/ctrlx_postgresql
```

### 1. Prepare your system
You will pack PostgreSQL in a snap using a strategy in which some local installed packages are staged during snapcraft process, so, you need to install PostgreSQL in your system. You can either follow the [official guide](https://www.postgresql.org/download/linux/ubuntu/) to install PostgreSQL on Ubuntu, or simply follow the summarized tutorial I include next.

- Create the file repository configuration:
```bash
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
- Import the repository signing key:
```bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```
- Update the package lists:
```bash
sudo apt-get update
```
-  Install the desired version of PostgreSQL. (This example was developped for version 14.10)
```bash
sudo apt-get -y install postgresql-14
```
- After the installation, open a new console and test if the right version was installed:
```bash
/usr/lib/postgresql/14/bin/postgres -V
```
You should get
```bash
postgres (PostgreSQL) 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)
```


### 2. Create the snap
The process has been automated for you in createSnap.sh. Just enter the following commands:
```bash
cd ctrlx_postgresql
./createSnap
```

### 3. Install the snap in ctrlX CORE
After running the process to create the snap, if it was sucessful, you will get a file called "ctrlx-postgresql_2.2.0_amd64.snap".

This .snap file can be directly intalled in CtrlX Core from the Apps menu. Just as a reminder, since this new app you just built has not been signed, you need to allow the installation from "unknown sources" in your device.

![Alt text](/images/unknownsources.png)

![Alt text](/images/popup.png)

## Code explanation

## 1. Snapcraft

```yaml
parts:
    postgresql:
        plugin: nil
        stage-packages:
            - postgresql
            - util-linux
            - libssl-dev
            - libcurl4-openssl-dev
   
    shscripts:  
        source: ./shscripts/
        plugin: dump
        organize:
          '*': bin/

    # Neccesary to embed additional files
    configs:
        source: ./configs
        plugin: dump
        organize:
           'package-assets/*': package-assets/${SNAPCRAFT_PROJECT_NAME}/
```
This snap has three parts:
- postgresql: it contains the main executables, locally installed packages dumped into the snap
- shscripts: it contains the executable that the daemon will run (run.sh), and the files the server needs to start (configuration and data diles)
- configs: it contains the snap configuration files, they define interfaces with the ctrlX OS. They are not related at all with PostgreSQL.

```yaml
slots:
  # Allow the snap files to be available outside it
  package-assets:
    interface: content
    content: package-assets
    source:
      read:
        - $SNAP/package-assets/${SNAPCRAFT_PROJECT_NAME}

plugs:
  # Allow read the ctrlX OS memory with the right persmisions
  active-solution:
    interface: content
    content: solutions
    target: $SNAP_COMMON/solutions
```
This snap defines a slot to make its files available from the outside, likewise, a plug is defined to be able to read the ctrl OS wih the right permissions

```yaml
hooks:
  # Automatically used when the snap connects the plug
  connect-plug-active-solution:
    plugs: [active-solution]
  # Automatically when the app is desinstalled
  remove:
    plugs: [active-solution]
```
Hooks are exectuables that are run in spefic moments of snap life. The files can be found under ./snap/hooks
- connect-plug-active-solution: it is called after the snap connects the active-solution plug. It creates the neccesary directories and give them the right ownership and permissions.
- remove: it is called when the snap is uninstalled. It gives back the ownership of the files to the root user, so they can be deleted from the ctrlX OS webinterface.

```yaml
layout:

  /var/run_v2/postgresql:
    bind: $SNAP_DATA/var/run_v2/postgresql

  /etc/ssl/certs:
    bind: $SNAP/etc/ssl/certs
  /etc/ssl/private:
    bind: $SNAP/etc/ssl/private

  /etc/postgresql/14/main:
    bind: $SNAP/etc/postgresql/14/main
```
Layouts are simply mappings between system directories (to which the confined snap has no access) and snap relative directories (to which the snap have access)

```yaml
apps: 
    ctrlx-postgresql:
        command: bin/run.sh 
        plugs: [network, network-bind, mount-observe, network-observe, system-observe, active-solution]
        daemon: simple
        passthrough:
          restart-condition: always
          restart-delay: 10s  
```
Apps are how the application is exposed to the end user. If the app is called with the same name as the whole snap, it is not neccessary to specify its name when calling.

In this case, the app simply calls run.sh, here a binary that starts the postgreSQL server is executed.

The apps is configured with a simple daemon that automatically starts it after 10s if it is not active. 

## 2. Non-root user
PostgreSQL is designed with a lot of security in mind, thus, among many other requirements, the sever must be started by a non-root user. Such non-root user must own all the neccesary files that are needed for the server to work.

We are going to run the server inside a snap, which implies a confined environment. In this confined environment, by default, we are only provided with a root user. So we need to find a way to run things inside this environment from a different user than root. 

The solution is using the ["system-usernames" snapcraft features](https://snapcraft.io/docs/system-usernames). It allows us to define a user called "snap_daemon" that has dropped priviledges.
```yaml
system-usernames:
  snap_daemon: shared
```
At the date this documentation was written (January 2024) system-user names only support the creation of a user called "snap_daemon" and nothing else, and also only with "shared" attributes.

Now, let's see how do we use this new "snap_daemon" user in our project.

Let's look first at "connect-plug-active-solution" hook.

Here we first make sure our directory is owned by root (althogh in theory it should be already owned). This is neccesary to be able to change permission later.

```sh
chown -R root "$MYDIR"
```
Then, if not already existing, we creat the neccesary directories. Next, we copy from the snap directories the neccesary files in the right persistent directories.

Once this is done, we give the right permissions to the data directories. It is strictly neccessary to give those, neither less nor more. 
```sh
chmod 777 -R "$MYDIR/configuration"
chmod 750 -R "$MYDIR/data_postgresql"
```
And finally we change the ownership to "snap_daemon" user. 
```sh
chown -R snap_daemon "$MYDIR" # data directory (configuration and data_postgresql are contained here)
chown -R snap_daemon "/var/run_v2/postgresql" # run time information directory (it was created before if not existing)
```

The last step is to call the binary that starts the server with the snap_daemon user, this is done in the "run.sh". Since we are inside a confinent snap environemt we cannot use the common unix command sintax. However, we can take advantage of the "setpriv" functionality as described in the [documentation](https://snapcraft.io/docs/system-usernames). The command will be as follows:

```sh
exec "${SNAP}"/usr/bin/setpriv --clear-groups --reuid snap_daemon --regid snap_daemon -- \
  $SNAP/usr/lib/postgresql/14/bin/postgres \
  --config-file=$MYDIR/configuration/postgresql.conf \
  --hba_file=$MYDIR/configuration/pg_hba.conf \
  --ident_file=$MYDIR/configuration/pg_ident.conf \
  -D $MYDIR/data_postgresql
```
I want to highligh that since the configuration files and data directory are not relative to the location of the executable, their path are explicitly indicated.

## 3. Configuration files
I have tried to keep the configuration files as similar as possible as they come with the installation of PostgreSQL (they one that are placed in the install directories in your local system after you install postgresql). However, some minor changes have been neccesary. The updated files are included in this repository, being such files the ones that are dumped to the snap.

One change ocurred in pg_hba.conf, where the users that have access to the server are defined. To avoid the need of login for the "postgres" user (the default one, acts as server manager), the verification method has been changed to "trust". This is not recommended for deployment, however, it is an easy way to check that everything is working fine.

```conf
local   all             postgres                                trust
```
The most important and relevant change was done in the runtime directory in which the server stores some run information, such as statistics. When the server is running normally, in a non-confined environemt, the server stores this information in /var/run/. The traditional way to deal with this in a snap confined environemt is to map this directory to one that is accesible from the snap, for example $SNAP_DATA/var/run/. This can be achieved with the use of layouts in snapcraft. 

Nevertheless, this cannot be the case here because layouts do not allow mapping to /var/run/ as stated in the [official documentation](https://snapcraft.io/docs/snap-layouts). The way to deal with this is telling the server that instead of storing in /var/run/, do it in another directory. In this case I chosed to name this other directory /var/run_v2/, just to avoid placing the files somewhere that eventually conflicts. I just simply substituded all the appearences of /var/run/ for /var/run_v2/ in the config files. 




