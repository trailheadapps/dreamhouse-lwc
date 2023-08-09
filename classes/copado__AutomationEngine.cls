/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutomationEngine {
    global AutomationEngine() {

    }
    @InvocableMethod(label='Execute Automation')
    global static List<copado.AutomationEngine.AutomationEngineResponse> execute(List<copado.AutomationEngine.AutomationEngineRequest> requests) {
        return null;
    }
global class AutomationEngineRequest extends copado.EngineRequest {
    @InvocableVariable(label='Automation Event' required=true)
    global String automationEventId;
    global AutomationEngineRequest() {

    }
}
global class AutomationEngineResponse extends copado.EngineResponse {
    @InvocableVariable(label='Status' required=false)
    global String status;
    global AutomationEngineResponse() {

    }
}
}
