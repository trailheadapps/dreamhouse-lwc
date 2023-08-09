/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PromoteAction extends copado.PromoteActionService implements copado.JobExecutionCallback {
    global PromoteAction() {

    }
    global void execute(copado__JobExecution__c job, String status) {

    }
    @InvocableMethod(label='Run a Copado promote' description='')
    global static List<copado.PromoteAction.Response> promote(List<copado.PromoteAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Action Callback' description='Apex Callback Class that implements JobExecutionCallback' required=false)
    global String actionCallback;
    @InvocableVariable(label='Deployment Dry Run' description='Include this parameter if you want to perform a validation-only deployment.' required=false)
    global Boolean deploymentDryRun;
    @InvocableVariable(label='Execute Deployment' description='Include this parameter if you want to run the deploy job template after the promote job template execution.' required=false)
    global Boolean executeDeployment;
    @InvocableVariable(label='Execute Promotion' description='Include this parameter if you want to run the promote job template.' required=false)
    global Boolean executePromotion;
    @InvocableVariable(label='Back Promotion' description='Include this parameter if the promotion that will be executed is a back-promotion.' required=false)
    global Boolean isBackPromotion;
    @InvocableVariable(label='Other Information' description='Additional information that can be passed for the job execution in JSON format' required=false)
    global String otherInformation;
    @InvocableVariable(label='Project Id' description='Id of the Project record that will be used to define the pipeline details and pipeline connections.' required=false)
    global Id projectId;
    @InvocableVariable(label='Promotion Id' description='Id of the Promotion record. If it is not defined, Copado will create a new promotion with the parameter values provided.' required=false)
    global Id promotionId;
    @InvocableVariable(label='Source Environment Id' description='Id of the promotion’s source environment. Copado will use this parameter to populate the destination environment if no promotion Id is specified.' required=false)
    global Id sourceEnvironmentId;
    @InvocableVariable(label='User Story Ids' description='Ids of the user stories to be included in the promotion.' required=false)
    global List<Id> userStoryIds;
    global Request() {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global copado__JobExecution__c jobExecution;
    @InvocableVariable( required=false)
    global copado__Promotion__c promotion;
    global Response() {

    }
}
}
