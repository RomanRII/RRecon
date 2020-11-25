#############################################################
TOOL="$HOME/Tools"
BASE="$HOME/Hunting"
#############################################################

makeDirs () {
    mkdir $TOOL $GOLOC $BASE
}

gitClones () {
    cd $TOOL
    git clone https://github.com/ghostlulzhacks/crawler.git
    git clone https://github.com/FortyNorthSecurity/EyeWitness.git
    git clone https://github.com/Edu4rdSHL/findomain.git
    git clone https://github.com/gwen001/github-search.git
    git clone https://github.com/robertdavidgraham/masscan.git
    git clone https://github.com/blechschmidt/massdns.git
    git clone https://github.com/smicallef/spiderfoot.git
    git clone https://github.com/sqlmapproject/sqlmap.git
    git clone https://github.com/aboul3la/Sublist3r.git
    git clone https://github.com/ghostlulzhacks/waybackMachine.git
}

makeDirs
gitClones

echo -e "\nInstall the following go tools: amass ffuf meg subjack waybackurls"
echo -e "Links to repos in README."
echo -e "Github tools have been cloned in""$TOOL"". Make sure to install/configure them before using RRecon."
echo -e "Ensure they are located in ""$HOME""/go/bin/*\n"
