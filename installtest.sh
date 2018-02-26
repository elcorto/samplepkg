#!/bin/sh

pkgname=$(basename $(pwd))
version=python3.6
user_prefix=$HOME/soft
user_site_pkg=$HOME/soft/lib/$version/site-packages
local_site_pkg=$HOME/.local/lib/$version/site-packages
user_easy_install_pth=$user_site_pkg/easy-install.pth
local_easy_install_pth=$local_site_pkg/easy-install.pth

log=installtest.log

err(){
    echo "error: $@"
    exit 1
}

uninstall(){
    pip3 uninstall -y $pkgname >> $log 2>&1
    sed -i "/$pkgname/d" $user_easy_install_pth $local_easy_install_pth
    rm -rfv $user_site_pkg/$pkgname* $local_site_pkg/$pkgname*  >> $log 2>&1
}

run(){
    cmd=$@
    uninstall
    echo "\n#cmd: $cmd" | tee -a $log
    unset PYTHONUSERBASE PYTHONPATH
    [ -z "$(env | grep PYTHON)" ] || err "unset env failed"
    eval "$cmd >> $log 2>&1"
    lst=$(pip3 list --format=columns | grep $pkgname | tr -s ' ')
    echo "#pip list                             : $lst" 
    echo "#user site-packages                   : $(ls -1 $user_site_pkg/ | grep $pkgname | paste -s -d' ')" 
    echo "#user site-packages/easy-install.pth  : $(grep $pkgname $user_easy_install_pth)" 
    echo "#local site-packages                  : $(ls -1 $local_site_pkg/ | grep $pkgname | paste -s -d' ')" 
    echo "#local site-packages/easy-install.pth : $(grep $pkgname $local_easy_install_pth)"
}

rm -f $log

cat << eof | tee -a $log
#locations:
#    HOME                : $HOME
#    user site-packages  : $user_site_pkg
#    local site-packages : $local_site_pkg

eof

run "pip3 install -e ."
run "PYTHONUSERBASE=$user_prefix pip3 install -e ."
run "PYTHONPATH=$user_site_pkg python3 setup.py develop --prefix=$user_prefix"

run "pip3 install ."
run "PYTHONUSERBASE=$user_prefix pip3 install ."
run "PYTHONPATH=$user_site_pkg python3 setup.py install --prefix=$user_prefix"

uninstall
