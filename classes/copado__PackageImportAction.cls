/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PackageImportAction implements copado.JobExecutionCallback {
    @InvocableMethod(label='Package Import Action')
    global static List<copado.PackageImportAction.Response> import(List<copado.PackageImportAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Platform related arguments in JSON format' required=false)
    global String jsonInformation;
    @InvocableVariable(label='Package Name or Id' required=true)
    global String packageNameOrId;
    @InvocableVariable(label='Pipeline Id' required=true)
    global Id pipelineId;
    global Request(String packageNameOrId, String pipelineId, String jsonInformation) {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global copado__JobExecution__c job;
}
}
