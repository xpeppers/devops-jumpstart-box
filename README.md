# DevOps jumpstart box

DevOps jumpstart workshop base box

## Create and/or provision box
    vagrant up --provision

## Export box file
    vagrant push local

## Push to Atlas
    vagrant login
    export ATLAS_TOKEN=`cat ~/.vagrant.d/data/vagrant_login_token`
    vagrant push remote
