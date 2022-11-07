/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RunJob implements Database.AllowsCallouts, System.Queueable {
    @InvocableMethod(label='Execute Job')
    global static void execute(List<copado.RunJob.Request> requests) {

    }
global class Request {
    @InvocableVariable( required=false)
    global Boolean allSteps;
    @InvocableVariable( required=false)
    global Id jobId;
    @InvocableVariable( required=false)
    global Id transactionId;
    @InvocableVariable( required=false)
    global String transactionId2;
}
}
