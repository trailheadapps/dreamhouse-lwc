/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CopadoSmartHelpController {
    global List<copado.CopadoSmartHelpController.SmartHelp> helpList {
        get;
        set;
    }
    global Boolean showTips {
        get;
        set;
    }
    global String tipKey {
        get;
        set;
    }
    global Boolean tipsAllowed {
        get;
        set;
    }
    global String tipType {
        get;
        set;
    }
    global String tipValue {
        get;
        set;
    }
    global String vfPageName {
        get;
        set;
    }
    global CopadoSmartHelpController() {

    }
    global System.PageReference removeTip() {
        return null;
    }
    global System.PageReference setHelpList() {
        return null;
    }
    global System.PageReference setTypeList() {
        return null;
    }
global class SmartHelp {
    global String apiName {
        get;
        set;
    }
    global String helpText {
        get;
        set;
    }
    global String helpUrl {
        get;
        set;
    }
    global String label {
        get;
        set;
    }
    global String t_action {
        get;
        set;
    }
    global String t_value {
        get;
        set;
    }
    global SmartHelp(String apiName, String label, String t_action, String t_value, String helpText) {

    }
    global SmartHelp(String apiName, String label, String t_action, String t_value, String helpText, String helpUrl) {

    }
}
}
