#!/system/bin/sh
# Systemless GMS Remover & microG Installer - service.sh
# Runs after boot to ensure microG packages are enabled and installed for user 0

# Wait until boot completes
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Ensure microG packages are registered, enabled, and unhidden for User 0
MICROG_PACKAGES="
com.google.android.gms
com.google.android.gsf
com.android.vending
"

for pkg in $MICROG_PACKAGES; do
    # Register/install package for existing user 0 if hidden/uninstalled
    cmd package install-existing --user 0 "$pkg" >/dev/null 2>&1
    cmd package install-existing "$pkg" >/dev/null 2>&1
    
    # Enable package state
    pm enable "$pkg" >/dev/null 2>&1
    pm enable-user --user 0 "$pkg" >/dev/null 2>&1
    pm unhide "$pkg" >/dev/null 2>&1
    cmd package unhide "$pkg" >/dev/null 2>&1
done

exit 0
