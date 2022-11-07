/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PackageVersionPublishAction implements copado.JobExecutionCallback {
    global void execute(copado__JobExecution__c job, String status) {

    }
    @InvocableMethod(label='Package Version Publish Action')
    global static List<copado.PackageVersionPublishAction.Response> publish(List<copado.PackageVersionPublishAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Package Version Id' required=true)
    global Id packageVersionId;
    global Request(Id packageVersionId) {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global copado__JobExecution__c job;
}
}
