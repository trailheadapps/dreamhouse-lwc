#sfdx force:org:list --clean
#sfdx force:org:create:scratch -f .\config\squada-scratch-def.json
sf org list --clean --no-prompt
sf org create scratch --definition-file .\config\squada-scratch-def.json
#sfdx force:package:install -i 