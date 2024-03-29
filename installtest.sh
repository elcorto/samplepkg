#!/bin/sh

set -eu

err(){
    echo "error: $@"
    exit 1
}


here=$(pwd)
[ -d src ] || err "no src/ found"
pkgname=$(basename $(ls $here/src))

log=installtest.log

# Adapt to your system.
version=python3.10
venv=__test_venv__
user_prefix=$HOME/soft
user_venv=$HOME/$venv/

local_prefix=$HOME/.local

# Seems like that there is no way to force pipenv to use a specific venv. No,
# PIPENV_VIRTUALENV is ignored. We can only use
#   PIPENV_VENV_IN_PROJECT=1 pipenv install
# to at least enforce $(pwd)/.venv .
pipenv_venv=$(dirname $0)/.venv

user_site_pkg=$user_prefix/lib/$version/site-packages/
user_venv_site_pkg=$user_venv/lib/$version/site-packages/
local_site_pkg=$local_prefix/lib/$version/site-packages/
pipenv_venv_site_pkg=$pipenv_venv/lib/$version/site-packages/

user_egg_link=$user_site_pkg/${pkgname}.egg-link
user_venv_egg_link=$user_venv_site_pkg/${pkgname}.egg-link
local_egg_link=$local_site_pkg/${pkgname}.egg-link
pipenv_venv_egg_link=$pipenv_venv_site_pkg/${pkgname}.egg-link

user_easy_install_pth=$user_site_pkg/easy-install.pth
user_venv_easy_install_pth=$user_venv_site_pkg/easy-install.pth
local_easy_install_pth=$local_site_pkg/easy-install.pth
pipenv_venv_easy_install_pth=$pipenv_venv_site_pkg/easy-install.pth


# Catch all package names. dummy[-_]test is the small dummy test package
# installable from pypi to test the pip setup.
pkg_rex="dummy.+test|$pkgname"


uninstall(){
    local fn
    echo "uninstall" >> $log
    # pip search -> dummy_test, but after install: pip list ->
    # dummy-test .. WTF!? This is NOT helpful.
    for name in $pkgname dummy_test dummy-test; do
        pip3 uninstall -y $name >> $log 2>&1
        for fn in $user_easy_install_pth $local_easy_install_pth; do
            [ -f $fn ] && sed -i "/$name/d" $fn
        done
        rm -rfv $user_site_pkg/$name* $local_site_pkg/$name* >> $log 2>&1
    done
    rm -rfv $user_venv >> $log 2>&1
    rm -rfv $pipenv_venv Pipfile* >> $log 2>&1
    unset $(env | grep PIPENV_ | sed -re 's/^(PIPENV_.+)=.+/\1/g')
    [ -z "$(env | grep PIPENV_)" ] || err "unset env vars PIPENV_* failed"
    unset PYTHONUSERBASE PYTHONPATH
    [ -z "$(env | grep PYTHON)" ] || err "unset env vars PYTHON* failed"
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
    echo "\n$cmd" | sed -re 's|//|/|g' | tee -a $log
    (
    uninstall
    eval "$cmd >> $log 2>&1"
    cat << eof
    which pip3 : $(which pip3)
    pip3 list  : $(pip3 list --format=columns | greppkg)
    PYTHONUSERBASE=$user_prefix pip3 list : $(PYTHONUSERBASE=$user_prefix pip3 list --format=columns | greppkg)
eof
    for dr in $user_site_pkg \
              $local_site_pkg \
              $user_venv_site_pkg \
              $pipenv_venv_site_pkg; do
        echo "$dr : $([ -d $dr ] && ls -1F $dr | greppkg)"
    done

    for fn in $user_egg_link \
              $user_venv_egg_link \
              $local_egg_link \
              $pipenv_venv_egg_link \
              $user_easy_install_pth \
              $user_venv_easy_install_pth \
              $local_easy_install_pth \
              $pipenv_venv_easy_install_pth; do
        echo "$fn : $([ -f $fn ] && grep -E "$pkg_rex" $fn | fmtdir)"
    done
    ) | ./fmt.py
}

rm -f $log

run "pip3 install ."
run "PYTHONUSERBASE=$user_prefix pip3 install ."
run "PYTHONPATH=$user_site_pkg python3 setup.py install --prefix=$user_prefix"

run "pip3 install -e ."
run "PYTHONUSERBASE=$user_prefix pip3 install -e ."
run "PYTHONPATH=$user_site_pkg python3 setup.py develop --prefix=$user_prefix"

# plain ol' Python venv, all other venv-ish tools/wrappers use this under the
# hood (right?, else PRs welcome!), so we treat only this here
run "$version -m venv --without-pip --symlinks $user_venv; . $user_venv/bin/activate; pip3 install ."
run "$version -m venv --symlinks $user_venv; . $user_venv/bin/activate; pip3 install ."

# pipenv: replace ". $pipenv_venv/bin/activate" w/ "pipenv shell" in interactive
# work

run "PIPENV_VENV_IN_PROJECT=1 pipenv install . >> $log 2>&1; . $pipenv_venv/bin/activate"
run "PIPENV_VENV_IN_PROJECT=1 pipenv install -e . >> $log 2>&1; . $pipenv_venv/bin/activate"

# same as the ones below
run "PIPENV_VENV_IN_PROJECT=1 pipenv install >> $log 2>&1; . $pipenv_venv/bin/activate; pip3 install ."
run "PIPENV_VENV_IN_PROJECT=1 pipenv install >> $log 2>&1; . $pipenv_venv/bin/activate; pip3 install -e ."

run "(PIPENV_VENV_IN_PROJECT=1 pipenv install && pipenv run pip install .) >> $log 2>&1; . $pipenv_venv/bin/activate"
run "(PIPENV_VENV_IN_PROJECT=1 pipenv install && pipenv run pip install -e .) >> $log 2>&1; . $pipenv_venv/bin/activate"

uninstall
