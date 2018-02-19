#!/bin/sh

name=$(basename $(pwd))
version=python3.6
user_prefix=$HOME/soft
user_site_pkg=$HOME/soft/lib/$version/site-packages
local_site_pkg=$HOME/.local/lib/$version/site-packages
user_easy_install_pth=$user_site_pkg/easy-install.pth
local_easy_install_pth=$local_site_pkg/easy-install.pth

err(){
    echo "error: $@"
    exit 1
}

uninstall(){
    pip3 uninstall -y $name > /dev/null 2>&1
    sed -i "/$name/d" $user_easy_install_pth $local_easy_install_pth
    rm -rf $user_site_pkg/$name* $local_site_pkg/$name*
}

run(){
    cmd=$@
    uninstall
    echo "\n#cmd: $cmd"
    unset PYTHONUSERBASE PYTHONPATH
    [ -z "$(env | grep PYTHON)" ] || err "unset env failed"
    log=installtest_$(echo "$cmd" | sed -re 's|[/ ]|_|g')
    eval "$cmd > $log 2>&1"
    lst=$(pip3 list --format=columns | grep $name | tr -s ' ')
    echo "#pip list                             : $lst" 
    echo "#user site-packages                   : $(ls -1 $user_site_pkg/ | grep $name | paste -s -d' ')" 
    echo "#user site-packages/easy-install.pth  : $(grep $name $user_easy_install_pth)" 
    echo "#local site-packages                  : $(ls -1 $local_site_pkg/ | grep $name | paste -s -d' ')" 
    echo "#local site-packages/easy-install.pth : $(grep $name $local_easy_install_pth)"
}

run "pip3 install -e ."
run "PYTHONUSERBASE=$user_prefix pip3 install -e ."
run "PYTHONPATH=$user_site_pkg python3 setup.py develop --prefix=$user_prefix"
run "pip3 install ."
run "PYTHONPATH=$user_site_pkg python3 setup.py install --prefix=$user_prefix"

uninstall
