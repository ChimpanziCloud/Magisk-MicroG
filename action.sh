#!/system/bin/sh
# Systemless GMS Remover & microG Installer - action.sh
# Triggered by tapping the module's Action Button in Magisk / KernelSU / APatch Manager.
# Clears corrupted GSF/GMS/Play Store databases (resolves SQLite schema downgrade errors)
# and resets Package Manager caches.

echo "============================================"
echo "  microG App Data & Cache Reset Tool        "
echo "============================================"
echo ""

# 1. Clear app data for microG / GSF / Play Store packages
#    This removes incompatible/stock v4 SQLite databases that cause
#    "Can't downgrade database from version 4 to 3" crashes.
echo "- Clearing app data and SQLite databases..."
for pkg in com.google.android.gsf com.google.android.gms com.android.vending; do
    if pm path "$pkg" >/dev/null 2>&1; then
        echo "  [+] Clearing $pkg..."
        pm clear "$pkg" >/dev/null 2>&1
    fi
done

# 2. Clear system package cache
echo "- Clearing Package Manager system cache..."
rm -rf /data/system/package_cache/* >/dev/null 2>&1

# 3. Ensure packages are enabled and unhidden for User 0
echo "- Re-enabling microG packages for User 0..."
for pkg in com.google.android.gms com.google.android.gsf com.android.vending; do
    if pm path "$pkg" >/dev/null 2>&1; then
        cmd package install-existing --user 0 "$pkg" >/dev/null 2>&1
        pm enable "$pkg"                              >/dev/null 2>&1
        pm enable-user --user 0 "$pkg"                >/dev/null 2>&1
        pm unhide "$pkg"                              >/dev/null 2>&1
        cmd package unhide "$pkg"                     >/dev/null 2>&1
    fi
done

echo ""
echo "============================================"
echo "  Reset Complete!"
echo ""
echo "  Corrupted GSF databases have been cleared."
echo "  Please test Play Integrity / microG now."
echo "============================================"

exit 0
