#!/bin/bash

# BASE INSTALLATION FROM THOUGHTBOT
curl --remote-name https://raw.githubusercontent.com/thoughtbot/laptop/main/mac
sh mac 2>&1 | tee ~/laptop.log
git clone https://github.com/thoughtbot/dotfiles ~/dotfiles
brew install rcm
env RCRC=$HOME/dotfiles/rcrc rcup

# OH MY ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# APPS
brew install --cask spectacle
brew install --cask keepingyouawake
brew install --cask vlc
brew install --cask spotify
brew install --cask visual-studio-code # USE Settings Sync to get your proper VSCode Settings!
brew install --cask discord
brew install --cask iterm2
brew install --cask inkscape
brew install --cask firefox
brew install --cask zoom
brew install --cask rocket
brew install --cask microsoft-edge
brew install --cask slack
brew install --cask intellij-idea

brew install ack
brew install jq
brew install ffmpeg
brew install wget2
brew install tailscale
brew install speedtest-cli
brew install grc
brew install gifsicle
brew install ncdu
brew install youtube-dl
brew install awscli

# Manage App Store installs
brew install mas
mas install 967805235	# Paste clipboard	https://apps.apple.com/us/app/paste-clipboard-manager/id967805235
mas install 982710545	# Forecast Bar		https://apps.apple.com/us/app/forecast-bar-weather-radar/id982710545?mt=12
mas install 408981434	# iMovie			https://apps.apple.com/us/app/imovie/id408981434?mt=12
mas install 682658836	# GarageBand		https://apps.apple.com/us/app/garageband/id682658836?mt=12
mas install 1339170533	# CleanMyMacX		https://apps.apple.com/us/app/cleanmymac-x/id1339170533?mt=12
mas install 497799835	# Xcode				https://apps.apple.com/us/app/xcode/id497799835?mt=12
mas install 957862217	# JackBox Games		https://apps.apple.com/us/app/the-jackbox-party-pack/id957862217?mt=12

# Manage grc dot file
cat > ~/.grc.conf <<EOF
regexp=SEVERE
colours=on_red
count=more

regexp=SUCCESS
colours=on_green
count=more
EOF

# Manage Makefile
cat > ~/makefile <<EOF

SHELL:=/usr/bin/env bash

.PHONY: all
all: help

.PHONY: ssh
ssh: ## ssh to jpc.io
	@ssh root@142.93.59.54

.PHONY: sync-amplify
sync-amplify: ## rsyncs from amplify-cli dir on mac to cloud desktop
	@sync-amplify


.PHONY: show-files
show-files: ## shows files hosted on jpc.io
	@ssh -t root@142.93.59.54 find /repo/johnpc.github.io/r/ -type f | xargs -I{} basename {} | xargs printf "https://jpc.io/r/%s\n"

.PHONY: show-files-s3
show-files-s3: ## shows files hosted on jpc.io
	@zsh list-s3-files
.PHONY: upload
upload: ## uploads a file to jpc.io
ifeq ($(path),)
	@echo [SEVERE] The path must be specified: make upload path=/path/to/file.txt | grcat ~/.grc.conf
else
	@scp $(path) root@142.93.59.54:~/r/
	@echo $(path) | rev | cut -d"/" -f1 | rev | xargs printf "[SUCCESS] File available at: https://jpc.io/r/%s\n" | grcat ~/.grc.conf
endif

.PHONY: upload-s3
upload-s3: ## uploads a file to jpc.io
ifeq ($(path),)
	@echo [SEVERE] The path must be specified: make upload-s3 path=/path/to/file.txt | grcat ~/.grc.conf
else
	@aws s3 cp $(path) s3://jpc-junk-drawer --profile jpc-golf --acl public-read
	@echo $(path) | rev | cut -d"/" -f1 | rev | xargs printf "[SUCCESS] File available at: https://jpc-junk-drawer.s3.amazonaws.com/%s\n" | grcat ~/.grc.conf
endif

.PHONY: link-shortener
link-shortener: ## uploads a file to jpc.io
ifeq ($(url),)
	@echo [SEVERE] The path must be specified: link-shortener url=https://example.com | grcat ~/.grc.conf
else
	@md5 -q -s $(url) | cut -c -6 | xargs touch | md5 -q -s $(url) | cut -c -6 | xargs printf 'aws s3 cp %s s3://www.jpc.io/r/  --profile personal --acl public-read --website-redirect $(url)' | zsh
	@echo $(path) | rev | cut -d"/" -f1 | rev | xargs printf "[SUCCESS] Redirect available at: https://jpc.io/r/%s\n" | grcat ~/.grc.conf
endif

.PHONY: upload-dir
upload-dir: ## uploads a directory to jpc.io
ifeq ($(path),)
	@echo [SEVERE] The path must be specified: make upload path=/path/to/file.txt | grcat ~/.grc.conf
else
	@rsync -av $(path) root@142.93.59.54:~/r/dir/ --ignore .git
	@echo $(path) | rev | cut -d"/" -f1 | rev | xargs printf "[SUCCESS] File available at: https://jpc.io/r/dir/%s\n" | grcat ~/.grc.conf
endif

.PHONY: hue
hue: ## starts hue control server at localhost:8001
	@cd ~/repos/hue-dashboard && vagrant up
	@echo [SUCCESS] Server is running at http://localhost:8001 | grcat ~/.grc.conf

.PHONY: ssh-remove
ssh-remove: ## removes a file from jpc.io
ifeq ($(filename),)
	@echo [SEVERE] The filename must be specified: make ssh-remove filename=filename.txt | grcat ~/.grc.conf
else
	@ssh root@142.93.59.54 "rm ~/r/$(filename)"
	@echo "[SUCCESS] File no longer available." | grcat ~/.grc.conf
endif

.PHONY: ssh-remove-s3
ssh-remove-s3: ## removes a file from jpc.io
ifeq ($(filename),)
	@echo [SEVERE] The filename must be specified: make ssh-remove-s3 filename=filename.txt | grcat ~/.grc.conf
else
	@aws s3 rm s3://www.jpc.io/r/$(filename) --profile personal
	@echo "[SUCCESS] File no longer available." | grcat ~/.grc.conf
endif

.PHONY: convert-to-gif
convert-to-gif: ## converts a .mov to a .gif
ifeq ($(path),)
	@echo [SEVERE] The path must be specified: make convert-to-gif path=/path/to/file.mov | grcat ~/.grc.conf
else
	@mov2gif $(path) $(path).gif
	@echo "[SUCCESS] File converted. Saved at $(path).gif" | grcat ~/.grc.conf
endif

.PHONY: clean-git
clean-git: ## removes merged git branches
	@git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d

.PHONY: download-stream
download-stream: ## downloads an m3u8 stream as an mp4
ifeq ($(url),)
	@echo [SEVERE] The path must be specified: make download-stream url=https://m3u8.file.m3u8 | grcat ~/.grc.conf
else
	@ffmpeg -i $(url) -c copy -bsf:a aac_adtstoasc ~/Desktop/m3u8.mp4
	@echo "[SUCCESS] File converted. Saved at ~/Desktop/m3u8.mp4" | grcat ~/.grc.conf
endif

.PHONY: censys
censys: ## sets up environment for censys
	@open https://github.com/censys/discover
	@code ~/repos/censys
	@open https://censysio.atlassian.net/secure/RapidBoard.jspa?rapidView=12

.PHONY: ip
ip: ## oututs public ip address
	@curl api.ipify.org | xargs printf "public ip: %s\n"
	@ipconfig getifaddr en0 | xargs printf "local ip: %s\n"

# via https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

EOF
```
