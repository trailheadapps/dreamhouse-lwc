/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RecalculateBranchStatus {
    global RecalculateBranchStatus() {

    }
    @InvocableMethod(label='Recalculate Branch Status' description='Sends request to given Copado webhookUrl')
    global static void execute(List<copado.RecalculateBranchStatus.InvocableVariables> variables) {

    }
global class InvocableVariables {
    @InvocableVariable(label='Branch Name' required=true)
    global String branchName;
    @InvocableVariable(label='Deployment Flow Id' required=true)
    global Id flowId;
    global InvocableVariables() {

    }
}
}
