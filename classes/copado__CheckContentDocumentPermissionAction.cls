/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CheckContentDocumentPermissionAction {
    global CheckContentDocumentPermissionAction() {

    }
    @InvocableMethod(label='Check File Permission' description='Checks if the current user is allowed to perform operations on the Files related to this records.')
    global static List<copado.CheckContentDocumentPermissionAction.Result> execute(List<copado.CheckContentDocumentPermissionAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Record Id' required=false)
    global String recordId;
    global Request() {

    }
}
global class Result {
    @InvocableVariable(label='Can Delete Files' required=false)
    global Boolean canDeleteFiles;
    global Result() {

    }
}
}
