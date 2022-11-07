/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RunUserStoryComplianceScan {
    global RunUserStoryComplianceScan() {

    }
    @InvocableMethod(label='User Story Compliance Scan' description='Sends request to given Copado webhookUrl')
    global static void execute(List<copado.RunUserStoryComplianceScan.InvocableVariables> variables) {

    }
global class InvocableVariables {
    @InvocableVariable(label='Branch Name' required=true)
    global String branch;
    @InvocableVariable(label='Git Repository Id' required=true)
    global Id repoId;
    @InvocableVariable(label='User Story Id' required=true)
    global Id storyId;
    global InvocableVariables() {

    }
}
}
