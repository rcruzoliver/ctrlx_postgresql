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


