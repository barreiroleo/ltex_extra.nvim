.PHONY: localtest

localtest:
	nvim --headless -c "PlenaryBustedDirectory test/"
