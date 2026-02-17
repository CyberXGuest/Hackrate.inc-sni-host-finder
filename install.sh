#!/data/data/com.termux/files/usr/bin/bash
#
# Hackrate Hunter - Termux Installation Script
# Author: Hackrate Security Team
# Usage: ./install.sh

# Color codes for Termux
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Print banner
clear
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ██╗  ██╗ █████╗  ██████╗██╗  ██╗██████╗  █████╗ ████████╗ ║
║   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗╚══██╔══╝ ║
║   ███████║███████║██║     █████╔╝ ██████╔╝███████║   ██║    ║
║   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══██╗██╔══██║   ██║    ║
║   ██║  ██║██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║   ██║    ║
║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ║
║                                                              ║
║                    TERMUX INSTALLER v2.0                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}[!] This script will install Hackrate Hunter on Termux${NC}"
echo -e "${YELLOW}[!] Make sure you have storage permissions enabled${NC}"
echo -e ""

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}[✗] This script must be run in Termux on Android${NC}"
    exit 1
fi

# Request storage permission
echo -e "${BLUE}[+] Requesting storage permission...${NC}"
termux-setup-storage
sleep 2

# Update packages
echo -e "${BLUE}[+] Updating Termux packages...${NC}"
pkg update -y && pkg upgrade -y

# Install required packages
echo -e "${BLUE}[+] Installing required packages...${NC}"
packages=(
    "python"
    "clang"
    "openssl"
    "libxml2"
    "libxslt"
    "libffi"
    "openssl-tool"
    "git"
    "nmap"
    "wget"
    "curl"
)

for pkg in "${packages[@]}"; do
    echo -e "${CYAN}  Installing $pkg...${NC}"
    pkg install -y $pkg
done

# Create directory structure
echo -e "${BLUE}[+] Creating Hackrate Hunter directories...${NC}"
mkdir -p ~/hackrate_hunter/{config,wordlists,results,logs,modules,tools}
mkdir -p ~/.config/hackrate

# Install Python dependencies
echo -e "${BLUE}[+] Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install colorama ipaddress requests beautifulsoup4 lxml pyOpenSSL cryptography

# Download wordlists
echo -e "${BLUE}[+] Downloading wordlists...${NC}"
cd ~/hackrate_hunter/wordlists

# Common hostnames
cat > common_hosts.txt << 'EOFLIST'
google.com
facebook.com
youtube.com
yahoo.com
baidu.com
wikipedia.org
amazon.com
twitter.com
instagram.com
linkedin.com
netflix.com
reddit.com
tumblr.com
github.com
stackoverflow.com
wordpress.com
blogspot.com
adobe.com
apple.com
microsoft.com
EOFLIST

# Popular ports
cat > popular_ports.txt << 'EOFLIST'
443
8443
4443
2087
2083
2096
9443
4343
8080
8443
EOFLIST

# Create configuration file
echo -e "${BLUE}[+] Creating configuration file...${NC}"
cat > ~/.config/hackrate/settings.ini << 'EOFCONF'
[DEFAULT]
timeout = 3
max_threads = 50
retries = 2
output_format = json
save_certificates = true
user_agent = Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36

[TERMUX]
battery_saver = true
notification_on_complete = true
vibrate_on_find = true
max_threads_battery = 25

[NETWORK]
prefer_ipv4 = true
dns_timeout = 2
resolve_hostnames = false
EOFCONF

# Copy main script
echo -e "${BLUE}[+] Installing main script...${NC}"
cat > ~/hackrate_hunter/hackrate_hunter.py << 'EOFMAIN'
[Content of hackrate_hunter.py from above]
EOFMAIN

# Create helper scripts
echo -e "${BLUE}[+] Creating helper scripts...${NC}"

# Mass scanner
cat > ~/hackrate_hunter/tools/mass_scanner.sh << 'EOFMASS'
#!/data/data/com.termux/files/usr/bin/bash
# Mass scanner for Hackrate Hunter

echo "Hackrate Hunter - Mass Scanner"
echo "================================"

read -p "Enter network range (e.g., 192.168.1.0/24): " range
read -p "Enter hostname to hunt: " hostname
read -p "Enter number of threads (default: 50): " threads

threads=${threads:-50}

echo "Starting mass scan..."
python ~/hackrate_hunter/hackrate_hunter.py --range $range --hostname $hostname --threads $threads
EOFMASS

# Results parser
cat > ~/hackrate_hunter/tools/results_parser.py << 'EOFPARSE'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

def parse_results(filename):
    with open(filename, 'r') as f:
        data = json.load(f)
    
    print(f"\nHackrate Hunter Results Analysis")
    print(f"=================================")
    print(f"Scan Date: {data['scan_time']}")
    print(f"Duration: {data['duration']:.1f} seconds")
    print(f"Total Targets: {data['stats']['scanned']}")
    print(f"Found: {data['stats']['found']}")
    print(f"Failed: {data['stats']['failed']}")
    print(f"Timeout: {data['stats']['timeout']}\n")
    
    if data['stats']['found'] > 0:
        print("Successful Hits:")
        print("-" * 40)
        for i, result in enumerate(data['results'], 1):
            if result['status'] == 'success':
                print(f"{i}. {result['ip']}:{result['port']} - {result['hostname']}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: results_parser.py <result_file.json>")
        sys.exit(1)
    parse_results(sys.argv[1])
EOFPARSE

# Create launcher script
echo -e "${BLUE}[+] Creating launcher script...${NC}"
cat > $PREFIX/bin/hackrate << 'EOFLAUNCH'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/hackrate_hunter
python hackrate_hunter.py "$@"
EOFLAUNCH

chmod +x $PREFIX/bin/hackrate

# Create desktop entry for Termux widget (optional)
mkdir -p ~/.shortcuts
cat > ~/.shortcuts/hackrate_hunter << 'EOFSHORTCUT'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/hackrate_hunter
clear
python hackrate_hunter.py --help
echo ""
read -p "Press Enter to continue..."
EOFSHORTCUT
chmod +x ~/.shortcuts/hackrate_hunter

# Set permissions
chmod +x ~/hackrate_hunter/tools/*.sh
chmod +x ~/hackrate_hunter/tools/*.py

# Create alias in bashrc
echo "alias hackrate='cd ~/hackrate_hunter && python hackrate_hunter.py'" >> ~/.bashrc

# Final message
echo -e ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    INSTALLATION COMPLETE!                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${CYAN}Hackrate Hunter has been installed successfully!${NC}"
echo -e ""
echo -e "${WHITE}Quick Start:${NC}"
echo -e "${YELLOW}  hackrate --ip 127.0.0.1 --hostname example.com${NC}"
echo -e "${YELLOW}  hackrate --range 192.168.1.0/24 --hostname example.com${NC}"
echo -e "${YELLOW}  hackrate --file targets.txt --hostname example.com${NC}"
echo -e ""
echo -e "${WHITE}Tools:${NC}"
echo -e "${YELLOW}  hackrate --help                 # Show help${NC}"
echo -e "${YELLOW}  mass_scanner                    # Interactive mass scanner${NC}"
echo -e "${YELLOW}  results_parser results.json     # Parse scan results${NC}"
echo -e ""
echo -e "${GREEN}[✓] Type 'hackrate --help' to get started!${NC}"
echo -e ""

# Ask for notification permission
termux-notification -t "Hackrate Hunter" -c "Installation complete! Ready to hunt SNI hosts." --ongoing
