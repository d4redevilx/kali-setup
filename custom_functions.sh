# Colors
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
PURPLE="\e[35m"
CYAN="\e[36m"
YELLOW="\e[1;33m"
WHITE="\e[1;37m"
ENDCOLOR="\e[0m"

# ----------------- Custom Functions -----------------

# Function to extract ports from a Nmap file
function extractPorts() {
    ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
    ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
    echo -e "\n${YELLOW}---------------- Port Scan Summary ------------------${ENDCOLOR}\n" > extractPorts.tmp
    echo -e "${BLUE}[+] IP Address:${ENDCOLOR}${WHITE} $ip_address ${ENDCOLOR}"  >> extractPorts.tmp
    echo -e "${BLUE}[+] Open ports:${ENDCOLOR}${WHITE} $ports ${ENDCOLOR}\n"  >> extractPorts.tmp
    echo -e "${BLUE}[+] Nmap Command:${ENDCOLOR}${WHITE} nmap -sCV -p${ports} -oN servicesScan ${ip_address} -vvv" >> extractPorts.tmp
    echo -e "${YELLOW}-----------------------------------------------------${ENDCOLOR}\n" >> extractPorts.tmp
    echo -e "nmap -sCV -p${ports} -oN servicesScan ${ip_address}" | tr -d '\n' | xclip -sel clip
    cat extractPorts.tmp; rm extractPorts.tmp
}

# Mount SMB share
function mount_smb() {
    if [ "$#" -ne 3 ]; then
        echo "Usage: mount_smb <IP> <share> <mountpoint>"
        return 1
    fi
    sudo mount -t cifs //$1/$2 $3 -o username=guest,password=
}

# Create test directories
function mk() {
    mkdir -p $1/{nmap,content,exploits,resource}
}

# Securely delete files
function rmk() {
    scrub -p dod $1
    shred -zun 10 -v $1
}

# Copy to clipboard
function copy() {
    cat $1 | xclip -sel clip
}

# Start HTTP server
function serv.http() {
    port=$1
    directory=$2
    if [[ "$1" = "" ]]; then
        port=8000
    fi
    if [[ "$2" = "" ]]; then
        directory="."
    fi
    echo -e "${BLUE}[+] HTTP server started in ${WHITE}$directory${ENDCOLOR} on port ${WHITE}$port${ENDCOLOR}"
    python3 -m http.server $port --directory $directory
}

# Nmap ports scan
function nmap_ports() {
    if [ -z "$1" ]; then
        echo -e "${RED}[-] Usage:${ENDCOLOR} nmap_ports <IP>${ENDCOLOR}"
        return 1
    fi
    ip=$1
    cmd="nmap -sS -p- --open -Pn -n --min-rate 5000 -oG openPorts -vvv $ip"
    echo -e "${BLUE}[+] Running:${ENDCOLOR} ${WHITE}$cmd${ENDCOLOR}"
    eval $cmd
}

# Nmap UDP scan (100 ports)
function nmap_udp_100() {
    if [ -z "$1" ]; then
        echo -e "${RED}[-] Usage:${ENDCOLOR} nmap_udp_100 <IP>${ENDCOLOR}"
        return 1
    fi
    ip=$1
    cmd="nmap -n -v -sU -F -T4 --reason --open -oA nmap/udp-fast $ip"
    echo -e "${BLUE}[+] Running:${ENDCOLOR} ${WHITE}$cmd${ENDCOLOR}"
    eval $cmd
}

# Nmap UDP scan (top 20 ports)
function nmap_udp_20() {
    if [ -z "$1" ]; then
        echo -e "${RED}[-] Usage:${ENDCOLOR} nmap_udp_20 <IP>${ENDCOLOR}"
        return 1
    fi
    ip=$1
    cmd="nmap -n -v -sU -T4 --top-ports=20 --reason --open -oA nmap/udp-top20 $ip"
    echo -e "${BLUE}[+] Running:${ENDCOLOR} ${WHITE}$cmd${ENDCOLOR}"
    eval $cmd
}

# Proxy scan with Nmap
function proxy_nmap() {
    if [ -z "$1" ]; then
        echo -e "${RED}[-] Usage:${ENDCOLOR} proxy_nmap <IP>${ENDCOLOR}"
        return 1
    fi
    ip=$1
    echo -e "${BLUE}[+] Running TCP scan through proxychains on all ports...${ENDCOLOR}"
    seq 1 65535 | xargs -P 500 -I {} proxychains nmap -sT -p{} --open -T5 -Pn -n $ip -vvv -oN servicesScan 2>&1 | grep "tcp open"
}

# Upload web shell
function upload_shell() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}[-] Usage:${ENDCOLOR} upload_shell <IP> <path_to_shell>${ENDCOLOR}"
        return 1
    fi
    ip=$1
    shell=$2
    echo -e "${BLUE}[+] Uploading web shell to ${WHITE}$ip${ENDCOLOR}"
    python3 -m http.server 8000 --directory $(dirname $shell)
    curl -X POST -F "file=@$shell" http://$ip/upload.php
}

# VPN function
function vpn() {
    # Check if OpenVPN is installed
    if ! command -v openvpn &> /dev/null; then
        echo -e "${RED}[-] OpenVPN is not installed. Installing OpenVPN...${ENDCOLOR}"
        sudo apt-get update && sudo apt-get install -y openvpn
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Error installing OpenVPN. Make sure you have internet access and admin permissions.${ENDCOLOR}"
            return 1
        fi
    fi
    
    # If no parameter or 'disconnect' parameter, disconnect from the current VPN
    if [ -z "$1" ] || [ "$1" == "disconnect" ]; then
        echo -e "${BLUE}[+] Disconnecting from the current VPN...${ENDCOLOR}"
        sudo pkill openvpn
        return 0
    fi
    
    # Define commands for each VPN
    case $1 in
        1)
            echo -e "${BLUE}[+] Connecting to HTB VPN...${ENDCOLOR}"
            # Assuming the OpenVPN configuration file for HTB is in /home/kali/VPN/htb.ovpn
            sudo openvpn --config /home/kali/VPN/htb.ovpn &
        ;;
        2)
            echo -e "${BLUE}[+] Connecting to HTB Academy VPN...${ENDCOLOR}"
            # Assuming the OpenVPN configuration file for HTB Academy is in /home/kali/VPN/htb_academy.ovpn
            sudo openvpn --config /home/kali/VPN/htb_academy.ovpn &
        ;;
        3)
            echo -e "${BLUE}[+] Connecting to Offsec VPN...${ENDCOLOR}"
            # Assuming the OpenVPN configuration file for Offsec is in /home/kali/VPN/universal.ovpn
            sudo openvpn --config /home/kali/VPN/universal.ovpn &
        ;;
        4)
            echo -e "${BLUE}[+] Connecting to Try Hack Me VPN...${ENDCOLOR}"
            # Assuming the OpenVPN configuration file for Try Hack Me is in /home/kali/VPN/thm.ovpn
            sudo openvpn --config /home/kali/VPN/thm.ovpn &
        ;;
        *)
            echo -e "${RED}[-] Invalid option.${ENDCOLOR} ${YELLOW}Please select a valid option (1-4).${ENDCOLOR}"
            return 1
        ;;
    esac
    
    echo -e "${GREEN}[+] VPN connected successfully.${ENDCOLOR} You can now start working."
}

# Netcat listener for Linux
function lin_shell() {
    port=$1
    
    if [[ "$1" = "" ]]; then
        port=4444
    fi
    
    nc -lnvp $port
}

# Netcat listener for Windows
function win_shell() {
    port=$1
    
    if [[ "$1" = "" ]]; then
        port=4444
    fi
    
    rlwrap nc -lnvp $port
}
