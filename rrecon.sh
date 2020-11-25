##########################################################################################################################################################################
DOMAIN=$1
COMPANY=$2
TOOL="$HOME/Tools"
GOLOC="$HOME/go"
BASE="$HOME/Hunting/$DOMAIN"
SUBDOMAINS="$BASE/Subdomains"
CRAWLDIR="$BASE/Crawled"
WAYBACKED="$BASE/Waybacked"
AMASSRES="$BASE/amass"
MISCRES="$BASE/Results"
TMP="/tmp"
GITHUBAPITOKEN=""
##########################################################################################################################################################################

init () {
	if [ -z $DOMAIN ]
	then
		echo -e "\nNo domain supplied.\nUsage: ./RRecon.sh <domain> <company name> | Ex: ./RRecon.sh capitalone.com 'Capital One'\n"
		exit 1
	fi
	if [ -z $COMPANY ]
	then
		echo -e "\nNo comapny name supplied.\nUsage: ./RRecon.sh <domain> <company name> | Ex: ./RRecon.sh capitalone.com 'Capital One'\n"
		exit 1
	fi

	if [ -d "$BASE" ]
	then
		echo -e "\nDirectory $BASE exists\n."
		exit 1
	else
		mkdir $BASE $SUBDOMAINS $CRAWLDIR $WAYBACKED $AMASSRES $MISCRES
	fi
}

lookupASN () {
#	Grabs ASN(s) for Company | ASNs.txt located in /home/*/Hunting/*/ASNs.txt
	COMPANY="'$COMPANY'"
	echo '"'"$HOME"'/go/bin/amass intel -org '"$COMPANY"' > '"$BASE"'/ASNs.txt''"' > "$TMP"/amassExec.txt
	python3 "$HOME"/Hunting/Tools/ReconBot.py amassASN
	rm "$TMP"/amassExec.txt
	echo "1 / ?"
}

cleanASN () {
#	Cleans ASN(s)
	cat "$BASE"/ASNs.txt | grep -E "^(.*?)\," -o | sort -u > "$BASE"/ASN-temp.txt
	rm "$BASE"/ASNs.txt
	cat "$BASE"/ASN-temp.txt | sed 's/,//g' > "$BASE"/ASNs.txt
	rm "$BASE"/ASN-temp.txt
	echo "2 / ?"
}

asnWhois () {
	input="$BASE""/ASNs.txt"
	while IFS= read -r line
	do
		VAR1+="whois -h whois.radb.net -- '-i origin "$line"' |grep -Eo '([0-9.])+{4}/[0-9]+' | sort -u;"
	done < "$input"
	echo $VAR1 > "$TMP"/whoisExec
	bash "$TMP"/whoisExec > "$BASE"/CIDRs.txt
	rm "$TMP"/whoisExec
	echo "3 / ?"
}

amassASNIntel () {
	input="$BASE"/ASNs.txt
	while IFS= read -r line
	do
		VAR2+="$HOME"'/go/bin/amass intel -asn '"$line"';'
	done < "$input"
	echo $VAR2 > "$TMP"/amassASNIntel
	bash "$TMP"/amassASNIntel > "$BASE"/amassASNIntel-tmp.txt
	rm "$TMP"/amassASNIntel
	cat "$BASE"/amassASNIntel-tmp.txt | sort -u > "$BASE"/amassASNIntel.txt
	rm "$BASE"/amassASNIntel-tmp.txt
	echo "4 / ?"
}

amassCIDRIntel () {
	input="$BASE"/CIDRs.txt
	while IFS= read -r line
	do
		VAR3+="$HOME"'/go/bin/amass intel -cidr '"$line"';'
	done < "$input"
	echo $VAR3 > "$TMP"/amassCIDRIntel
	bash "$TMP"/amassCIDRIntel > "$BASE"/amassCIDRIntel-tmp.txt
	rm "$TMP"/amassCIDRIntel
	cat "$BASE"/amassCIDRIntel-tmp.txt | sort -u > "$BASE"/amassCIDRIntel.txt
	rm "$BASE"/amassCIDRIntel-tmp.txt
	echo "5 / ?"
}

amassWhoisIntel () {
	VAR4="$HOME"'/go/bin/amass intel -whois -d '"$DOMAIN"';'
	echo $VAR4 > "$TMP"/amassWhoisIntel
	bash "$TMP"/amassWhoisIntel > "$BASE"/amassWhoisIntel.txt
	rm "$TMP"/amassWhoisIntel
	echo "6 / ?"
}

rapid7ForwardDNS () {
	tmpDomain="$DOMAIN"
	echo '.'"$tmpDomain" | sed 's/\./\\\./g' > "$TMP"/domain-tmp.txt
	INPUT="$TMP"/domain-tmp.txt
	while IFS= read -r line
	do
		VAR5="zgrep '""$line"'",'"'"' /mnt/forwarddns/2020-07-24-1595549209-fdns_any.json.gz'
	done < "$INPUT"
	rm "$TMP"/domain-tmp.txt
	echo $VAR5 > "$TMP"/rapid7
	bash "$TMP"/rapid7 > "$BASE"/rapid7Scan.txt
	cat "$BASE"/rapid7Scan.txt | jq -r '.name' | sort -u > "$BASE"/rapid7names.txt
	cat "$BASE"/rapid7Scan.txt | jq -r '.value' | sort -u > "$BASE"/rapid7Values.txt
	rm "$BASE"/rapid7Scan.txt
	echo "7 / ?"
}

githubScan () {
	python3 "$TOOL"/github-search/github-subdomains.py -d "$DOMAIN" -t "$GITHUBAPITOKEN" > "$BASE"/githubScan1.txt
	python3 "$TOOL"/github-search/github-subdomains.py -d "$DOMAIN" -t "$GITHUBAPITOKEN" > "$BASE"/githubScan2.txt
	python3 "$TOOL"/github-search/github-subdomains.py -d "$DOMAIN" -t "$GITHUBAPITOKEN" > "$BASE"/githubScan3.txt
	cat "$BASE"/githubScan*.txt > "$BASE"/githubScan.txt
	rm "$BASE"/githubScan3.txt "$BASE"/githubScan2.txt "$BASE"/githubScan1.txt 
	echo "8 / ?"
}

ffufDirScan () {
	"$HOME"/go/bin/ffuf -w "/home/roman/Tools/Wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt" -u http://"$DOMAIN"/FUZZ -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:79.0) Gecko/20100101 Firefox/79.0" -r  -o "$BASE"/ffufDirScan-temp.txt
	cat "$BASE"/ffufDirScan-temp.txt | jq > "$BASE"/ffufDirScan.txt	
	echo "9 / ?"
}

amassPassiveEnum () {
	VAR6="$HOME"'/go/bin/amass enum -passive -d '"$DOMAIN"';'
	echo $VAR6 > "$TMP"/amassPassiveEnum
	bash "$TMP"/amassPassiveEnum > "$BASE"/amassPassiveEnum.txt
	rm "$TMP"/amassPassiveEnum
	echo "10 / ?"
}

massDNS () {
	# Resolvers.txt = 8.8.8.8 4.4.4.4 1.1.1.1 8.8.4.4   -- New line for each entry
	"$TOOL"/massdns/bin/massdns -r "$TOOL"/Wordlists/resolvers.txt -t A -o Sr "$BASE"/githubScan.txt | sort -u > "$BASE"/massdns.tmp
	cat "$BASE"/massdns.tmp | grep -v "SERVFAIL" | grep -v "NXDOMAIN" | grep -E "([a-z0-9][a-z0-9\-]{0,61}[a-z0-9]\.)+[a-z0-9][a-z0-9\-]*[a-z0-9]" -o  | sort -u > "$BASE"/githubScanmassdns.txt
	rm "$BASE"/massdns.tmp
	"$TOOL"/massdns/bin/massdns -r "$TOOL"/Wordlists/resolvers.txt -t A -o Sr "$BASE"/amassPassiveEnum.txt | sort -u > "$BASE"/amassPassiveEnum.tmp
	rm "$BASE"/amassPassiveEnum.txt
	cat "$BASE"/amassPassiveEnum.tmp | grep -v "SERVFAIL" | grep -v "NXDOMAIN" | grep -E "([a-z0-9][a-z0-9\-]{0,61}[a-z0-9]\.)+[a-z0-9][a-z0-9\-]*[a-z0-9]" -o  | sort -u > "$BASE"/amassPassiveEnum.txt
	rm "$BASE"/amassPassiveEnum.tmp
	"$TOOL"/massdns/bin/massdns -r "$TOOL"/Wordlists/resolvers.txt -t A -o Sr "$BASE"/rapid7names.txt | sort -u > "$BASE"/rapid7names.tmp
	"$TOOL"/massdns/bin/massdns -r "$TOOL"/Wordlists/resolvers.txt -t A -o Sr "$BASE"/rapid7Values.txt | sort -u > "$BASE"/rapid7Values.tmp
	rm "$BASE"/rapid7names.txt 
	mv "$BASE"/rapid7names.tmp "$BASE"/rapid7names.txt
	mv "$BASE"/rapid7Values.tmp "$BASE"/rapid7Values-masscanned.txt
	echo "11 / ?"
}

waybacked () {
	python3 "$TOOL"/waybackMachine/waybackMachine.py "$DOMAIN" > "$BASE"/waybacked.txt
	echo "12 / ?"
}

jsSearch () {
	cd "$BASE"
	python3 "$TOOL"/jsearch/jsearch.py -u https://"$DOMAIN" -n "$COMPANY"
	mv "$BASE"/"$DOMAIN" "$BASE"/jsearch
	cd "$BASE"/jsearch
	cat *.js > AIO.js
	echo "13 / ?"
}

linkFinder () {
	python3 "$TOOL"/LinkFinder/linkfinder.py -i "$BASE"/jsearch/AIO.js -o cli > "$BASE"/linkFinder.txt
	rm -r "$BASE"/jsearch/AIO.js
	echo "14 / ?"
}

finishedAlert () {
	python3 "$HOME"/Hunting/Tools/ReconBot.py scancomplete
}

#########-Execution Order-######### 
init
lookupASN
cleanASN
asnWhois
amassASNIntel
amassCIDRIntel
amassWhoisIntel
rapid7ForwardDNS
githubScan
ffufDirScan
amassPassiveEnum
scanComplete
massDNS
waybacked
jsSearch
linkFinder
finishedAlert
################################### 
