#!/usr/bin/env python3
"""
HACKRATE HUNTER - SNI Host Discovery Tool for Termux & Ethical Hacking
Author: Hackrate Security Team
Version: 2.0 (Termux Optimized)
License: Educational Purpose Only
"""

import os
import sys
import json
import socket
import ssl
import threading
import argparse
from datetime import datetime
import ipaddress
from concurrent.futures import ThreadPoolExecutor, as_completed
import time
import random
import signal
import configparser
from pathlib import Path

# Try to import colorama for Termux color support
try:
    from colorama import init, Fore, Back, Style
    init(autoreset=True)
    COLORS = True
except ImportError:
    COLORS = False
    # Create dummy color classes
    class Fore:
        RED = GREEN = YELLOW = BLUE = MAGENTA = CYAN = WHITE = RESET = ''
    class Style:
        BRIGHT = DIM = NORMAL = RESET_ALL = ''

# ============================================================
#                    HACKRATE HUNTER BANNER
# ============================================================
BANNER = f"""
{Fore.RED}{Style.BRIGHT}
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ██╗  ██╗ █████╗  ██████╗██╗  ██╗██████╗  █████╗ ████████╗ ║
║   ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗╚══██╔══╝ ║
║   ███████║███████║██║     █████╔╝ ██████╔╝███████║   ██║    ║
║   ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══██╗██╔══██║   ██║    ║
║   ██║  ██║██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║   ██║    ║
║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ║
║                                                              ║
║                    ████████╗███████╗██████╗ ███╗   ███╗     ║
║                    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║     ║
║                       ██║   █████╗  ██████╔╝██╔████╔██║     ║
║                       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║     ║
║                       ██║   ███████╗██║  ██║██║ ╚═╝ ██║     ║
║                       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ║
║                                                              ║
║              {Fore.CYAN}SNI HOST HUNTER - TERMUX EDITION{Fore.RED}               ║
║                 {Fore.YELLOW}Ethical Hacking Tool v2.0{Fore.RED}                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
{Style.RESET_ALL}

{Fore.YELLOW}[!] Legal Disclaimer: This tool is for educational purposes only{Fore.RESET}
{Fore.YELLOW}[!] Only use on systems you own or have explicit permission to test{Fore.RESET}
{Fore.YELLOW}[!] Unauthorized scanning may be illegal and unethical{Fore.RESET}

{Fore.CYAN}[✓] Termux Optimized Version Loaded{Fore.RESET}
{Fore.CYAN}[✓] Platform: {sys.platform}{Fore.RESET}
{Fore.CYAN}[✓] Colors: {'Enabled' if COLORS else 'Disabled'}{Fore.RESET}
"""

class HackrateHunter:
    def __init__(self, config_file=None):
        """Initialize Hackrate Hunter with configuration"""
        self.version = "2.0"
        self.start_time = time.time()
        self.results = []
        self.lock = threading.Lock()
        self.stats = {
            'scanned': 0,
            'found': 0,
            'failed': 0,
            'timeout': 0
        }
        
        # Load configuration
        self.config = self.load_config(config_file)
        
        # Set defaults from config
        self.timeout = self.config.getint('DEFAULT', 'timeout', fallback=3)
        self.max_threads = self.config.getint('DEFAULT', 'max_threads', fallback=50)
        self.retries = self.config.getint('DEFAULT', 'retries', fallback=2)
        self.user_agent = self.config.get('DEFAULT', 'user_agent', 
            fallback='Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36')
        
        # Create output directory
        self.output_dir = Path.home() / 'hackrate_output'
        self.output_dir.mkdir(exist_ok=True)
        
        # Handle Ctrl+C gracefully
        signal.signal(signal.SIGINT, self.signal_handler)
        
    def load_config(self, config_file):
        """Load configuration from file"""
        config = configparser.ConfigParser()
        
        # Default configuration
        config['DEFAULT'] = {
            'timeout': '3',
            'max_threads': '50',
            'retries': '2',
            'user_agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36',
            'output_format': 'json',
            'save_certificates': 'false'
        }
        
        # Try to load config file
        if config_file and Path(config_file).exists():
            config.read(config_file)
            print(f"{Fore.GREEN}[✓] Loaded config from: {config_file}{Fore.RESET}")
        else:
            # Try default config locations
            default_configs = [
                Path('/data/data/com.termux/files/home/.config/hackrate/settings.ini'),
                Path('./config/settings.ini'),
                Path.home() / '.hackrate.ini'
            ]
            
            for cfg in default_configs:
                if cfg.exists():
                    config.read(cfg)
                    print(f"{Fore.GREEN}[✓] Loaded config from: {cfg}{Fore.RESET}")
                    break
        
        return config
    
    def print_status(self, message, status='info'):
        """Print colored status messages"""
        colors = {
            'success': Fore.GREEN + '[✓] ',
            'error': Fore.RED + '[✗] ',
            'warning': Fore.YELLOW + '[!] ',
            'info': Fore.CYAN + '[+] ',
            'found': Fore.MAGENTA + '[🎯] '
        }
        
        prefix = colors.get(status, Fore.WHITE + '[?] ')
        timestamp = datetime.now().strftime('%H:%M:%S')
        
        print(f"{Fore.WHITE}[{timestamp}]{Fore.RESET} {prefix}{message}{Fore.RESET}")
    
    def check_sni_host(self, ip, hostname, port=443):
        """Check if a specific hostname is served on the IP address"""
        for attempt in range(self.retries):
            try:
                # Create socket with timeout
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(self.timeout)
                sock.connect((ip, port))
                
                # Create SSL context
                context = ssl.create_default_context()
                context.check_hostname = False
                context.verify_mode = ssl.CERT_NONE
                
                # Set SNI hostname
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    # Get certificate
                    cert = ssock.getpeercert()
                    
                    # Extract certificate info
                    cert_info = self.extract_cert_info(cert)
                    
                    # Get server info
                    server_info = {
                        'ip': ip,
                        'hostname': hostname,
                        'port': port,
                        'status': 'success',
                        'certificate': cert_info,
                        'timestamp': datetime.now().isoformat(),
                        'ssl_version': ssock.version(),
                        'cipher': ssock.cipher()
                    }
                    
                    return server_info
                    
            except socket.timeout:
                if attempt == self.retries - 1:
                    return {'ip': ip, 'hostname': hostname, 'status': 'timeout'}
            except socket.error as e:
                if attempt == self.retries - 1:
                    return {'ip': ip, 'hostname': hostname, 'status': 'socket_error', 'error': str(e)}
            except ssl.SSLError as e:
                if attempt == self.retries - 1:
                    return {'ip': ip, 'hostname': hostname, 'status': 'ssl_error', 'error': str(e)}
            except Exception as e:
                if attempt == self.retries - 1:
                    return {'ip': ip, 'hostname': hostname, 'status': 'error', 'error': str(e)}
            
            time.sleep(0.5)  # Wait before retry
        
        return {'ip': ip, 'hostname': hostname, 'status': 'failed'}
    
    def extract_cert_info(self, cert):
        """Extract useful information from certificate"""
        if not cert:
            return None
            
        info = {
            'subject': {},
            'issuer': {},
            'san': [],
            'not_before': None,
            'not_after': None,
            'serial_number': None,
            'version': None
        }
        
        try:
            # Subject
            for item in cert.get('subject', []):
                for key, value in item:
                    info['subject'][key] = value
            
            # Issuer
            for item in cert.get('issuer', []):
                for key, value in item:
                    info['issuer'][key] = value
            
            # Subject Alternative Names
            san = cert.get('subjectAltName', [])
            info['san'] = [value for key, value in san if key == 'DNS']
            
            # Validity
            info['not_before'] = cert.get('notBefore')
            info['not_after'] = cert.get('notAfter')
            
            # Other fields
            info['serial_number'] = cert.get('serialNumber')
            info['version'] = cert.get('version')
            
        except Exception:
            pass
        
        return info
    
    def scan_targets(self, targets, hostname, port=443):
        """Scan multiple targets"""
        total = len(targets)
        completed = 0
        
        self.print_status(f"Starting scan of {total} targets for hostname: {hostname}", 'info')
        self.print_status(f"Port: {port} | Timeout: {self.timeout}s | Threads: {self.max_threads}", 'info')
        
        with ThreadPoolExecutor(max_workers=self.max_threads) as executor:
            # Submit all tasks
            future_to_ip = {
                executor.submit(self.check_sni_host, ip, hostname, port): ip 
                for ip in targets
            }
            
            # Process as they complete
            for future in as_completed(future_to_ip):
                ip = future_to_ip[future]
                
                try:
                    result = future.result()
                    
                    with self.lock:
                        self.results.append(result)
                        completed += 1
                        
                        # Update stats
                        if result['status'] == 'success':
                            self.stats['found'] += 1
                            self.print_status(
                                f"Found {result['ip']}:{result['port']} - "
                                f"CN: {result.get('certificate', {}).get('subject', {}).get('commonName', 'N/A')}",
                                'found'
                            )
                        elif result['status'] == 'timeout':
                            self.stats['timeout'] += 1
                        else:
                            self.stats['failed'] += 1
                        
                        self.stats['scanned'] = completed
                        
                        # Progress update every 10 targets
                        if completed % 10 == 0:
                            elapsed = time.time() - self.start_time
                            progress = (completed / total) * 100
                            self.print_status(
                                f"Progress: {completed}/{total} ({progress:.1f}%) | "
                                f"Found: {self.stats['found']} | "
                                f"Time: {elapsed:.1f}s",
                                'info'
                            )
                            
                except Exception as e:
                    self.print_status(f"Error scanning {ip}: {e}", 'error')
        
        # Final stats
        self.print_stats()
    
    def scan_ip_range(self, ip_range, hostname, port=443):
        """Scan an IP range in CIDR notation"""
        try:
            network = ipaddress.ip_network(ip_range, strict=False)
            targets = [str(ip) for ip in network.hosts()]
            self.scan_targets(targets, hostname, port)
        except Exception as e:
            self.print_status(f"Invalid IP range: {e}", 'error')
    
    def scan_from_file(self, filename, hostname, port=443):
        """Scan IPs from a file"""
        try:
            with open(filename, 'r') as f:
                targets = [line.strip() for line in f if line.strip()]
            self.scan_targets(targets, hostname, port)
        except FileNotFoundError:
            self.print_status(f"File not found: {filename}", 'error')
        except Exception as e:
            self.print_status(f"Error reading file: {e}", 'error')
    
    def scan_single(self, ip, hostname, port=443):
        """Scan a single IP"""
        result = self.check_sni_host(ip, hostname, port)
        self.results.append(result)
        
        if result['status'] == 'success':
            self.print_status(f"Success! {ip} serves {hostname}", 'success')
            cert_info = result.get('certificate', {})
            if cert_info:
                print(f"\n{Fore.CYAN}Certificate Information:{Fore.RESET}")
                print(f"  Subject CN: {cert_info.get('subject', {}).get('commonName', 'N/A')}")
                print(f"  Issuer CN: {cert_info.get('issuer', {}).get('commonName', 'N/A')}")
                print(f"  Valid until: {cert_info.get('not_after', 'N/A')}")
                if cert_info.get('san'):
                    print(f"  SAN: {', '.join(cert_info['san'][:3])}")
        else:
            self.print_status(f"Failed: {result['status']}", 'error')
    
    def print_stats(self):
        """Print scanning statistics"""
        elapsed = time.time() - self.start_time
        success_rate = (self.stats['found'] / self.stats['scanned'] * 100) if self.stats['scanned'] > 0 else 0
        
        print(f"\n{Fore.CYAN}{'='*50}{Fore.RESET}")
        print(f"{Fore.GREEN}SCAN STATISTICS:{Fore.RESET}")
        print(f"{Fore.CYAN}{'='*50}{Fore.RESET}")
        print(f"  Total scanned: {self.stats['scanned']}")
        print(f"  Found: {Fore.GREEN}{self.stats['found']}{Fore.RESET}")
        print(f"  Failed: {Fore.RED}{self.stats['failed']}{Fore.RESET}")
        print(f"  Timeout: {Fore.YELLOW}{self.stats['timeout']}{Fore.RESET}")
        print(f"  Success rate: {success_rate:.1f}%")
        print(f"  Time elapsed: {elapsed:.1f} seconds")
        print(f"  Speed: {self.stats['scanned']/elapsed:.1f} targets/second")
        print(f"{Fore.CYAN}{'='*50}{Fore.RESET}")
    
    def save_results(self, filename=None):
        """Save results to file"""
        if not filename:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = self.output_dir / f"hackrate_scan_{timestamp}.json"
        
        try:
            output = {
                'tool': 'Hackrate Hunter',
                'version': self.version,
                'scan_time': datetime.now().isoformat(),
                'duration': time.time() - self.start_time,
                'stats': self.stats,
                'results': self.results
            }
            
            with open(filename, 'w') as f:
                json.dump(output, f, indent=2, default=str)
            
            self.print_status(f"Results saved to: {filename}", 'success')
            
            # Also create a readable summary
            summary_file = filename.with_suffix('.txt')
            self.save_summary(summary_file)
            
        except Exception as e:
            self.print_status(f"Error saving results: {e}", 'error')
    
    def save_summary(self, filename):
        """Save human-readable summary"""
        successful = [r for r in self.results if r['status'] == 'success']
        
        with open(filename, 'w') as f:
            f.write("="*60 + "\n")
            f.write("           HACKRATE HUNTER - SCAN SUMMARY\n")
            f.write("="*60 + "\n\n")
            
            f.write(f"Scan Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Duration: {time.time() - self.start_time:.1f} seconds\n")
            f.write(f"Total targets: {self.stats['scanned']}\n")
            f.write(f"Successful hits: {self.stats['found']}\n")
            f.write(f"Failed: {self.stats['failed']}\n")
            f.write(f"Timeout: {self.stats['timeout']}\n\n")
            
            if successful:
                f.write("SUCCESSFUL HITS:\n")
                f.write("-"*40 + "\n")
                for i, result in enumerate(successful, 1):
                    f.write(f"\n{i}. Target: {result['ip']}:{result['port']}\n")
                    f.write(f"   Hostname: {result['hostname']}\n")
                    
                    cert = result.get('certificate', {})
                    if cert:
                        f.write(f"   Certificate CN: {cert.get('subject', {}).get('commonName', 'N/A')}\n")
                        if cert.get('san'):
                            f.write(f"   SAN: {', '.join(cert['san'][:3])}\n")
                    
                    f.write(f"   Timestamp: {result['timestamp']}\n")
            
            f.write("\n" + "="*60 + "\n")
            f.write("End of Hackrate Hunter Report\n")
            f.write("="*60 + "\n")
        
        self.print_status(f"Summary saved to: {filename}", 'success')
    
    def signal_handler(self, sig, frame):
        """Handle Ctrl+C gracefully"""
        print(f"\n\n{Fore.YELLOW}[!] Scan interrupted by user{Fore.RESET}")
        self.print_stats()
        
        if self.results:
            save = input(f"\n{Fore.CYAN}[?] Save partial results? (y/n): {Fore.RESET}").lower()
            if save == 'y':
                self.save_results()
        
        sys.exit(0)

def load_wordlist(filename):
    """Load wordlist from file"""
    try:
        with open(filename, 'r') as f:
            return [line.strip() for line in f if line.strip()]
    except:
        return []

def main():
    # Print banner
    print(BANNER)
    
    parser = argparse.ArgumentParser(
        description='HACKRATE HUNTER - SNI Discovery Tool for Termux',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    # Target options
    target_group = parser.add_argument_group('Target Options')
    target_group.add_argument('--ip', help='Single IP address to scan')
    target_group.add_argument('--range', help='IP range (CIDR notation, e.g., 192.168.1.0/24)')
    target_group.add_argument('--file', help='File containing IP addresses')
    target_group.add_argument('--hostname', required=True, help='Target hostname to check')
    
    # Scan options
    scan_group = parser.add_argument_group('Scan Options')
    scan_group.add_argument('--port', type=int, default=443, help='Port to scan (default: 443)')
    scan_group.add_argument('--timeout', type=int, default=3, help='Connection timeout (default: 3)')
    scan_group.add_argument('--threads', type=int, default=50, help='Max threads (default: 50)')
    scan_group.add_argument('--retries', type=int, default=2, help='Retry count (default: 2)')
    
    # Output options
    output_group = parser.add_argument_group('Output Options')
    output_group.add_argument('--output', help='Output file (default: auto-generated)')
    output_group.add_argument('--quiet', action='store_true', help='Quiet mode - minimal output')
    
    # Wordlist options
    wordlist_group = parser.add_argument_group('Wordlist Options')
    wordlist_group.add_argument('--hostlist', help='File containing multiple hostnames to check')
    wordlist_group.add_argument('--portlist', help='File containing ports to scan')
    
    # Config options
    config_group = parser.add_argument_group('
