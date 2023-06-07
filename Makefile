.ONESHELL:
.SILENT:
.PHONY: all
.DEFAULT: all

SHELL := /bin/bash
TOOLS := landing-zone aws-cli golang
TOOLS := $(TOOLS) clean
TMP := /tmp/landing-zone

all: $(TOOLS)

landing-zone:
	if [[ ! -f /etc/landing-zone ]]; then
		echo "Installing landing-zone tools"
		$(call landing-zone)
	fi

aws-cli:
	INSTALL_MSG="Installing aws-cli"
	LATEST_VERSION=`curl -sL https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst | head -n 10 | grep '^2.'`
	CURRENT_VERSION=$$(aws --version version 2>/dev/null | awk '{print $$1}' | cut -d'/' -f2)
	if [[ "$$LATEST_VERSION" != "$$CURRENT_VERSION" ]]; then
		$(call create-tmp,$@)
		TMP=$(TMP)/$@
		echo "$$INSTALL_MSG" \
		&& cd $$TMP && curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o $$.zip && unzip -o $$.zip >/dev/null \
		&& sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update > /dev/null && rm -rf $$TMP && echo $$INSTALL_MSG - done
		complete -C '/usr/local/bin/aws_completer' aws
	fi

golang:
	$(eval GOROOT=/usr/local/go)
	$(eval GOPATH=$${HOME}/go)
	$(eval GPATH=$(GOROOT)/bin:$${PATH})
	LATEST_VERSION=`curl -sL https://golang.org/VERSION?m=text`
	CURRENT_VERSION=$$(go version 2>/dev/null | awk '{print $$3}')
	if [[ "$$LATEST_VERSION" != "$$CURRENT_VERSION" ]]; then
		INSTALL_MSG="Installing golang $$LATEST_VERSION"
		$(call create-tmp,$@)
		TMP=$(TMP)/$@
		echo "$$INSTALL_MSG" \
		&& sudo rm -rf /usr/local/go && cd $$TMP && curl -sL "https://go.dev/dl/$$LATEST_VERSION.linux-amd64.tar.gz" -o $$.tar.gz && sudo tar -C /usr/local -xzf $$.tar.gz >/dev/null \
		&& rm -rf $$TMP && echo $$INSTALL_MSG - done \
		&& $(call update-bashrc,export GOROOT,$(GOROOT)) \
		&& $(call update-bashrc,export GOPATH,$(GOPATH)) \
		&& $(call update-bashrc,export PATH,$(GPATH))
	fi

clean:
	echo "Cleaning up"
	sudo apt autoremove -y
	sudo apt clean -y
	sudo rm -rf /var/lib/apt/lists/*
	sudo rm -rf /tmp/*
	sudo rm -rf /var/tmp/*
	rm -rf $(TMP)
	echo "Reload the bash terminal or run \`source ~/.bashrc\` to update the environment variables"

define create-tmp
  mkdir -p $(TMP)/$(1)
endef

define update-bashrc
	echo "$(1)=$(2)"
	sed -i "/^$${1}=/{h;s/=.*/=$${2}/};${x;/^$/{s//$${1}=$${2}/;H};x}" ~/.bashrc
endef

define landing-zone
	echo "$$USER  ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$$USER >/dev/null \
	&& sudo chmod 0440 /etc/sudoers.d/$$USER \
	&& sudo apt update -y \
	&& sudo apt install -y \
		apt-utils \
		software-properties-common \
		apt-transport-https \
	&& sudo apt upgrade -y \
	&& sudo apt install -y --no-install-recommends gnupg curl vim \
	&& sudo touch /etc/landing-zone
endef