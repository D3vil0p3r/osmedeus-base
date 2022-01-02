#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/osmedeus/osmedeus-base/master/install.sh | bash

# global stuff
BASE_PATH="$HOME/osmedeus-base"
BINARIES_PATH="$BASE_PATH/binaries"
DATA_PATH="$BASE_PATH/data"
TMP_DIST="/tmp/tmp-binaries"
DEFAULT_SHELL="$HOME/.bashrc"
CWD=$(pwd)
PACKGE_MANAGER="apt-get"

echo -e "\033[1;37m[\033[1;31m+\033[1;37m]\033[1;32m Set Data Directory:\033[1;37m $DATA_PATH \033[0m"
echo -e "\033[1;37m[\033[1;31m+\033[1;37m]\033[1;32m Set Binaries Directory:\033[1;37m $BINARIES_PATH \033[0m"

SUDO="sudo"
if [ "$(whoami)" == "root" ]; then
    SUDO=""
fi
[ -x "$(command -v apt)" ] && PACKGE_MANAGER="apt"

announce() {
    echo -e "\033[1;37m[\033[1;31m+\033[1;37m]\033[1;32m $1 \033[0m"
}

install_banner() {
    echo -e "\033[1;37m[\033[1;34m+\033[1;37m]\033[1;32m Installing $1 \033[0m"
}

download() {
    echo -e "\033[1;37m[\033[1;36m+\033[1;37m]\033[1;32m Downloading $1 \033[0m"
    wget --no-check-certificate -q -O $1 $2
    if [ ! -f "$1" ]; then
        wget --no-check-certificate -q -O $1 $2
    fi
}

extractZip() {
	unzip -q -o -j $1 -d $BINARIES_PATH/
	rm -rf $1
}

extractGz() {
	tar -xf $1 -C $BINARIES_PATH/
	rm -rf $1
}

announce "NOTE that this installation only works on\033[0m Linux based machine."
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "\033[1;34m[!] MacOS machine detected. Exit the script\033[0m"
    announce "Check out https://docs.osmedeus.org/faq/ for more information"
    exit 1
fi

$SUDO $PACKGE_MANAGER update -qq > /dev/null 2>&1
install_banner "Essential tool: wget, git, make, nmap, masscan, chromium"
# reinstall all essioontials tools just to double check
[ -x "$(command -v wget)" ] || $SUDO $PACKGE_MANAGER -qq install wget -y 2>/dev/null
[ -x "$(command -v curl)" ] || $SUDO $PACKGE_MANAGER -qq install curl -y 2>/dev/null
[ -x "$(command -v tmux)" ] || $SUDO $PACKGE_MANAGER -qq install tmux -y 2>/dev/null
[ -x "$(command -v git)" ] || $SUDO $PACKGE_MANAGER -qq install git -y 2>/dev/null
[ -x "$(command -v nmap)" ] || $SUDO $PACKGE_MANAGER -qq install nmap -y 2>/dev/null
[ -x "$(command -v masscan)" ] || $SUDO $PACKGE_MANAGER -qq install masscan -y 2>/dev/null
[ -x "$(command -v make)" ] || $SUDO $PACKGE_MANAGER -qq install build-essential -y 2>/dev/null
[ -x "$(command -v unzip)" ] || $SUDO $PACKGE_MANAGER -qq install unzip -y 2>/dev/null
[ -x "$(command -v chromium)" ] || $SUDO $PACKGE_MANAGER -qq install chromium -y 2>/dev/null
[ -x "$(command -v chromium-browser)" ] || $SUDO $PACKGE_MANAGER -qq install chromium-browser -y 2>/dev/null
[ -x "$(command -v make)" ] || $SUDO $PACKGE_MANAGER -qq install build-essential -y 2>/dev/null
[ -x "$(command -v jq)" ] || $SUDO $PACKGE_MANAGER -qq install jq -y 2>/dev/null
[ -x "$(command -v rsync)" ] || $SUDO $PACKGE_MANAGER -qq install rsync -y 2>/dev/null
[ -x "$(command -v htop)" ] || $SUDO $PACKGE_MANAGER -qq install htop -y 2>/dev/null
[ -x "$(command -v netstat)" ] || $SUDO $PACKGE_MANAGER -qq install coreutils net-tools -y 2>/dev/null
# [ -x "$(command -v rg)" ] || $SUDO $PACKGE_MANAGER -qq install ripgrep -y 2>/dev/null
# [ -x "$(command -v pip)" ] || $SUDO $PACKGE_MANAGER -qq install python-pip -y 2>/dev/null
# [ -x "$(command -v pip3)" ] || $SUDO $PACKGE_MANAGER -qq install python3-pip -y 2>/dev/null

announce "Clean up old stuff first"
rm -rf $BINARIES_PATH/* && mkdir -p $BINARIES_PATH 2>/dev/null
rm -rf $TMP_DIST && mkdir -p $TMP_DIST 2>/dev/null

announce "Cloning Osmedeus base repo:\033[0m https://github.com/osmedeus/osmedeus-base"
rm -rf $BASE_PATH && git clone --depth=1 https://github.com/osmedeus/osmedeus-base $BASE_PATH
# # retry to clone in case of anything wrong with the connection
if [ ! -d "$BASE_PATH" ]; then
    git clone --depth=1 https://github.com/osmedeus/osmedeus-base $BASE_PATH
fi

[ -z "$(which osmedeus)" ] && osmBin=/usr/local/bin/osmedeus || osmBin=$(which osmedeus)
announce "Setup Osmedeus Core Engine:\033[0m $osmBin"
unzip -q -o -j $BASE_PATH/dist/osmedeus-linux.zip -d $BASE_PATH/dist/
rm -rf $osmBin && cp $BASE_PATH/dist/osmedeus $osmBin && chmod +x $osmBin

#### done the osm core part

install_banner "External binaries"

download $TMP_DIST/amass.zip https://github.com/OWASP/Amass/releases/download/v3.15.2/amass_linux_amd64.zip
extractZip $TMP_DIST/amass.zip

download $TMP_DIST/subfinder.zip https://github.com/projectdiscovery/subfinder/releases/download/v2.4.9/subfinder_2.4.9_linux_amd64.zip
extractZip $TMP_DIST/subfinder.zip

download $TMP_DIST/nuclei.zip https://github.com/projectdiscovery/nuclei/releases/download/v2.5.7/nuclei_2.5.7_linux_amd64.zip
extractZip $TMP_DIST/nuclei.zip

download $TMP_DIST/httpx.zip https://github.com/projectdiscovery/httpx/releases/download/v1.1.4/httpx_1.1.4_linux_amd64.zip
extractZip $TMP_DIST/httpx.zip

download $TMP_DIST/aquatone.zip https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip
extractZip $TMP_DIST/aquatone.zip

download $BINARIES_PATH/findomain https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux

download $TMP_DIST/gau.gz https://github.com/lc/gau/releases/download/v2.0.6/gau_2.0.6_linux_amd64.tar.gz
extractGz $TMP_DIST/gau.gz

download $TMP_DIST/ffuf.gz https://github.com/ffuf/ffuf/releases/download/v1.3.1/ffuf_1.3.1_linux_amd64.tar.gz
extractGz $TMP_DIST/ffuf.gz

## my tools 

download $TMP_DIST/gospider.zip https://github.com/jaeles-project/gospider/releases/download/v1.1.6/gospider_v1.1.6_linux_x86_64.zip
extractZip $TMP_DIST/gospider.zip

download $TMP_DIST/jaeles.zip https://github.com/jaeles-project/jaeles/releases/download/beta-v0.17/jaeles-v0.17-linux.zip
extractZip $TMP_DIST/jaeles.zip

download $TMP_DIST/goverview.gz https://github.com/j3ssie/goverview/releases/download/v1.0.1/goverview_v1.0.1_linux_amd64.tar.gz
extractGz $TMP_DIST/goverview.gz

download $TMP_DIST/metabigor.gz https://github.com/j3ssie/metabigor/releases/download/v1.10/metabigor_v1.10_linux_amd64.tar.gz
extractGz $TMP_DIST/metabigor.gz

rm -rf $BINARIES_PATH/LICENSE*  $BINARIES_PATH/README* $BINARIES_PATH/config.ini 2>/dev/null

install_banner "auxiliary tools"
git clone --depth=1 https://github.com/osmedeus/auxs-binaries $TMP_DIST/auxs-binaries
# retry to clone in case of anything wrong with the connection
if [ ! -d "$TMP_DIST/auxs-binaries" ]; then
    git clone --depth=1 https://github.com/osmedeus/auxs-binaries $TMP_DIST/auxs-binaries
fi

cp $TMP_DIST/auxs-binaries/releases/* $BINARIES_PATH/
chmod +x $BINARIES_PATH/*
export PATH=$BINARIES_PATH:$PATH
### done the binaries part

isInFile=$(cat $DEFAULT_SHELL | grep -c "osm-default.rc")
if [ $isInFile -eq 0 ]; then
   echo 'source $HOME/osmedeus-base/token/osm-default.rc' >> $DEFAULT_SHELL
fi

osmedeus config reload
install_banner "Osmedeus Web UI"
rm -rf ~/.osmedeus/server/* >/dev/null 2>&1
mkdir -p ~/.osmedeus/server >/dev/null 2>&1
cp -R $BASE_PATH/ui ~/.osmedeus/server/ui >/dev/null 2>&1

install_banner "Osmedeus Community Workflow:\033[0m https://github.com/osmedeus/osmedeus-workflow"
rm -rf $BASE_PATH/workflow >/dev/null 2>&1
git clone --depth=1 https://github.com/osmedeus/osmedeus-workflow $BASE_PATH/workflow
## retry to clone in case of anything wrong with the connection
if [ ! -d "$BASE_PATH/workflow" ]; then
    git clone --depth=1 https://github.com/osmedeus/osmedeus-workflow $BASE_PATH
fi

install_banner "Downloading Vulnscan template"
jaeles config init >/dev/null 2>&1
rm -rf ~/nuclei-templates && git clone --depth=1 https://github.com/projectdiscovery/nuclei-templates.git ~/nuclei-templates >/dev/null 2>&1

###### Private installation for premium package

if [ -f "$BASE_PATH/secret/secret.sh" ]; then
    install_banner "private component"
    . $BASE_PATH/secret/secret.sh
fi

#######

echo "---->>>"
osmedeus health
echo "---->>>"
announce "The installation is done..."
announce "Check here if you want to setup API & token:\033[0m https://docs.osmedeus.org/installation/token/"
announce "Run\033[0m source ~/.bashrc \033[1;32m to complete the install"
announce "Run\033[1;32m osmedeus config reload \033[0m to reload the config file"
