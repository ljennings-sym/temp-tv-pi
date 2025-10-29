PREFIX := $(HOME)/.config/usb-video-player
AUTOSTART := $(HOME)/.config/autostart
SCRIPT := usb-player.sh
SPLASH := splash.png
DESKTOP_FILE := usb-player.desktop

all: install

install: $(PREFIX) $(AUTOSTART)
	@echo "Installing USB Video Player..."



#   Copy script and splash image
	@cp src/$(SCRIPT) $(PREFIX)/
	@cp splash/$(SPLASH) $(PREFIX)/

#   Make script executable
	@chmod +x $(PREFIX)/$(SCRIPT)

#   Generate autostart .desktop file with absolute path
	@echo "[Desktop Entry]" > $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "Type=Application" >> $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "Name=USB Video Player" >> $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "Exec=$(PREFIX)/$(SCRIPT)" >> $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "X-GNOME-Autostart-enabled=true" >> $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "NoDisplay=false" >> $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "Comment=Automatically play USB videos" >> $(AUTOSTART)/$(DESKTOP_FILE)

	@echo "Installation complete. Script will start automatically on login."


$(PREFIX):
#	Clean up any previous installations that were on the machine
	@rm -rf $(PREFIX)
	@mkdir -p $(PREFIX)

$(AUTOSTART):
# 	uninstall previous and create autostart if not present
	@rm -f $(AUTOSTART)/$(DESKTOP_FILE)
	@mkdir -p $(AUTOSTART)



uninstall:
	@echo "Removing USB Video Player..."
	@rm -rf $(PREFIX)
	@rm -f $(AUTOSTART)/$(DESKTOP_FILE)
	@echo "Uninstalled."
