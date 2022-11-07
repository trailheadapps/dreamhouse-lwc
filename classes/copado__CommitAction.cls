/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CommitAction implements copado.JobExecutionCallback {
    global CommitAction() {

    }
    @InvocableMethod(label='Commit changes' description='Commit your changes')
    global static List<copado.CommitAction.Response> commitChanges(List<copado.CommitAction.Request> requests) {
        return null;
    }
    global void execute(copado__JobExecution__c job, String status) {

    }
global class Change {
    @InvocableVariable(label='a' description='action: add, delete, ret-only, full pps, ...' required=false)
    global String a;
    @InvocableVariable(label='c' description='category: copadodx, vlocity, cpq, ...' required=false)
    global String c;
    @InvocableVariable(label='j' description='json additional information' required=false)
    global String j;
    @InvocableVariable(label='m' description='module directory e.g. force-app/main/default' required=false)
    global String m;
    @InvocableVariable(label='n' description='name' required=false)
    global String n;
    @InvocableVariable(label='t' description='type' required=false)
    global String t;
    global Change() {

    }
}
global class Request {
    @InvocableVariable(label='Action Callback' description='Apex Callback Class that implements JobExecutionCallback' required=false)
    global String actionCallback;
    @InvocableVariable(label='Base branch' description='Base branch for the commit. If not provided, a default value is calculated based on User Story, Release, or Pipeline' required=false)
    global String baseBranch;
    @InvocableVariable(label='Changes' description='List of changes to commit' required=false)
    global List<copado.CommitAction.Change> changes;
    @InvocableVariable(label='Commit Id' description='Id of an existing git commit with the changes. Likely specified when commiting from CLI' required=false)
    global String commitId;
    @InvocableVariable(label='Execute commit' description='If set to false, actual commit behaviour will be skipped and only operations in Copado will happen. Likely specified to false when commiting from CLI. Defaults to true' required=false)
    global Boolean executeCommit;
    @InvocableVariable(label='JSON Information' description='Additional commit information in JSON format' required=false)
    global String jsonInformation;
    @InvocableVariable(label='Message' description='Commit message. If not provided, a default value is calculated based on User Story Name and Title' required=false)
    global String message;
    @InvocableVariable(label='Recreate feature branch' description='If specified, previous branch and User Story Metadata records previously commited will be deleted. Defaults to false' required=false)
    global Boolean recreateFeatureBranch;
    @InvocableVariable(label='User Story Id' description='Commit your changes' required=true)
    global Id userStoryId;
    global Request() {

    }
}
global class Response {
    @InvocableVariable(label='Job Execution' description='Job Execution record for the commit action' required=false)
    global copado__JobExecution__c jobExecution;
    @InvocableVariable(label='User Story Commit' description='User Story Commit record created as part of the commit process' required=false)
    global copado__User_Story_Commit__c userStorycommit;
    global Response() {

    }
}
}
