/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CreateExecution {
    @InvocableMethod(label='Execute Job Template')
    global static List<copado__JobExecution__c> execute(List<copado.CreateExecution.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable( required=false)
    global List<copado.AdditionalStep> additionalSteps;
    @InvocableVariable( required=false)
    global String callback;
    @InvocableVariable( required=false)
    global String dataJson;
    @InvocableVariable( required=false)
    global String destinationId;
    @InvocableVariable( required=false)
    global String parentId;
    @InvocableVariable( required=false)
    global String pipelineId;
    @InvocableVariable( required=false)
    global List<copado__JobStep__c> postSteps;
    @InvocableVariable( required=false)
    global List<copado__JobStep__c> preSteps;
    @InvocableVariable( required=false)
    global Boolean runAfterInstantiation;
    @InvocableVariable( required=false)
    global String sourceId;
    @InvocableVariable( required=false)
    global String templateName;
    @InvocableVariable( required=false)
    global String transactionId;
    global Request() {

    }
}
}
