#!/bin/sh

version=python3.7
venv=__test_venv__

pkgname=$(basename $(pwd))
user_prefix=$HOME/soft
user_venv=$HOME/$venv/

user_site_pkg=$user_prefix/lib/$version/site-packages/
user_venv_site_pkg=$user_venv/lib/$version/site-packages/
local_site_pkg=$HOME/.local/lib/$version/site-packages/

user_egg_link=$user_site_pkg/${pkgname}.egg-link
local_egg_link=$local_site_pkg/${pkgname}.egg-link

user_easy_install_pth=$user_site_pkg/easy-install.pth
local_easy_install_pth=$local_site_pkg/easy-install.pth

log=installtest.log

# Catch all package names. dummy[-_]test is the small dummy test package
# installable from pypi to test the pip setup.
pkg_rex="dummy.+test|$pkgname"


err(){
    echo "error: $@"
    exit 1
}


uninstall(){
    echo "uninstall" >> $log
    # pip search -> dummy_test, but after install: pip list ->
    # dummy-test .. WTF!? This is NOT helpful.
    for name in $pkgname dummy_test dummy-test; do
        pip3 uninstall -y $name >> $log 2>&1
        sed -i "/$name/d" $user_easy_install_pth $local_easy_install_pth
        rm -rfv $user_site_pkg/$name* $local_site_pkg/$name* >> $log 2>&1
    done
    rm -rfv $user_venv >> $log 2>&1
}


fmtdir(){
    ret=''
    items=$(cat)
    for item in $items; do
        if [ -d $(readlink -f $item) ]; then
            ret="$ret $item/"
        else
            ret="$ret $item"
        fi
    done
    echo "$ret" | tr -s ' ' | paste -s -d ' '
}


greppkg(){
    cat | grep -E "$pkg_rex" | tr -s ' ' | paste -s -d ' '
}


run(){
    cmd=$@
    uninstall
    echo "\n$cmd" | sed -re 's|//|/|g' | tee -a $log
    (
    unset PYTHONUSERBASE PYTHONPATH
    [ -z "$(env | grep PYTHON)" ] || err "unset env vars PYTHON* failed"
    eval "$cmd >> $log 2>&1"
    cat << eof
    which pip3                            : $(which pip3)
    $user_site_pkg                        : $(ls -1F $user_site_pkg/ | greppkg)
    $user_easy_install_pth                : $(grep -E "$pkg_rex" $user_easy_install_pth | fmtdir)
    $user_egg_link                        : $([ -f $user_egg_link ] && grep -E "$pkg_rex" $user_egg_link | fmtdir)
    $user_venv_site_pkg                   : $([ -d $user_venv_site_pkg ] && ls -1F $user_venv_site_pkg/ | greppkg)
    $local_site_pkg                       : $(ls -1F $local_site_pkg/ | greppkg)
    $local_easy_install_pth               : $(grep -E "$pkg_rex" $local_easy_install_pth | fmtdir)
    $local_egg_link                       : $([ -f $local_egg_link ] && grep -E "$pkg_rex" $local_egg_link | fmtdir)
    pip3 list                             : $(pip3 list --format=columns | greppkg)
    PYTHONUSERBASE=$user_prefix pip3 list : $(PYTHONUSERBASE=$user_prefix pip3 list --format=columns | greppkg)
eof
    ) | ./fmt.py
}
##    PYTHONPATH=$user_site_pkg pip3 list   : $(ckempty $(PYTHONPATH=$user_site_pkg pip3 list --format=columns | greppkg))


rm -f $log

run "pip3 install ."
run "PYTHONUSERBASE=$user_prefix pip3 install ."
run "PYTHONPATH=$user_site_pkg python3 setup.py install --prefix=$user_prefix"

run "pip3 install -e ."
run "PYTHONUSERBASE=$user_prefix pip3 install -e ."
run "PYTHONPATH=$user_site_pkg python3 setup.py develop --prefix=$user_prefix"

run "$version -m venv --without-pip --symlinks $user_venv; . $user_venv/bin/activate; pip3 install ."
run "$version -m venv --symlinks $user_venv; . $user_venv/bin/activate; pip3 install ."

uninstall
