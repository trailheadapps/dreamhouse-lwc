/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ExportAutomationTemplate {
    global ExportAutomationTemplate() {

    }
    @InvocableMethod(label='Export Automation Template' description='Export Automation template record with related steps')
    global static List<String> execute(List<copado.ExportAutomationTemplate.InvocableVariables> variables) {
        return null;
    }
global class InvocableVariables {
    @InvocableVariable(label='Automation Template Id' required=true)
    global Id automationTemplateId;
    @InvocableVariable(label='Automation Template Name' required=false)
    global String automationTemplateName;
    global InvocableVariables() {

    }
}
}
