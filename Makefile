MOD_FOLDER_LOC = /home/brian/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/289070/pfx/drive_c/users/steamuser/My\ Documents/My\ Games/Sid\ Meier\'s\ Civilization\ VI/Mods
DEV_TOOLS_LOC = /home/brian/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/404350/pfx/drive_c/users/steamuser/My\ Documents/Mods/

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


.PHONY: clean ## Deletes local mod folder and local packages
clean:
	@rm -rf "$(MOD_FOLDER_LOC)/Ci6ndex"
	@rm -rf "$(DEV_TOOLS_LOC)/Ci6ndex"
	@rm -rf build/

.PHONY: dev ## Copies script files to local Civ 6 installation for debugging / testing
dev:
	@mkdir -p $(MOD_FOLDER_LOC)/Ci6ndex
	@rm -rf $(MOD_FOLDER_LOC)/Ci6ndex/*
	@cp -r * $(MOD_FOLDER_LOC)/Ci6ndex/
	
.PHONY: build ## Copies script files to CIV 6 development tool prefix
build:
	@mkdir -p $(DEV_TOOLS_LOC)/Ci6ndex
	@rm -rf $(DEV_TOOLS_LOC)/Ci6ndex/*
	@cp -r * $(DEV_TOOLS_LOC)/Ci6ndex/

.PHONY: package ## Creates a tar archive of the mod
package:
	@mkdir -p build
	@mkdir -p build/temp/Ci6ndex
	@cp -r $(filter-out build/%, $(wildcard *)) build/temp/Ci6ndex/
	@tar -czf build/ci6ndex.tar.gz -C build/temp --exclude=.git --exclude=.gitignore .
	@rm -rf build/temp
