/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ValidateOrgAction {
    global ValidateOrgAction() {

    }
    @InvocableMethod(label='Validate Org Credential' description='Checks if org credential is validated, if not, try to validate and return result')
    global static List<copado.ValidateOrgAction.Result> execute(List<copado.ValidateOrgAction.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable(label='Org Id' required=false)
    global String orgId;
    global Request() {

    }
}
global class Result {
    @InvocableVariable(label='Is Valid Org' required=false)
    global Boolean isValidOrg;
    global Result() {

    }
}
}
