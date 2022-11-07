/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DeleteOldContentVersionsAction {
    global DeleteOldContentVersionsAction() {

    }
    @InvocableMethod(label='Delete Old Versions From Record Files' description='Deletes all the versions of record Files, leaving only the last one. Returns the new File Id with the latest version (as original File is removed due to limitations deleting versions in Salesforce).')
    global static List<copado.DeleteOldContentVersionsAction.Result> execute(List<copado.DeleteOldContentVersionsAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Record Id' required=false)
    global String recordId;
    global Request() {

    }
}
global class Result {
    @InvocableVariable(label='ContentDocument Ids' required=false)
    global List<Id> contentDocumentIds;
    global Result() {

    }
}
}
