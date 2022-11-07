/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CreatePromotions {
    global CreatePromotions() {

    }
    @InvocableMethod(label='Create Promotion' description='Creates promotion record and returns it.')
    global static List<SObject> execute(List<copado.CreatePromotions.InvocableVariables> variables) {
        return null;
    }
global class InvocableVariables {
    @InvocableVariable(label='Back Promotion' required=true)
    global Boolean backPromotion;
    @InvocableVariable(label='Destination Environment Id' required=true)
    global Id destinationEnvironmentId;
    @InvocableVariable(label='Order User Stories By' required=false)
    global String orderUserStoriesBy;
    @InvocableVariable(label='Project Id' required=false)
    global Id projectId;
    @InvocableVariable(label='Release Id' required=false)
    global Id releaseId;
    @InvocableVariable(label='Source Environment Id' required=true)
    global Id sourceEnvironmentId;
    global InvocableVariables() {

    }
}
}
