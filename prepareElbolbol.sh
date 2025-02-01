#!/bin/bash

# Install figlet
sudo pacman -S --noconfirm figlet &&

# Install waybackurls
go install github.com/tomnomnom/waybackurls@latest &&

# Install cariddi
go install github.com/edoardottt/cariddi/cmd/cariddi@latest &&

# Install hakrawler
go install github.com/hakluke/hakrawler@latest &&

# Install katana
go install github.com/projectdiscovery/katana/cmd/katana@latest &&

# Install paramspider
git clone https://github.com/devanshbatham/ParamSpider.git && cd ParamSpider && pip3 install -r requirements.txt --break-system-packages && cd .. && rm -rf ParamSpider &&

# Install paramx
go install github.com/m3n0sd0n4ld/paramx@latest &&

# Install jsleak
go install github.com/channyein1337/jsleak@latest &&

# Install mantra
go install github.com/0xspade/mantra@latest
