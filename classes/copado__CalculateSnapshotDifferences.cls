/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CalculateSnapshotDifferences {
    global CalculateSnapshotDifferences() {

    }
    @InvocableMethod(label='Calculate Snapshot Differences' description='Sends request to given Copado webhookUrl')
    global static void execute(List<copado.CalculateSnapshotDifferences.InvocableVariables> variables) {

    }
global class InvocableVariables {
    @InvocableVariable(label='Deploy' required=true)
    global Boolean deploy;
    @InvocableVariable(label='Snapshot differences Id' required=true)
    global Id snapshotDiffId;
    global InvocableVariables() {

    }
}
}
