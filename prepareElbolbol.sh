#!/bin/bash

# Install figlet
notify-send -u normal -t 5000 "BolBol Is comming" "installing figlet"
sudo pacman -S --noconfirm figlet &&
# Install waybackurls
notify-send -u normal -t 5000 "installing waybackurls"
yay -S waybackurls
# Install cariddi
notify-send -u normal -t 5000 "installing cariddi"
yay -S cariddi
# Install hakrawler
# notify-send -u normal -t 5000 "installing hakrawler"
# yay -S hakrawler
# Install goSpider
notify-send -u normal -t 5000 "installing goSpider"
go install github.com/jaeles-project/gospider@latest
# Install katana
notify-send -u normal -t 5000 "installing katana"
go install github.com/projectdiscovery/katana/cmd/katana@latest
#Install paramspider
notify-send -u normal -t 5000 "installing paramspider"
git clone https://github.com/devanshbatham/ParamSpider.git && cd ParamSpider && pip install . --break-system-packages && cd ..
# Install paramx
notify-send -u normal -t 5000 "installing paramx"
go install github.com/m3n0sd0n4ld/paramx@latest
# Install kxss 
notify-send -u normal -t 5000 "installing kxss"
go install github.com/Emoe/kxss@latest
# Install jsleak
notify-send -u normal -t 5000 "installing jsleak "
go install github.com/channyein1337/jsleak@latest
# Install mantra
notify-send -u normal -t 5000 "installing mantra"
yay -S mantra
# Install waymore 
notify-send -u normal -t 5000 "installing waymore "
pip install waymore --break-system-packages
# Install arjun
notify-send -u normal -t 5000 "installing arjun "
pip install arjun --break-system-packages

