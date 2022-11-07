/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CheckStatusAction {
    @InvocableMethod(label='Check Status Action')
    global static List<copado.CheckStatusAction.Response> fetch(List<copado.CheckStatusAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Job Execution Id' required=false)
    global String jobId;
    @InvocableVariable(label='Result Id' required=false)
    global String resultId;
    global Request() {

    }
    global Request(String jobId, String resultId) {

    }
}
global class Response {
    @InvocableVariable(label='Error message' required=false)
    global String errorMessage;
    @InvocableVariable(label='Progress status of Job/Result' required=false)
    global String progressStatus;
    @InvocableVariable(label='Result Id/Latest step result Id' required=false)
    global Id resultId;
    @InvocableVariable(label='Status of Job/Result' required=false)
    global String status;
}
}
