/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PromotionDeployAction extends copado.PromoteActionService implements copado.JobExecutionCallback {
    global PromotionDeployAction() {

    }
    @InvocableMethod(label='Run a Copado promotion deployment' description='')
    global static List<copado.PromotionDeployAction.Response> deploy(List<copado.PromotionDeployAction.Request> requests) {
        return null;
    }
    global void execute(copado__JobExecution__c job, String status) {

    }
global class Request {
    @InvocableVariable(label='Action Callback' description='Apex Callback Class that implements JobExecutionCallback' required=false)
    global String actionCallback;
    @InvocableVariable(label='Deployment Dry Run' description='Include this parameter if you want to perform a validation-only deployment.' required=false)
    global Boolean deploymentDryRun;
    @InvocableVariable(label='Execute Deployment' description='Include this parameter if you want to run the deploy job template.' required=false)
    global Boolean executeDeployment;
    @InvocableVariable(label='Other Information' description='Additional information that can be passed for the job execution in JSON format' required=false)
    global String otherInformation;
    @InvocableVariable(label='Promotion Id' description='Id of the Promotion record. Copado will create a new deployment with the parameter values provided.' required=true)
    global Id promotionId;
    global Request() {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global copado__JobExecution__c jobExecution;
    global Response() {

    }
}
}
