# Hackrate Hunter - SNI Host Discovery Tool 🔍

[![Termux](https://img.shields.io/badge/Termux-Required-green)](https://termux.com)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue)](https://python.org)
[![License](https://img.shields.io/badge/License-Educational-red)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.0-purple)]()

<p align="center">
  <img src="docs/banner.png" alt="Hackrate Hunter Banner" width="600">
</p>

## ⚡ Overview

**Hackrate Hunter** is a powerful SNI (Server Name Indication) host discovery tool designed specifically for **Termux** on Android. It helps ethical hackers and security researchers identify which hostnames are served on specific IP addresses through TLS/SSL certificate analysis.

### 🎯 Features

- **Termux Optimized** - Works perfectly on Android devices
- **Multi-threaded Scanning** - Fast concurrent connections
- **SNI Support** - Checks Server Name Indication in TLS handshakes
- **Certificate Analysis** - Extracts and displays certificate information
- **Multiple Input Methods** - Single IP, CIDR ranges, file lists
- **Smart Retry System** - Automatic retries on failures
- **Results Export** - JSON and human-readable formats
- **Wordlist Support** - Scan multiple hostnames/ports
- **Battery Saver** - Optimized for mobile devices
- **Real-time Stats** - Live progress and statistics

## 📱 Installation on Termux

### Quick Install (Recommended)

```bash
# Update Termux
pkg update && pkg upgrade

# Install git
pkg install git

# Clone repository

git clone https://github.com/CyberXGuest/Hackrate.inc-sni-host-finder.git

# Run installer
cd Hackrate.inc-sni-host-finder
chmod +x install.sh
./install.sh
You can use it to find sni host 
