MOD_FOLDER_LOC := /home/brian/.steam/steam/steamapps/compatdata/289070/pfx/drive_c/users/steamuser/Documents/My\ Games/Sid\ Meier\'s\ Civilization\ VI/Mods

.PHONY: help ## print this
help:
	@echo ""
	@echo "$(PROJECT_NAME) Development CLI"
	@echo ""
	@echo "Usage:"
	@echo "  make <command>"
	@echo ""
	@echo "Commands:"
	@grep '^.PHONY: ' Makefile | sed 's/.PHONY: //' | awk '{split($$0,a," ## "); printf "  \033[34m%0-10s\033[0m %s\n", a[1], a[2]}'


.PHONY: clean ## Deletes local mod folder
clean:
	@rm -rf $(MOD_FOLDER_LOC)/Ci6ndex

.PHONY: dev ## Copies script files to local Civ 6 installation for debugging / testing
dev:
	@cd ..
	@cp -r ci6ndex-mod/ $(MOD_FOLDER_LOC)/Ci6ndex
