/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DeployDataAction {
    global DeployDataAction() {

    }
    @InvocableMethod(label='Deploy Data' description='Deploy data using Data Templates/Data Sets. This method creates a multi-step deployment with a Data Template step and (optionally) executes it. It returns the deployment Id.')
    global static List<Id> execute(List<copado.DeployDataAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Data Template Id' description='Required if source type is Environment' required=false)
    global String dataTemplateId;
    @InvocableVariable(label='Execute Immediately' description='Default is false' required=false)
    global Boolean deployNow;
    @InvocableVariable(label='Destination Branch name' description='Required if destination type is Branch' required=false)
    global String destinationBranchName;
    @InvocableVariable(label='Destination Credential Id' description='If not specified, current Org Credential will be used' required=false)
    global String destinationCredentialId;
    @InvocableVariable(label='Destination Data Set Id' description='Required if destination type is Data Set' required=false)
    global String destinationDataSetId;
    @InvocableVariable(label='Destination type' description='Possible values: Enum options in DataDeployer.Destination (i.e. Environment, Data Set, Branch)' required=false)
    global String destinationType;
    @InvocableVariable(label='Source Branch name' description='Required if source type is Branch' required=false)
    global String sourceBranchName;
    @InvocableVariable(label='Source Credential Id' description='If not specified, current Org Credential will be used' required=false)
    global String sourceCredentialId;
    @InvocableVariable(label='Source Data Set Id' description='Required if source type is Data Set' required=false)
    global String sourceDataSetId;
    @InvocableVariable(label='Source type' description='Possible values: Enum options in DataDeployer.Source (i.e. Environment, Data Set, Branch)' required=false)
    global String sourceType;
    global Request() {

    }
}
}
