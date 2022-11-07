var deploymentJobResults = deploymentJobResults || {};
deploymentJobResults.labels = deploymentJobResults.labels || {};

deploymentJobResults.labels.SELECTED = 'Select';
deploymentJobResults.labels.LEVELHEADER = 'Level';//UCU made it LEVELHEADER, cause LEVEL keyword does not work for some reason, possible reserved keyword on the process by jqx maybe.
deploymentJobResults.labels.MESSAGE = 'Message';
deploymentJobResults.labels.COPADOTIP = 'Copado Tip';
deploymentJobResults.labels.NO_STEP_RESULTS_FOUND = 'No results found';
deploymentJobResults.labels.MISSING_PARAMS = 'The deploymentId or jobId parameters were not found.';

deploymentJobResults.init = function(deploymentId, jobId, stepName, orgName) {
	stepName = (stepName!=null)? stepName : '';
	orgName = (orgName!=null)? orgName : '';

	$copado('#stepName').text(stepName);
	$copado('#orgName').text(orgName);

	// get job results
	try {
		if(!deploymentId || !jobId) {
			deploymentJobResults.showMessage('ERROR', deploymentJobResults.labels.MISSING_PARAMS);
			$copado('#loading').hide();
			return false;
		}
		deploymentJobResults.getJobResult(deploymentId, jobId);
	}
	catch (e) {
		console.error('Error: ', e);
		unlockScreen();
	}
};
deploymentJobResults.getJobResult = function(deploymentId, jobId) {
	console.log('Getting Job Result: ', deploymentId, jobId);
	lockScreen();
	try {
		var result = JsRemoting.attachments.getLatestDeploymentJobResult(deploymentId, jobId);

		if (result != null) {
			var jsonData = $copado.parseJSON(result.Body);
			if (jsonData.length > 0) {
				var $container = $copado('#stepResult');
				deploymentJobResults.createResultTable(jsonData, $container);
				unlockScreen();
			}
			else {
				$container.append('<center><i class="empty-msg">' + deploymentJobResults.labels.NO_STEP_RESULTS_FOUND + '</i></center>');
			}
		}
		else {
			deploymentJobResults.showMessage('INFO', deploymentJobResults.labels.NO_STEP_RESULTS_FOUND);
			$copado('#loading').hide();
			unlockScreen();
		}
	}
	catch (e) {
		console.error('Error: ', e);
		$copado('#loading').hide();
		unlockScreen();
	}
};
deploymentJobResults.createResultTable = function(res, $container) {
	for(var i=0; i<res.length; i++){
		res[i].b = false;
	}

	function escapeHtml(unsafe) {
        return unsafe
             .replace(/&/g, "&amp;")
             .replace(/</g, "&lt;")
             .replace(/>/g, "&gt;")
             .replace(/"/g, "&quot;")
             .replace(/'/g, "&#039;");
     }

    console.log('------ res: ', res);
	var source2 = {
		localdata: res,
		datafields: [,{
			name: 'l',
			type: 'string'
		}, {
			name: 'm',
			type: 'string'
		}, {
			name: 't',
			type: 'string'
		}],
		datatype: "array"
	};
	//adapter wrapper
	dataAdapter2 = new $copado.jqx.dataAdapter(source2),

	//keep jquery pointer for performance query
	$grid2 = $copado('<div>');

	$container.append($grid2);

	var preRender = function(row, column, value) {
		return '<pre class="co-preCell">' + value + '</pre>';
	};

	var height = utilsV2.getUrlParameter('height');
	height = (height)?height:500;

	var pageSize = utilsV2.getUrlParameter('pageSize');
	pageSize = (pageSize)?parseInt(pageSize):200;

	$grid2.jqxGrid({
		width: '100%',
        source: dataAdapter2,
        showfilterrow: true,
        filterable: true,
        theme: 'base',
        editable: false,
        scrollmode: 'logical',
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '20', '50', '100', '200', '500', '1000', '2000', '5000'],
        pagesize: 20,
        sortable: true,
        columnsresize: true,
        autorowheight: true,
        autoheight: true,
        altrows: true,
        localization: localizationobj,
		columns: [
            {
                text: deploymentJobResults.labels.LEVELHEADER,
                columntype: 'textbox',
                filtertype: 'textbox',
                datafield: 'l',
                width: '10%'
            }, {
                text: deploymentJobResults.labels.MESSAGE,
                columntype: 'textbox',
                filtertype: 'input',
                datafield: 'm',
                cellsrenderer: preRender,
                width: '70%'
            }, {
                text: deploymentJobResults.labels.COPADOTIP,
                datafield: 't',
                filtertype: 'textbox',
                filtercondition: 'contains',
                columntype: 'textbox',
                cellsrenderer: preRender,
                width: '20%'
            }
        ]
	});

	var filtergroup2 = new $copado.jqx.filter();
	var filter2 = filtergroup2.createfilter('booleanfilter', false, 'EQUAL');
	filtergroup2.addfilter(1, filter2);
	$grid2.jqxGrid('clearfilters');
	$grid2.jqxGrid('addfilter', 'b', filtergroup2);
	$grid2.jqxGrid('applyfilters');

	$copado('#loading').hide();
	if(ga)ga('send', 'event', 'Deployment Result Page', 'result', 'render', res.length);
};
deploymentJobResults.showMessage = function(type, msg) {
	$copado('.fixedMsg')
		.html($copado('[id$=js-msg-'+type+']').html().replace('__MSG__', msg));
};