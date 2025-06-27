#!/bin/bash

# user inputs
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <project_name> <target_ip>"
  exit 1
fi

# vars
PROJECT_NAME="$1"
TARGET="$2"
BASE_DIR="./$PROJECT_NAME"
WORDLIST="/home/drew/tools/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt"


# creating folders
echo "[+] Creating folder structure under: $BASE_DIR"
mkdir -p "$BASE_DIR/port_scans"
mkdir -p "$BASE_DIR/web_fuzzing"
mkdir -p "$BASE_DIR/fingerprinting"


# running tools
echo "[+] Running nmap..."
nmap -Pn "$TARGET" > "$BASE_DIR/port_scans/nmap.txt" &
# nmap -Pn -sV -oN "$BASE_DIR/port_scans/nmap.txt" "$TARGET" &

echo "[+] Running gobuster..."
gobuster dir -u "http://$TARGET" -w "$WORDLIST" -t 50 --no-error -o "$BASE_DIR/web_fuzzing/gobuster.txt" &

echo "[+] Running ffuf..."
ffuf -u "http://$TARGET/FUZZ" -w "$WORDLIST" -t 50 -fc 404 > "$BASE_DIR/web_fuzzing/ffuf.txt" &

echo "[+] Running whatweb..."
whatweb "$TARGET" > "$BASE_DIR/fingerprinting/whatweb.txt" &

echo "[+] Running nikto..."
nikto -h "$TARGET" -output "$BASE_DIR/fingerprinting/nikto.txt" &

# wait for everything to finish running
wait
echo "[+] All recon tools finished. Output saved in: $BASE_DIR"



# restructure plan
# -----------------------
# nmap scans - normal scan, deep scan, scan all ports, scan UDP ports
# fuzzing - gobuster, ffuf
# fingerprinting - whatweb
# find all subdomains - active domains, screenshots

# research more recon/enumeration tools