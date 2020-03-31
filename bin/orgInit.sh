#!/bin/bash

DURATION=7

if [ "$#" -eq 1 ]; then
  DURATION=$1
fi

sfdx force:org:create -a dreamhouse -s -f config/project-scratch-def.json -d $DURATION
sfdx force:source:push
sfdx force:user:permset:assign -n dreamhouse
sfdx force:data:tree:import --plan data/sample-data-plan.json
sfdx force:org:open -p /lightning/page/home
echo "Org is set up"
