/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ValidateDataSetAction {
    global ValidateDataSetAction() {

    }
    @InvocableMethod(label='Validate Data Set' description='Checks different conditions for the Data Set record (e.g. if the files for the Data Set are valid for a deployment).')
    global static List<copado.ValidateDataSetAction.Result> execute(List<copado.ValidateDataSetAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Record Id' required=false)
    global String recordId;
    global Request() {

    }
}
global class Result {
    @InvocableVariable(label='Has Valid Files?' required=false)
    global Boolean hasValidFiles;
    global Result() {

    }
}
}
