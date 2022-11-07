/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RunTestsAction implements copado.JobExecutionCallback {
    global RunTestsAction() {

    }
    global void execute(copado__JobExecution__c execution, String status) {

    }
    @InvocableMethod(label='Run a List of Copado Tests' description='Extracts and Runs a list of Copado Tests of a specific type')
    global static List<copado.RunTestsAction.Response> execute(List<copado.RunTestsAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Acceptance Criteria' description='JSON formatted properties that will be applied to compute each test result. If provided, will override the acceptance criteria defined at the test record level.' required=false)
    global String acceptanceCriteria;
    @InvocableVariable(label='Action Callback' description='Apex Callback Class that implements TestsStepCallback, invoked after job execution completion. Its functional purpose is to inject post-execution logic needed by the action consumer.' required=false)
    global String actionCallback;
    @InvocableVariable(label='Context Ids' description='List of Salesforce Record Ids that contain Tests. It might be multiple test records, user stories, features or applications.' required=true)
    global List<Id> contextIds;
    @InvocableVariable(label='Deprecated - Create Consolidated Result' description='Specifies if consolidated result has to be created for Job Execution, by default it is true' required=false)
    global Boolean createConsolidatedResult;
    @InvocableVariable(label='Environment Id' description='The Identifier (Salesforce Record Id, URL, URI, ApiName, Git branch, etc) of the “Environment” to run the tests in.' required=false)
    global String environmentId;
    @InvocableVariable(label='Extension Configuration' description='By providing a Extension Configuration, it will override the Extension Configuration related to the tests in contexts for its execution.' required=false)
    global String extensionConfigurationId;
    @InvocableVariable(label='Deprecated - Properties Override' description='Deprecated - JSON String overriding properties with different values. For instance, allows Quality Gates to use stricter values e.g. Code Coverage on Unit Test runs.' required=false)
    global String propertiesOverride;
    @InvocableVariable(label='Consolidated Result Id' description='Id of an existing consolidated result, to be updated with the overall test execution status. If provided, test independent results will not be generated.' required=false)
    global String resultId;
    @InvocableVariable(label='Test Tool' description='Master label of the Test Tool custom metadata type record that applies to all Test's Tool Configurations.' required=true)
    global String tool;
    @InvocableVariable(label='Deprecated - Test Type' description='Deprecated - Master label of the Test Type custom metadata type record that applies to all Tests contained in contextIds.' required=false)
    global String type;
    global Request() {

    }
    global copado.RunTestsAction.Request acceptanceCriteria(String json) {
        return null;
    }
    global copado.RunTestsAction.Request actionCallback(String className) {
        return null;
    }
    global copado.RunTestsAction.Request context(List<Id> ids) {
        return null;
    }
    global copado.RunTestsAction.Request createConsolidatedResult(Boolean createConsolidatedResult) {
        return null;
    }
    global copado.RunTestsAction.Request environment(String id) {
        return null;
    }
    global copado.RunTestsAction.Request extensionConfigurationId(String id) {
        return null;
    }
    global copado.RunTestsAction.Request propertiesOverride(String json) {
        return null;
    }
    global copado.RunTestsAction.Request result(Id resultId) {
        return null;
    }
    global copado.RunTestsAction.Request tool(String testTool) {
        return null;
    }
    global copado.RunTestsAction.Request type(String testType) {
        return null;
    }
}
global class Response {
    @InvocableVariable(label='Job Execution' description='Job Execution record for the Run Test Action' required=false)
    global copado__JobExecution__c jobExecution;
}
}
