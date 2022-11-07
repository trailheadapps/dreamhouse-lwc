/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RefreshFeatures {
    global RefreshFeatures() {

    }
    @InvocableMethod(label='Refresh Features' description='')
    global static List<copado.RefreshFeatures.Response> execute(List<copado.RefreshFeatures.Request> requests) {
        return null;
    }
global class Request {
    @InvocableVariable( required=false)
    global Boolean syncOnPremiseDeployer;
    @InvocableVariable( required=false)
    global Boolean syncVlocity;
    global Request() {

    }
}
global class Response {
    @InvocableVariable( required=false)
    global String message;
    @InvocableVariable( required=false)
    global Boolean success;
    global Response() {

    }
}
}
