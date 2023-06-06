$userstory =  $args[0] ? $args[0]: 'us001'
$dias = $args[1] ? $args[1]: 7
#sfdx force:org:list --clean
#sfdx force:org:create:scratch -f .\config\scratch-with-omin.json
#sf org list --clean --no-prompt
git branch $userstory
sf org create scratch --definition-file .\config\scratch-with-omin.json -y $dias --name $userstory --alias $userstory
sfdx force:user:password:generate
sfdx force:source:push
sf data import tree --plan .\data\sample-data-plan.json
#sf package install --package 04t5c000000o7RXAAY