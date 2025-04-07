.PHONY: setup
setup: 
	@echo "Installing ASDF-VM"
	@if [ "$(shell uname)" = "Linux" ]; then \
		echo "Running on Linux"; \
		sudo apt-get update; \
		sudo apt-get install -y build-essential curl git pass zlib1g-dev libbz2-dev libncurses-dev libffi-dev libreadline-dev libsqlite3-dev tk-dev liblzma-dev zlib1g-dev libssl-dev libgdbm-dev libnss3-dev libgdbm-compat-dev uuid-dev libcurl4-openssl-dev; \
	elif [ "$(shell uname)" = "Darwin" ]; then \
		echo "Running on macOS"; \
		brew install coreutils curl git pass; \
	else \
		echo "Unknown OS"; \
		exit 1; \
	fi

	@git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0;
	
	@if echo "$$SHELL" | grep -q "/fish"; then \
		echo "Running with Fish"; \
		echo 'source ~/.asdf/asdf.fish' >> ~/.config/fish/config.fish; \
		mkdir -p ~/.config/fish/completions; \
		ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions; \
	elif echo "$$SHELL" | grep -q "/bash"; then \
		echo "Running with Bash"; \
		echo '. "~/.asdf/asdf.sh"' >> ~/.bashrc; \
		echo '. "~/.asdf/completions/asdf.bash"' >> ~/.bashrc; \
	elif echo "$$SHELL" | grep -q "/zsh"; then \
		echo "Running with Zsh"; \
		echo '. "~/.asdf/asdf.sh"' >> ~/.zshrc; \
	else \
		echo "Unsupported shell: $$SHELL"; \
		exit 1; \
	fi
	
	@echo "Generating required files"
	@sh generate-env-files.sh

.PHONY: requirements
requirements:
	@echo "Installing Pre-Requirements"
	@if [ "$(shell uname)" = "Linux" ]; then \
		echo "Running on Linux"; \
		sudo apt-get update; \
		sudo apt-get install -y build-essential curl git pass zlib1g-dev libbz2-dev libncurses-dev libffi-dev libreadline-dev libsqlite3-dev tk-dev liblzma-dev zlib1g-dev libssl-dev libgdbm-dev libnss3-dev libgdbm-compat-dev uuid-dev libcurl4-openssl-dev; \
	elif [ "$(shell uname)" = "Darwin" ]; then \
		echo "Running on macOS"; \
		brew install coreutils curl git pass; \
	else \
		echo "Unknown OS"; \
		exit 1; \
	fi
