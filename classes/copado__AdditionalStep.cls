/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AdditionalStep {
    @InvocableVariable( required=false)
    global List<copado__JobStep__c> postSteps;
    @InvocableVariable( required=false)
    global List<copado__JobStep__c> preSteps;
    @InvocableVariable( required=false)
    global String state;
    global AdditionalStep(String state) {

    }
    global AdditionalStep(String state, List<copado__JobStep__c> preSteps, List<copado__JobStep__c> postSteps) {

    }
}
