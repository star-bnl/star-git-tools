PREFIX ?= /usr/local
BINPREFIX ?= "$(PREFIX)/bin"

BINS = $(wildcard bin/git-*)
COMMANDS = $(subst bin/, , $(BINS))

default: install

install:
	@mkdir -p $(DESTDIR)$(BINPREFIX)
	@echo "... installing bins to $(DESTDIR)$(BINPREFIX)"
	$(eval TEMPFILE := $(shell mktemp -q $${TMPDIR:-/tmp}/star-git-tools.XXXXXX 2>/dev/null || mktemp -q))
	@# chmod from rw-------(default) to rwxrwxr-x, so that users can exec the scripts
	@chmod 775 $(TEMPFILE)
	$(eval EXISTED_ALIASES := $(shell \
		git config --get-regexp 'alias.*' | awk '{print "git-" substr($$1, 7)}'))
	@$(foreach COMMAND, $(COMMANDS), \
		disable=''; \
		if test ! -z "$(filter $(COMMAND), $(EXISTED_ALIASES))"; then \
			read -p "$(COMMAND) conflicts with an alias, still install it and disable the alias? [y/n]" answer; \
			test "$$answer" = 'n' -o "$$answer" = 'N' && disable="true"; \
		fi; \
		if test -z "$$disable"; then \
			echo "... installing $(COMMAND)"; \
			cat bin/$(COMMAND) > $(TEMPFILE); \
			cp -f $(TEMPFILE) $(DESTDIR)$(BINPREFIX)/$(COMMAND); \
		fi; \
	)
	$(eval BINPATH := $(shell cd $(DESTDIR)$(BINPREFIX); pwd))
	@echo
	@echo "Make sure $(BINPATH) is in your PATH. E.g. add to your .bashrc"
	@echo "export PATH+=\":$(BINPATH)\""

uninstall:
	@$(foreach BIN, $(BINS), \
		echo "... uninstalling $(DESTDIR)$(BINPREFIX)/$(notdir $(BIN))"; \
		rm -f $(DESTDIR)$(BINPREFIX)/$(notdir $(BIN)); \
	)

.PHONY: default install uninstall
