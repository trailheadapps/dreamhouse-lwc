/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CreatePromotedUserStories {
    global CreatePromotedUserStories() {

    }
    @InvocableMethod(label='Create Promoted User Stories' description='Creates promoted user stories under given Promotion record.')
    global static List<SObject> execute(List<copado.CreatePromotedUserStories.InvocableVariables> variables) {
        return null;
    }
global class InvocableVariables {
    @InvocableVariable(label='Promotion Id' required=false)
    global Id promotionId;
    @InvocableVariable(label='User Story Ids' required=true)
    global List<Id> userStoryIds;
    global InvocableVariables() {

    }
}
}
