#!/data/data/com.termux/files/usr/bin/bash
#
# ╔══════════════════════════════════════════════════════════════╗
# ║                                                              ║
# ║   ██╗  ██╗ █████╗  ██████╗██╗  ██╗██████╗  █████╗ ████████╗ ║
# ║   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗╚══██╔══╝ ║
# ║   ███████║███████║██║     █████╔╝ ██████╔╝███████║   ██║    ║
# ║   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══██╗██╔══██║   ██║    ║
# ║   ██║  ██║██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║   ██║    ║
# ║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ║
# ║                                                              ║
# ║                    ████████╗███████╗██████╗ ███╗   ███╗     ║
# ║                    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║     ║
# ║                       ██║   █████╗  ██████╔╝██╔████╔██║     ║
# ║                       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║     ║
# ║                       ██║   ███████╗██║  ██║██║ ╚═╝ ██║     ║
# ║                       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ║
# ║                                                              ║
# ║              SNI HOST HUNTER - TERMUX EDITION               ║
# ║                 Interactive Scanner v2.0                     ║
# ║                                                              ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Author: Hackrate Security Team
# Description: Interactive SNI Host Scanner for Termux
# Version: 2.0
#

# Color codes for Termux
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# Script variables
SCRIPT_VERSION="2.0"
SCAN_DIR="$HOME/hackrate_scans"
RESULTS_DIR="$SCAN_DIR/results"
LOG_DIR="$SCAN_DIR/logs"
TEMP_DIR="$SCAN_DIR/temp"
FOUND_HOSTS="$RESULTS_DIR/found_hosts.txt"
CURRENT_SCAN_LOG="$LOG_DIR/scan_$(date +%Y%m%d_%H%M%S).log"

# Create necessary directories
mkdir -p "$RESULTS_DIR" "$LOG_DIR" "$TEMP_DIR"

# Function to clear screen and show banner
show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║   ██╗  ██╗ █████╗  ██████╗██╗  ██╗██████╗  █████╗ ████████╗ █████╗ ███████╗
║   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝
║   ███████║███████║██║     █████╔╝ ██████╔╝███████║   ██║   ███████║█████╗  
║   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══██╗██╔══██║   ██║   ██╔══██║██╔══╝  
║   ██║  ██║██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║   ██║   ██║  ██║███████╗
║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
║                                                                           ║
║                    ███████╗███╗  ██╗██╗
║                    ██╔════╝████╗  ██║██║
║                    ███████╗██╔██╗ ██║██║
║                    ╚════██║██║╚██╗██║██║
║                    ███████║██║ ╚████║██║
║                    ╚══════╝╚═╝  ╚═══╝╚═╝
║                                                                           ║
║                    ${YELLOW}HOST HUNTER - TERMUX EDITION${CYAN}                    ║
║                    ${GREEN}Interactive SNI Scanner v${SCRIPT_VERSION}${CYAN}               ║
║                                                                           ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  ${WHITE}╔═╗╦ ╦╔╦╗╔═╗╔╦╗╔═╗╔╦╗  ╔═╗╦ ╦╔╗╔╔═╗╔═╗╦╔═╗╔╗╔╔═╗${CYAN}              ║
║  ${WHITE}╠═╣║ ║ ║ ╠═╣ ║ ║╣ ║║║  ║  ║ ║║║║║╣ ║  ║║ ║║║║║╣ ${CYAN}              ║
║  ${WHITE}╩ ╩╚═╝ ╩ ╩ ╩ ╩ ╚═╝╩ ╩  ╚═╝╚═╝╝╚╝╚═╝╚═╝╩╚═╝╝╚╝╚═╝${CYAN}              ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Show legal disclaimer
    echo -e "${YELLOW}${BOLD}[!] LEGAL DISCLAIMER${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}• This tool is for EDUCATIONAL PURPOSES only${NC}"
    echo -e "${RED}• Only use on systems you OWN or have PERMISSION to test${NC}"
    echo -e "${RED}• Unauthorized scanning may be ILLEGAL in your jurisdiction${NC}"
    echo -e "${RED}• The authors are NOT responsible for any misuse${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Show system info
    echo -e "${GREEN}${BOLD}[✓] System Information${NC}"
    echo -e "${CYAN}  • Date: $(date)${NC}"
    echo -e "${CYAN}  • Device: $(getprop ro.product.model 2>/dev/null || echo 'Termux')${NC}"
    echo -e "${CYAN}  • Android: $(getprop ro.build.version.release 2>/dev/null || echo 'Unknown')${NC}"
    echo -e "${CYAN}  • Storage: $(df -h /sdcard | awk 'NR==2 {print $4}') free${NC}"
    echo -e "${CYAN}  • Results Dir: $RESULTS_DIR${NC}"
    echo ""
    
    # Check if hackrate command exists
    if command -v hackrate &> /dev/null; then
        echo -e "${GREEN}${BOLD}[✓] Hackrate Hunter is installed${NC}"
    else
        echo -e "${RED}${BOLD}[✗] Hackrate Hunter not found!${NC}"
        echo -e "${YELLOW}Please run the installer first: ./install.sh${NC}"
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    case "$level" in
        "INFO") echo -e "${CYAN}[${timestamp}] [INFO] ${message}${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[${timestamp}] [✓] ${message}${NC}" ;;
        "ERROR") echo -e "${RED}[${timestamp}] [✗] ${message}${NC}" ;;
        "WARNING") echo -e "${YELLOW}[${timestamp}] [!] ${message}${NC}" ;;
        "FOUND") echo -e "${PURPLE}[${timestamp}] [🎯] ${message}${NC}" ;;
        *) echo -e "${WHITE}[${timestamp}] [${level}] ${message}${NC}" ;;
    esac
    
    # Also log to file
    echo "[${timestamp}] [${level}] ${message}" >> "$CURRENT_SCAN_LOG"
}

# Function to save found host to file
save_found_host() {
    local ip="$1"
    local hostname="$2"
    local port="$3"
    local cert_info="$4"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    local found_entry="[$timestamp] IP: $ip | Port: $port | Hostname: $hostname | Certificate: $cert_info"
    
    echo "$found_entry" >> "$FOUND_HOSTS"
    echo "$found_entry" >> "$RESULTS_DIR/found_$(date +%Y%m%d).txt"
    
    log_message "FOUND" "Saved: $ip:$port - $hostname"
}

# Function to scan single IP
scan_single_ip() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        SINGLE IP SCAN MODE"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    # Get target IP
    read -p "$(echo -e ${GREEN}"[?] Enter target IP address: "${NC})" target_ip
    
    # Validate IP
    if [[ ! $target_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "ERROR" "Invalid IP address format!"
        return 1
    fi
    
    # Get hostname to scan
    read -p "$(echo -e ${GREEN}"[?] Enter hostname to hunt (e.g., google.com): "${NC})" target_hostname
    
    if [ -z "$target_hostname" ]; then
        log_message "ERROR" "Hostname cannot be empty!"
        return 1
    fi
    
    # Get port
    read -p "$(echo -e ${GREEN}"[?] Enter port [default: 443]: "${NC})" target_port
    target_port=${target_port:-443}
    
    # Get timeout
    read -p "$(echo -e ${GREEN}"[?] Enter timeout in seconds [default: 3]: "${NC})" timeout
    timeout=${timeout:-3}
    
    echo ""
    log_message "INFO" "Starting scan..."
    log_message "INFO" "Target: $target_ip:$target_port"
    log_message "INFO" "Looking for: $target_hostname"
    echo ""
    
    # Run the scan
    output=$(hackrate --ip "$target_ip" --hostname "$target_hostname" --port "$target_port" --timeout "$timeout" 2>&1)
    scan_result=$?
    
    # Check if host was found
    if echo "$output" | grep -q "Found\|success"; then
        log_message "SUCCESS" "Host found on $target_ip!"
        
        # Extract certificate info
        cert_cn=$(echo "$output" | grep "Certificate CN:" | cut -d':' -f2- | xargs)
        
        # Save to found hosts file
        save_found_host "$target_ip" "$target_hostname" "$target_port" "$cert_cn"
        
        # Display full output
        echo ""
        echo -e "${GREEN}${BOLD}Scan Results:${NC}"
        echo "$output"
    else
        log_message "ERROR" "Host not found on $target_ip"
        echo ""
        echo "$output"
    fi
    
    echo ""
    read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
}

# Function to scan IP range
scan_ip_range() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        IP RANGE SCAN MODE"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    # Get network range
    read -p "$(echo -e ${GREEN}"[?] Enter network range (CIDR, e.g., 192.168.1.0/24): "${NC})" network_range
    
    # Validate CIDR
    if [[ ! $network_range =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        log_message "ERROR" "Invalid CIDR format!"
        return 1
    fi
    
    # Get hostname to scan
    read -p "$(echo -e ${GREEN}"[?] Enter hostname to hunt (e.g., google.com): "${NC})" target_hostname
    
    if [ -z "$target_hostname" ]; then
        log_message "ERROR" "Hostname cannot be empty!"
        return 1
    fi
    
    # Get port
    read -p "$(echo -e ${GREEN}"[?] Enter port [default: 443]: "${NC})" target_port
    target_port=${target_port:-443}
    
    # Get threads
    read -p "$(echo -e ${GREEN}"[?] Enter number of threads [default: 50]: "${NC})" threads
    threads=${threads:-50}
    
    echo ""
    log_message "WARNING" "This will scan up to $(echo $network_range | cut -d'/' -f2) IP addresses"
    log_message "WARNING" "This may take several minutes..."
    echo ""
    
    read -p "$(echo -e ${YELLOW}"[?] Proceed with scan? (y/n): "${NC})" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_message "INFO" "Scan cancelled"
        return
    fi
    
    echo ""
    log_message "INFO" "Starting range scan..."
    log_message "INFO" "Network: $network_range"
    log_message "INFO" "Looking for: $target_hostname on port $target_port"
    log_message "INFO" "Threads: $threads"
    echo ""
    
    # Run the scan
    hackrate --range "$network_range" --hostname "$target_hostname" --port "$target_port" --threads "$threads" --output "$RESULTS_DIR/range_scan_$(date +%Y%m%d_%H%M%S).json"
    
    echo ""
    log_message "SUCCESS" "Range scan completed!"
    echo ""
    read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
}

# Function to scan from file
scan_from_file() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        FILE-BASED SCAN MODE"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    # Get file path
    read -p "$(echo -e ${GREEN}"[?] Enter path to IP list file: "${NC})" ip_file
    
    if [ ! -f "$ip_file" ]; then
        log_message "ERROR" "File not found: $ip_file"
        return 1
    fi
    
    # Count IPs
    ip_count=$(wc -l < "$ip_file")
    log_message "INFO" "File contains $ip_count IP addresses"
    
    # Get hostname to scan
    read -p "$(echo -e ${GREEN}"[?] Enter hostname to hunt (e.g., google.com): "${NC})" target_hostname
    
    if [ -z "$target_hostname" ]; then
        log_message "ERROR" "Hostname cannot be empty!"
        return 1
    fi
    
    # Get port
    read -p "$(echo -e ${GREEN}"[?] Enter port [default: 443]: "${NC})" target_port
    target_port=${target_port:-443}
    
    # Get threads
    read -p "$(echo -e ${GREEN}"[?] Enter number of threads [default: 50]: "${NC})" threads
    threads=${threads:-50}
    
    echo ""
    log_message "INFO" "Starting file-based scan..."
    log_message "INFO" "File: $ip_file"
    log_message "INFO" "Targets: $ip_count IPs"
    log_message "INFO" "Looking for: $target_hostname on port $target_port"
    echo ""
    
    # Run the scan
    hackrate --file "$ip_file" --hostname "$target_hostname" --port "$target_port" --threads "$threads" --output "$RESULTS_DIR/file_scan_$(date +%Y%m%d_%H%M%S).json"
    
    echo ""
    log_message "SUCCESS" "File scan completed!"
    echo ""
    read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
}

# Function to scan website domain
scan_website() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        WEBSITE DOMAIN SCAN MODE"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    # Get domain
    read -p "$(echo -e ${GREEN}"[?] Enter website domain (e.g., example.com): "${NC})" domain
    
    if [ -z "$domain" ]; then
        log_message "ERROR" "Domain cannot be empty!"
        return 1
    fi
    
    log_message "INFO" "Resolving IP for $domain..."
    
    # Resolve IP
    ip=$(ping -c 1 "$domain" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    
    if [ -z "$ip" ]; then
        # Try alternative method
        ip=$(nslookup "$domain" 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    fi
    
    if [ -z "$ip" ]; then
        log_message "ERROR" "Could not resolve domain: $domain"
        return 1
    fi
    
    log_message "SUCCESS" "Domain resolved to IP: $ip"
    echo ""
    
    # Get port
    read -p "$(echo -e ${GREEN}"[?] Enter port [default: 443]: "${NC})" target_port
    target_port=${target_port:-443}
    
    echo ""
    log_message "INFO" "Scanning $ip for hostname $domain..."
    
    # Run the scan
    output=$(hackrate --ip "$ip" --hostname "$domain" --port "$target_port" 2>&1)
    
    # Check if host was found
    if echo "$output" | grep -q "Found\|success"; then
        log_message "SUCCESS" "Host found on $ip!"
        
        # Extract certificate info
        cert_cn=$(echo "$output" | grep "Certificate CN:" | cut -d':' -f2- | xargs)
        
        # Save to found hosts file
        save_found_host "$ip" "$domain" "$target_port" "$cert_cn"
        
        # Display full output
        echo ""
        echo -e "${GREEN}${BOLD}Scan Results:${NC}"
        echo "$output"
    else
        log_message "ERROR" "Host not found on $ip"
        echo ""
        echo "$output"
    fi
    
    echo ""
    read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
}

# Function to view found hosts
view_found_hosts() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        FOUND HOSTS DATABASE"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    if [ ! -f "$FOUND_HOSTS" ]; then
        log_message "WARNING" "No hosts found yet!"
        echo ""
        read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
        return
    fi
    
    # Count found hosts
    total_found=$(wc -l < "$FOUND_HOSTS")
    log_message "INFO" "Total found hosts: $total_found"
    echo ""
    
    echo -e "${CYAN}${BOLD}Last 10 found hosts:${NC}"
    echo "──────────────────────────────────"
    tail -10 "$FOUND_HOSTS" | while read line; do
        echo -e "${GREEN}$line${NC}"
    done
    
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "1. View all found hosts"
    echo "2. Search in found hosts"
    echo "3. Export found hosts"
    echo "4. Clear found hosts"
    echo "5. Back to main menu"
    echo ""
    
    read -p "$(echo -e ${GREEN}"[?] Choose option (1-5): "${NC})" view_option
    
    case $view_option in
        1)
            echo ""
            log_message "INFO" "All found hosts:"
            echo "──────────────────────────────────"
            cat "$FOUND_HOSTS" | nl
            ;;
        2)
            read -p "$(echo -e ${GREEN}"[?] Enter search term: "${NC})" search_term
            echo ""
            log_message "INFO" "Search results for '$search_term':"
            echo "──────────────────────────────────"
            grep -i "$search_term" "$FOUND_HOSTS" || echo "No matches found"
            ;;
        3)
            export_file="$RESULTS_DIR/found_hosts_export_$(date +%Y%m%d_%H%M%S).txt"
            cp "$FOUND_HOSTS" "$export_file"
            log_message "SUCCESS" "Exported to: $export_file"
            ;;
        4)
            read -p "$(echo -e ${RED}"[?] Clear all found hosts? (y/n): "${NC})" confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                > "$FOUND_HOSTS"
                log_message "INFO" "Found hosts cleared"
            fi
            ;;
        5)
            return
            ;;
        *)
            log_message "ERROR" "Invalid option"
            ;;
    esac
    
    echo ""
    read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
}

# Function to show statistics
show_statistics() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        SCAN STATISTICS"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    # Count found hosts
    if [ -f "$FOUND_HOSTS" ]; then
        total_found=$(wc -l < "$FOUND_HOSTS")
    else
        total_found=0
    fi
    
    # Count log files
    log_count=$(ls -1 "$LOG_DIR" 2>/dev/null | wc -l)
    
    # Count result files
    result_count=$(ls -1 "$RESULTS_DIR"/*.json 2>/dev/null | wc -l)
    
    # Get latest scan
    latest_scan=$(ls -t "$LOG_DIR" 2>/dev/null | head -1)
    
    echo -e "${CYAN}${BOLD}Hackrate Hunter Statistics${NC}"
    echo "──────────────────────────────────"
    echo -e "${GREEN}Total found hosts: $total_found${NC}"
    echo -e "${GREEN}Total scans performed: $log_count${NC}"
    echo -e "${GREEN}Result files: $result_count${NC}"
    echo -e "${GREEN}Database location: $FOUND_HOSTS${NC}"
    
    if [ ! -z "$latest_scan" ]; then
        echo -e "${GREEN}Latest scan: $latest_scan${NC}"
    fi
    
    # Show top 5 most found hostnames
    if [ $total_found -gt 0 ]; then
        echo ""
        echo -e "${CYAN}${BOLD}Top 5 most found hostnames:${NC}"
        echo "──────────────────────────────────"
        grep -o "Hostname: [^|]*" "$FOUND_HOSTS" | cut -d' ' -f2 | sort | uniq -c | sort -rn | head -5
    fi
    
    echo ""
    read -p "$(echo -e ${CYAN}"Press Enter to continue..."${NC})"
}

# Function to show help
show_help() {
    echo ""
    log_message "INFO" "═══════════════════════════════════════════"
    log_message "INFO" "        HELP & DOCUMENTATION"
    log_message "INFO" "═══════════════════════════════════════════"
    echo ""
    
    echo -e "${CYAN}${BOLD}Hackrate Hunter - Quick Guide${NC}"
    echo "──────────────────────────────────"
    echo ""
    echo -e "${GREEN}What is SNI?${NC}"
    echo "Server Name Indication (SNI) allows multiple HTTPS websites"
    echo "to be hosted on the same IP address using different certificates."
    echo ""
    echo -e "${GREEN}Scan Types:${NC}"
    echo "  1. Single IP Scan - Check one IP for a specific hostname"
    echo "  2. Range Scan     - Scan entire network for a hostname"
    echo "  3. File Scan      - Scan IP list from file"
    echo "  4. Website Scan   - Resolve domain and scan its IP"
    echo ""
    echo -e "${GREEN}Output Files:${NC}"
    echo "  • Found hosts: $FOUND_HOSTS"
    echo "  • Scan logs:   $LOG_DIR"
    echo "  • Results:     $RESULTS_DIR"
    echo ""
    echo -e "${GREEN}Tips:${NC}"
    echo "  • Use more threads for faster scanning"
    echo "  • Increase timeout for slow connections"
    echo "  • Save results regularly"
    echo "  • Always get permission before scanning"
    echo ""
    echo -e "${GREEN}Legal:${NC}"
    echo "  • Only scan 
