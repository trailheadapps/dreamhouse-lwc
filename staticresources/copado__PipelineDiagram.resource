var $copado = $copado || jQuery.noConflict();
var pipelineDashboard = pipelineDashboard || {};
pipelineDashboard.data = pipelineDashboard.data || {};
pipelineDashboard.data.map = pipelineDashboard.data.map || new Map();
pipelineDashboard.data.selection = pipelineDashboard.data.selection || new Map();
pipelineDashboard.config = pipelineDashboard.config || {};
pipelineDashboard.labels = pipelineDashboard.labels || {};
pipelineDashboard.canvas = {};

pipelineDashboard.data.stepNames = pipelineDashboard.data.stepNames || [];

pipelineDashboard.parseTemplates = function(){
    pipelineDashboard.data.templateObj = JSON.parse(pipelineDashboard.data.templateJSOn);
    pipelineDashboard.data.map.clear();
    const mapSteps = new Map(Object.entries(pipelineDashboard.data.templateObj));
    pipelineDashboard.processStepsJSON(mapSteps);

};

pipelineDashboard.selectTemplate = function(){
    pipelineDashboard.data.selection.clear();
    pipelineDashboard.data.map.forEach(function(value,key){
    	if(value.data.branch){
    		value.children.forEach(function(child,ckey){
    			var childDetails = new Map(Object.entries(child));
    			childDetails.forEach(function(inner_V,inner_K){
    				pipelineDashboard.data.selection.put(inner_V.data.branch,value.data.branch);
    			});
    		})
    	}
    });
    var object = {};
    pipelineDashboard.data.selection.forEach((value, key) => {
        var keys = key.split('.'),
            last = keys.pop();
        keys.reduce((r, a) => r[a] = r[a] || {}, object)[last] = value;
    });
    pipelineDashboard.data.selectedJSON = JSON.stringify(object);
    return false;
};

pipelineDashboard.processStepsJSON = function(stepMap){
    var key = stepMap.keys().next().value;
    var step = stepMap.get(key);
    pipelineDashboard.data.map.put(key,step);
    console.info('Appending environment box from object');
    step.children.forEach(function(element) {
        console.log('processStepsJSON :: element',element);
        if(element instanceof Object){
            console.log('processStepsJSON :: Object',element);
            var innerMap = new Map(Object.entries(element));
            pipelineDashboard.processStepsJSON(innerMap);
        }
    });
    pipelineDashboard.selectTemplate();
};