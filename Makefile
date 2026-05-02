KREW=./krew-"`uname | tr '[:upper:]' '[:lower:]'`_amd64"

.PHONY: init
init: ## Auto-detect environment and initialize dotfiles via chezmoi
	@echo "Detected OS: $$(uname -s)"
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		echo "Setting up macOS environment..."; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "Installing Homebrew..."; \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; \
		fi; \
		echo "Looking for chezmoi..."; \
		if ! command -v chezmoi >/dev/null 2>&1; then \
			echo "Installing chezmoi..."; \
			brew install chezmoi; \
		fi; \
		chezmoi init --apply --source "$(PWD)"; \
	elif [ "$$(uname -s)" = "Linux" ]; then \
		echo "Setting up Linux environment..."; \
		if ! command -v chezmoi >/dev/null 2>&1 && [ ! -f "$(HOME)/bin/chezmoi" ]; then \
			echo "Installing chezmoi..."; \
			curl -fsLS https://get.chezmoi.io | sh; \
		fi; \
		if [ -f "$(HOME)/bin/chezmoi" ]; then \
			"$(HOME)/bin/chezmoi" init --apply --source "$(PWD)"; \
		elif command -v chezmoi >/dev/null 2>&1; then \
			chezmoi init --apply --source "$(PWD)"; \
		else \
			echo "Error: chezmoi not found after install"; exit 1; \
		fi; \
	else \
		echo "Unsupported OS: $$(uname -s)"; exit 1; \
	fi

.PHONY: update
update: ## Sync current directory changes to dotfiles via chezmoi
	chezmoi apply --source "$(PWD)"

.PHONY: clean
clean: ## Remove files managed by chezmoi and clean up third-party directories
	@echo "Looking for chezmoi binary..."
	@if command -v chezmoi >/dev/null 2>&1; then \
		CHEZMOI_BIN=$$(command -v chezmoi); \
	elif [ -f "$(HOME)/bin/chezmoi" ]; then \
		CHEZMOI_BIN="$(HOME)/bin/chezmoi"; \
	else \
		echo "chezmoi not installed, nothing to clean."; exit 0; \
	fi; \
	echo "Removing chezmoi managed files in $(HOME)..."; \
	if $$CHEZMOI_BIN source-path >/dev/null 2>&1; then \
		$$CHEZMOI_BIN managed -i files | while read -r file; do \
			target="$(HOME)/$$file"; \
			if [ -f "$$target" ] || [ -L "$$target" ]; then \
				echo "Removing $$target"; \
				rm -f "$$target"; \
			fi; \
		done; \
		$$CHEZMOI_BIN managed -i scripts | while read -r script; do \
			target="$(HOME)/$$script"; \
			if [ -f "$$target" ] || [ -L "$$target" ]; then \
				echo "Removing $$target"; \
				rm -f "$$target"; \
			fi; \
		done; \
	else \
		echo "Chezmoi state not found or initialized."; \
	fi
	@echo "Cleaning up third-party tool directories..."
	rm -rf "$(HOME)/.zprezto" "$(HOME)/.tmux" "$(HOME)/.asdf"
	@echo "Cleanup completed."

.PHONY: krew
krew: ## 配置 Kubernetes kubectl 外掛管理器
	set -x; cd "$$(mktemp -d)" && \
	curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" && \
	tar zxvf krew.tar.gz && \
	"$$(KREW)" install --manifest=krew.yaml --archive=krew.tar.gz && \
	"$$(KREW)" update
	kubectl krew install access-matrix
	kubectl krew install cssh
	kubectl krew install pod-logs
	kubectl krew install pod-shell
	kubectl krew install rbac-lookup
	kubectl krew install rbac-view
	kubectl krew install trace
	kubectl krew install view-secret
	kubectl krew install view-utilization
	kubectl krew install warp

.PHONY: helm
helm: ## 配置 kubernetes helm
	asdf plugin add helm && asdf install helm latest
	helm plugin install https://github.com/technosophos/helm-template
	helm plugin install https://github.com/maorfr/helm-backup
	helm plugin install https://github.com/maorfr/helm-restore
	helm plugin install https://github.com/maorfr/helm-inject
	helm plugin install https://github.com/maorfr/helm-logs
	helm plugin install https://github.com/mstrzele/helm-edit
	helm plugin install https://github.com/adamreese/helm-env
	helm plugin install https://github.com/adamreese/helm-last
	helm plugin install https://github.com/ContainerSolutions/helm-monitor
	helm plugin install https://github.com/databus23/helm-diff
	helm plugin install https://github.com/futuresimple/helm-secrets

.PHONY: iterm
iterm: ## 配置 iTerm
	curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
	curl -L https://iterm2.com/utilities/imgcat -o /usr/local/bin/imgcat
	curl -L https://iterm2.com/utilities/imgls -o /usr/local/bin/imgls
	chmod a+x /usr/local/bin/*

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
