var variableLookup = variableLookup || {};
variableLookup.bindings = variableLookup.bindings || {};
variableLookup.data = variableLookup.data || {};

variableLookup.data.destinationOrg = [];
variableLookup.data.copadoOrg = [];
variableLookup.data.deployment = [];
variableLookup.data.resumeUrl = [];

variableLookup.data.destinationOrg = [
    {label: 'Org Id', value: 'DestinationOrg.OrgId' },
    {label: 'Name', value: 'DestinationOrg.Name' },
    {label: 'Session Id', value: 'DestinationOrg.SessionId' },
    {label: 'Endpoint', value: 'DestinationOrg.Endpoint' },
    {label: 'Record Id', value: 'DestinationOrg.RecordId' }];
variableLookup.data.copadoOrg = [
    {label: 'Org Id', value: 'copadoOrg.OrgId' },
    {label: 'Name', value: 'copadoOrg.Name' },
    {label: 'Session Id', value: 'copadoOrg.SessionId' },
    {label: 'Endpoint', value: 'copadoOrg.Endpoint' }];
variableLookup.data.deployment = [
    {label: 'Name', value: 'Deployment.Name' },
	{label: 'Record Id', value: 'Deployment.RecordId' }];
variableLookup.data.resumeUrl = [
	{label: 'Resume URL', value: 'ResumeUrl'}];

variableLookup.bindings.bindActions = function(){
	variableLookup.bindings.bindLevel1();
	variableLookup.bindings.bindLevel2();
};
variableLookup.bindings.bindLevel1 = function(){
	$copado('#js-selectorLevel1').change(function(){
		var parent = $copado(this).val();
		switch(parent){
			case 'destinationOrg':
				variableLookup.bindings.listLevel2(variableLookup.data.destinationOrg);
				break;
			case 'copadoOrg':
				variableLookup.bindings.listLevel2(variableLookup.data.copadoOrg);
				break;
			case 'deployment':
				variableLookup.bindings.listLevel2(variableLookup.data.deployment);
				break;
			case 'resumeUrl':
				variableLookup.bindings.listLevel2(variableLookup.data.resumeUrl);
				break;
			default: //default child option is blank
				$copado('#js-selectorLevel2').html('');
				$copado('#js-copyValue').val('');
		}
	});
};
variableLookup.bindings.bindLevel2 = function(){
	$copado('#js-selectorLevel2').change(function(){
		var parent = $copado(this).val();
		if(parent!=''){
			$copado('#js-copyValue').val('{!'+parent+'}');
			$copado('#js-copyValue').select();
		}
		else{
			$copado('#js-copyValue').val('');
		}
	});
};
//function to populate child select box
variableLookup.bindings.listLevel2 = function(array_list){
    $copado('#js-selectorLevel2').html(''); //reset level 2 options
    $copado('#js-selectorLevel2').append('<option value=\"\">--Select--</option>');
    $copado(array_list).each(function (i) { //populate level2 options
        $copado('#js-selectorLevel2').append('<option value=\"'+array_list[i].value+'\">'+array_list[i].label+'</option>');
    });
};