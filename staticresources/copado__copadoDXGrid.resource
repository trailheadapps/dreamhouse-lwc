function setWithoutRebinding(list, newList) {
    list.splice(0, list.length); // clear the array, without re-binding it.
    newList = newList.slice(0);
    // NR: add elements in chunks, to avoid stack trace limits
    while(newList.length)
        Array.prototype.push.apply(list, newList.splice(0,10000));
}

function copadoDXGrid(conf) {
    this._initGrid(conf);
    // Save the HTML for use in resetGrid
    this._initialHTML = this.eltMain.html();
}

copadoDXGrid.prototype._initGrid = function(conf) {
    this.conf = conf;

    this.conf.gridMode = this.conf.gridMode || "orgMetadata"; // grid mode affects the behavior of the loading, rendering columns, and saving.
    this.isMetadataGrid = this.conf.gridMode === 'orgMetadata';
    this.conf.dxGridType = this.conf.dxGridType || ''; // dx grid type affects columns for dx pages.

    console.debug('_initGrid()', this.conf.gridMode, this.isMetadataGrid);
    //console.assert(this.conf.data.orgId, "copadoDXGrid.init: config had no orgId"); MY: With DX orgId is not required.

    this.allMetaData = [];
    this.selectedMetadata = []; // selected items, referencing this.allMetaData
    this.allMetaData_cachedDate = "";

    //this.conf.isScalable = false; // true for having the filter INSIDE the grid, not as a combobox 
    this.isTypeFilterable = (this.conf.isScalable); // true for having the filter INSIDE the grid, not as a combobox
    console.debug("copadoDXGrid() conf.isScalable", this.conf.isScalable);

    this.TypeFilterType = 'checkedlist';
    this.filterByType = ''; // null means: no filter selected
    this.filterByTypeList = [];
    this.filterByTypeSelectedIndex = 0;
    this.savedFilters = null;

    this.isRendered = false;
    this.eltGrid = null;
    this.eltMetaDataTypeFilter = null;
    this.eltTabs = null;

    this.conf.eltMainId = this.conf.eltMainId || 'metadataGrid2'; // overridable main ID
    this.eltMain = $copado('#'+this.conf.eltMainId);
    console.assert(this.eltMain.length);

    if(this.conf.isScalable)
        this.eltMain.find('.mg2_scaleFilterFrame').show();
    else
        this.eltMain.find('.mg2_scaleFilterFrame').hide();

    if(this.conf.gridMode==='Translations') {
        // translations are never filterable by type. They will be manually filtered later
        this.isTypeFilterable = false;
        this.filterByType = 'Translations';
        this.eltMain.find('.mg2_scaleFilterFrame').hide();
    }

};

// Resets the grid
copadoDXGrid.prototype.resetGrid = function(conf) {
    console.debug("copadoDXGrid.resetGrid()");
    this.eltMain.html(this._initialHTML);
    this._initGrid(conf);
};

// selects/deselects a bunch of elements.
copadoDXGrid.prototype._setSelectionState = function(selected, elts, calledFromSelectAll, rowdata) {
    console.debug("copadoDXGrid._setSelectionState", selected, elts.length);

    // NR: we need to translate the elts list to the real elts for (un)selectAll
    var i, e, t, idx_allItems = null;
    if(calledFromSelectAll) {
        idx_allItems = {};
        for(i=0 ; i < this.allMetaData.length ; i++ ) {
            e = this.allMetaData[i];
            idx_allItems[e.t+' '+e.n] = e;
        }
    }

    // locate each elt in the
    for(i=0 ; i < elts.length ; i++) {
        e = elts[i];
        if(idx_allItems) {
            e =  idx_allItems[elts[i].t+' '+elts[i].n];
            if(!e)
                continue; // the element selected might not be in allMetaData, just ignore it.
        }
        e.s = selected;

        if (typeof showTip != 'undefined' && showTip && selected) {
            showTip(e.t);
         }

        var existsInSelected = this.selectedMetadata.indexOf(e);
        if(selected && existsInSelected===-1) {
            this.selectedMetadata.push(e);
        }else if(!selected && existsInSelected>-1) {
            this.selectedMetadata.splice(existsInSelected,1);
        }
        // little hack to allow actually clicking on "r" and setting s, and saving
        if( this.conf.gridMode === 'gitCommit') {
            if(rowdata)
                e.r = rowdata.r;
            if(calledFromSelectAll && !selected)
                e.r = false;
        }
    }

    // visual feedback, flashing the tab
    var elt = this.eltMain.find('.mg2_tabs li').get(1);
    elt.style.animation = '';
    setTimeout(function() {
        elt.style.animation = 'flash 2s 1';
    }, 5);

    // fire a custom event telling the selection changed.
    var event = new CustomEvent("copadocopadoDXGridChanged", { detail: { metadataGrid2: this } });
    document.dispatchEvent(event);
};

// forces filtering by the type currently selected
copadoDXGrid.prototype._setGridFiltersByType = function() {
    var that = this;
    var isTranslationsMode = this.conf.gridMode==='Translations';
    if(this.isTypeFilterable || isTranslationsMode) {
        if(isTranslationsMode) {
            that.filterByType = 'Translations';
            console.debug("_setGridFiltersByType() translations");
        }
        that.eltGrid.jqxGrid('removefilter', 't');
        var group = new $copado.jqx.filter();
        var filter = group.createfilter('stringfilter', that.filterByType, 'contains');
        group.addfilter(0, filter);

        that.eltGrid.jqxGrid('addfilter', 't', group);
        that.eltGrid.jqxGrid('applyfilters');
    }
};

copadoDXGrid.prototype._reapplyFilters = function(tabIndex) {
    var that = this;
    // if there are no tabs defined, there are no filters to reapply.
    if(!this.eltTabs) {
        metadataGridDX.eltGrid.jqxGrid('updatebounddata');
        return;
    }

    if(tabIndex===undefined)
        tabIndex = this.eltTabs.jqxTabs('selectedItem');

    if(tabIndex === 0) {
        // Filter by TYPE
        that.eltGrid.jqxGrid('setcolumnproperty', 's', 'filterable', true);
        that.eltGrid.jqxGrid('removefilter', 's');
        that.eltGrid.jqxGrid('applyfilters');
        if(that.savedFilters)
            that.eltGrid.jqxGrid('loadstate', that.savedFilters);
        that._setGridFiltersByType();
    }else if(tabIndex === 1) {
        that.savedFilters = that.eltGrid.jqxGrid('getstate');
        // Filter by SELECTION, regardless of the type
        that.eltGrid.jqxGrid('clearfilters');
        that.eltGrid.jqxGrid('setcolumnproperty', 's', 'filterable', false);
        that.eltGrid.jqxGrid('addfilter', 's', that.jqxFilterBySelection);
        that.eltGrid.jqxGrid('applyfilters');
    }else{
        console.warn("uknown tab!");
    }
};

copadoDXGrid.prototype._getColumnsByGridMode = function() {
    var type = this.conf.gridMode;
    var dxType = this.conf.dxGridType;
    var columns;

    if (type == 'metadataselector') {
        columns = [{
                text: copadoLabels.selected,
                columntype: 'checkbox',
                filtertype: 'bool',
                datafield: 's',
                width: 60
            },
            {
                text: copadoLabels.name,
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'n',
                width: 400
            },
            {
                text: copadoLabels.type,
                datafield: 't',
                filterable: true,
                filtertype: this.TypeFilterType,
                editable: false,
                columntype: 'textbox'
            },
            {
                text: copadoLabels.LASTMODIFIEDBY,
                filtertype: 'textbox',
                editable: false,
                datafield: 'b',
                width: 220
            },
            {
                text: copadoLabels.LastModifiedDate,
                filtertype: 'textbox',
                editable: false,
                datafield: 'd',
                width: 120
            },
            {
                text: copadoLabels.CREATEDBY,
                filtertype: 'textbox',
                editable: false,
                datafield: 'cb',
                width: 220
            },
            {
                text: copadoLabels.CREATEDDATE,
                filtertype: 'textbox',
                editable: false,
                datafield: 'cd',
                width: 120
            }
        ];
    } /*else if(type == 'testClasses'){
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
                filtertype: 'textbox',
                filtercondition: 'contains',
                editable: false,
                datafield: 'n',
                width: '70%'
            },
            {
                text: copadoLabels.type,
                editable: false,
                width: '20%',
                cellsrenderer: function(){
                    return 'ApexClass';
                }
            }
        ];
    } */else if(type === 'orgMetadata') {

          columns = [
              {
                  text: copadoLabels.name,
                  filtertype: 'textbox',
                  filtercondition: 'contains',
                  editable: false,
                  datafield: 'n'
              },
              {
                  text: copadoLabels.type,
                  datafield: 't',
                  filterable: true,
                  filtertype: 'checkedlist',
                  editable: false,
                  columntype: 'textbox',
                  width: 160
              },
              {
                  text: copadoLabels.LastModifiedById,
                  filtertype: 'textbox',
                  editable: false,
                  datafield: 'b',
                  width: 120
              },
              {
                  text: copadoLabels.LastModifiedDate,
                  filtertype: 'textbox',
                  editable: false,
                  datafield: 'd',
                  width: 120
              },
              {
                  text: copadoLabels.CREATEDBY,
                  filtertype: 'textbox',
                  editable: false,
                  datafield: 'cb',
                  width: 220
              },
              {
                  text: copadoLabels.CREATEDDATE,
                  filtertype: 'textbox',
                  editable: false,
                  datafield: 'cd',
                  width: 120}
          ];

    } else if(type === 'branches' || dxType === 'dxOperations' || dxType === 'branches'){
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
                 filtertype: 'textbox',
                 filtercondition: 'contains',
                 editable: false,
                 datafield: 'name',
                 width: '40%'
             },
             {
                 text: copadoLabels.type,
                 datafield: 'type',
                 filterable: true,
                 filtertype: this.TypeFilterType,
                 editable: false,
                 columntype: 'textbox',
                 width: '30%'
             },
             {
                 text: copadoLabels.LastModifiedDate,
                 filtertype: 'textbox',
                 editable: false,
                 datafield: 'lastUpdate',
                 cellsformat: 'M/d/yyyy',
                 width: '25%'
             }
         ];
     }//else if(type === 'gitCommit') {
//        columns = [{
//            text: copadoLabels.selected,
//            columntype: 'checkbox',
//            filtertype: 'bool',
//            datafield: 's',
//            width: 60
//        }, {text: copadoLabels.RETRIEVE_ONLY, columntype: 'checkbox', filterable: false, datafield: 'r', width: 85 }, {
//            text: copadoLabels.name,
//            filtertype: 'textbox',
//            filtercondition: 'contains',
//            editable: false,
//            datafield: 'n',
//            width: '30%'
//        }, {
//            text: copadoLabels.type,
//            datafield: 't',
//            filtertype: this.TypeFilterType,
//            filterable: true,
//            editable: false,
//            columntype: 'textbox',
//            width: '10%'
//        }, {
//            text: copadoLabels.LastModifiedById,
//            filtertype: 'textbox',
//            filtercondition: 'contains',
//            editable: false,
//            datafield: 'b',
//            width: 220
//        }, {
//            text: copadoLabels.LastModifiedDate,
//            filtertype: 'textbox',
//            filtercondition: 'contains',
//            editable: false,
//            datafield: 'd',
//            width: 120
//        },
//            {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield:'cb', width:220},
//            {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield:'cd', width:120}
//        ];
//
         // }
          else if(type === 'DXpermissionSet') {
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
                      filtertype: 'textbox',
                      filtercondition: 'contains',
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

//    } else if(type === 'gitCommitEditable') {
//        columns = [{
//            text: copadoLabels.selected,
//            columntype: 'checkbox',
//            filtertype: 'bool',
//            datafield: 's',
//            width: 60
//        }, {
//            text: copadoLabels.name,
//            filtertype: 'textbox',
//            filtercondition: 'contains',
//            editable: true,
//            datafield: 'n',
//            width: '30%',
//            validation: function (cell, value) {
//                if (!value || value == " ") {
//                    return { result: false, message: "You must specify a value" };
//                }
//                if (value.indexOf(' ') >= 0) {
//                    return { result: false, message: "Remove all blank spaces" };
//                }
//                return true;
//            }
//        }, {
//            text: copadoLabels.type,
//            datafield: 't',
//            filtertype: this.TypeFilterType,
//            filterable: true,
//            editable: true,
//            columntype: 'textbox',
//            width: '10%',
//            validation: function (cell, value) {
//                if (!value || value == " ") {
//                    return { result: false, message: "You must specify a value" };
//                }
//                if (value.indexOf(' ') >= 0) {
//                    return { result: false, message: "Remove all blank spaces" };
//                }
//                return true;
//            }
//        }, {
//            text: copadoLabels.LastModifiedById,
//            filtertype: 'textbox',
//            filtercondition: 'contains',
//            editable: false,
//            datafield: 'b',
//            width: 220
//        }, {
//            text: copadoLabels.LastModifiedDate,
//            filtertype: 'textbox',
//            filtercondition: 'contains',
//            editable: false,
//            datafield: 'd',
//            width: 120
//        },
//            {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield:'cb', width:220},
//            {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield:'cd', width:120}
//        ];
    } else {
        columns = [{
            text: copadoLabels.selected,
            columntype: 'checkbox',
            filtertype: 'bool',
            datafield: 's',
            width: 60
        }, {
            text: copadoLabels.name,
            filtertype: 'textbox',
            filtercondition: 'contains',
            editable: false,
            datafield: 'n',
            width: '30%'
        }, {
            text: copadoLabels.type,
            datafield: 't',
            filtertype: this.TypeFilterType,
            filterable: true,
            editable: false,
            columntype: 'textbox',
            width: '10%'
        }, {
            text: copadoLabels.LastModifiedById,
            filtertype: 'textbox',
            filtercondition: 'contains',
            editable: false,
            datafield: 'b',
            width: 220
        }, {
            text: copadoLabels.LastModifiedDate,
            filtertype: 'textbox',
            filtercondition: 'contains',
            editable: false,
            datafield: 'd',
            width: 120
        },
            {text: copadoLabels.CREATEDBY, filtertype: 'textbox', editable:false, datafield:'cb', width:220},
            {text: copadoLabels.CREATEDDATE, filtertype: 'textbox', editable:false, datafield:'cd', width:120}
        ];
    }
    return columns;
};

// (re) renders the grid
copadoDXGrid.prototype.render = function(cbAfterRender) {
    var that = this;

    if(this.isRendered) {
        // Just refresh and return, never re-render
        var datainformation = this.eltGrid.jqxGrid('getdatainformation');
        console.debug('copadoDXGrid.render() re-rendering', this.filterByType, datainformation);
        this._reapplyFilters(0);
        this.eltGrid.jqxGrid('updatebounddata', 'filter');
        if(cbAfterRender)
            cbAfterRender();
        return;
    }
    this.isRendered = true;
    console.debug('copadoDXGrid.render() rendering');

    // rendering the "tabs", which in fact are a filter type
    this.eltTabs = this.eltMain.find('.mg2_tabs');

    if(this.eltTabs.length) {
        this.eltTabs.jqxTabs({});

        this.jqxFilterBySelection = new $copado.jqx.filter();
        this.jqxFilterBySelection.addfilter(1, this.jqxFilterBySelection.createfilter('booleanfilter', true, 'EQUAL'));

        this.eltTabs.on('selected', function (event) {
            if(!event.args)
                return;
            that._reapplyFilters(event.args.item);
        });
    }else{
        this.eltTabs = null;
    }

    // rendering the metadata type filter and binding its actions
//    if(this.isTypeFilterable) {
//
//        this.eltMetaDataTypeFilter = this.eltMain.find('.mg2_scaleFilter');
//
//        this.eltMetaDataTypeFilter.jqxComboBox({
//            source: this.filterByTypeList,
//            selectedIndex: 0,
//            width: '300px',
//            height: '30px'
//        });
//        this.eltMetaDataTypeFilter.bind('select', function(event) {
//            var args = event.args;
//            if (args) {
//                that.filterByTypeSelectedIndex = args.index;
//                that.filterByType = that.filterByTypeList[that.filterByTypeSelectedIndex];
//            }
//        });
//        this.eltMetaDataTypeFilter.bind('close', function(event) {
//            console.debug('copadoDXGrid: filter loading', that.filterByType);
//            if(!that.filterByType)
//                return;
//
//            document.body.focus();
//            that.eltMetaDataTypeFilter.jqxComboBox({ disabled: true });
//
//            // detach the slow process.
//            window.setTimeout(function() {
//                lockScreen();
//                // even if loadmetadata is never called, this will ensure the combo is enabled.
//                that.eltMetaDataTypeFilter.jqxComboBox({ disabled: false });
//                that.loadMetaData(function(error) {
//                    console.debug('copadoDXGrid: filter done');
//                    that.render();
//                    unlockScreen();
//                    that.eltMetaDataTypeFilter.jqxComboBox({ disabled: false });
//
//                    // fire a custom event telling the selection changed.
//                    var event = new CustomEvent("copadocopadoDXGridTypeChanged", { detail: { metadataGrid2: this } });
//                    document.dispatchEvent(event);
//                });
//            },500);
//        });
//    }

    // now, finally, render the grid (must be done last!)
    var theme = 'base';
    var gridHeight = '300px';
    if(that.conf.style && that.conf.style.height){
        gridHeight = that.conf.style.height;
    }
    var dataFieldsMap = [];
    if(this.conf.dxGridType !== 'branches') {
        dataFieldsMap = [
            {name: 's', type: 'bool'},
            {name: 'r', type: 'bool'},
            {name: 't', type: 'string'},
            {name: 'n', type: 'string'},
            {name: 'b', type: 'string'},
            {name: 'd', type: 'string'},
            {name: 'cb', type: 'string'},
            {name: 'cd', type: 'string'}
        ];
    } else {
        dataFieldsMap = [
            {name: 's', type: 'bool'},
            {name: 'name', type: 'string'},
            {name: 'type', type: 'string'},
            {name: 'lastUpdate', type: 'string'}
        ];
    }
    var source = {
        localdata: this.allMetaData,
        datafields: dataFieldsMap,
        datatype: 'array',
        updaterow: function (rowid, rowdata, commit) {
            try{
//                if(commit)
//                    commit(true);
//                else
//                    console.warn("no commit fn defined");
                if(rowdata != null)
                    that._setSelectionState(rowdata.s, [that.allMetaData[rowid]], false, rowdata);
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
            console.log('copadoDXGrid.render() ready grid event');
            try{
                if(that.hasPreviousSelected)
                    that.addSelectedFilter(that.eltGrid);
                if(cbAfterRender){
                    cbAfterRender(that);
                }
                //that.eltGrid.jqxGrid('sortby','d', false, null, false);
            }catch(e) { console.error(e); }
        }
    });

//    if(this.conf.gridMode === 'gitCommit') {
//
//        this.eltGrid.on('cellvaluechanged', function (event) {
//            // hack: if the col clicked is r, check the selection as well
//            var t = that.eltGrid.jqxGrid('getrowdata', event.args.rowindex);
//
//            if (event.args.datafield=='r' && t.r === true && t.s === false) {
//                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "s", true);
//                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "r", true);
//            }
//            else if(event.args.datafield=='r' && t.r === false && t.s === true) {
//                that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "r", false);
//            }
//            else if (event.args.datafield=='s' && t.r === true && t.s === false) {
//               that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "r", false);
//               that.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, "s", false);
//            }
//            //that.eltGrid.jqxGrid('refreshdata');
//            //that.eltGrid.jqxGrid('applyfilters');
//            that._setSelectionState(t.s, [t], true, t);
//        });
//    }

    /*if(this.conf.gridMode === 'gitCommitEditable') {

        this.eltGrid.on('cellbeginedit', function (event) {
            if(event.args.value) {
                var rowindex = event.args.rowindex;
                var column = event.args.datafield;

                // delete the name or type if it is a placeholder
                if (column == "n" && event.args.value == "[Metadata API Name]" || column == "t" && event.args.value == "[Metadata Type]") {
                    that.eltGrid.jqxGrid('setcellvalue', rowindex, column, "");
                }
            }
        });

        this.eltGrid.on('cellendedit', function (event) {
            var rowindex = event.args.rowindex;
            var column = event.args.datafield;
            var value = event.args.value;

            // if name or type value is edited, save it in the source and in the grid.
            // if the text value is empty, default to the placeholder values
            if (column == "n") {
                var datarow = that.eltGrid.jqxGrid('getrowdata', rowindex);
                if(datarow) {
                    source.localdata[rowindex].n = value;
                    datarow.n = value;
                    that.eltGrid.jqxGrid('updaterow', rowindex, datarow);
                }
            } else if (column == "t") {
                var datarow = that.eltGrid.jqxGrid('getrowdata', rowindex);
                if(datarow) {
                    source.localdata[rowindex].t = value;
                    datarow.t = value;
                    that.eltGrid.jqxGrid('updaterow', rowindex, datarow);
                }
            }
        });

        // Initialize the add row button
        var addRow = function() {
                var datarow = {
                    "n":"[Metadata API Name]",
                    "s":true,
                    "b":"",
                    "cb":"",
                    "t":"[Metadata Type]"
                };
                that.eltGrid.jqxGrid('addrow', source.localdata.length, datarow);
                source.localdata.push(datarow);
                var rowscounts = that.eltGrid.jqxGrid('getdatainformation').rowscount;
                that.eltGrid.jqxGrid('ensurerowvisible',rowscounts-1);
        };

        var $addRowButton = $copado('<button>Add Row</button>').on('click', function(e) {
                e.preventDefault();
                addRow();
            });
        this.eltMain.find('.jqx-grid-pager > div')
            .prepend($addRowButton)
    }*/

    if(this.conf.gridMode !== 'orgMetadata') {
        var selectAll = function(sel) {
                var list = that.eltGrid.jqxGrid('getrows');
                that._setSelectionState(sel, list, true);
                that.render();
        };
        // Initialize the select all/unselect all buttons
        var $unselectAll = $copado('<button>Unselect All</button>').on('click', function(e) {
                e.preventDefault();
                selectAll(false);
            });

        var $selectAll = $copado('<button>Select All</button>').on('click', function(e) {
            e.preventDefault();
            selectAll(true);
        });
        this.eltMain.find('.jqx-grid-pager > div')
            .prepend($unselectAll)
            .prepend($selectAll);
    }
};

copadoDXGrid.prototype._createCacheDeleteButton = function(){
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
};

/*copadoDXGrid.prototype.loadMetaDataTypes = function(callbackFinished, forceReloading) {
    var that = this;
    console.debug('loadMetaDataTypes() calling forceReloading=', forceReloading);

    // never reload the metadata types
    if(this.filterByTypeList.length &&!forceReloading) {
        if(callbackFinished)
            callbackFinished(event);
        return;
    }

    JsRemoting.metaData.getList(
        this.conf.data.orgId,
        this.conf.ns,
        function(result) {
            console.debug('copadoDXGrid.loadMetaDataTypes()', result.length);
            if(!result || !result.length)
                alert('Could not load metadata types from the server');
            setWithoutRebinding(that.filterByTypeList, result);

            // TODO: this shouldnt be here, since it's UI
            if(that.isTypeFilterable) {
                that.eltMetaDataTypeFilter.jqxComboBox('source', that.filterByTypeList);
            }

            if(callbackFinished)
                callbackFinished();
        },
        function(event) {
            console.error('loadMetaDataTypes()', event);
            alert('Exception: ' + event.message);
            if(callbackFinished)
                callbackFinished(event);
        },
        function(event) {
            console.error('loadMetaDataTypes() #2', event);
            alert('Exception: ' + event.message);
            if(callbackFinished)
                callbackFinished(event);
        }
    );
};*/

copadoDXGrid.prototype.loadSelectedMetaData = function(callbackFinished) {
    var selectedMetadata = dw.u.getSavedData(this.conf.data.id, this.conf.attachmentName);
    console.debug('copadoDXGrid.loadSelectedMetaData()', selectedMetadata?selectedMetadata.length:selectedMetadata);
    if( selectedMetadata === false ) {
        setWithoutRebinding(this.selectedMetadata, []);
        if(callbackFinished)
            callbackFinished();
        return;
    }
    setWithoutRebinding(this.selectedMetadata, selectedMetadata);
    if(callbackFinished)
        callbackFinished();
};

copadoDXGrid.prototype.loadSelectedMetaDataJSON = function(selectedMetadata, callbackFinished) {
    if( selectedMetadata.length === false ) {
        setWithoutRebinding(this.selectedMetadata, []);
        if(callbackFinished)
            callbackFinished();
        return;
    }
    setWithoutRebinding(this.allMetaData, selectedMetadata);
    setWithoutRebinding(this.selectedMetadata, selectedMetadata);
    if(callbackFinished)
        callbackFinished();
};

// (re) loads only the metadata, possibly filtered
copadoDXGrid.prototype.loadMetaData = function(callbackFinished, forceRefresh) {
    var that = this;
    var conf = this.conf;

    if(this.isTypeFilterable && !this.filterByType) {
        console.debug('copadoDXGrid.loadMetaData: not loading metadata');
        that._setGridData([]); // set the data, even if it is emptyish.
        if(callbackFinished)
            callbackFinished();
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
    console.debug('copadoDXGrid.loadMetaData', "force?"+forceRefresh, conf.data.orgId, this.filterByType, url);

    dw.u.getCachedRemote({
       url: url,
       name: this.filterByType || conf.attachmentName,
       parentId: conf.data.orgId,
       force: forceRefresh,
       synchronous: false,
       success: function(allMetaData, cachedDate){
            console.debug('copadoDXGrid.loadMetaData done', '#'+allMetaData.length, cachedDate, that.selectedMetadata.length, that.filterByType);
            that._setGridData(allMetaData);

            that.allMetaData_cachedDate  = cachedDate;
            that._createCacheDeleteButton();

            // refresh the grid/filter, so the column type has filter values
            if(!this.isTypeFilterable)
                that.eltGrid.jqxGrid('updatebounddata');
            
            if(callbackFinished)
                callbackFinished();
       },
       error: function(r){
           console.error('copadoDXGrid.Error: ',r);
            if(callbackFinished)
                callbackFinished(r);
       }
    });
};

// (re) loads all the data of the grid, does not render.
copadoDXGrid.prototype.loadData = function(callbackFinished) {
    var that = this;
    console.debug('copadoDXGrid.loadData() isTypeFilterable=', that.isTypeFilterable);
    this.loadSelectedMetaData(function(err) {
        if(err) {
            console.error('copadoDXGrid.loadData() error=', err);
            alert(err);
            return;
        }
//        if(that.isTypeFilterable) {
//            that.loadMetaDataTypes();
//            that.loadMetaData(callbackFinished);
//        }else{
            that.loadMetaData(callbackFinished);
       // }
    });
};

// calls the API to refresh the metadata attachment (filtered or not)
copadoDXGrid.prototype.refreshCache = function(callbackFinished) {
    var that = this;
    lockScreen();
    this.loadMetaData(function() {
        console.info("copadoDXGrid.refreshCache() grid data refreshed");
        that.render();
        unlockScreen();
        if(callbackFinished)
            callbackFinished();
    }, true);
 };

// changes the grid data, replacing whatever is in there now.
copadoDXGrid.prototype._matchSelectedItemsWithAllMetaData = function(allMetaData) {
    var i, e, t, idx_allItems = {};

    // create a quick index of all the metadata items.
    for(i=0 ; i < allMetaData.length ; i++ ) {
        e = allMetaData[i];
        e.s = e.s || false;
        idx_allItems[e.t+' '+e.n] = e;
    }

//    if( this.conf.gridMode === 'gitCommit') {
//        for(i=0 ; i < allMetaData.length ; i++ ) {
//            e = allMetaData[i];
//            e.r = e.r || false;
//        }
//    }

    // now, try to find the selected items. If not found, add them to the allMetaData array.
    // the grid will filter those if needed.
    for(i=0 ; i < this.selectedMetadata.length ; i++ ) {
        e = this.selectedMetadata[i];
        e.s = true;
        t = idx_allItems[e.t+' '+e.n];
        if( t ) {
            t.s = true;
        }else{
            allMetaData.push(e);
        }
    }
};

// changes the grid data, replacing whatever is in there now.
copadoDXGrid.prototype._setGridData = function(allMetaData) {
    this._matchSelectedItemsWithAllMetaData(allMetaData);

    if( this.conf.gridMode === 'gitCommit') {
        // save all the .r selections, rebind the data, and restore them in the new dataset.
        var e, eltsWithRetrieveOnly = [];
        for(i=0 ; i < this.selectedMetadata.length ; i++ ) {
            e = this.selectedMetadata[i];
            if(e.r)
                eltsWithRetrieveOnly.push(e.t+' '+e.n);
        }
        setWithoutRebinding(this.allMetaData, allMetaData);

        idx_allItems = {};
        for(i=0 ; i < this.allMetaData.length ; i++ ) {
            e = this.allMetaData[i];
            if( eltsWithRetrieveOnly.indexOf(e.t+' '+e.n)>-1) {
                e.r = true;
            }
        }
    }else{
        setWithoutRebinding(this.allMetaData, allMetaData);
    }

    console.debug("copadoDXGrid._setGridData() all=", this.allMetaData.length, 'sel=',this.selectedMetadata.length);
};

// fetches the selected data again. Useful for the "cancel" action
copadoDXGrid.prototype.reloadSelections = function(tabNumber) {
    var that = this;
    lockScreen();
    that.loadSelectedMetaData(function() {
        that._matchSelectedItemsWithAllMetaData(that.allMetaData);
        // NR: workaround because the selection show all the data, for some reason.
        if(that.eltTabs)
            that.eltTabs.jqxTabs('select', tabNumber || 0);
        that.render();
        unlockScreen();
    });
};

/*copadoDXGrid.prototype.refreshMetadataTypes = function() {
    var that = this;
    lockScreen();
    $copado('[id*=removeMTCache]').hide();
    dw.u.deleteAttach(that.conf.data.orgId,'MetadataTypes');
    that.loadMetaDataTypes(function() {
        unlockScreen();
    }, true);
    return false;
}*/