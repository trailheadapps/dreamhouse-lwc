/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class UserStoryCounter {
    global UserStoryCounter() {

    }
    @InvocableMethod(label='Get User Story Count' description='Gets the number of user stories ahead or behind (based on the provided type parameter), for the given pipeline and environment')
    global static List<Integer> getUserStoryCount(List<copado.UserStoryCounter.InvocableVariables> variables) {
        return null;
    }
global class InvocableVariables {
    @InvocableVariable(label='Environment Id' required=true)
    global Id environmentId;
    @InvocableVariable(label='Pipeline Id' required=true)
    global Id pipelineId;
    @InvocableVariable(label='Type (Ahead / Behind)' required=true)
    global String type;
    global InvocableVariables() {

    }
}
}
