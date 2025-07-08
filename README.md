# Captive Portal Evil 🔒💀

> ⚠️ Educational Purpose Only — This tool is intended for **authorized security testing**, **CTFs**, and **learning**. Do **not** use it on networks without permission.

## 🧠 About

**Captive Portal Evil** is a deceptive Wi-Fi login page tool used in red teaming and social engineering assessments. It mimics a legitimate login portal to capture user credentials or inject payloads in an isolated test environment.

## 🔧 Features

- Fake login page mimicking real-world portals (coffee shops, hotels, etc.)
- Credential harvesting with logging
- DNS spoofing to redirect all traffic to the captive portal
- Simple setup using Bash Scripting 
- Customizable HTML/CSS portal templates

## 📦 Requirements

- Linux (Kali, Parrot, Ubuntu, etc.)
- `apache2`, `hostapd`, `hostapd-mana`, `a2enmod`, `nft`, `dnsmasq`, `iwlist`
- Need root permission
- A wireless adapter that supports AP mode (Need Both 2.4GHz and 5 GHz)

## 🚀 Installation

```bash
git clone https://github.com/WinMinOo385/Captive_Portal.git
cd Captive_Portal
chmod +x evil-twin.sh
sudo ./evil-twin.sh
```
