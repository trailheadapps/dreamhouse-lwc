var seleniumSettings = seleniumSettings || {};
seleniumSettings.config = seleniumSettings.config || {};
seleniumSettings.data = seleniumSettings.data || {};
seleniumSettings.providerSelector = seleniumSettings.providerSelector || {};
seleniumSettings.template = seleniumSettings.template || {};
seleniumSettings.grid = seleniumSettings.grid || {};

seleniumSettings.labels = seleniumSettings.labels || {};

seleniumSettings.config.url = '';
seleniumSettings.config.GRID_DIV_ID = 'jqxGrid';
seleniumSettings.data.hasPreviousSelected = false;
seleniumSettings.data.selections = '';
seleniumSettings.data.platforms = [];
seleniumSettings.data.selectedProvider = '';
seleniumSettings.data.gridSelections = [];
seleniumSettings.data.gridDataSource = {};

seleniumSettings.labels.SELECTED = 'Selected';
seleniumSettings.labels.OS = 'OS';
seleniumSettings.labels.OS_VERSION = 'OS Version';
seleniumSettings.labels.BROWSER = 'Browser';
seleniumSettings.labels.BROWSER_VERSION = 'Browser Version';
seleniumSettings.labels.DEVICE = 'Device';
seleniumSettings.labels.RESOLUTION = 'Resolution';
seleniumSettings.labels.SELECTALL = 'Select All';
seleniumSettings.labels.UNSELECTALL = 'Unselect All';


seleniumSettings.providerSelector.CUSTOM_DIV_ID = 'customPlatformWrapper';
seleniumSettings.providerSelector.isVisible = false;
seleniumSettings.providerSelector.isCustom = false;



seleniumSettings.doCallout = function(){
	var _tmp = seleniumSettings.data.selectedProvider.replace(new RegExp(' ','g'),'').toLowerCase();
	if(_tmp==''||_tmp=='custom/other'){
		seleniumSettings.providerSelector.isCustom = true;
		seleniumSettings.providerSelector.hide();
		seleniumSettings.providerSelector.showCustom();
		return false;
	}
	var url = seleniumSettings.config.herokuServer+'/json/v1/getBrowserList/'+seleniumSettings.data.selectedProvider.replace(new RegExp(' ','g'),'').toLowerCase() + copadoApp.urlParameters;
	console.log('Calling Heroku', url);
	utilsV2.method = 'GET';
	utilsV2.onFailureCB = function(res){
		seleniumSettings.providerSelector.hide();
		alert(res);
	};
	utilsV2.onSuccessCB = function(res){
		seleniumSettings.grid.init(res);
	};
	seleniumSettings.providerSelector.loading();
	utilsV2.getRemote(url);
};
seleniumSettings.getPlatforms = function(sel){
	seleniumSettings.data.selectedProvider = sel.value;
	console.info('Selected Platform: '+seleniumSettings.data.selectedProvider);
	if(seleniumSettings.data.selectedProvider==''){
		seleniumSettings.providerSelector.hideCustom();
		return;
	}
	if(seleniumSettings.data.selectedProvider=='custom/other' || (seleniumSettings.data.selectedProvider!='Browser Stack' && seleniumSettings.data.selectedProvider!='Sauce Labs')){
		seleniumSettings.providerSelector.isCustom = true;
		seleniumSettings.providerSelector.hide();
		seleniumSettings.providerSelector.showCustom();
		return;
	}
	seleniumSettings.providerSelector.isCustom = false;
	seleniumSettings.providerSelector.hideCustom();	
	seleniumSettings.providerSelector.loading();

	seleniumSettings.doCallout();
};
seleniumSettings.grid.init = function(data){
	if(!data || data.length==0)return;
	var _odata = JSON.parse(data);
	try{
		var _selections = (seleniumSettings.data.selections.length>0)?JSON.parse(seleniumSettings.data.selections) : [];
		seleniumSettings.data.hasPreviousSelected = _selections.length>0;
		var _mergedData = seleniumSettings.grid.mergeData(_odata, _selections);
		seleniumSettings.grid.start(_mergedData, false);
		seleniumSettings.providerSelector.show();
	}
	catch(e){
		console.error(e);
	}
};
seleniumSettings.grid.mergeData = function(data, selections){
	var len = selections.length;
						 
	while(len--){
		if(typeof selections[len] !== 'object'){
			delete selections[len];
		}else{
			selections[len].s =true;
		}
	}

	var len2 = selections.length;
	for(var i = 0; i < len2 ; i++){
		var el = selections[i];

		var index = seleniumSettings.grid.getIndexByBR(data, el.o, el.ov, el.b, el.bv, el.d, el.r);
		if(index > -1){
			data[index].s = true;
		}
		else{
			if(typeof(window._errNotFoundShown) == 'undefined' ){
				window._errNotFoundShown = true;
				alert(copadoLabels.missing_element_msg+' OS:'+el.o+' ('+el.ov+') '+el.b+' ('+el.bv+') '+' '+el.d+' '+el.r);
			}
		}
	}
	return data;
};
seleniumSettings.grid.start = function(res, isReadOnly){
	if(!res || res.length==0)return;

	seleniumSettings.data.platforms = res;

	try{    
		var theme = 'base',
		
		source = {
			localdata: seleniumSettings.data.platforms,
			datafields: [
				{ name: 's', type: 'bool' },
				{ name: 'o', type: 'string' },
				{ name: 'ov', type: 'string' },
				{ name: 'b', type: 'string' },
				{ name: 'bv', type: 'string' },
				{ name: 'd', type: 'string' }, 
				{ name: 'r', type: 'string' }
			],
			datatype: 'array',
			updaterow: function (rowid, rowdata, commit) {
				commit(true);
				seleniumSettings.data.platforms[rowid] = rowdata;
			}
		};
		seleniumSettings.data.gridDataSource = source.localdata;

		//adapter wrapper
		dataAdapter = new $copado.jqx.dataAdapter(source);
		
		//keep jquery pointer for performance query
		$grid = $copado('<div>');
		
		$copado('#'+seleniumSettings.config.GRID_DIV_ID).html($grid);
		
		var height = utilsV2.getUrlParameter('height');
		height = (height)?height:500;
	
		var pageSize = utilsV2.getUrlParameter('pageSize');
		pageSize = (pageSize)?parseInt(pageSize):200;

		var _columns = [];
		if(isReadOnly){
			_columns = [
				{ text:seleniumSettings.labels.OS, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'o' },
				{ text:seleniumSettings.labels.OS_VERSION, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'ov' },
				{ text:seleniumSettings.labels.BROWSER, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'b' },
				{ text:seleniumSettings.labels.BROWSER_VERSION, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'bv' },
				{ text:seleniumSettings.labels.DEVICE, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'d' },
				{ text:seleniumSettings.labels.RESOLUTION, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'r', minwidth:120 }
			];
		}
		else{
			_columns = [
				{ text:seleniumSettings.labels.SELECTED, filtertype:'bool', editable:true, columntype:'checkbox', datafield:'s', width:80},
				{ text:seleniumSettings.labels.OS, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'o' },
				{ text:seleniumSettings.labels.OS_VERSION, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'ov' },
				{ text:seleniumSettings.labels.BROWSER, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'b' },
				{ text:seleniumSettings.labels.BROWSER_VERSION, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'bv' },
				{ text:seleniumSettings.labels.DEVICE, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'d' },
				{ text:seleniumSettings.labels.RESOLUTION, filtertype:'textbox', filtercondition:'contains', editable:false, columntype:'string', datafield:'r', minwidth:120 }
			];
		}

		var dataAdapter = new $copado.jqx.dataAdapter(source);
		$grid.jqxGrid({
			width: '100%',
			height: height,
			source: dataAdapter,
			showfilterrow: true,
			filterable: true,
			theme: theme,
			editable: true, 
			selectionmode: 'none',
			enablebrowserselection: true,
			pageable: true,
			pagesizeoptions: ['10', '20', '50','100','200','500','1000','2000','5000'],
			pagesize: pageSize,
			sortable: true,
			columnsresize: true,
			localization: localizationobj,
			columns: _columns,
			ready: function() {
				console.log('ready grid event');
				!isReadOnly && seleniumSettings.data.hasPreviousSelected && seleniumSettings.grid.addSelectedFilter($grid);
			}
		});

		if(isReadOnly==false){
			var selectAll = function(sel){
				$grid.jqxGrid('beginupdate');
				var list = $grid.jqxGrid('getrows');
				for(var i in list){
					source.localdata[ list[i].dataindex || i ].s = sel;
				}
			
				$grid.jqxGrid('endupdate');
				setTimeout(function(){$grid.jqxGrid('updatebounddata','cells');},222);
			},
			
			$unselectAll = $copado('<button id="btnUnselectAll">'+seleniumSettings.labels.UNSELECTALL+'</button>').
				on('click',function(e){
					e.preventDefault();
					selectAll(false);
				}),
			
			$selectAll = $copado('<button id="btnSelectAll">'+seleniumSettings.labels.SELECTALL+'</button>').
				on('click', function(e){
					e.preventDefault();
					selectAll(true);
				});
	   
			$copado('.jqx-grid-pager > div')
				.prepend($unselectAll)
				.prepend($selectAll);
		}
	}
	catch(e){
		console.error(e);
	}
};
seleniumSettings.grid.addSelectedFilter = function($grid){
	try {
		console.log('Add selected fiter ', $grid);
		var filtergroup2 = new $copado.jqx.filter();
		var filter2 = filtergroup2.createfilter('booleanfilter', true, 'EQUAL');
		filtergroup2.addfilter(1, filter2);
		$grid.jqxGrid('clearfilters');
		$grid.jqxGrid('addfilter', 's', filtergroup2);
		$grid.jqxGrid('applyfilters');
	}
	catch (e) {
		console.error('addfilter', e);
	}
};
/**
      * helper to find index items by browser and resolution
      * @param  {[type]} arr [description]
      * @param  {[type]} b   [description]
      * @param  {[type]} r   [description]
      * @return {[type]}     [description]
      */
seleniumSettings.grid.getIndexByBR = function(arr, o, ov, b, bv, d, r){
	var initialIndex =  0 ;
	len = arr.length;
	 
	for(initialIndex; initialIndex < len; initialIndex++){
	    var el = arr[initialIndex];
	    try{ 
		    if(el.o==o && el.ov==ov && el.b===b && el.bv===bv && el.d===d && el.r===r){
		        this.initialIndex = initialIndex;
		        return initialIndex;
		    }
	    }
	    catch(e){
	        console.error(e);
	        return -1;
	    }
	}
	return -1;
};
/**
      * helper to find get grid selections
      * @return {[type]}     [description]
      */
seleniumSettings.grid.getGridSelections = function(){
	if(seleniumSettings.data.gridDataSource && seleniumSettings.data.gridDataSource.length>0){
		var data = seleniumSettings.data.gridDataSource, 
		len = data.length;

		seleniumSettings.data.gridSelections = [];

		while(len--){
			var o = {s:true, o:data[len].o, ov:data[len].ov, b:data[len].b, bv:data[len].bv, d:data[len].d, r:data[len].r};
			data[len].s && seleniumSettings.data.gridSelections.push(o);
		}
		return seleniumSettings.data.gridSelections;
	}
};
seleniumSettings.grid.setSaveValues = function(retUrl){
	seleniumSettings.grid.getGridSelections();
	if(seleniumSettings.data.selectedProvider!='' && seleniumSettings.data.selectedProvider!='Custom/Other' && seleniumSettings.data.gridSelections.length==0){
		console.log(seleniumSettings.data.selectedProvider, seleniumSettings.grid.getGridSelections);
		alert('You must select at least one platform to test before saving this record.');
		return false;
	}
	else if(seleniumSettings.data.selectedProvider=='Browser Stack' || seleniumSettings.data.selectedProvider=='Sauce Labs'){
		$copado('textarea[class$="js-selectedPlatforms"]').val(JSON.stringify(seleniumSettings.data.gridSelections));
	}
	//retUrl parameter is for editSeleniumSettingOverride page
	retUrl ? doSalesforceSave(retUrl) : doSalesforceSave();
};


seleniumSettings.providerSelector.show = function(){
	seleniumSettings.providerSelector.isVisible = true;
	$copado('#'+seleniumSettings.config.GRID_DIV_ID).show();
};
seleniumSettings.providerSelector.hide = function(){
	seleniumSettings.providerSelector.isVisible = false;
	$copado('#'+seleniumSettings.config.GRID_DIV_ID).hide();
};
seleniumSettings.providerSelector.loading = function() {
	seleniumSettings.providerSelector.isVisible = false;
	var loadingHTML = '<center><img src="/img/loading.gif" /> <i>' + copadoLabels.loading + '<span id="retry-label"></span></i></center>';
	seleniumSettings.providerSelector.show();
	$copado('#'+seleniumSettings.config.GRID_DIV_ID).html(loadingHTML);
};
seleniumSettings.providerSelector.hideCustom = function(){
	seleniumSettings.providerSelector.isCustom = false;
	$copado('#'+seleniumSettings.providerSelector.CUSTOM_DIV_ID).hide();
};
seleniumSettings.providerSelector.showCustom = function(){
	seleniumSettings.providerSelector.isCustom = true;
	$copado('#'+seleniumSettings.providerSelector.CUSTOM_DIV_ID).show();
}
