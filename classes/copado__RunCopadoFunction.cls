/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RunCopadoFunction {
    global RunCopadoFunction() {

    }
    @InvocableMethod(label='Invoke Copado Function' description='Invokes a Copado Function that sends a callout to the desired backend endpoint.')
    global static List<String> execute(List<copado.RunCopadoFunction.InvocableVariables> variables) {
        return null;
    }
global class InvocableVariables {
    @InvocableVariable(label='Context Id' required=false)
    global String contextId;
    @InvocableVariable(label='Function API Name' required=true)
    global String functionApiName;
    @InvocableVariable(label='Options' required=false)
    global List<copado.Parameter> options;
    @InvocableVariable(label='Options (JSON)' required=false)
    global String optionsJSON;
    @InvocableVariable(label='Parameters' required=false)
    global List<copado.Parameter> parameters;
    @InvocableVariable(label='Parameters (JSON)' required=false)
    global String parametersJSON;
    @InvocableVariable(label='Result Apex Callback' required=false)
    global String resultCallback;
    @InvocableVariable(label='Show Validation Errors' description='If set to true, throws an error when the validation fails' required=false)
    global Boolean showValidationErrors;
    global InvocableVariables() {

    }
}
}
