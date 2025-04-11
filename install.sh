#!/bin/bash

# ----------------- Terminal color configuration -----------------

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
PURPLE="\e[35m"
CYAN="\e[36m"
YELLOW="\e[1;33m"
WHITE="\e[1;37m"
ENDCOLOR="\e[0m"

# ----------------- Dependency and tool installation -----------------

echo -e "${YELLOW}[+] Updating system...${ENDCOLOR}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install xclip rlwrap bloodhound flameshot -y

# ----------------- Installation of useful tools -----------------

# Directory for tools
TOOLS_DIR=~/tools
mkdir -p "$TOOLS_DIR"
mkdir -p ~/.local/share/fonts/

# Install fonts and tools like Bat and LSD
echo -e "${YELLOW}[+] Installing fonts and tools...${ENDCOLOR}"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip
unzip -q Hack.zip -d ~/.local/share/fonts/
fc-cache -fv

# Install bat and lsd
wget -q https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
wget -q https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd_1.1.5_amd64.deb
sudo dpkg -i bat_0.25.0_amd64.deb
sudo dpkg -i lsd_1.1.5_amd64.deb

# ----------------- Creating work directories -----------------

echo -e "${YELLOW}[+] Creating work directories...${ENDCOLOR}"
mkdir -p ~/htb ~/offsec ~/thm ~/pgp ~/labs ~/VPN

# ----------------- Copying configuration files -----------------

echo -e "${YELLOW}[+] Copying configuration files...${ENDCOLOR}"

# Copy aliases and functions files
cp .aliases ~/.aliases
cp custom_functions.sh ~/custom_functions.sh
chmod +x ~/custom_functions.sh

# Include configurations in .zshrc
echo -e "\n# Custom Aliases" >> ~/.zshrc
echo 'source ~/.aliases' >> ~/.zshrc
echo -e "\n# Custom Functions" >> ~/.zshrc
echo 'source ~/custom_functions.sh' >> ~/.zshrc

echo -e "${GREEN}[+] Configuration script complete!${ENDCOLOR}"
