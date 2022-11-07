/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RunDeployPromotion {
    global RunDeployPromotion() {

    }
    @InvocableMethod(label='Deploy a Promotion' description='Sends request to given Copado webhookUrl')
    global static void execute(List<copado.RunDeployPromotion.InvocableVariables> variables) {

    }
global class InvocableVariables {
    @InvocableVariable(label='Is Check Only?' required=true)
    global Boolean checkOnly;
    @InvocableVariable(label='Deployment Name' required=true)
    global String deploymentName;
    @InvocableVariable(label='Promotion Id' required=true)
    global Id promotionId;
    @InvocableVariable(label='Test Level' required=true)
    global String testLevel;
    global InvocableVariables() {

    }
}
}
