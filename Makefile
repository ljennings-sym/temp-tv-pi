PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share/videoplayerd
SYSTEMD=/lib/systemd/system
UDEVDIR=/etc/udev/rules.d

install:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: You must run this as root (sudo)"; \
		exit 1; \
	fi \

	@if ! command -v mpv >/dev/null 2>&1; then \
		echo "Error: mpv is not installed. Please install it first."; \
		exit 1; \
	fi

	@if ! command -v socat >/dev/null 2>&1; then \
		echo "Error: socat is not installed. Please install it first."; \
		exit 1; \
	fi

	@echo "Installing videoplayerd..."

#	installing the script to /usr/local/bin and the fallback screen to /usr/local/share
	install -Dm755 src/videoplayerd.sh $(BINDIR)/videoplayerd
	install -Dm644 assets/splash.png $(SHAREDIR)/splash.png

#	Creating systemd service that contiuously polls the mount point to see if something is mounted, and plays any videos there if so
	install -Dm644 system/videoplayerd.service $(SYSTEMD)/videoplayerd.service

#	create udev rule so that any usb drives inserted are automatically mounted to /media/usb-player
	install -Dm644 system/99-videoplayerd-automount.rules $(UDEVDIR)/99-videoplayerd-automount.rules

#	reloading systemd and udev
	systemctl daemon-reload
	udevadm control --reload

	@echo "Installation complete."
	@echo "To enable service: sudo systemctl enable --now videoplayerd.service"

uninstall:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: You must run this as root (sudo)"; \
		exit 1; \
	fi \

	@echo "Stopping service (if running)..."
	-systemctl stop videoplayerd.service 2>/dev/null || true
	-systemctl disable videoplayerd.service 2>/dev/null || true

	@echo "\nRemoving installed files..."
	rm -f $(BINDIR)/videoplayerd
	rm -rf $(SHAREDIR)
	rm -f $(SYSTEMD)/videoplayerd.service
	rm -f $(UDEVDIR)/99-videoplayerd-automount.rules

	@echo "\nReloading system..."
	systemctl daemon-reload
	udevadm control --reload
	@echo "\nDone."
