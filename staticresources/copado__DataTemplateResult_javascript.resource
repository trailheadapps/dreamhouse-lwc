// Data Template Object Result Javascript
var dtor = dtor || {};

((app) => {
    'use strict';
    app.navigateToRecord = (id, sourceTargetURL) => {
        var sourceTargetUrlMap = JSON.parse(objDataTemplateResultVars.sourceTarget);
        return window.open(sourceTargetUrlMap[sourceTargetURL] + id, '_blank');
    };

    var jqxLoading = () => {
        var loadingHTML = '<center><img src="/img/loading.gif" /> <i>' + copadoLabels.loading +'<span id="retry-label"></span></i></center>';
        $copado('#jqxgrid').html(loadingHTML);
    };

    var noDataToDisplay = () => {
        var noDataHtml = '<center>' + copadoLabels.noDataToDisplay + '</center>';
        $copado('#jqxgrid').html(noDataHtml);
    };

    var prepareGrid = () => {
        var att = dw.u.getDecodedAttach(objDataTemplateResultVars.depId, objDataTemplateResultVars.attName + '.json');
        if(att){
            var body = att.Body;
            try{
                var metadataRecords = JSON.parse(body);
                startGrid(metadataRecords);
            } catch(e){
                console.error(e);
                noDataToDisplay();
            }
        } else {
            noDataToDisplay();
        }
    };
    var startGrid = (data) => {
        try{
            //normalize data
            var len = data.length;
            var cellsIconStatus = function(row, column, value, defaultHtml) {
                var element = $copado(defaultHtml);
                var icon = value === 'Success' ? 'check.png' : value === 'Error' ? 'cross.png' : value === 'Warning' ? 'warning.png' : 'warning.png';
                var iconurl = objDataTemplateResultVars.imagesURL + icon;

                element.html('<img src="' + iconurl + '" style="height: 20px ;width: 20px;margin-left: 5px;"/>');
                return element[0].outerHTML;
            }
            var cellsNavigateToRecord = function (row, column, value, defaultHtml) {
                var element = $copado(defaultHtml);
                var sourceTarget = column === 'sourceRecordId' ? 'source' : 'target';
                element.html('<a href="#" onclick="dtor.navigateToRecord(\'' + value + '\', \'' + sourceTarget + '\');return false;">' + value + '</a>');
                return element[0].outerHTML;
            };

            var columnNames = ['sourceRecordId', 'destinationRecordId', 'status', 'errorMessage'];
            var _datafields = [];

            var columns = [
                {text: 'Source Record ID', filtertype: 'textbox', filtercondition: 'contains', editable: false, datafield: 'sourceRecordId', cellsrenderer: cellsNavigateToRecord, width: '180px'},
                {text: 'Target Record ID', filtertype: 'textbox', filtercondition:  'contains', editable: false, datafield: 'destinationRecordId',cellsrenderer: cellsNavigateToRecord, width: '180px'},
                {text: 'Status', filtertype: 'checkedlist', editable: false, cellsalign: 'center', datafield: 'status', cellsrenderer: cellsIconStatus, width: '130px'},
                {text: 'Error Message', filtertype: 'textbox', filtercondition: 'contains', editable: false, datafield: 'errorMessage'}
            ];

            for(var c = 0; c < columnNames.length; c++ ){
                var df = {};
                df.name = columnNames[c];
                df.type = 'string';
                _datafields.push(df);
            }

            var theme = 'base',
            source = {
                localdata: data,
                datafields: _datafields,
                datatype: "array",
                updaterow: function (rowid, rowdata, commit) {
                    data[rowid] = rowdata;
                    commit(true);
                }
            },
            //adapter wrapper
            dataAdapter = new $copado.jqx.dataAdapter(source),

            //keep jquery pointer for performance query
            $grid = $copado('<div>');

            $copado("#jqxgrid").html($grid);

            $grid.jqxGrid({
                width: '100%',
                autoheight: true,
                source: dataAdapter,
                showfilterrow: true,
                filterable: true,
                theme: theme,
                editable: false,
                selectionmode: 'none',
                enablebrowserselection: true,
                pageable: true,
                pagesizeoptions: ['10', '20', '50','100','500'],
                pagesize: 20,
                sortable: true,
                columnsresize: true,
                localization: localizationobj,
                columns: columns
            });
        } catch(e){
            console.error('error',e);
            noDataToDisplay();
        }
    };

    $(document).ready(() => {
        jqxLoading();
        prepareGrid();
    });
})(dtor);