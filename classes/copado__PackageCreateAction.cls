/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PackageCreateAction implements copado.JobExecutionCallback {
    @InvocableMethod(label='Package Create Action')
    global static List<copado.PackageCreateAction.Response> create(List<copado.PackageCreateAction.Request> requests) {
        return null;
    }
    global void execute(copado__JobExecution__c job, String status) {

    }
global class Request {
    @InvocableVariable(label='Platform related package data in JSON format' required=false)
    global String jsonInformation;
    @InvocableVariable(label='Package Id' required=true)
    global Id packageId;
    global Request(Id packageId, String jsonInformation) {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global copado__JobExecution__c job;
}
}
