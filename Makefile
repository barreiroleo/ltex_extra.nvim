.PHONY: localtest test

localtest:
	echo "===> Local Testing"
	nvim --headless -c "PlenaryBustedDirectory test/"

test:
	echo "===> Testing"
	nvim --headless --noplugin -u test/minimal_init.lua \
        -c "PlenaryBustedDirectory test/ {minimal_init = './test/minimal_init.lua'}"

clean:
	echo "===> Cleaning"
	rm /tmp/lua_*
