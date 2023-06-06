.ONESHELL:
.SILENT:
.PHONY: all
.DEFAULT: all

SHELL := /bin/bash
TOOLS := landing-zone aws-cli
TOOLS := $(TOOLS) clean
TMP := /tmp/landing-zone

all: $(TOOLS)

landing-zone:
	$(info Installing landing-zone tools)
	sudo apt update -y
	sudo apt install -y \
		apt-utils \
		software-properties-common \
		apt-transport-https
	sudo apt upgrade -y
	sudo apt install -y --no-install-recommends gnupg curl vim

aws-cli:
	INSTALL_MSG="Installing aws-cli"
	$(call create-tmp,$@)
	TMP=$(TMP)/$@
	aws --version 2>/dev/null || echo "$$INSTALL_MSG" \
	&& cd $$TMP && curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o $$.zip && unzip -o $$.zip >/dev/null \
	&& sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update > /dev/null && rm -rf $$TMP && echo $$INSTALL_MSG - done
	complete -C '/usr/local/bin/aws_completer' aws

clean:
	$(info Cleaning up)
	sudo apt autoremove -y
	sudo apt clean -y
	sudo rm -rf /var/lib/apt/lists/*
	sudo rm -rf /tmp/*
	sudo rm -rf /var/tmp/*
	rm -rf $(TMP)

define create-tmp
    mkdir -p $(TMP)/$(1)
endef