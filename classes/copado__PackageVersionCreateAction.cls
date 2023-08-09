/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PackageVersionCreateAction implements copado.JobExecutionCallback {
    @InvocableMethod(label='Package Version Create Action')
    global static List<copado.PackageVersionCreateAction.Response> create(List<copado.PackageVersionCreateAction.Request> requests) {
        return null;
    }
    global void execute(copado__JobExecution__c job, String status) {

    }
global class Request {
    @InvocableVariable(label='Description' required=false)
    global String description;
    @InvocableVariable(label='Platform related Version data JSON format' required=false)
    global String jsonInformation;
    @InvocableVariable(label='Package Id' required=false)
    global Id packageId;
    @InvocableVariable(label='Version Name' required=false)
    global String versionName;
    @InvocableVariable(label='Version Number' required=false)
    global String versionNumber;
    global Request(Id packageId, String jsonInformation) {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global copado__JobExecution__c job;
}
}
