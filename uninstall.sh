#!/system/bin/sh
# Systemless GMS Remover & microG Installer - uninstall.sh
# Executed automatically by Magisk / KernelSU when the module is removed

BACKUP_DIR="/data/backup"
BACKUP_TAR="$BACKUP_DIR/microg_full_backup.tar.gz"

mkdir -p "$BACKUP_DIR"

TAR_PATHS=""

# 1. Back up all GMS and microG data directories in /data/data and /data/user_de/0
for base_dir in /data/data /data/user_de/0; do
    if [ -d "$base_dir" ]; then
        for folder in "$base_dir"/*gms* "$base_dir"/*gsf* "$base_dir"/*vending* "$base_dir"/com.google.android.*; do
            if [ -d "$folder" ]; then
                rel_dir="${folder#/}"
                TAR_PATHS="$TAR_PATHS $rel_dir"
            fi
        done
    fi
done

# 2. Back up system / product app files if present
SYS_PATHS="
system/priv-app/GmsCore
system/priv-app/Phonesky
system/priv-app/GsfProxy
system/etc/permissions/privapp-permissions-microg.xml
product/priv-app/GmsCore
product/priv-app/Phonesky
product/priv-app/GsfProxy
"

for sys_path in $SYS_PATHS; do
    if [ -e "/$sys_path" ]; then
        TAR_PATHS="$TAR_PATHS $sys_path"
    fi
done

if [ -n "$TAR_PATHS" ]; then
    cd /
    tar -czf "$BACKUP_TAR" $TAR_PATHS >/dev/null 2>&1
fi

exit 0
