generate:
	ruby generate.rb

check:
	nvim --headless --clean --cmd "set rtp+=." -l check.lua

preview:
	ruby palette.rb

.PHONY: generate check preview
