/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CalculateOrgDifferences {
    global CalculateOrgDifferences() {

    }
    @InvocableMethod(label='Calculate Org Differences' description='Sends request to given Copado webhookUrl')
    global static void execute(List<copado.CalculateOrgDifferences.InvocableVariables> variables) {

    }
global class InvocableVariables {
    @InvocableVariable(label='Deploy differences' required=true)
    global Boolean deploy;
    @InvocableVariable(label='Org Difference Id' required=true)
    global Id orgDiffId;
    global InvocableVariables() {

    }
}
}
