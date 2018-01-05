CURRENT_DIR                  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MKFILES                       := $(shell find $(CURRENT_DIR) -maxdepth 1 -mindepth 1 -type f -name "*.mk" | sort)
-include $(MKFILES)

.PHONY: link_files
link_files:
	@test -d "${HOME}/.config/nvim" \
		|| mkdir -p ${HOME}/.config/nvim
	@test -f "${HOME}/.githubconfig" \
		|| echo "[github]\n\tuser =\n\ttoken =" > ${HOME}/.githubconfig

	@find $(CURRENT_DIR) -name "zshrc" -exec ln -sf {} ${HOME}/.zshrc \;
	@find $(CURRENT_DIR) -name "gitconfig" -exec ln -sf {} ${HOME}/.gitconfig \;
	@find $(CURRENT_DIR) -name "gitignore" -exec ln -sf {} ${HOME}/.gitignore \;
	@find $(CURRENT_DIR) -name "vimrc" -exec ln -sf {} ${HOME}/.config/nvim/init.vim \;
	@test -d "${HOME}/.jupyter" && rm -rf ${HOME}/.jupyter
	@find $(CURRENT_DIR) -name "jupyter" -exec ln -sf {} ${HOME}/.jupyter \;
	@test -d "${HOME}/.todo" && rm -rf ${HOME}/.todo
	@find $(CURRENT_DIR) -name "todo" -exec ln -sf {} ${HOME}/.todo \;
ifdef ZSH_CUSTOM
	@find $(CURRENT_DIR) -name 'dotfiles_config.zsh' -exec ln -sf {} $(ZSH_CUSTOM) \;
endif
