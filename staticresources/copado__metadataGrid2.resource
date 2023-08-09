function setWithoutRebinding(list, newList) {
    list.splice(0, list.length); // clear the array, without re-binding it.
    // NR: add elements in chunks, to avoid stack trace limits
    console.debug('setWithoutRebinding:::newList',Array.isArray(newList));
    if(!newList) newList = [];
    while (newList.length) {
        Array.prototype.push.apply(list, newList.splice(0, 10000));
    }
}

function MetadataGrid2(conf, cb) {
    this._initGrid(conf,cb);
    // Save the HTML for use in resetGrid
    this._initialHTML = this.eltMain.html();
}

MetadataGrid2.prototype._initGrid = function(conf, cb) {
    this.conf = conf;

    this.conf.gridMode = this.conf.gridMode || 'orgMetadata'; // grid mode affects the behavior of the loading, rendering columns, and saving.
    this.isMetadataGrid = this.conf.gridMode === 'orgMetadata';
    this.conf.dxGridType = this.conf.dxGridType || ''; // dx grid type affects columns for dx pages.

    console.debug('_initGrid()', this.conf.gridMode, this.isMetadataGrid);
    //console.assert(this.conf.data.orgId, "MetadataGrid2.init: config had no orgId"); MY: With DX orgId is not required.

    this.allMetaData = [];
    this.types = [];
    this.selectedMetadata = []; // selected items, referencing this.allMetaData
    this.allMetaData_cachedDate = '';

    //this.conf.isScalable = false; // true for having the filter INSIDE the grid, not as a combobox
    this.isTypeFilterable = this.conf.isScalable; // true for having the filter INSIDE the grid, not as a combobox
    console.debug('MetadataGrid2() conf.isScalable', this.conf.isScalable);

    this.TypeFilterType = 'checkedlist';
    this.filterByType = ''; // null means: no filter selected
    this.filterByTypeList = [];
    this.filterByTypeSelectedIndex = 0;
    this.savedFilters = null;

    this.isRendered = false;
    this.eltGrid = null;
    this.eltMetaDataTypeFilter = null;
    this.eltTabs = null;
    this.dependencyRetrieveArray = [];

    this.conf.eltMainId = this.conf.eltMainId || 'metadataGrid2'; // overridable main ID
    this.eltMain = $copado('#'+this.conf.eltMainId);
    console.assert(this.eltMain.length);

    if (this.conf.isScalable) this.eltMain.find('.mg2_scaleFilterFrame').show();
    else this.eltMain.find('.mg2_scaleFilterFrame').hide();

    if(this.conf.gridMode==='Translations') {
        // translations are never filterable by type. They will be manually filtered later
        this.isTypeFilterable = false;
        this.filterByType = 'Translations';
        this.eltMain.find('.mg2_scaleFilterFrame').hide();
    }

    cb && cb();
};

// Resets the grid
MetadataGrid2.prototype.resetGrid = function(conf) {
    console.debug('MetadataGrid2.resetGrid()');
    this.eltMain.html(this._initialHTML);
    this._initGrid(conf);
};

// selects/deselects a bunch of elements.
MetadataGrid2.prototype._setSelectionState = function(selected, elts, calledFromSelectAll, rowdata) {
    // NR: we need to translate the elts list to the real elts for (un)selectAll
    var i,
        e,
        t,
        idx_allItems = null;
    if(calledFromSelectAll) {
        idx_allItems = {};
        for(i=0 ; i < this.allMetaData.length ; i++ ) {
            e = this.allMetaData[i];
            idx_allItems[e.t+' '+e.n] = e;
        }
    }

    // locate each elt in the
    var tipTypes = [];
    for(i=0 ; i < elts.length ; i++) {
        e = elts[i];
        if(idx_allItems) {
            e =  idx_allItems[elts[i].t+' '+elts[i].n];
            if (!e) continue; // the element selected might not be in allMetaData, just ignore it.
        }
        e.s = selected;
        if (typeof showTip !== 'undefined' && showTip && selected && tipTypes.indexOf(e.t) < 0) {
            showTip(e.t, e.n);
           tipTypes.push(e.t);
        }

        var existsInSelected = this.selectedMetadata.indexOf(e);
        if(selected && existsInSelected===-1) {
            this.selectedMetadata.push(e);
        }else if(!selected && existsInSelected>-1) {
            this.selectedMetadata.splice(existsInSelected,1);
        }
        // little hack to allow actually clicking on "r" and setting s, and saving
        if( this.conf.gridMode === 'gitCommit') {
            if (rowdata) e.r = rowdata.r;
            if (calledFromSelectAll && !selected) e.r = false;
        }
    }
    var currentTab = this.eltTabs.jqxTabs('selectedItem');
    if(currentTab && currentTab !== 2) {
        // visual feedback, flashing the tab
        var elt = this.eltMain.find('.mg2_tabs li').get(1);
        elt.style.animation = '';
        setTimeout(function() {
            elt.style.animation = 'flash 2s 1';
        }, 5);
    }
    // fire a custom event telling the selection changed.
    var event = new CustomEvent('copadoMetadataGrid2Changed', { detail: { metadataGrid2: this } });
    document.dispatchEvent(event);
};

// forces filtering by the type currently selected
MetadataGrid2.prototype._setGridFiltersByType = function() {
    var that = this;
    var isTranslationsMode = this.conf.gridMode==='Translations';
    if(this.isTypeFilterable || isTranslationsMode) {
        if(isTranslationsMode) {
            that.filterByType = 'Translations';
            console.debug('_setGridFiltersByType() translations');
        }
        that.eltGrid.jqxGrid('removefilter', 't');
        /*var group = new $copado.jqx.filter();
        var filter = group.createfilter('stringfilter', that.filterByType, 'contains');
        group.addfilter(0, filter);

        that.eltGrid.jqxGrid('addfilter', 't', group);
        that.eltGrid.jqxGrid('applyfilters');*/
    }
};
MetadataGrid2.prototype._reapplyFilters = function(tabIndex) {
    var that = this;
    if (tabIndex === undefined && this.eltTabs) tabIndex = this.eltTabs.jqxTabs('selectedItem');

    //console.debug('_reapplyFilters()', tabIndex, that.savedFilters);
    if(tabIndex === 0) {
        // Filter by TYPE
        that.eltGrid.jqxGrid('setcolumnproperty', 's', 'filterable', true);
        that.eltGrid.jqxGrid('removefilter', 's');
        that.eltGrid.jqxGrid('applyfilters');
        if (that.savedFilters) that.eltGrid.jqxGrid('loadstate', that.savedFilters);
        that._setGridFiltersByType();
    }else if(tabIndex === 1) {
        that.savedFilters = that.eltGrid.jqxGrid('getstate');
        // Filter by SELECTION, regardless of the type
        that.eltGrid.jqxGrid('clearfilters');
        that.eltGrid.jqxGrid('setcolumnproperty', 's', 'filterable', false);
        that.eltGrid.jqxGrid('addfilter', 's', that.jqxFilterBySelection);
        that.eltGrid.jqxGrid('applyfilters');
    } else if (tabIndex === 2 && that.conf.dxGridType == 'dxartifact') {
         that.savedFilters = that.eltGrid.jqxGrid('getstate');
         // Filter by SELECTION, regardless of the type
         that.eltGrid.jqxGrid('clearfilters');
         that.eltGrid.jqxGrid('setcolumnproperty', 'rd', 'filterable', false);
     }else{
        console.warn('uknown tab!');
        that.eltGrid.jqxTabs('select', 0);
    }
};

MetadataGrid2.prototype._getColumnsByGridMode = function() {
    var type = this.conf.gridMode;
    var dxType = this.conf.dxGridType;
    var columns;
    if (type == 'metadataselector') {
        columns = [
            {
            text: copadoLabels.selected,
            columntype: 'checkbox',
            filtertype: 'bool',
            datafield: 's',
            width: 60
        },
        {
            text: copadoLabels.name,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'n',
            width: 400
        },
        {
            text: copadoLabels.type,
            datafield: 't',
            filterable: !this.isTypeFilterable,
            filtertype: this.TypeFilterType,
            editable: false,
            columntype: 'textbox'
        },
        {
            text: copadoLabels.LASTMODIFIEDBY,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'b',
            width: 220
        },
        {
            text: copadoLabels.LastModifiedDate,
            filtertype: 'range',
            cellsformat: 'yyyy-MM-dd',
            editable: false,
            datafield: 'd',
            width: 120
        },
        {
            text: copadoLabels.CREATEDBY,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'cb',
            width: 220
        },
        {
            text: copadoLabels.CREATEDDATE,
            filtertype: 'range',
            cellsformat: 'yyyy-MM-dd',
            editable: false,
            datafield: 'cd',
            width: 120
        }
        ];
    } else if(type == 'testClasses'){
        columns = [
            {
                text: copadoLabels.selected,
                columntype: 'checkbox',
                filtertype: 'bool',
                datafield: 's',
                width: '10%'
            },
            {
                text: copadoLabels.name,
                filtertype: 'input',
                columntype: 'textbox',
                editable: false,
                datafield: 'n',
                width: '60%'
            },
            {
                text: copadoLabels.type,
                editable: false,
                width: '30%',
                filterable: false,
                cellsrenderer: function(){
                    return 'ApexClass';
                }
            }
        ];
    } else if(type === 'orgMetadata') {
        if(dxType === 'branches') {
            columns = [
                {
                    text: copadoLabels.selected,
                    filtertype: 'bool',
                    filterable: false,
                    datafield: 'select',
                    editable: false,
                    width: 60
                },
                {
                    text: copadoLabels.name,
                    filtertype: 'input',
                    columntype: 'textbox',
                    editable: false,
                    datafield: 'name',
                    width: '40%'
                },
                {
                    text: copadoLabels.type,
                    datafield: 'type',
                    filterable: !this.isTypeFilterable,
                    filtertype: this.TypeFilterType,
                    editable: false,
                    columntype: 'textbox',
                    width: '30%'
                },
                {
                    text: copadoLabels.LastModifiedDate,
                    filtertype: 'range',
                    editable: false,
                    datafield: 'lastUpdate',
                    cellsformat: 'yyyy-MM-dd',
                    width: '25%'
                }
            ];
        } else {
            columns = [
                {
                    text: copadoLabels.name,
                    filtertype: 'input',
                    columntype: 'textbox',
                    editable: false,
                    datafield: 'n'
                },
                {
                    text: copadoLabels.type,
                    datafield: 't',
                    filterable: !this.isTypeFilterable,
                    filtertype: this.TypeFilterType,
                    editable: false,
                    columntype: 'textbox',
                    width: 160
                },
                {
                    text: copadoLabels.LastModifiedById,
                    filtertype: 'input',
                    columntype: 'textbox',
                    editable: false,
                    datafield: 'b',
                    width: 120
                },
                {
                    text: copadoLabels.LastModifiedDate,
                    filtertype: 'range',
                    editable: false,
                    cellsformat: 'yyyy-MM-dd',
                    datafield: 'd',
                    width: 120
                },
                {
                    text: copadoLabels.CREATEDBY,
                    filtertype: 'input',
                    columntype: 'textbox',
                    editable: false,
                    datafield: 'cb',
                    width: 220
                },
                {
                    text: copadoLabels.CREATEDDATE,
                    filtertype: 'range',
                    editable: false,
                    datafield: 'cd',
                    cellsformat: 'yyyy-MM-dd',
                    width: 120
                }
            ];
        }
    } else if(type === 'gitCommit') {
        columns = [
            {
            text: copadoLabels.selected,
            columntype: 'checkbox',
            filtertype: 'bool',
            datafield: 's',
            width: 60
            },
            {
            text: copadoLabels.RETRIEVE_ONLY,
            columntype: 'checkbox',
            filterable: false,
            datafield: 'r',
            width: 85
            },
            {
            text: copadoLabels.name,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'n',
            width: '30%'
            },
            {
            text: copadoLabels.type,
            datafield: 't',
            filtertype: this.TypeFilterType,
            filterable: !this.isTypeFilterable,
            editable: false,
            columntype: 'textbox',
            width: '10%'
            },
            {
            text: copadoLabels.LastModifiedById,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'b',
            width: 220
            },
            {
            text: copadoLabels.LastModifiedDate,
            filtertype: 'range',
            cellsformat: 'yyyy-MM-dd',
            editable: false,
            datafield: 'd',
            width: 120
            },
            {
            text: copadoLabels.CREATEDBY,
            filtertype: 'input',
            columntype: 'textbox',
            editable:false,
            datafield:'cb',
            width:220
            },
            {
            text: copadoLabels.CREATEDDATE,
            filtertype: 'range',
            cellsformat: 'yyyy-MM-dd',
            editable:false,
            datafield:'cd',
            width:120
            }
        ];
    }else if(type === 'DXpermissionSet') {
      columns = [
          {
              text: copadoLabels.selected,
              columntype: 'checkbox',
              filtertype: 'bool',
              datafield: 's',
              width: '10%'
          },
          {
              text: copadoLabels.name,
              filtertype: 'input',
              columntype: 'textbox',
              editable: false,
              datafield: 'n',
              width: '45%'
          },
          {
              text: copadoLabels.type,
              datafield: 't',
              editable: false,
              columntype: 'textbox',
              width: '45%'
          }
    ];
    } else if(type === 'gitCommitEditable') {
        columns = [
            {
            text: copadoLabels.selected,
            columntype: 'checkbox',
            filtertype: 'bool',
            datafield: 's',
            width: 60
            },
            {
            text: copadoLabels.name,
            filtertype: 'input',
            columntype: 'textbox',
            editable: true,
            datafield: 'n',
            width: '30%',
            validation: function (cell, value) {
                    if (!value || value == ' ') {
                        return { result: false, message: 'You must specify a value' };
                }
                return true;
            }
            },
            {
            text: copadoLabels.type,
            datafield: 't',
            filtertype: this.TypeFilterType,
            filterable: !this.isTypeFilterable,
            editable: true,
            columntype: 'textbox',
            width: '10%',
            validation: function (cell, value) {
                    if (!value || value == ' ') {
                        return { result: false, message: 'You must specify a value' };
                }
                if (value.indexOf(' ') >= 0) {
                        return { result: false, message: 'Remove all blank spaces' };
                }
                return true;
            }
            },
            {
            text: copadoLabels.LastModifiedById,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'b',
            width: 220
            },
            {
            text: copadoLabels.LastModifiedDate,
            filtertype: 'range',
            cellsformat: 'yyyy-MM-dd',
            editable: false,
            datafield: 'd',
            width: 120
        },
            {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield:'cb', width:220},
            {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield:'cd', width:120}
        ];
    } else {
        columns = [
            {
            text: copadoLabels.selected,
            columntype: 'checkbox',
            filtertype: 'bool',
            datafield: 's',
            width: 60
            },
            {
            text: copadoLabels.name,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'n',
            width: '30%'
            },
            {
            text: copadoLabels.type,
            datafield: 't',
            filtertype: this.TypeFilterType,
            filterable: !this.isTypeFilterable,
            editable: false,
            columntype: 'textbox',
            width: '10%'
            },
            {
            text: copadoLabels.LastModifiedById,
            filtertype: 'input',
            columntype: 'textbox',
            editable: false,
            datafield: 'b',
            width: 220
            },
            {
            text: copadoLabels.LastModifiedDate,
            filtertype: 'range',
            cellsformat: 'yyyy-MM-dd',
            editable: false,
            datafield: 'd',
            width: 120
        },
            {text: copadoLabels.CREATEDBY, filtertype: 'input', columntype: 'textbox', editable:false, datafield:'cb', width:220},
            {text: copadoLabels.CREATEDDATE, filtertype: 'range', cellsformat: 'yyyy-MM-dd', editable:false, datafield:'cd', width:120}
        ];
    }
    return columns;
};

// (re) renders the grid
MetadataGrid2.prototype.render = function(cbAfterRender) {
    var that = this;

    if(this.isRendered) {
        // Just refresh and return, never re-render
        console.debug('MetadataGrid2.render() re-rendering', this.filterByType);
        this._reapplyFilters(0);
        this.eltGrid.jqxGrid('updatebounddata', 'filter');
        if (cbAfterRender) cbAfterRender();
        return;
    }
    this.isRendered = true;
    console.debug('MetadataGrid2.render() rendering');

    // rendering the "tabs", which in fact are a filter type
    this.eltTabs = this.eltMain.find('.mg2_tabs');
    if(this.eltTabs.length) {
        this.eltTabs.jqxTabs({});

        this.jqxFilterBySelection = new $copado.jqx.filter();
        this.jqxFilterBySelection.addfilter(1, this.jqxFilterBySelection.createfilter('booleanfilter', true, 'EQUAL'));

        this.eltTabs.on('selected', function (event) {
            if (!event.args) return;
            that._reapplyFilters(event.args.item);
        });
    }else{
        this.eltTabs = null;
    }

    // rendering the metadata type filter and binding its actions
    console.debug('isTypeFilterable====> ',this.isTypeFilterable);
    if(this.isTypeFilterable) {
        this.eltMetaDataTypeFilter = this.eltMain.find('.mg2_scaleFilter');
        console.debug('this.eltMetaDataTypeFilter==> ',this.eltMetaDataTypeFilter);
        console.debug('this.filterByTypeList==> ',this.filterByTypeList);
        this.eltMetaDataTypeFilter.jqxComboBox({
            source: this.filterByTypeList,
            selectedIndex: 0,
            width: '300px',
            height: '30px'
        });
        this.eltMetaDataTypeFilter.bind('select', function(event) {
            var args = event.args;
            console.debug('args===> ',args);
            if (args) {
                that.filterByTypeSelectedIndex = args.index;
                that.filterByType = args.item.label;
            }
        });
        this.eltMetaDataTypeFilter.bind('close', function(event) {
            console.debug('MetadataGrid2: filter loading', that.filterByType);
            if (!that.filterByType) return;
            document.body.focus();
            that.eltMetaDataTypeFilter.jqxComboBox({ disabled: true });

            // detach the slow process.
            window.setTimeout(function() {
                lockScreen();
                // even if loadmetadata is never called, this will ensure the combo is enabled.
                that.eltMetaDataTypeFilter.jqxComboBox({ disabled: false });
                that.loadMetaData(function(error) {
                    console.debug('MetadataGrid2: filter done');
                    that.render();
                    unlockScreen();
                    that.eltMetaDataTypeFilter.jqxComboBox({ disabled: false });

                    // fire a custom event telling the selection changed.
                    var event = new CustomEvent('copadoMetadataGrid2TypeChanged', { detail: { metadataGrid2: this } });
                    document.dispatchEvent(event);
                });
            },500);
        });
    }

    // now, finally, render the grid (must be done last!)
    var theme = 'base';
    var $window = $copado(window);
    var gridHeight = ($window.height() - 320).toString();
    if ($copado('.mg2_gitOperation').length) {
        gridHeight = ($window.height() - 480).toString();
    }
    if(!((typeof sforce != 'undefined') && sforce && (!!sforce.one))){
        gridHeight = gridHeight - 130;
    }
    if(parseInt(gridHeight) < 400){
        gridHeight = '400';
    }
    var dataFieldsMap = [];
    if(this.conf.dxGridType !== 'branches') {
        dataFieldsMap = [
            {name: 's', type: 'bool'},
            {name: 'r', type: 'bool'},
            {name: 't', type: 'string'},
            {name: 'n', type: 'string'},
            {name: 'b', type: 'string'},
            {name: 'd', type: 'date'},
            {name: 'cb', type: 'string'},
            {name: 'cd', type: 'date'}
        ];
    } else {
        dataFieldsMap = [
            {name: 's', type: 'bool'},
            {name: 'name', type: 'string'},
            {name: 'type', type: 'string'},
            {name: 'lastUpdate', type: 'date'}
        ];
    }
    var source = {
        localdata: this.allMetaData,
        datafields: dataFieldsMap,
        datatype: 'array',
        updaterow: function (rowid, rowdata, commit) {
            try{
                if (commit) commit(true);
                else console.warn('no commit fn defined');
                if (rowdata != null) that._setSelectionState(rowdata.s, [that.allMetaData[rowid]], false, rowdata);
            }catch(e) {
                console.error(e);
            }
        }
    };
    //adapter wrapper
    var dataAdapter = new $copado.jqx.dataAdapter(source);
    //keep jquery pointer for performance query
    this.eltGrid = this.eltMain.find('.mg2_jqxgrid');
    console.assert(this.eltGrid.length);
    //save local source
    this.datasource = source;

    this.eltGrid.jqxGrid({
        width: '100%',
        height: gridHeight,
        source: dataAdapter,
        showfilterrow: true,
        filterable: true,
        theme: theme,
        editable: true,
        selectionmode: 'none',
        enablebrowserselection: true,
        pageable: true,
        pagesizeoptions: ['10', '50','100','500','1000','5000'],
        pagesize: 200,
        sortable: true,
        columnsresize: true,
        localization: localizationobj,
        columns: this._getColumnsByGridMode(),
        ready: function(){
            console.log('MetadataGrid2.render() ready grid event');
            try{
                //TS: This is for fixing big metadata filter not opening/rendering due to timing (or something like that) issue
                if(that.conf.isScalable){
                    that.eltMetaDataTypeFilter.jqxComboBox({source: ['']});
                }
                if (that.hasPreviousSelected) that.addSelectedFilter(that.eltGrid);
                if(cbAfterRender){
                    cbAfterRender(that);
                }
                //that.eltGrid.jqxGrid('sortby','d', false, null, false);
            } catch (e) {
                console.error(e);
            }
        }
    });

    if(this.conf.gridMode === 'gitCommit') {
        this.eltGrid.on('cellvaluechanged', function (event) {
            // hack: if the col clicked is r, check the selection as well
            var t = that.eltGrid.jqxGrid('getrowdata', event.args.rowindex);

            if (event.args.datafield=='r' && t.r === true && t.s === false) {
                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 's', true);
                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', true);
            } else if (event.args.datafield == 'r' && t.r === false && t.s === true) {
                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', false);
            } else if (event.args.datafield == 's' && t.r === true && t.s === false) {
                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', false);
                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 's', false);
            }
            //that.eltGrid.jqxGrid('refreshdata');
            //that.eltGrid.jqxGrid('applyfilters');
            that._setSelectionState(t.s, [t], true, t);
        });
    }

    if(this.conf.gridMode === 'gitCommitEditable') {
        var that = this;
        this.eltGrid.on('cellbeginedit', function (event) {
            var eltTabs = that.eltMain.find('.mg2_tabs');
            var tabSelected = eltTabs.jqxTabs('selectedItem');
            if(tabSelected === 1){
                console.log('Entered tab selected Must return');
                return false;
            }
            if(event.args.value) {
                var rowindex = event.args.rowindex;
                var column = event.args.datafield;

                if (column == 'n' && event.args.value == '[Metadata API Name]') {
                    that.eltGrid.jqxGrid('setcellvalue', rowindex, column, '');
                } else if (column == 't' && event.args.value == '[Metadata Type]') {
                    that.eltGrid.jqxGrid('setcellvalue', rowindex, column, ' ');
                }
            }
        });
        // Initialize the add row button
        var addRow = function() {
                var datarow = {
                n: '[Metadata API Name]',
                s: true,
                b: '',
                cb: '',
                t: '[Metadata Type]'
                };
                that.eltGrid.jqxGrid('addrow', source.localdata.length, datarow);
                source.localdata.push(datarow);
                var rowscounts = that.eltGrid.jqxGrid('getdatainformation').rowscount;
                that.eltGrid.jqxGrid('ensurerowvisible',rowscounts-1);
                unlockScreen();
        };

        var $addRowButton = $copado('<button>Add Row</button>').on('click', function(e) {
                lockScreen();
                e.preventDefault();
                addRow();
            });
        this.eltMain.find('.jqx-grid-pager > div').prepend($addRowButton);
    }

    if(this.conf.gridMode !== 'orgMetadata') {
        var selectAll = function(sel) {
                var list = that.eltGrid.jqxGrid('getrows');
                that._setSelectionState(sel, list, true);
                that.render();
        };
        // Initialize the select all/unselect all buttons
        var $unselectAll = $copado('<button id="unselectAll">Unselect All</button>').on('click', function(e) {
                e.preventDefault();
                selectAll(false);
            // setting tab to "All Metadata" when there is no selection.
            if(that.eltTabs) {
                that.eltTabs.jqxTabs('select', 0);
            }
            });

        var $selectAll = $copado('<button id="selectAll">Select All</button>').on('click', function(e) {
            e.preventDefault();
            selectAll(true);
        });
        this.eltMain.find('.jqx-grid-pager > div').prepend($unselectAll).prepend($selectAll);
    }
};

MetadataGrid2.prototype._createCacheDeleteButton = function(){
    var $btn = $copado('[id$=removeCache]');
    this._createCacheDeleteButtonText = this._createCacheDeleteButtonText || $copado('[id$=removeCache]').html() || '';
    var text = this._createCacheDeleteButtonText;
    if (!this.allMetaData_cachedDate) {
        $copado('[id*=removeCacheContainer]').hide();
    } else {
        $copado('[id*=removeCacheContainer]').show();
        text = this._createCacheDeleteButtonText.replace('__DATE__', this.allMetaData_cachedDate);
        $btn.html( text );
    }
    if (this.filterByType) {
        text = text.replace('__METATYPE__', 'for ' + this.filterByType||'');
        $btn.html( text );
    } else {
        text = text.replace('__METATYPE__', '');
        $btn.html( text );
    }

    $btn.show();

    var $btnRefresh = $copado('[id$=refreshInfo]');
    this._refreshText = this._refreshText || $copado('[id$=refreshInfo]').html() || '';
    var refreshtxt = this._refreshText;
    if (!this.allMetaData_cachedDate) {
        $copado('[id*=refreshInfoContainer]').hide();
    } else {
        $copado('[id*=refreshInfoContainer]').show();
        refreshtxt = this._refreshText.replace('__DATE__', this.allMetaData_cachedDate);
        $btnRefresh.html(refreshtxt);
    }

    $btnRefresh.show();

};
MetadataGrid2.defaultTypes =
    'ActionLinkGroupTemplate,AnalyticSnapshot,ApexClass,ApexComponent,ApexPage,ApexTestSuite,ApexTrigger,AppMenu,ApprovalProcess,AssignmentRule,AssignmentRules,AuraDefinitionBundle,AuthProvider,AutoResponseRule,AutoResponseRules,BrandingSet,BusinessProcess,CallCenter,CaseSubjectParticle,Certificate,ChannelLayout,ChatterExtension,CleanDataService,Community,CompactLayout,ConnectedApp,ContentAsset,CorsWhitelistOrigin,CspTrustedSite,CustomApplication,CustomApplicationComponent,CustomFeedFilter,CustomField,CustomLabel,CustomLabels,CustomMetadata,CustomObject,CustomObjectTranslation,CustomPageWebLink,CustomPermission,CustomSite,CustomTab,Dashboard,DataCategoryGroup,DelegateGroup,Document,DuplicateRule,EclairGeoData,EmailServicesFunction,EmailTemplate,EmbeddedServiceBranding,EmbeddedServiceConfig,EscalationRule,EscalationRules,EventDelivery,EventSubscription,ExternalDataSource,ExternalServiceRegistration,FieldSet,FlexiPage,Flow,FlowCategory,FlowDefinition,GlobalValueSet,GlobalValueSetTranslation,Group,HomePageComponent,HomePageLayout,Index,InstalledPackage,Layout,LeadConvertSettings,Letterhead,LightningBolt,LightningExperienceTheme,ListView,MatchingRule,MatchingRules,NamedCredential,NetworkBranding,PathAssistant,PermissionSet,PlatformCachePartition,PostTemplate,Profile,ProfilePasswordPolicy,ProfileSessionSetting,Queue,QuickAction,RecordType,RemoteSiteSetting,Report,ReportType,Role,SamlSsoConfig,Scontrol,Settings,SharingCriteriaRule,SharingOwnerRule,SharingReason,SharingRules,SharingSet,SiteDotCom,StandardValueSet,StandardValueSetTranslation,StaticResource,SynonymDictionary,TopicsForObjects,ValidationRule,Vlocity,WebLink,Workflow,WorkflowAlert,WorkflowFieldUpdate,WorkflowKnowledgePublish,WorkflowOutboundMessage,WorkflowRule,WorkflowSend,WorkflowTask';
MetadataGrid2.prototype.loadMetaDataTypes = function(callbackFinished, forceReloading, preDefinedSource) {
    var that = this;
    console.log('loadMetaDataTypes() calling forceReloading=', forceReloading);
    console.log('loadMetaDataTypes() calling this.filterByTypeList=', this.filterByTypeList);
    console.log('preDefinedSource===> ',preDefinedSource);
    console.log('preDefinedSource==type=> ',typeof preDefinedSource);
    console.log('that.filterByTypeList==type=> ',typeof that.filterByTypeList);
    console.log('MetadataGrid2.defaultTypes=> ',MetadataGrid2.defaultTypes);

    // never reload the metadata types
    if(this.filterByTypeList.length &&!forceReloading) {
        if (callbackFinished) callbackFinished(event);
        return;
    }
    if(!preDefinedSource){
        JsRemoting.metaData.getList(
            this.conf.data.orgId,
            this.conf.ns,
            function(result) {
                if(!result || !result.length){
                    // TODO: remove result row and comment out for alert when backend implements dx login for metadataTypesRetriever
                    result = MetadataGrid2.defaultTypes.split(',');
                    //alert('Could not load metadata types from the server');
                }

                setWithoutRebinding(that.filterByTypeList, result);

                // TODO: this shouldnt be here, since it's UI
                if(that.isTypeFilterable) {
                    that.eltMetaDataTypeFilter.jqxComboBox('source', that.filterByTypeList);
                }

                if (callbackFinished) callbackFinished();
            },
            function(event) {
                console.error('loadMetaDataTypes()', event);
                alert('Exception: ' + event.message);
                if (callbackFinished) callbackFinished(event);
            },
            function(event) {
                console.error('loadMetaDataTypes() #2', event);
                alert('Exception: ' + event.message);
                if (callbackFinished) callbackFinished(event);
            }
        );
    } else{
        that.filterByTypeList = preDefinedSource;
        console.log('big metadata combobox rendered with predefined source');
        that.eltMetaDataTypeFilter.jqxComboBox('source', that.filterByTypeList);
    }
};

MetadataGrid2.prototype.loadSelectedMetaData = function(callbackFinished) {
    var selectedMetadata;
    if (this.conf.isRollback) {
        var testClassFile = dw.u.getFileContent(this.conf.data.id, this.conf.attachmentName);
        if(testClassFile && testClassFile !== null){
            selectedMetadata = JSON.parse(atob(dw.u.getFileContent(this.conf.data.id, this.conf.attachmentName)));
        }
    }
    else{
        selectedMetadata = dw.u.getSavedData(this.conf.data.id, this.conf.attachmentName);
    }
    
    console.debug('MetadataGrid2.loadSelectedMetaData()', selectedMetadata?selectedMetadata.length:selectedMetadata);
    if( selectedMetadata === false ) {
        setWithoutRebinding(this.selectedMetadata, []);
        if (callbackFinished) callbackFinished();
        return;
    }
    setWithoutRebinding(this.selectedMetadata, selectedMetadata);
    if (callbackFinished) callbackFinished();
};

MetadataGrid2.prototype.loadSelectedMetaDataJSON = function(jsonData, callbackFinished) {
    var that = this;
    var selectedMetadata = jsonData;
    if( selectedMetadata.length === false ) {
        setWithoutRebinding(that.selectedMetadata, []);
        if (callbackFinished) callbackFinished();
        return;
    }
    //setWithoutRebinding(this.allMetaData, selectedMetadata);
    setWithoutRebinding(that.selectedMetadata, selectedMetadata);
    that.render();
    if (callbackFinished) callbackFinished();
};

// (re) loads only the metadata, possibly filtered
MetadataGrid2.prototype.loadMetaData = function(callbackFinished, forceRefresh) {
    var that = this;
    var conf = this.conf;
    var deletedMetadataItems = '';

    if(this.isTypeFilterable && !this.filterByType) {
        console.debug('MetadataGrid2.loadMetaData: not loading metadata');
        that._setGridData([]); // set the data, even if it is emptyish.
        if (callbackFinished) callbackFinished();
        return;
    }
    if(!this.conf.data.orgId) return;
    var url = conf.server.metadataUrl.replace(new RegExp('__ORGID__', 'g'), conf.data.orgId);
    url = this.filterByType ? url + '&type=' + (this.filterByType||'') + '&scalable=true' : url;
    if(this.conf.gridMode==='Users') {
        url = this.conf.users_url;
    }else if(this.conf.gridMode==='metadataselector' && window.rock !== undefined) {
        url = rock.config.metadata_url;
    }
    console.debug('MetadataGrid2.loadMetaData', 'force?' + forceRefresh, conf.data.orgId, this.filterByType, url);
    dw.u.getCachedRemote({
       url: url,
       name: this.filterByType || conf.attachmentName,
       parentId: conf.data.orgId,
       force: forceRefresh,
       synchronous: false,
       success: function(allMetaData, cachedDate){
            if (allMetaData)
                console.log(
                    'MetadataGrid2.loadMetaData done ',
                    '#' + allMetaData.length,
                    cachedDate,
                    that.selectedMetadata.length,
                    that.filterByType
                );
            else allMetaData = [];
            var existingFlag = false;
            for(var j=0; j<that.selectedMetadata.length; j++){
                for(var i=0; i<allMetaData.length; i++){
                    if(allMetaData[i].n == that.selectedMetadata[j].n && allMetaData[i].t == that.selectedMetadata[j].t) existingFlag = true;
                }
                if(existingFlag === false && !conf.isScalable){
                    deletedMetadataItems += that.selectedMetadata[j].n + ', ';
                }
                existingFlag = false;
            }
            if(deletedMetadataItems.length > 0){
                deletedMetadataItems = deletedMetadataItems.slice(0,deletedMetadataItems.length - 2);
                alert(
                    'Previously selected ' +
                        deletedMetadataItems +
                        ' metadata item' +
                        (deletedMetadataItems.indexOf(',') > -1 ? 's are' : ' is') +
                        ' deleted from the source environment.\n\nPlease ignore this pop-up if you are already aware of this.'
                );
            }
            //Sorting grid rows based on the last modified date - Latest first
            var date1,date2;
            allMetaData.sort(function(a, b) {
                date1 = a.d ? new Date(a.d): new Date(1900,12,12);
                date2 = b.d ? new Date(b.d): new Date(1900,12,12);
                return date2-date1;
            });
            that._setGridData(allMetaData);

            that.allMetaData_cachedDate  = cachedDate;
            that._createCacheDeleteButton();

            // refresh the grid/filter, so the column type has filter values
            if(!this.isTypeFilterable){
                that.eltGrid.jqxGrid('updatebounddata');
                if(that.eltGrid){
                    that.eltGrid.jqxGrid('setcolumnproperty', 't', 'filteritems',that.types.sort());
                }
            } 

            if (callbackFinished) callbackFinished(cachedDate);
       },
       error: function(r){
           console.error('MetadataGrid2.Error: ',r);
            if (callbackFinished) callbackFinished(r);
       }
    });
};

// (re) loads all the data of the grid, does not render.
MetadataGrid2.prototype.loadData = function(callbackFinished) {
    var that = this;
    console.debug('MetadataGrid2.loadData() isTypeFilterable=', that.isTypeFilterable);
    this.loadSelectedMetaData(function(err) {
        if(err) {
            console.error('MetadataGrid2.loadData() error=', err);
            alert(err);
            return;
        }
        if(that.isTypeFilterable) {
            that.loadMetaDataTypes();
            that.loadMetaData(callbackFinished);
        }else{
            that.loadMetaData(callbackFinished);
        }
    });
};

// calls the API to refresh the metadata attachment (filtered or not)
MetadataGrid2.prototype.refreshCache = function(callbackFinished) {
    var that = this;
    lockScreen();
    this.loadMetaData(function(cachedDate) {
        console.info('MetadataGrid2.refreshCache() grid data refreshed');
        that.render();
        unlockScreen();
        if (callbackFinished) callbackFinished(cachedDate);
    }, true);
 };

 // calls the API to refresh the metadata attachment (filtered or not)
MetadataGrid2.prototype.refreshDeletedMetadataCache = function(callbackFinished) {
    var that = this;
    lockScreen();
    this.loadData(function(cachedDate) {
        console.info('MetadataGrid2.refreshCache() grid data refreshed');
        that.render();
        unlockScreen();
        if (callbackFinished) callbackFinished(cachedDate);
    }, true);
};
 
// changes the grid data, replacing whatever is in there now.
MetadataGrid2.prototype._matchSelectedItemsWithAllMetaData = function(allMetaData) {
    var i,
        e,
        t,
        idx_allItems = {};
    // create a quick index of all the metadata items.
    if(!allMetaData) allMetaData = [];
    for(i=0 ; i < allMetaData.length ; i++ ) {
        e = allMetaData[i];
        e.s = e.s || false;
        idx_allItems[e.t+' '+e.n] = e;
    }

    if( this.conf.gridMode === 'gitCommit') {
        for(i=0 ; i < allMetaData.length ; i++ ) {
            e = allMetaData[i];
            e.r = e.r || false;
        }
    }

    // now, try to find the selected items. If not found, add them to the allMetaData array.
    // the grid will filter those if needed.
    for(i=0 ; i < this.selectedMetadata.length ; i++ ) {
        e = this.selectedMetadata[i];
        e.s = true;
        t = idx_allItems[e.t+' '+e.n];
        if( t ) {
            t.s = true;
            // This line mark, if needed, selected metadata as "Retrieve Only".
            // When it comes from: Recommit User Story feature.
            t.r = e.r;
        }else{
            allMetaData.push(e);
        }
    }
};

// changes the grid data, replacing whatever is in there now.
MetadataGrid2.prototype._setGridData = function(allMetaData) {
    this._matchSelectedItemsWithAllMetaData(allMetaData);
    if( this.conf.gridMode === 'gitCommit') {
        // save all the .r selections, rebind the data, and restore them in the new dataset.
        var e,
            eltsWithRetrieveOnly = [];
        for(i=0 ; i < this.selectedMetadata.length ; i++ ) {
            e = this.selectedMetadata[i];
            if (e.r) eltsWithRetrieveOnly.push(e.t + ' ' + e.n);
        }
        setWithoutRebinding(this.allMetaData, allMetaData);

        idx_allItems = {};
        for(i=0 ; i < this.allMetaData.length ; i++ ) {
            e = this.allMetaData[i];
            
            if(!this.types.includes(e.t)){
                this.types.push(e.t);
            }
            
            if( eltsWithRetrieveOnly.indexOf(e.t+' '+e.n)>-1) {
                e.r = true;
            }
        }
    }else{
        if(allMetaData){
            for(i=0 ; i < allMetaData.length ; i++ ) {
                if(!this.types.includes(allMetaData[i].t)){
                    this.types.push(allMetaData[i].t);
                }
            }
        }
        setWithoutRebinding(this.allMetaData, allMetaData);
    }

    console.debug('MetadataGrid2._setGridData() all=', this.allMetaData.length, 'sel=', this.selectedMetadata.length);
};

Array.prototype.unique = function() {
    var a = this.concat();
    for(var i=0; i<a.length; ++i) {
        for(var j=i+1; j<a.length; ++j) {
            if (a[i] === a[j]) a.splice(j--, 1);
        }
    }

    return a;
};

// append the items to .allMetaData and selectedMetadata (if the items are selected)
MetadataGrid2.prototype.addItemsIfMissing = function(items) {
    // create a map of the existing metadata items
    var e,
        idx_allItems = {},
        idx_selectedItems = {};
    for(i=0 ; i < this.allMetaData.length ; i++ ) {
        e = this.allMetaData[i];
        idx_allItems[e.t+' '+e.n] = e;
    }
    for(i=0 ; i < this.selectedMetadata.length ; i++ ) {
        e = this.selectedMetadata[i];
        idx_selectedItems[e.t+' '+e.n] = e;
    }
    // now see if each item in items exists or needs to be added and/or selected.
    for(var i=0 ; i < items.length ; i++) {
        e = items[i];
        var key = e.t+' '+e.n;
        if( idx_allItems[key] ) {
            idx_allItems[key].s = e.s;
            // if the element is selected, ensure it is in the .selectedMetadata array
            if(e.s && !idx_selectedItems[key]) {
                //e.s = true;
                this.selectedMetadata.push(e);
            }
        }else{
            this.allMetaData.push(e);
            idx_allItems[key] = e;
            // if the element is selected, ensure it is in the .selectedMetadata array
            if(e.s) {
                e.s = true;//this.selectedMetadata.push(e);
            }
        }
    }
};

// fetches the selected data again. Useful for the "cancel" action
MetadataGrid2.prototype.reloadSelections = function(tabNumber) {
    var that = this;
    lockScreen();
    that.loadSelectedMetaData(function() {
        that._matchSelectedItemsWithAllMetaData(that.allMetaData);
        // NR: workaround because the selection show all the data, for some reason.
        if (that.eltTabs) that.eltTabs.jqxTabs('select', tabNumber || 0);
        that.render();
        unlockScreen();
    });
};

// fetches the selected data again. Useful for the "cancel" action
MetadataGrid2.prototype.reloadSelectionsJSON = function(json, tabNumber) {
    var that = this;
    lockScreen();
    that.loadSelectedMetaDataJSON(json, function() {
        that._matchSelectedItemsWithAllMetaData(that.allMetaData);
        // NR: workaround because the selection show all the data, for some reason.
        if (that.eltTabs) that.eltTabs.jqxTabs('select', tabNumber || 0);
        that.render();
        unlockScreen();
    });

    var $window = $copado(window);
    this.eltGrid = this.eltMain.find('.mg2_jqxgrid');
    var gridHeight = ($window.height() - 320).toString();
    if ($copado('.mg2_gitOperation').length) {
        gridHeight = ($window.height() - 480).toString();
    }
    if(!((typeof sforce != 'undefined') && sforce && (!!sforce.one))){
        gridHeight = gridHeight - 130;
    }
    if(parseInt(gridHeight) < 400){
        gridHeight = '400';
    }
    this.eltGrid.jqxGrid({ height: gridHeight });
};

MetadataGrid2.prototype.refreshMetadataTypes = function() {
    var that = this;
    lockScreen();
    $copado('[id*=removeMTCache]').hide();
    dw.u.deleteAttach(that.conf.data.orgId,'MetadataTypes');
    that.loadMetaDataTypes(function() {
        unlockScreen();
    }, true);
    return false;
};
