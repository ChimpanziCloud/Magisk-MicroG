#!/system/bin/sh
# Systemless GMS Remover & microG Installer - customize.sh

ui_print "**********************************************"
ui_print "  Systemless GMS Remover + microG Installer   "
ui_print "                  v2.1                        "
ui_print "**********************************************"

# Check if module is already installed on system
ALREADY_INSTALLED=false
if [ -d "/data/adb/modules/$MODID" ]; then
    ALREADY_INSTALLED=true
    ui_print "- Module '$MODID' is already installed!"
    ui_print "  [!] Skipping backup restoration, stock GMS deletion scan & permissions file creation."
fi

if [ "$ALREADY_INSTALLED" = false ]; then
    # 1. Check & Restore microG / GMS App Data & System/Product files from /data/backup
    BACKUP_DIR="/data/backup"
    FULL_BACKUP_TAR="$BACKUP_DIR/microg_full_backup.tar.gz"
    DATA_BACKUP_TAR="$BACKUP_DIR/microg_data_backup.tar.gz"

    TARGET_TAR=""
    if [ -f "$FULL_BACKUP_TAR" ]; then
        TARGET_TAR="$FULL_BACKUP_TAR"
    elif [ -f "$DATA_BACKUP_TAR" ]; then
        TARGET_TAR="$DATA_BACKUP_TAR"
    fi

    if [ -n "$TARGET_TAR" ]; then
        ui_print "- Found GMS / microG backup archive: $TARGET_TAR"
        ui_print "  [+] Restoring GMS app data from /data/data and /system /product files..."
        tar -xzf "$TARGET_TAR" -C / >/dev/null 2>&1
        
        # Restore file ownership for restored user data folders in /data/data
        for pkg_dir in /data/data/*gms* /data/data/*gsf* /data/data/*vending* /data/data/com.google.android.*; do
            if [ -d "$pkg_dir" ]; then
                pkg_uid=$(stat -c "%u" "$pkg_dir" 2>/dev/null)
                if [ -n "$pkg_uid" ] && [ "$pkg_uid" -ne 0 ]; then
                    chown -R "$pkg_uid:$pkg_uid" "$pkg_dir" >/dev/null 2>&1
                fi
            fi
        done
        ui_print "  [+] Full /data/data GMS files and system restoration complete!"
    else
        ui_print "- No GMS / microG backup archive found in /data/backup."
    fi

    # 2. Clean leftover stock GMS updates from /data/app (without marking packages uninstalled for user 0)
    ui_print "- Cleaning stock GMS/Play Store update binaries from /data/app..."
    rm -rf /data/app/*com.google.android.gms* >/dev/null 2>&1
    rm -rf /data/app/*com.google.android.gsf* >/dev/null 2>&1
    rm -rf /data/app/*com.android.vending* >/dev/null 2>&1

    # 3. Systemlessly hide stock GMS system folders
    ui_print "- Systemlessly hiding stock GMS system directories..."

    remove_systemless_dir() {
        local sys_dir="$1"
        if [ -d "$sys_dir" ]; then
            local rel_path="${sys_dir#/}"
            local target_dir="$MODPATH/$rel_path"
            
            case "$rel_path" in
                system/priv-app/GmsCore|system/priv-app/Phonesky|system/priv-app/GsfProxy)
                    ;;
                *)
                    ui_print "  [+] Hiding system folder: $sys_dir"
                    mkdir -p "$target_dir"
                    touch "$target_dir/.replace"
                    ;;
            esac
        fi
    }

    SEARCH_DIRS="
/system/app
/system/priv-app
/product/app
/product/priv-app
/system_ext/app
/system_ext/priv-app
/vendor/app
/vendor/priv-app
"

    GMS_DIR_NAMES="
PrebuiltGmsCore
GmsCore
GmsCoreSetupWizard
GoogleServicesFramework
Phonesky
GoogleFeedback
GooglePartnerSetup
GoogleOneTimeInitializer
GoogleContactsSyncAdapter
GoogleCalendarSyncAdapter
SetupWizard
"

    for base in $SEARCH_DIRS; do
        for name in $GMS_DIR_NAMES; do
            if [ -d "$base/$name" ]; then
                remove_systemless_dir "$base/$name"
            fi
        done
    done

    # Deep search for GMS APKs
    for base in /system /product /system_ext; do
        if [ -d "$base" ]; then
            find "$base" -maxdepth 3 -type f \( -name "*GmsCore*.apk" -o -name "*Phonesky*.apk" -o -name "*GoogleServicesFramework*.apk" \) 2>/dev/null | while read -r apk_file; do
                apk_dir=$(dirname "$apk_file")
                remove_systemless_dir "$apk_dir"
            done
        fi
    done

    # 4. Systemlessly fix Android 14/15 split permissions issue
    ui_print "- Applying Android 14/15 split permission fix..."
    SPLIT_PERM_FILE="/product/etc/permissions/split-permissions-google.xml"
    if [ -f "$SPLIT_PERM_FILE" ]; then
        mkdir -p "$MODPATH/product/etc/permissions"
        touch "$MODPATH/product/etc/permissions/split-permissions-google.xml"
        ui_print "  [+] Systemlessly neutralised Google split-permissions file"
    fi
fi

# 5. Set proper permissions for microG priv-apps & sysconfig
ui_print "- Configuring microG permissions..."
set_perm_recursive "$MODPATH/system/priv-app" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/etc/permissions" 0 0 0755 0644

ui_print "**********************************************"
ui_print "- Module installation complete!"
ui_print "- Please reboot your device."
ui_print "**********************************************"
