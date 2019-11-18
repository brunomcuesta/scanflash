#!/bin/bash
# Title: scanflash
# Author: Bruno M. Cuesta
# Version: 1.0
# Date: 25/10/2019
# Purpose: Enumeration of paths and subdomains using GNU Parallel

# Constants Colors
RED='\033[31;1m'
GREEN='\033[32;1m'
BLUE='\033[34;1m'
YELLOW='\033[33;1m'
CYAN='\033[36;1m'
MAGENTA='\033[35;1m'
END='\033[m'

# Constant Version
VERSION='1.0'

#===============================
# Banner function
#===============================

banner () {
    echo
    echo -e "${YELLOW}##########################################${END}"
	echo
    echo -e "${YELLOW}                Scanflash				    ${END}"
    echo -e "${YELLOW}          Parallel Enumeration			${END}"
    echo -e "${YELLOW}               Version $VERSION           ${END}"
	echo
    echo -e "${YELLOW}##########################################${END}"
    echo
}

#===============================
# Usage function
#===============================

usage () {
printf "
${BLUE}Options${END}:
-t, --target, Host
-p, --paths, Scan for paths
-s, --sub, Scan for subdomains
-r, --robots, Scan for paths in robots.txt
-f, --file, Custom wordlist from argument
-h, --help, Show usage and exit
-v, --version, Show version and exit

${MAGENTA}Full scanning example${END}:
$0 -t example.com -psr
\n"
}

#====================================
# Checking if parallel is installed
#====================================

check_parallel () {
	parallel_path=/usr/bin/parallel
	if [ ! -e "$parallel_path"  ]; then
		printf "${RED}The 'parallel' package is not installed for run this script${END}.\n"
		printf "[${MAGENTA}Installation$END]: $ sudo apt-get install parallel\n"
		exit -1
	fi
}

#===============================
# Validating host argument
#===============================

validate_host () {
	printf "\n${BLUE}Running url validation...${END}\n"
    schemes=("http://" "www." "https://")
    for s in $schemes; do
        url="$s$DOMAIN"
        response=$(curl $url -sLI --connect-timeout 5 -w "%{http_code}-%{url_effective}" -o /dev/null)
        if [[ $response =~ "200"* ]]; then
            domain=$(awk -F '-' '{print $2}' <<<$response)
			printf "[${GREEN}Valid URL${END}] ${GREEN}>>>${END} $domain"
            break
        else
			printf "[${RED}Invalid Host${END}] ${RED}>>>${END} $DOMAIN \n"
			exit -1
		fi
    done
}

#===============================
# Scanning paths function
#===============================

scan_paths () {
	printf "\n${BLUE}Scanning paths...${END}\n"
    paths=$(parallel -j 10 curl -sLI --connect-timeout 5 -w "%{http_code}-%{url_effective}'\n'" -o /dev/null $domain{} < $wordlist)
    for p in $paths; do
        if [[ $p =~ "200"* ]]; then
            printf "[${GREEN}Found${END}] ${GREEN}>>>${END} "
            printf $p | awk -F '-' '{print $2}'	
		fi
    done
	printf "${MAGENTA}Scanning paths completed!${END}"
}

#===============================
# Scanning subdomains function
#===============================

scan_subdomains () {
	printf "\n${BLUE}Scanning subdomains...${END}\n"
    TEXT=$(cat $wordlist | cut -f1 -d "/" | cut -f1 -d "." | tr '[:upper:]' '[:lower:]' | sort -u)
    target=$(sed "s/.*:\/\///" <<<$domain )
    scheme=$(awk -F// '{print $1}' <<<$domain)
    subs=$(parallel -j 10 curl -sLI --connect-timeout 5 -w "%{http_code}-%{url_effective}'\n'" -o /dev/null "$scheme//"{}".$target" <<<$TEXT )
    for s in $subs; do
        if [[ $s =~ "200"* ]]; then
            printf "[${GREEN}Found${END}] ${GREEN}>>>${END} "
            printf $s | awk -F '-' '{print $2}'
		fi
    done
	printf "${MAGENTA}Scanning subdomains completed!${END}"
}

#===============================
# Scanning robots.txt function
#===============================

scan_robots () {
	printf "\n${BLUE}Scanning robots.txt..${END}\n"
    txt='robots.txt'
    paths_robots=$(curl -sL "$domain$txt" -w "%{content_type}" 2>/dev/null | cut -d ":" -f2 | sed -e "s/^[ \t]*//" | grep "^/")
    for p in $paths_robots; do
        line_robots=$(curl ${domain::-1}$p -sLI --connect-timeout 5 -w "%{http_code}-%{url_effective} '\n'" -o /dev/null)
        if [[ $line_robots =~ "200"* ]]; then
            printf "[${GREEN}Found${END}] ${GREEN}>>>${END} "
            printf $line_robots | awk -F '-' '{print $2}'
		fi
    done
	printf "${MAGENTA}Scanning robots.txt completed!${END}"
}

#=====================
# Get arguments
#=====================

while getopts "t:psrf:hv" option; do
case "${option}" in
	"t"|"--target") DOMAIN=${OPTARG} ;;
	"p"|"--paths") PATHS=true ;;
	"s"|"--sub") SUBDOMAINS=true ;;
	"r"|"--robots") ROBOTS=true ;;
	"f"|"--file") WORDLIST=${OPTARG} ;;
	"h"|"--help") usage ;;
	"v"|"--version") printf "\n${MAGENTA}Version${END}: $VERSION\n" exit 0 ;;
	"?") exit 1 ;;
esac
done
shift $((OPTIND -1))

#========================
# Main Function
#========================

Main () {
	check_parallel
	if [ $DOMAIN ]; then
		initial=$(date +%s)
	 	banner
		validate_host
		if [ -e "$WORDLIST" ]; then
			printf "\n${YELLOW}>>> Using custom wordlist${END}: $(basename $WORDLIST)"
			wordlist="$WORDLIST"
		else
			printf "\n${YELLOW}>>>Using default wordlist.txt.${END}\n"
			wordlist='wordlist.txt'
		fi
		if [ $PATHS ]; then
			scan_paths
		fi
		if [ $SUBDOMAINS ]; then
			scan_subdomains
		fi
		if [ $ROBOTS ]; then
			scan_robots
		fi
		finish=$(date +%s)
		printf "\n${BLUE}Finished in %.F second(s)${END} \n" $(echo "$finish - $initial"|bc)  
	else
		usage >&2
		exit 1
	fi
}

#========================
# Execute Main Function
#========================
Main

exit 0
