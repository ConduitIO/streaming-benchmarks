.PHONY: install-tools
install-tools: install-benchi install-csvtk

.PHONY: install-benchi
install-benchi:
	# TODO check if already installed
	curl https://raw.githubusercontent.com/ConduitIO/benchi/main/install.sh | sh

.PHONY: install-csvtk
install-csvtk:
	# TODO
