'use strict';

var jqx = jqx || {};
var jqxdatatable_config = jqxdatatable_config ? jqxdatatable_config : undefined;
var globalSldsResourcePath = globalSldsResourcePath ? globalSldsResourcePath : undefined;
var metadataGridImagesPath = metadataGridImagesPath ? metadataGridImagesPath : undefined;
var $ = jQuery.noConflict();
var isRollback = isRollback ? isRollback : undefined;

/*********** Metadata Grid config functions **********/

var MetadataGrid3 = (() => {
    function setWithoutRebinding(list, newList) {
        list.splice(0, list.length); // clear the array, without re-binding it.
        // NR: add elements in chunks, to avoid stack trace limits

        if (!newList) {
            newList = [];
        }

        while (newList.length) {
            Array.prototype.push.apply(list, newList.splice(0, 10000));
        }
    }

    function MetadataGrid3(conf, cb) {
        this.TypeFilterType = '';

        this._initGrid(conf, cb);
        // Save the HTML for use in resetGrid
        this._initialHTML = this.eltMain.html();
    }

    MetadataGrid3.prototype._initGrid = function (conf, callback) {
        this.conf = conf;

        this.conf.gridMode = this.conf.gridMode || 'orgMetadata'; // grid mode affects the behavior of the loading, rendering columns, and saving.
        this.isMetadataGrid = this.conf.gridMode === 'orgMetadata';
        this.conf.dxGridType = this.conf.dxGridType || ''; // dx grid type affects columns for dx pages.

        this.allMetaData = [];
        this.originalMetadata = [];
        this.selectedMetadata = []; // selected items, referencing this.allMetaData
        this.allMetaData_cachedDate = '';

        this.isTypeFilterable = this.conf.isScalable ? this.conf.isScalable : false; // true for having the filter INSIDE the grid, not as a combobox

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

        this.conf.eltMainId = this.conf.eltMainId || 'metadataGrid3'; // overridable main ID
        this.eltMain = $copado(`#${this.conf.eltMainId}`);

        if (this.conf.isScalable) {
            this.eltMain.find('.mg2_scaleFilterFrame').show();
        } else {
            this.eltMain.find('.mg2_scaleFilterFrame').hide();
        }

        if (this.conf.gridMode === 'Translations') {
            // translations are never filterable by type. They will be manually filtered later
            this.isTypeFilterable = false;
            this.filterByType = 'Translations';
            this.eltMain.find('.mg2_scaleFilterFrame').hide();
        }

        callback && callback();
    };

    // Resets the grid
    MetadataGrid3.prototype.resetGrid = function (conf) {
        this.eltMain.html(this._initialHTML);
        this._initGrid(conf);
    };

    // selects/deselects a bunch of elements.
    MetadataGrid3.prototype._setSelectionState = function (selected, elts, calledFromSelectAll, rowdata) {
        // NR: we need to translate the elts list to the real elts for (un)selectAll
        var i, e, t, existsInSelected, elt, event;
        var idx_allItems = null;
        var tipTypes = [];
        var currentTab = this.eltTabs.jqxTabs('selectedItem');
        
       
        if (calledFromSelectAll) {
            idx_allItems = {};
            for (i = 0; i < this.allMetaData.length; i++) {
                e = this.allMetaData[i];
                idx_allItems[e.t + ' ' + e.n] = e;
            }
        }

        // locate each elt in the
        for (i = 0; i < elts.length; i++) {
            e = elts[i];
            if (idx_allItems) {
                e = idx_allItems[elts[i].t + ' ' + elts[i].n];
                if (!e) {
                    continue; // the element selected might not be in allMetaData, just ignore it.
                }
            }
            e.s = selected;
            if (typeof showTip !== 'undefined' && showTip && selected && tipTypes.indexOf(e.t) < 0) {
                showTip(e.t);
                tipTypes.push(e.t);
            }

            existsInSelected = this.selectedMetadata.indexOf(e);
            if (selected && existsInSelected === -1) {
                this.selectedMetadata.push(e);
            } else if (!selected && existsInSelected > -1) {
                this.selectedMetadata.splice(existsInSelected, 1);
            }
            // little hack to allow actually clicking on 'r' and setting s, and saving
            if (this.conf.gridMode === 'gitCommit' || this.conf.gridMode === 'gitCommitCompare') {
                if (rowdata) {
                    e.r = rowdata.r;
                }
                if (calledFromSelectAll && !selected) {
                    e.r = false;
                }
                if(calledFromSelectAll && this.originalMetadata.length>0 && this.originalMetadata[i].n === e.n && selected){
                    e.r = this.originalMetadata[i].r;
                }
            }
        }

        if (currentTab && currentTab !== 2) {
            // visual feedback, flashing the tab
            elt = this.eltMain.find('.mg2_tabs li').get(1);
            elt.style.animation = '';
            setTimeout(() => {
                elt.style.animation = 'flash 2s 1';
            }, 5);
        }
        // fire a custom event telling the selection changed.
        event = new CustomEvent('copadoMetadataGrid3Changed', { detail: { metadataGrid3: this } });
        document.dispatchEvent(event);
    };

    // forces filtering by the type currently selected
    MetadataGrid3.prototype._setGridFiltersByType = function () {
        var isTranslationsMode = this.conf.gridMode === 'Translations';
        var group, filter;

        if (this.isTypeFilterable || isTranslationsMode) {
            if (isTranslationsMode) {
                this.filterByType = 'Translations';
            }

            this.eltGrid.jqxGrid('removefilter', 't');
        }
    };

    MetadataGrid3.prototype._reapplyFilters = function (tabIndex) {
        if (tabIndex === undefined && this.eltTabs) {
            tabIndex = this.eltTabs.jqxTabs('selectedItem');
        }

        if (tabIndex === 0) {
            // Filter by TYPE
            this.eltGrid.jqxGrid('setcolumnproperty', 's', 'filterable', true);
            this.eltGrid.jqxGrid('removefilter', 's');
            this.eltGrid.jqxGrid('applyfilters');

            if (this.savedFilters) {
                this.eltGrid.jqxGrid('loadstate', this.savedFilters);
            }

            this._setGridFiltersByType();
        } else if (tabIndex === 1) {
            this.savedFilters = this.eltGrid.jqxGrid('getstate');
            // Filter by SELECTION, regardless of the type
            this.eltGrid.jqxGrid('clearfilters');
            this.eltGrid.jqxGrid('setcolumnproperty', 's', 'filterable', false);
            this.eltGrid.jqxGrid('addfilter', 's', this.jqxFilterBySelection);
            this.eltGrid.jqxGrid('applyfilters');
        } else if (tabIndex === 2 && this.conf.dxGridType === 'dxartifact') {
            this.savedFilters = this.eltGrid.jqxGrid('getstate');
            // Filter by SELECTION, regardless of the type
            this.eltGrid.jqxGrid('clearfilters');
            this.eltGrid.jqxGrid('setcolumnproperty', 'rd', 'filterable', false);
        } else {
            console.warn('unknown tab!');
            this.eltGrid.jqxTabs('select', 0);
        }
    };

    MetadataGrid3.prototype.createColumnsConfig = function (type) {
        var validateBlankSpaces = (cell, value) => {
            if (value.indexOf(' ') >= 0) {
                return { result: false, message: 'Remove all blank spaces' };
            }
            return true;
        };
        var validateSpecifyValue = (cell, value) => {
            if (!value || value === ' ') {
                return { result: false, message: 'You must specify a value' };
            }
            return true;
        };
        var validationFn = (cell, value) => {
            if (validateSpecifyValue(cell, value) !== true) {
                return validateSpecifyValue(cell, value);
            } else if (validateBlankSpaces(cell, value) !== true) {
                return validateBlankSpaces(cell, value);
            } else {
                return true;
            }
        };

        var cellsrendererFn = () => {
            return 'ApexClass';
        };

        /**
         * Helper to colored status cell by status
         * @param  {[type]} row         [description]
         * @param  {[type]} column      [description]
         * @param  {[type]} value       [description]
         * @param  {[type]} defaultHtml [description]
         * @return {[type]}             [description]
         */
        var cellsrendererCmm = (row, column, value, defaultHtml) => {
            var color = false;
            if (value == 'deleted' || value == 'delete') {
                color = '#FFC6C6';
            } else if (value == 'updated' || value == 'update') {
                color = '#FFFFE3';
            } else if (value == 'created' || value == 'create') {
                color = '#CCFFCC';
            }

            if (color) {
                var element = $copado(defaultHtml);
                element.css({
                    'background-color': color,
                    'text-align': 'center'
                });
                return element[0].outerHTML;
            }
            return defaultHtml;
        };

        var columnsConfig = {
            /*******  Table configuration order  *******/
            /*           text                     width           filtertype        datafield  columntype  filtercondition  editable        validation      cellsrenderer            filterable    cellsformat    */
            metadataselector: [
                [copadoLabels.selected, '5%', 'bool', 'r', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.name, '30%', 'input', 'n', 'textbox', null, false, null, null, true, null],
                [copadoLabels.type, '15%', this.TypeFilterType, 't', 'textbox', null, false, null, null, null, null],
                [copadoLabels.LASTMODIFIEDBY, '15%', 'input', 'b', 'textbox', null, false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '10%', 'range', 'd', null, null, false, null, null, null, 'yyyy-MM-dd'],
                [copadoLabels.CREATEDBY, '15%', 'input', 'cb', 'textbox', null, false, null, null, null, null],
                [copadoLabels.CREATEDDATE, '10%', 'range', 'cd', null, null, false, null, null, null, 'yyyy-MM-dd']
            ],

            testClasses: [
                [copadoLabels.selected, '10%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.name, '70%', 'input', 'n', 'textbox', null, false, null, null, null, null],
                [copadoLabels.type, '20%', null, null, null, null, false, null, cellsrendererFn, null, null]
            ],

            'orgMetadata-branches': [
                [copadoLabels.selected, '5%', 'bool', 'select', null, null, false, null, null, false, null],
                [copadoLabels.name, '40%', 'input', 'name', 'textbox', null, false, null, null, true, null],
                [copadoLabels.type, '30%', this.TypeFilterType, 'type', 'textbox', null, false, null, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedDate, '25%', 'range', 'lastUpdate', null, null, false, null, null, null, 'yyyy-MM-dd']
            ],

            orgMetadata: [
                [copadoLabels.name, '35%', 'input', 'n', 'textbox', null, false, null, null, null, null],
                [copadoLabels.type, '15%', this.TypeFilterType, 't', 'textbox', null, false, null, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedById, '15%', 'input', 'b', 'textbox', null, false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '10%', 'range', 'd', null, null, false, null, null, null, 'yyyy-MM-dd'],
                [copadoLabels.CREATEDBY, '15%', 'input', 'cb', 'textbox', null, false, null, null, null, null],
                [copadoLabels.CREATEDDATE, '10%', 'range', 'cd', null, null, false, null, null, null, 'yyyy-MM-dd']
            ],

            gitCommit: [
                [copadoLabels.selected, '5%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.RETRIEVE_ONLY, '5%', null, 'r', 'checkbox', null, null, null, null, false, null],
                [copadoLabels.name, '35%', 'input', 'n', 'textbox', null, false, null, null, null, null],
                [copadoLabels.type, '10%', this.TypeFilterType, 't', 'textbox', null, false, null, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedById, '15%', 'input', 'b', 'textbox', null, false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '10%', 'range', 'd', null, null, false, null, null, null, 'yyyy-MM-dd'],
                [copadoLabels.CREATEDBY, '10%', 'input', 'cb', 'textbox', null, false, null, null, null, null],
                [copadoLabels.CREATEDDATE, '10%', 'range', 'cd', null, null, false, null, null, null, 'yyyy-MM-dd']
            ],

            dwOverviewGrid: [
                [copadoLabels.RETRIEVE_ONLY, '5%', 'bool', 'r', 'checkbox', null, false, null, null, false, null],
                [copadoLabels.TEST_ONLY, '5%', 'bool', 'to', 'checkbox', null, false, null, null, false, null],
                [copadoLabels.STATUS, '5%', 'input', 'a', 'textbox', 'contains', false, null, cellsrendererCmm, null, null],
                [copadoLabels.name, '30%', 'input', 'n', 'textbox', 'contains', false, null, null, null, null],
                [copadoLabels.type, '20%', this.TypeFilterType, 't', 'textbox', null, false, null, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedById, '20%', 'input', 'b', 'textbox', null, false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '20%', 'range', 'd', null, null, false, null, null, null, 'yyyy-MM-dd']
            ],

            gitCommitCompare: [
                [copadoLabels.selected, '5%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.RETRIEVE_ONLY, '5%', null, 'r', 'checkbox', null, null, null, null, false, null],
                [copadoLabels.ACTION, '5%', 'input', 'a', 'textbox', 'contains', false, null, cellsrendererCmm, null, null],
                [copadoLabels.name, '25%', 'input', 'n', 'textbox', 'contains', false, null, null, null, null],
                [copadoLabels.type, '13%', this.TypeFilterType, 't', 'textbox', null, false, null, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedById, '20%', 'input', 'b', null, 'contains', false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '12%', 'range', 'd', null, 'contains', false, null, null, null, 'yyyy-MM-dd'],
                ['', '15%', 'input', 'ch', null, null, false, null, null, false, null]
            ],

            gitCommitLegacy: [
                [copadoLabels.selected, '5%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.COMMIT_INFO, '15%', 'input', 'cmm', 'textbox', 'contains', false, null, cellsrendererCmm, null, null],
                [copadoLabels.name, '40%', 'input', 'n', 'textbox', 'contains', false, null, null, null, null],
                [copadoLabels.type, '40%', this.TypeFilterType, 't', 'textbox', null, false, null, null, !this.isTypeFilterable, null]
            ],

            DXpermissionSet: [
                [copadoLabels.selected, '10%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.name, '45%', 'input', 'n', 'textbox', null, false, null, null, null, null],
                [copadoLabels.type, '45%', null, 't', 'textbox', null, false, null, null, null, null]
            ],

            gitCommitEditable: [
                [copadoLabels.selected, '5%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.name, '30%', 'input', 'n', null, null, true, validateBlankSpaces, null, null, null],
                [copadoLabels.type, '15%', this.TypeFilterType, 't', 'textbox', null, true, validationFn, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedById, '15%', 'input', 'b', null, null, false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '10%', 'range', 'd', null, null, false, null, null, null, 'yyyy-MM-dd'],
                [copadoLabels.CREATEDBY, '15%', 'input', 'cb', null, null, false, null, null, null, null],
                [copadoLabels.CREATEDDATE, '10%', 'range', 'cd', null, null, false, null, null, null, 'yyyy-MM-dd']
            ],

            default: [
                [copadoLabels.selected, '5%', 'bool', 's', 'checkbox', null, null, null, null, null, null],
                [copadoLabels.name, '30%', 'input', 'n', 'textbox', null, false, null, null, null, null],
                [copadoLabels.type, '15%', this.TypeFilterType, 't', 'textbox', null, false, null, null, !this.isTypeFilterable, null],
                [copadoLabels.LastModifiedById, '15%', 'input', 'b', 'textbox', null, false, null, null, null, null],
                [copadoLabels.LastModifiedDate, '10%', 'range', 'd', null, null, false, null, null, null, 'yyyy-MM-dd'],
                [copadoLabels.CREATEDBY, '15%', 'input', 'cb', 'textbox', null, false, null, null, null, null],
                [copadoLabels.CREATEDDATE, '10%', 'range', 'cd', null, null, false, null, null, null, 'yyyy-MM-dd']
            ]
        };

        var columns = [];
        var index = 0;

        var objectStruct = {
            text: '',
            width: null,
            filtertype: null,
            datafield: null,
            columntype: null,
            filtercondition: null,
            editable: null,
            validation: null,
            cellsrenderer: null,
            filterable: null,
            cellsformat: null
        };

        var object = {};

        columnsConfig[type].forEach((item) => {
            index = 0;
            object = {};
            if (isRollback) {
                if (item[0] == copadoLabels.RETRIEVE_ONLY) {
                    item[1] = '8%';
                } else if (item[0] == copadoLabels.STATUS) {
                    item[1] = '10%';
                } else if (item[0] == copadoLabels.name) {
                    item[1] = '35%';
                } else if (item[0] == copadoLabels.TEST_ONLY) {
                    item[1] = '8%';
                } else if (item[0] == copadoLabels.selected) {
                    item[1] = '6%';
                } else if (item[0] == copadoLabels.type) {
                    item[1] = '25%';
                } else if (item[0] == copadoLabels.ACTION) {
                    item[1] = '10%';
                }
            }
            for (var property in objectStruct) {
                if (item[index] !== null) {
                    object[property] = item[index];
                }
                if (type == 'gitCommitCompare' && property == 'editable' && isRollback && item[0] == copadoLabels.RETRIEVE_ONLY) {
                    object[property] = false;
                }

                index++;
            }

            if (
                ((object.text !== copadoLabels.STATUS && object.text !== copadoLabels.TEST_ONLY) || isRollback) &&
                !((object.text === copadoLabels.LastModifiedById || object.text === copadoLabels.LastModifiedDate) && isRollback)
            ) {
                columns.push(object);
            }
        });
        return columns;
    };

    MetadataGrid3.prototype._getColumnsByGridMode = function () {
        var type = this.conf.gridMode;
        var dxType = this.conf.dxGridType;
        var columns = this.createColumnsConfig(type);

        return columns;
    };

    // (re) renders the grid
    MetadataGrid3.prototype.render = function (cbAfterRender) {
        var self = this;
        var theme = 'base';
        var gridHeight = jqxdatatable_config.height || '300px';
        var dataFieldsMap = [];
        var args, event, source, dataAdapter, rowindex, column;

        if (this.isRendered) {
            // Just refresh and return, never re-render
            this._reapplyFilters(0);
            this.eltGrid.jqxGrid('updatebounddata', 'filter');

            if (cbAfterRender) {
                cbAfterRender();
            }

            return;
        }

        this.isRendered = true;

        // rendering the "tabs", which in fact are a filter type
        this.eltTabs = this.eltMain.find('.mg2_tabs');

        if (this.eltTabs.length) {
            this.eltTabs.jqxTabs({});

            this.jqxFilterBySelection = new $copado.jqx.filter();
            this.jqxFilterBySelection.addfilter(1, this.jqxFilterBySelection.createfilter('booleanfilter', true, 'EQUAL'));

            this.eltTabs.on('selected', (event) => {
                if (!event.args) {
                    return;
                }
                self._reapplyFilters(event.args.item);
            });
        } else {
            this.eltTabs = null;
        }

        // rendering the metadata type filter and binding its actions
        if (this.isTypeFilterable) {
            this.eltMetaDataTypeFilter = this.eltMain.find('.mg2_scaleFilter');

            this.eltMetaDataTypeFilter.jqxComboBox({
                source: this.filterByTypeList,
                selectedIndex: 0,
                width: '300px',
                height: '30px'
            });
            this.eltMetaDataTypeFilter.bind('select', (event) => {
                args = event.args;

                if (args) {
                    self.filterByTypeSelectedIndex = args.index;
                    self.filterByType = self.filterByTypeList[self.filterByTypeSelectedIndex];
                }
            });
            this.eltMetaDataTypeFilter.bind('close', (event) => {
                if (!self.filterByType) {
                    return;
                }

                document.body.focus();
                self.eltMetaDataTypeFilter.jqxComboBox({ disabled: true });

                // detach the slow process.
                window.setTimeout(() => {
                    lockScreen();
                    // even if loadmetadata is never called, this will ensure the combo is enabled.
                    self.eltMetaDataTypeFilter.jqxComboBox({ disabled: false });
                    self.loadMetaData((error) => {
                        self.render();
                        unlockScreen();
                        self.eltMetaDataTypeFilter.jqxComboBox({ disabled: false });

                        // fire a custom event telling the selection changed.
                        event = new CustomEvent('copadoMetadataGrid3TypeChanged', { detail: { metadataGrid3: this } });
                        document.dispatchEvent(event);
                    });
                }, 500);
            });
        }

        // now, finally, render the grid (must be done last!)
        if (this.conf.style && this.conf.style.height) {
            gridHeight = this.conf.style.height;
        }
        if (this.conf.dxGridType !== 'branches') {
            dataFieldsMap = [
                { name: 's', type: 'bool' },
                { name: 'cmm', type: 'string' },
                { name: 'r', type: 'bool' },
                { name: 't', type: 'string' },
                { name: 'n', type: 'string' },
                { name: 'b', type: 'string' },
                { name: 'd', type: 'date' },
                { name: 'cb', type: 'string' },
                { name: 'cd', type: 'date' },
                { name: 'ch', type: 'string' },
                { name: 'a', type: 'string' },
                { name: 'to', type: 'bool' }
            ];
        } else {
            dataFieldsMap = [
                { name: 's', type: 'bool' },
                { name: 'name', type: 'string' },
                { name: 'type', type: 'string' },
                { name: 'lastUpdate', type: 'date' }
            ];
        }

        source = {
            localdata: this.allMetaData,
            datafields: dataFieldsMap,
            datatype: 'array',
            updaterow: function (rowid, rowdata, commit) {
                try {
                    if (commit) {
                        commit(true);
                    } else {
                        console.warn('no commit fn defined');
                    }
                    if (rowdata != null) {
                        self._setSelectionState(rowdata.s, [self.allMetaData[rowid]], false, rowdata);
                    }
                } catch (error) {
                    console.error(error);
                }
            }
        };

        //adapter wrapper
        dataAdapter = new $copado.jqx.dataAdapter(source);
        //keep jquery pointer for performance query
        this.eltGrid = this.eltMain.find('.mg2_jqxgrid');
        // console.assert(this.eltGrid.length);

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
            pagesizeoptions: ['10', '50', '100', '500', '1000', '5000'],
            pagesize: 200,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            columns: this._getColumnsByGridMode(),
            ready: () => {
                try {
                    if (self.hasPreviousSelected) {
                        self.addSelectedFilter(self.eltGrid);
                    }
                    if (cbAfterRender) {
                        cbAfterRender(self);
                    }
                } catch (error) {
                    console.error(error);
                }
            }
        });

        if (this.conf.gridMode === 'gitCommit' || this.conf.gridMode === 'gitCommitCompare') {
            this.eltGrid.on('cellvaluechanged', (event) => {
                // hack: if the col clicked is r, check the selection as well
                var t = self.eltGrid.jqxGrid('getrowdata', event.args.rowindex);

                if (event.args.datafield == 'r' && t.r === true && t.s === false) {
                    self.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 's', true);
                    self.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', true);
                } else if (event.args.datafield == 'r' && t.r === false && t.s === true) {
                    self.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', false);
                } else if (event.args.datafield == 's' && t.r === true && t.s === false) {
                    self.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', false);
                    self.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 's', false);
                }
                
                self._setSelectionState(t.s, [t], true, t);
                if(self.originalMetadata){
                    for(let i=0; i<self.originalMetadata.length ; i++)
                    {
                        if(self.originalMetadata[i].n === t.n && t.s === true && self.originalMetadata[i].r === true){
                            self.eltGrid.jqxGrid('setcellvalue', event.args.rowindex, 'r', true);
                        }
                    }
                }
                
            });
        }

        if (this.conf.gridMode === 'gitCommitEditable') {
            this.eltGrid.on('cellbeginedit', (event) => {
                var eltTabs = self.eltMain.find('.mg2_tabs');
                var tabSelected = eltTabs.jqxTabs('selectedItem');

                if (tabSelected === 1) {
                    console.warn('Entered tab selected must return');
                    return false;
                }

                if (event.args.value) {
                    rowindex = event.args.rowindex;
                    column = event.args.datafield;

                    if (column === 'n' && event.args.value === '[Metadata API Name]') {
                        self.eltGrid.jqxGrid('setcellvalue', rowindex, column, '');
                    } else if (column === 't' && event.args.value === '[Metadata Type]') {
                        self.eltGrid.jqxGrid('setcellvalue', rowindex, column, ' ');
                    }
                }
            });

            // Initialize the add row button
            var addRow = () => {
                var datarow = {
                    n: '[Metadata API Name]',
                    s: true,
                    b: '',
                    cb: '',
                    t: '[Metadata Type]'
                };
                self.eltGrid.jqxGrid('addrow', source.localdata.length, datarow);
                source.localdata.push(datarow);
                var rowscounts = self.eltGrid.jqxGrid('getdatainformation').rowscount;
                self.eltGrid.jqxGrid('ensurerowvisible', rowscounts - 1);
                unlockScreen();
            };

            var $addRowButton = $copado('<button>Add Row</button>').on('click', function (event) {
                lockScreen();
                event.preventDefault();
                addRow();
            });

            this.eltMain.find('.jqx-grid-pager > div').prepend($addRowButton);
        }

        if (this.conf.gridMode !== 'orgMetadata' && this.conf.gridMode !== 'dwOverviewGrid') {
            var selectAll = (sel) => {
                var list = self.eltGrid.jqxGrid('getrows');
                self._setSelectionState(sel, list, true);
                self.render(jqx.assignState);
            };
            // Initialize the select all/unselect all buttons
            var $unselectAll = $copado('<button id="unselectAll">Unselect All</button>').on('click', (event) => {
                event.preventDefault();
                selectAll(false);
            });

            var $selectAll = $copado('<button id="selectAll">Select All</button>').on('click', (event) => {
                event.preventDefault();
                selectAll(true);
            });
            this.eltMain.find('.jqx-grid-pager > div').prepend($unselectAll).prepend($selectAll);
        }
    };

    MetadataGrid3.prototype._createCacheDeleteButton = function () {
        var $btn = $copado('[id$=removeCache]');
        this._createCacheDeleteButtonText = this._createCacheDeleteButtonText || $copado('[id$=removeCache]').html() || '';
        var text = this._createCacheDeleteButtonText;

        if (!this.allMetaData_cachedDate) {
            $copado('[id*=removeCacheContainer]').hide();
        } else {
            $copado('[id*=removeCacheContainer]').show();
            text = this._createCacheDeleteButtonText.replace('__DATE__', this.allMetaData_cachedDate);
            $btn.html(text);
        }

        if (this.filterByType) {
            text = text.replace('__METATYPE__', 'for ' + this.filterByType || '');
            $btn.html(text);
        } else {
            text = text.replace('__METATYPE__', '');
            $btn.html(text);
        }

        $btn.show();
    };

    MetadataGrid3.defaultTypes =
        'ActionLinkGroupTemplate,AnalyticSnapshot,ApexClass,ApexComponent,ApexPage,ApexTestSuite,ApexTrigger,AppMenu,ApprovalProcess,AssignmentRule,AssignmentRules,AuraDefinitionBundle,AuthProvider,AutoResponseRule,AutoResponseRules,BrandingSet,BusinessProcess,CallCenter,CaseSubjectParticle,Certificate,ChannelLayout,ChatterExtension,CleanDataService,Community,CompactLayout,ConnectedApp,ContentAsset,CorsWhitelistOrigin,CspTrustedSite,CustomApplication,CustomApplicationComponent,CustomFeedFilter,CustomField,CustomLabel,CustomLabels,CustomMetadata,CustomObject,CustomObjectTranslation,CustomPageWebLink,CustomPermission,CustomSite,CustomTab,Dashboard,DataCategoryGroup,DelegateGroup,Document,DuplicateRule,EclairGeoData,EmailServicesFunction,EmailTemplate,EmbeddedServiceBranding,EmbeddedServiceConfig,EscalationRule,EscalationRules,EventDelivery,EventSubscription,ExternalDataSource,ExternalServiceRegistration,FieldSet,FlexiPage,Flow,FlowCategory,FlowDefinition,GlobalValueSet,GlobalValueSetTranslation,Group,HomePageComponent,HomePageLayout,Index,InstalledPackage,Layout,LeadConvertSettings,Letterhead,LightningBolt,LightningExperienceTheme,ListView,MatchingRule,MatchingRules,NamedCredential,NetworkBranding,PathAssistant,PermissionSet,PlatformCachePartition,PostTemplate,Profile,ProfilePasswordPolicy,ProfileSessionSetting,Queue,QuickAction,RecordType,RemoteSiteSetting,Report,ReportType,Role,SamlSsoConfig,Scontrol,Settings,SharingCriteriaRule,SharingOwnerRule,SharingReason,SharingRules,SharingSet,SiteDotCom,StandardValueSet,StandardValueSetTranslation,StaticResource,SynonymDictionary,TopicsForObjects,ValidationRule,Vlocity,WebLink,Workflow,WorkflowAlert,WorkflowFieldUpdate,WorkflowKnowledgePublish,WorkflowOutboundMessage,WorkflowRule,WorkflowSend,WorkflowTask';

    MetadataGrid3.prototype.loadMetaDataTypes = function (callbackFinished, forceReloading, preDefinedSource) {
        var self = this;
        // never reload the metadata types
        if (this.filterByTypeList.length && !forceReloading) {
            if (callbackFinished) {
                callbackFinished(event);
            }
            return;
        }

        if (!preDefinedSource) {
            JsRemoting.metaData.getList(
                this.conf.data.orgId,
                this.conf.ns,
                (result) => {
                    if (!result || !result.length) {
                        // TODO: remove result row and comment out for alert when backend implements dx login for metadataTypesRetriever
                        result = MetadataGrid3.defaultTypes.split(',');
                    }

                    setWithoutRebinding(self.filterByTypeList, result);

                    // TODO: this shouldnt be here, since it's UI
                    if (self.isTypeFilterable) {
                        self.eltMetaDataTypeFilter.jqxComboBox('source', self.filterByTypeList);
                    }

                    if (callbackFinished) {
                        callbackFinished();
                    }
                },
                (event) => {
                    console.error('loadMetaDataTypes()', event);
                    if (callbackFinished) {
                        callbackFinished(event);
                    }
                },
                (event) => {
                    console.error('loadMetaDataTypes() #2', event);
                    if (callbackFinished) {
                        callbackFinished(event);
                    }
                }
            );
        } else {
            this.filterByTypeList = preDefinedSource;
            this.eltMetaDataTypeFilter.jqxComboBox('source', this.filterByTypeList);
        }
    };

    // read
    MetadataGrid3.prototype.loadSelectedMetaData = function (callbackFinished) {
        var selectedMetadata = dw.u.getSavedData(this.conf.data.id, this.conf.attachmentName, undefined, isRollback);

        if (selectedMetadata === false) {
            setWithoutRebinding(this.selectedMetadata, []);
            if (callbackFinished) {
                callbackFinished();
            }
            return;
        }

        setWithoutRebinding(this.selectedMetadata, selectedMetadata);

        if (callbackFinished) {
            callbackFinished();
        }
    };

    MetadataGrid3.prototype.loadSelectedMetaDataJSON = function (jsonData, callbackFinished) {
        var selectedMetadata = jsonData;

        if (selectedMetadata.length === false) {
            setWithoutRebinding(this.selectedMetadata, []);
            if (callbackFinished) {
                callbackFinished();
            }
            return;
        }
        setWithoutRebinding(this.selectedMetadata, selectedMetadata);
        this.render();
        if (callbackFinished) {
            callbackFinished();
        }
    };

    // Show tabs once metetadata is loaded
    MetadataGrid3.prototype.showTabs = function () {
        $copado('.mg2_tabs').removeClass('slds-hidden').addClass('slds-visible');
        $copado('[id$=metadataDiv]').removeClass('slds-hidden').addClass('slds-visible');
    };

    // (re) loads only the metadata, possibly filtered
    MetadataGrid3.prototype.loadMetaData = function (callbackFinished, forceRefresh) {
        var self = this;
        var conf = this.conf;
        var deletedMetadataItems = '';
        var url;

        if (this.isTypeFilterable && !this.filterByType) {
            this._setGridData([]); // set the data, even if it is emptyish.
            if (callbackFinished) {
                callbackFinished();
            }
            return;
        }

        if (!this.conf.data.orgId && !this.conf.data.stepId && !this.conf.data.deleteStepId) {
            return;
        }

        if (this.conf.data.stepId || this.conf.data.deleteStepId) {
            var allMetaData = [];
            if (this.conf.data.stepId) {
                if (this.conf.gridMode != 'dwOverviewGrid') {
                    allMetaData = JSON.parse(atob(dw.u.getFileContent(this.conf.data.stepId, this.conf.attachmentName)));
                } else {
                    let gitPromotionContent = dw.u.getFileContent(this.conf.data.stepId, this.conf.attachmentName + '_Git Promotion');
                    if (gitPromotionContent != null) {
                        allMetaData.push(...JSON.parse(atob(gitPromotionContent)));
                    }

                    let deleteMetadataContent = dw.u.getFileContent(this.conf.data.stepId, this.conf.attachmentName + '_Delete Metadata');
                    if (deleteMetadataContent != null) {
                        allMetaData.push(...JSON.parse(atob(deleteMetadataContent)));
                    }
                }
            }
            if (this.conf.data.deleteStepId) {
                const deleteMetadata = JSON.parse(atob(dw.u.getFileContent(this.conf.data.deleteStepId, this.conf.attachmentName)));
                allMetaData.push(...deleteMetadata);
            }
            var existingFlag = false;

            //var testclasses = dw.u.getAttach(this.conf.data.stepId,'Test Classes');
            var testClassFile = dw.u.getFileContent(this.conf.data.stepId, 'Test Classes');
            var testClasses;
            if (testClassFile && testClassFile !== null) {
                testClasses = JSON.parse(atob(dw.u.getFileContent(this.conf.data.stepId, 'Test Classes')));
                testClasses.forEach((testclass) => {
                    testclass.t = 'ApexClass';
                    testclass.to = true;
                    allMetaData.push(testclass);
                });
            }

            for (var j = 0; j < self.selectedMetadata.length; j++) {
                for (var i = 0; i < allMetaData.length; i++) {
                    if (allMetaData[i].n == self.selectedMetadata[j].n) {
                        existingFlag = true;
                    }
                }

                if (existingFlag === false && !conf.isScalable) {
                    deletedMetadataItems += `${self.selectedMetadata[j].n}, `;
                }

                existingFlag = false;
            }

            if (deletedMetadataItems.length > 0) {
                deletedMetadataItems = deletedMetadataItems.slice(0, deletedMetadataItems.length - 2);
                alert(
                    'Previously selected ' +
                        deletedMetadataItems +
                        ' metadata item' +
                        (deletedMetadataItems.indexOf(',') > -1 ? 's are' : ' is') +
                        ' deleted from the source environment.\n\nPlease ignore this pop-up if you are already aware of this.'
                );
            }

            self.originalMetadata = JSON.parse(JSON.stringify(allMetaData));
            self.showTabs();
            self._setGridData(allMetaData);

            if (!this.isTypeFilterable) {
                self.eltGrid.jqxGrid('updatebounddata');
            }
            return;
        }

        url = conf.server.metadataUrl.replace(new RegExp('__ORGID__', 'g'), conf.data.orgId);
        url = this.filterByType ? url + '&type=' + (this.filterByType || '') + '&scalable=true' : url;

        if (this.conf.gridMode === 'Users') {
            url = this.conf.users_url;
        } else if (this.conf.gridMode === 'metadataselector' && window.rock !== undefined) {
            url = rock.config.metadata_url;
        }

        dw.u.getCachedRemote({
            url: url,
            name: this.filterByType || conf.attachmentName,
            parentId: conf.data.orgId,
            force: forceRefresh,
            synchronous: false,
            success: function (allMetaData, cachedDate) {
                var existingFlag = false;

                if (!allMetaData) {
                    allMetaData = [];
                }

                for (var j = 0; j < self.selectedMetadata.length; j++) {
                    for (var i = 0; i < allMetaData.length; i++) {
                        if (allMetaData[i].n == self.selectedMetadata[j].n) {
                            existingFlag = true;
                        }
                    }

                    if (existingFlag === false && !conf.isScalable) {
                        deletedMetadataItems += `${self.selectedMetadata[j].n}, `;
                    }

                    existingFlag = false;
                }

                if (deletedMetadataItems.length > 0) {
                    deletedMetadataItems = deletedMetadataItems.slice(0, deletedMetadataItems.length - 2);
                    alert(
                        'Previously selected ' +
                            deletedMetadataItems +
                            ' metadata item' +
                            (deletedMetadataItems.indexOf(',') > -1 ? 's are' : ' is') +
                            ' deleted from the source environment.\n\nPlease ignore this pop-up if you are already aware of this.'
                    );
                }

                self.showTabs();
                self._setGridData(allMetaData);
                self.allMetaData_cachedDate = cachedDate;
                self._createCacheDeleteButton();

                // refresh the grid/filter, so the column type has filter values
                if (!this.isTypeFilterable) {
                    self.eltGrid.jqxGrid('updatebounddata');
                }

                if (callbackFinished) {
                    callbackFinished(cachedDate);
                }
            },
            error: (error) => {
                console.error('MetadataGrid3.Error: ', error);
                if (callbackFinished) {
                    callbackFinished(error);
                }
            }
        });
    };

    // (re) loads all the data of the grid, does not render.
    MetadataGrid3.prototype.loadData = function (callbackFinished) {
        var self = this;

        this.loadSelectedMetaData((error) => {
            if (error) {
                console.error('MetadataGrid3.loadData() error=', error);
                alert(error);
                return;
            }
            if (self.isTypeFilterable) {
                self.loadMetaDataTypes();
                self.loadMetaData(callbackFinished);
            } else {
                self.loadMetaData(callbackFinished);
            }
        });
    };

    // calls the API to refresh the metadata attachment (filtered or not)
    MetadataGrid3.prototype.refreshCache = function (callbackFinished) {
        var self = this;
        lockScreen();

        this.loadMetaData((cachedDate) => {
            console.info('MetadataGrid3.refreshCache() grid data refreshed');

            self.render();
            unlockScreen();
            if (callbackFinished) {
                callbackFinished(cachedDate);
            }
        }, true);
    };

    // changes the grid data, replacing whatever is in there now.
    MetadataGrid3.prototype._matchSelectedItemsWithAllMetaData = function (allMetaData) {
        var i,
            e,
            t,
            idx_allItems = {};
        // create a quick index of all the metadata items.
        if (!allMetaData) {
            allMetaData = [];
        }
        for (i = 0; i < allMetaData.length; i++) {
            e = allMetaData[i];
            e.s = e.s || false;
            idx_allItems[e.t + ' ' + e.n] = e;
        }

        if (this.conf.gridMode === 'gitCommit' || this.conf.gridMode === 'gitCommitCompare') {
            for (i = 0; i < allMetaData.length; i++) {
                e = allMetaData[i];
                e.r = e.r || false;
            }
        }

        // now, try to find the selected items. If not found, add them to the allMetaData array.
        // the grid will filter those if needed.
        var selectionFlag =
            allMetaData.length == 0 && this.conf.gridMode === 'gitCommitLegacy' && this.selectedMetadata && this.selectedMetadata[0].cmm
                ? true
                : false;
        for (i = 0; i < this.selectedMetadata.length; i++) {
            e = this.selectedMetadata[i];
            if (selectionFlag) {
                e.s = false;
            } else {
                e.s = true;
            }

            t = idx_allItems[e.t + ' ' + e.n];
            if (t) {
                t.s = true;
                // This line mark, if needed, selected metadata as "Retrieve Only".
                // When it comes from: Recommit User Story feature.
                t.r = e.r;
            } else {
                allMetaData.push(e);
            }
        }
        if (selectionFlag) {
            this.selectedMetadata = [];
        }
        return selectionFlag;
    };

    var getRetrieveEndpointModel = (metaDataParam) => {
        var data = {
            name: metaDataParam.n,
            type: metaDataParam.t
        };

        return data;
    };

    // changes the grid data, replacing whatever is in there now.
    MetadataGrid3.prototype._setGridData = function (allMetaDataParam) {
        var i,
            e,
            eltsWithRetrieveOnly = [];
        var idx_allItems = {};
        var data = {};
        let compare = '';

        this._matchSelectedItemsWithAllMetaData(allMetaDataParam);

        if (this.conf.gridMode === 'gitCommitCompare' && allMetaDataParam) {
            for (i = 0; i < allMetaDataParam.length; i++) {
                // Check that the row is not vlocity
                if (!allMetaDataParam[i].v) {
                    data = getRetrieveEndpointModel(allMetaDataParam[i]);
                    if(!allMetaDataParam[i].r){
                        compare = `<a type="Button" class="compareBtn" style="font-size: 12px;color: #1589EE" data-index="${i}" data-name="${data.name}" data-type="${data.type}" onclick="jqx.retrieveCompareData(this)" >
                        <img src="${metadataGridImagesPath}/compare.png" />
                        <span>Compare</span>
                        </a>`;
                    }
                     
                    allMetaDataParam[i]['ch'] = `<div id="compareCell" class="slds-media slds-media_center slds-p-left_medium">
                        <div id="compareMsgWrapper">
                            <div id="compareMsg">`+ compare+                              
                            `</div>
                            <div id="differencesBothMsg" style="display: none;">
                                <a type="Button" class="diffBtn" style="font-size: 12px;color: #1589EE" data-index="${i}" onclick="jqx.showDifferences(this)" >
                                    <img src="${metadataGridImagesPath}/differences_both_icon.png" />
                                    <span>View differences</span>
                                </a>
                            </div>
                            <div id="differencesSourceAddedMsg" style="display: none;">
                                <a type="Button" class="diffBtn" style="font-size: 12px;color: #1589EE" data-index="${i}" onclick="jqx.showDifferences(this)" >
                                    <img src="${metadataGridImagesPath}/differences_source_added_icon.png" />
                                    <span>View differences</span>
                                </a>
                            </div>
                            <div id="differencesSourceDeletedMsg" style="display: none;">
                                <a type="Button" class="diffBtn" style="font-size: 12px;color: #1589EE" data-index="${i}" onclick="jqx.showDifferences(this)" >
                                    <img src="${metadataGridImagesPath}/differences_source_deleted_icon.png" />
                                    <span>View differences</span>
                                </a>
                            </div>
                            <div id="noDifferencesMsg" style="display: none;">
                                <a type="Button" class="diffBtn" style="font-size: 12px; color: #1589EE;" data-index="${i}" onclick="jqx.showDifferences(this)" >
                                    <img src="${metadataGridImagesPath}/compare.png" />
                                    <span>No differences</span>
                                </a>
                            </div>
                            <div id="loadingMsg" style="display: none;">
                                <div role="status" class="slds-spinner slds-spinner_brand slds-spinner_x-small slds-input__spinner">
                                    <div class="slds-spinner__dot-a"></div>
                                    <div class="slds-spinner__dot-b"></div>
                                </div>
                            </div>
                            <div id="errorMsg" style="display: none;">
                                <a type="Button" style="font-size: 12px; color: red;" data-index="${i}" data-name="${data.name}" data-type="${data.type}" onclick="jqx.retrieveCompareData(this)" class="errorBtn">
                                      <img src="${metadataGridImagesPath}/differences_error_icon.png" />
                                      <span>Error</span>
                                </a>
                            </div>
                        </div>
                    </div>`;                  
                } else {
                    data = getRetrieveEndpointModel(allMetaDataParam[i]);
                    allMetaDataParam[i]['ch'] = `<div id="previewCell" class="slds-media slds-media_center slds-p-left_medium">
                        <div id="compareMsgWrapper">
                            <div id="previewCellMsg">
                                <a type="Button" class="compareBtn" style="font-size: 12px;color: #1589EE" data-index="${i}" data-name="${data.name}" data-type="${data.type}" onclick="jqx.previewVlocityMetadata(this)">
                                    <img src="${metadataGridImagesPath}/compare.png" />
                                    <span>Preview</span>
                                </a>
                            </div>
                            <div id="previewErrorMsg" style="display: none;">
                                <a type="Button" style="font-size: 12px; color: red;" data-index="${i}" data-name="${data.name}" data-type="${data.type}" class="errorBtn">
                                      <img src="${metadataGridImagesPath}/differences_error_icon.png" />
                                      <span>Preview failed</span>
                                </a>
                            </div>
                            <div id="previewLoadingMsg" style="display: none;">
                                <div role="status" class="slds-spinner slds-spinner_brand slds-spinner_x-small slds-input__spinner">
                                    <div class="slds-spinner__dot-a"></div>
                                    <div class="slds-spinner__dot-b"></div>
                                </div>
                            </div>
                        </div>
                    </div>`;
                }
            }
        }

        if (this.conf.gridMode === 'gitCommit' || this.conf.gridMode === 'gitCommitCompare' || this.conf.gridMode === 'gitCommitLegacy') {
            // save all the .r selections, rebind the data, and restore them in the new dataset.
            for (i = 0; i < this.selectedMetadata.length; i++) {
                e = this.selectedMetadata[i];
                if (e.r) {
                    eltsWithRetrieveOnly.push(e.t + ' ' + e.n);
                }
            }

            setWithoutRebinding(this.allMetaData, allMetaDataParam);

            for (i = 0; i < this.allMetaData.length; i++) {
                e = this.allMetaData[i];
                if (eltsWithRetrieveOnly.indexOf(e.t + ' ' + e.n) > -1) {
                    e.r = true;
                }
            }
        } else {
            setWithoutRebinding(this.allMetaData, allMetaDataParam);
        }
    };

    // append the items to .allMetaData and selectedMetadata (if the items are selected)
    MetadataGrid3.prototype.addItemsIfMissing = function (items) {
        // create a map of the existing metadata items
        var i,
            e,
            key,
            idx_allItems = {},
            idx_selectedItems = {};

        for (i = 0; i < this.allMetaData.length; i++) {
            e = this.allMetaData[i];
            idx_allItems[e.t + ' ' + e.n] = e;
        }

        for (i = 0; i < this.selectedMetadata.length; i++) {
            e = this.selectedMetadata[i];
            idx_selectedItems[e.t + ' ' + e.n] = e;
        }

        // now see if each item in items exists or needs to be added and/or selected.
        for (i = 0; i < items.length; i++) {
            e = items[i];
            key = `${e.t} ${e.n}`;
            if (idx_allItems[key]) {
                idx_allItems[key].s = e.s;
                // if the element is selected, ensure it is in the .selectedMetadata array
                if (e.s && !idx_selectedItems[key]) {
                    this.selectedMetadata.push(e);
                }
            } else {
                this.allMetaData.push(e);
                idx_allItems[key] = e;
                // if the element is selected, ensure it is in the .selectedMetadata array
                if (e.s) {
                    e.s = true; //this.selectedMetadata.push(e);
                }
            }
        }
    };

    // fetches the selected data again. Useful for the "cancel" action
    MetadataGrid3.prototype.reloadSelections = function (tabNumber) {
        var self = this;

        lockScreen();
        self.loadSelectedMetaData(() => {
            self._matchSelectedItemsWithAllMetaData(self.allMetaData);
            // NR: workaround because the selection show all the data, for some reason.
            if (self.eltTabs) {
                self.eltTabs.jqxTabs('select', tabNumber || 0);
            }
            self.render();
            unlockScreen();
        });
    };

    // fetches the selected data again. Useful for the "cancel" action
    MetadataGrid3.prototype.reloadSelectionsJSON = function (json, tabNumber) {
        var self = this;
        var islegacy;

        lockScreen();
        self.loadSelectedMetaDataJSON(json, function () {
            islegacy = self._matchSelectedItemsWithAllMetaData(self.allMetaData);
            // NR: workaround because the selection show all the data, for some reason.
            if (self.eltTabs) {
                self.eltTabs.jqxTabs('select', tabNumber || 0);
            }
            self.render();
            unlockScreen();
        });

        return !islegacy;
    };

    MetadataGrid3.prototype.refreshMetadataTypes = function () {
        lockScreen();
        $copado('[id*=removeMTCache]').hide();
        dw.u.deleteAttach(this.conf.data.orgId, 'MetadataTypes');
        this.loadMetaDataTypes(() => {
            unlockScreen();
        }, true);

        return false;
    };

    return MetadataGrid3;
})();

/*********** Functions to initialize a JQX table ***********/
((app) => {
    app.source = [];
    app.target = [];

    var iconsList = [
        {
            svgButtonsClass: 'refreshIcon',
            name: 'refresh'
        }
    ];
    var svgStruct = [];

    app.renderSVG = (elemId) => {
        var elem = $copado(elemId);
        var struct = svgStruct[elemId];
        var imageURL, SVG, SVGUse;

        if (struct) {
            imageURL = struct.imageURL;
            SVG = $copado('<svg/>', {
                class: struct.class
            });
            SVGUse = $copado('<use/>');

            SVGUse.attr('xlink:href', imageURL);
            elem.prepend(SVG.append(SVGUse));
            elem.html(elem.html());
        }
    };

    app.applyRenderSVG = () => {
        if (iconsList) {
            iconsList.forEach((element) => {
                app.renderSVG('.' + element.svgButtonsClass);
            });
        }
    };

    app.setSVGStruct = () => {
        if (globalSldsResourcePath) {
            iconsList.forEach((item) => {
                svgStruct['.' + item.svgButtonsClass] = {
                    imageURL: `${globalSldsResourcePath}/icons/utility-sprite/svg/symbols.svg#${item.name}`,
                    class: 'slds-button__icon'
                };
            });
        }
    };

    var setWithoutRebinding = (list, newList) => {
        list.splice(0, list.length); // clear the array, without re-binding it.
        while (newList.length) {
            Array.prototype.push.apply(list, newList.splice(0, 10000));
        }
    };

    // Refresh metadata cache of subjected org credential. @see app.config.data.orgId
    app.refreshCache = () => {
        app.grid.refreshCache();
        rerenderRefreshCachePoller();
    };

    app.comparisonState = [];

    app.assignState = () => {
        for (let i = 0; i < jqx.comparisonState.length; i++) {
            if (jqx.comparisonState[i]) {
                $copado('.mg2_jqxgrid').jqxGrid('setcellvalue', i, 'ch', jqx.comparisonState[i]);
            }
        }
    };

    var handleCompareMessages = (index, messageId, additionalDetails) => {
        var messages = $copado(`.compareBtn[data-index="${index}"]`).closest('#compareMsgWrapper').children();
        var localElem, outerHtml;

        messages.each((i, msg) => {
            $copado(msg).css('display', 'none');
        });

        localElem = $copado(`.compareBtn[data-index="${index}"]`).closest('#compareMsgWrapper').find(`#${messageId}`);

        if (localElem.length > 0) {
            $copado(localElem).css('display', 'block');

            if (additionalDetails) {
                $copado(localElem).attr('title', additionalDetails);
            }

            if ($copado(localElem).attr('id').indexOf('compareMsg') === -1) {
                $copado(localElem).css('padding-left', '1rem');

                outerHtml = $copado('<div>')
                    .append(
                        $copado('<div id="compareMsgWrapper">').append(
                            $copado(`.compareBtn[data-index="${index}"]`).closest('#compareMsgWrapper').children()
                        )
                    )
                    .html();

                if (outerHtml.length > 0) {
                    app.comparisonState[index] = outerHtml;
                    $copado('.mg2_jqxgrid').jqxGrid('setcellvalue', index, 'ch', outerHtml);
                }
            }
        }
    };

    var checkLoadings = (index, messageId, additionalDetails) => {
        var interval = setInterval(() => {
            var msg = messageId;
            var elem = $copado(`.compareBtn[data-index="${index}"]`);
            var isDataRetrieved = jqx.source[index] !== undefined;

            if (elem.length > 0 && isDataRetrieved) {
                handleCompareMessages(index, msg, additionalDetails);

                clearInterval(interval);
            }
        }, 1000);
    };

    var showCompareColumnMessage = (messageId, index, additionalDetails) => {
        var localElem = $copado(`.compareBtn[data-index="${index}"]`).closest('#compareMsgWrapper').find(`#${messageId}`);

        if (localElem.length > 0) {
            handleCompareMessages(index, messageId, additionalDetails);
        } else {
            checkLoadings(index, messageId, additionalDetails);
        }
    };

    var httpRequest = (endpoint, elem, cbOnEnd, direction, index) => {
        showCompareColumnMessage('loadingMsg', index);

        sforce.connection.remoteFunction({
            url: endpoint,
            requestHeaders: {
                'Content-Type': 'application/json',
                'cache-control': ' no-cache',
                userId: _temp_conf.userId,
                orgId: _temp_conf.orgId,
                token2: _temp_conf.token2
            },
            method: 'GET',
            onSuccess: (response) => {
                direction == 'source' ? (app.source[index] = response) : (app.target[index] = response);
                cbOnEnd && cbOnEnd();
            },
            onFailure: (error) => {
                try {
                    var jsonObj = JSON.parse(error);
                    var addMsg = jsonObj.error;
                } catch (ex) {
                    var xmlDOM = new DOMParser().parseFromString(error, 'text/xml');
                    addMsg = xmlDOM && xmlDOM.querySelector('title') ? xmlDOM.querySelector('title').textContent : '';
                }

                showCompareColumnMessage('errorMsg', index, addMsg);
                console.error(error);
            }
        });
    };

    app.showDifferences = (elem) => {
        var index = $copado(elem).data('index');
        if (isRollback) {
            assignFileData('', '');
            var targetJSON = JSON.parse(app.target[index]);
            var sourceJSON = app.source[index];
            window.preSourceRollback = [sourceJSON, ''];
            var targetJSONbytes = targetJSON.zipBytes;
            var zip = new JSZip(targetJSONbytes, { base64: true });
            var bundleTarget = [zip, Object.keys(zip.files)];
            var preTarget = [];
            preTarget[0] =
                Object.keys(bundleTarget[0].files)[0] != 'package.xml' ? bundleTarget[0].file(Object.keys(bundleTarget[0].files)[0]).asText() : '';
            preTarget[1] = bundleTarget[1][0];
            window.preTargetRollback = preTarget;
        } else {
            assignFileData(JSON.parse(app.source[index]).zipBytes, JSON.parse(app.target[index]).zipBytes);
        }
    };

    var isZipBytesEqual = (zipbSource, zipbTarget) => {
        if (!zipbSource && zipbTarget) {
            return false;
        }
        var zip1 = new JSZip(zipbSource, { base64: true });
        var zip2 = new JSZip(zipbTarget, { base64: true });
        var isEqual = true;
        var currentName;
        for (var i = 0; i < Object.keys(zip1.files).length; i++) {
            currentName = Object.keys(zip1.files)[i];
            if (currentName && currentName.toLowerCase() != 'package.xml') {
                if (zip1.file(currentName).asText() != zip2.file(currentName).asText()) {
                    isEqual = false;
                }
            }
        }
        return isEqual;
    };

    app.previewVlocityMetadata = (elem) => {
        if (isRollback) {
            showCompareColumnMessage('previewLoadingMsg', index);
            var name = $copado(elem).attr('data-name');
            var type = $copado(elem).attr('data-type');
            var index = $copado(elem).data('index');
            var gitPromotionZip;
            var deleteMetadataZip;

            if (jqxdatatable_config.data.stepId) {
                let gitPromotionContent = dw.u.getFileContent(jqxdatatable_config.data.stepId, 'Rollback vlocity.zip');
                if (gitPromotionContent != null) {
                    gitPromotionZip = new JSZip(gitPromotionContent, { base64: true });
                }
            }

            if (jqxdatatable_config.data.deleteStepId) {
                let deleteMetadataContent = dw.u.getFileContent(jqxdatatable_config.data.deleteStepId, 'Rollback vlocity.zip');
                if (deleteMetadataContent != null) {
                    deleteMetadataZip = new JSZip(deleteMetadataContent, { base64: true });
                }
            }
            var targetText = 'PREVIEW NOT AVAILABLE';
            var preTarget = [];
            var sourceContent;
            if (gitPromotionZip && gitPromotionZip.file('vlocity/' + type + '/' + name + '/' + name + '_DataPack.json')) {
                sourceContent = gitPromotionZip.file('vlocity/' + type + '/' + name + '/' + name + '_DataPack.json');
            } else if (deleteMetadataZip && deleteMetadataZip.file('vlocity/' + type + '/' + name + '/' + name + '_DataPack.json')) {
                sourceContent = deleteMetadataZip.file('vlocity/' + type + '/' + name + '/' + name + '_DataPack.json');
            } else {
                showCompareColumnMessage('previewErrorMsg', index);
                return;
            }

            app.source[index] = sourceContent.asText();
            app.target[index] = targetText;
            preTarget[0] = targetText;
            window.preSourceRollback = [app.source[index], ''];
            window.preTargetRollback = preTarget;
            app.showDifferences(elem);
        }
    };

    app.retrieveCompareData = (elem) => {
        var index = $copado(elem).data('index');
        var baseUrl = jqxdatatable_config.server.baseUrl;
        var url = 'metadata/retrieve?targetOrgId=ORG_ID&metadataType=TYPE&metadataFullName=NAME';
        var name = $copado(elem).attr('data-name');
        var type = $copado(elem).attr('data-type');
        var sourceOrgId = jqxdatatable_config.data.orgId;
        var targetOrgId = jqxdatatable_config.data.targetOrgId;

        var sourceUrl =
            baseUrl +
            url
                .replace(/ORG_ID/, sourceOrgId)
                .replace(/TYPE/, type)
                .replace(/NAME/, window.escape(name));
        var targetUrl =
            baseUrl +
            url
                .replace(/ORG_ID/, targetOrgId)
                .replace(/TYPE/, type)
                .replace(/NAME/, window.escape(name));

        var deferreds = [];
        var deferredSource = new $copado.Deferred();
        var deferredTarget = new $copado.Deferred();
        deferreds.push(deferredTarget);

        if (isRollback) {
            var gitPromotionZip;
            var deleteMetadataZip;

            if (jqxdatatable_config.data.stepId) {
                let gitPromotionContent = dw.u.getFileContent(jqxdatatable_config.data.stepId, 'Rollback metadata.zip');
                if (gitPromotionContent != null) {
                    gitPromotionZip = new JSZip(gitPromotionContent, { base64: true });
                }
            }

            if (jqxdatatable_config.data.deleteStepId) {
                let deleteMetadataContent = dw.u.getFileContent(jqxdatatable_config.data.deleteStepId, 'Rollback metadata.zip');
                if (deleteMetadataContent != null) {
                    deleteMetadataZip = new JSZip(deleteMetadataContent, { base64: true });
                }
            }

            const nestedMetadataTypes = {
                CustomField: 'objects:object',
                ValidationRule: 'objects:object',
                WorkflowFieldUpdate: 'workflows:workflow',
                WorkflowAlert: 'workflows:workflow',
                WorkflowTask: 'workflows:workflow',
                WorkflowRule: 'workflows:workflow',
                FieldSet: 'objects:object',
                WebLink: 'objects:object',
                CustomLabel: 'labels:labels',
                CompactLayout: 'objects:object'
            };

            var folderAndExt = metadataTypes['type:' + type];
            if (!folderAndExt && nestedMetadataTypes[type] !== undefined) {
                folderAndExt = nestedMetadataTypes[type];
                if (type === 'CustomLabel') {
                    name = 'CustomLabels';
                } else {
                    name = name.split('.')[0];
                }
            }
            if (!folderAndExt) {
                showCompareColumnMessage('errorMsg', index, 'Metadata type not supported for comparison');
                return;
            }

            var ext = folderAndExt.split(':')[1];
            var folder = folderAndExt.split(':')[0];
            if (gitPromotionZip && gitPromotionZip.file(folder + '/' + name + '.' + ext) != null) {
                app.source[index] = gitPromotionZip.file(folder + '/' + name + '.' + ext).asText();
            } else if (deleteMetadataZip && deleteMetadataZip.file(folder + '/' + name + '.' + ext) != null) {
                app.source[index] = deleteMetadataZip.file(folder + '/' + name + '.' + ext).asText();
            } else {
                app.source[index] = '';
            }
        } else {
            deferreds.push(deferredSource);
            httpRequest(
                sourceUrl,
                elem,
                () => {
                    deferredSource.resolve();
                },
                'source',
                index
            );
        }

        httpRequest(
            targetUrl,
            elem,
            () => {
                deferredTarget.resolve();
            },
            'target',
            index
        );

        $copado.when.apply(this, deferreds).then(function () {
            var targetJSON = JSON.parse(app.target[index]);
            var sourceJSON;
            if (isRollback) {
                sourceJSON = app.source[index];
            } else {
                sourceJSON = JSON.parse(app.source[index]);
            }
            var additionalMessage = '\nClick here to repeat the callout.';

            if (
                (isRollback || sourceJSON.success) &&
                targetJSON.success &&
                (isRollback || !sourceJSON.messages || (sourceJSON.messages && !sourceJSON.messages[0].problem)) &&
                (!targetJSON.messages || (targetJSON.messages && !targetJSON.messages[0].problem))
            ) {
                if (isZipBytesEqual(sourceJSON.zipBytes, targetJSON.zipBytes) || (isRollback && sourceJSON == preTarget[0])) {
                    showCompareColumnMessage('noDifferencesMsg', index);
                } else {
                    showCompareColumnMessage('differencesBothMsg', index);
                }
            } else {
                if (targetJSON.messages && targetJSON.messages[0].problem && targetJSON.messages[0].problem.includes('cannot be found')) {
                    // Metadata doesn't exist on target
                    showCompareColumnMessage('differencesSourceAddedMsg', index, 'New Metadata will be added to target');
                } else if (sourceJSON.messages && sourceJSON.messages[0].problem && sourceJSON.messages[0].problem.includes('cannot be found')) {
                    // Metadata doesn't exist on source
                    showCompareColumnMessage('differencesSourceDeletedMsg', index, 'Metadata has been deleted in source');
                } else {
                    showCompareColumnMessage(
                        'errorMsg',
                        index,
                        !sourceJSON.success
                            ? sourceJSON.error + ' (Source)' + additionalMessage
                            : !targetJSON.success
                            ? targetJSON.error + ' (Target)' + additionalMessage
                            : sourceJSON.messages && sourceJSON.messages[0].problem
                            ? sourceJSON.messages[0].problem + ' (Source)' + additionalMessage
                            : targetJSON.messages[0].problem + ' (Target)' + additionalMessage
                    );
                }
            }
        });
    };

    var getPreSelection = (attachmentId, isRollback, testClsFileId, deletePreselectionId) => {
        if (attachmentId || deletePreselectionId) {
            app.orgMD = app.orgMD || [];
            if (isRollback) {
                var savedItems = [];
                if (attachmentId) {
                    var savedItemsGp = dw.u.getFileById(attachmentId);
                    if (savedItemsGp) {
                        savedItemsGp = Base64.decode(savedItemsGp[0].VersionData);
                        savedItems.push(...$copado.parseJSON(savedItemsGp));
                    }
                }

                if (deletePreselectionId) {
                    var savedItemsDm = dw.u.getFileById(deletePreselectionId);
                    if (savedItemsDm) {
                        savedItemsDm = Base64.decode(savedItemsDm[0].VersionData);
                        savedItems.push(...$copado.parseJSON(savedItemsDm));
                    }
                }

                if (testClsFileId) {
                    var testclasses = dw.u.getFileById(testClsFileId);
                    if (testclasses) {
                        testclasses = Base64.decode(testclasses[0].VersionData);
                        testclasses = $copado.parseJSON(testclasses);
                        testclasses.forEach((testclass) => {
                            testclass.t = 'ApexClass';
                            testclass.to = true;
                            savedItems.push(testclass);
                        });
                    }
                }

                setWithoutRebinding(app.orgMD, savedItems);
                var selectionFlag = app.grid.reloadSelectionsJSON(app.orgMD, 1);
                selectionFlag && app.grid._reapplyFilters(1);
            } else {
                var savedItems = dw.u.getAttachById(attachmentId);
                if (savedItems) {
                    savedItems = Base64.decode(savedItems[0].Body);
                    savedItems = $copado.parseJSON(savedItems);
                    setWithoutRebinding(app.orgMD, savedItems);
                    var selectionFlag = app.grid.reloadSelectionsJSON(app.orgMD, 1);
                    selectionFlag && app.grid._reapplyFilters(1);
                } else {
                    alert('Could not load selections from other User Story commits.');
                }
            }
        }
    };

    var returnParameter = (param) => {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var pValue = url.searchParams.get(param);

        return pValue;
    };

    var prepareGrid = () => {
        var previewOnlyColumns;

        app.grid = new MetadataGrid3(app.conf);

        if (app.grid.conf.previewOnly) {
            app.grid.allMetaData = app.grid.selectedMetadata;
            previewOnlyColumns = app.grid._getColumnsByGridMode;
        }

        app.grid.render(() => {
            if (app.conf.scalableGrid === 'true') {
                app.grid.loadMetaDataTypes();
            }
        });
        app.grid.loadMetaData();
        app.datasource = app.grid.datasource;
    };

    app.initJQXDataTable = (config, force, isRollback) => {
        var preselectionId;
        var testClsFileId;
        var deletePreselectionId;

        if (config) {
            app.conf = config;
            app.forceCall = force;
            //do normalize ns to empty string or value
            app.conf.ns = app.conf.ns || '';

            if (app.conf.scalableGrid == 'true') {
                app.conf.isScalable = app.conf.scalableGrid;
            }

            //prepare metadataGrid3 render it in the page, load data and assign to object prop
            prepareGrid();
            app.conf.elts.gitCommitMainForm = document.querySelector('[id$=selectChangesForm]');
            preselectionId = returnParameter('MetadataPreselectionId');
            deletePreselectionId = returnParameter('DeleteMetadataPreselectionId');
            if (config.gridMode === 'dwOverviewGrid') {
                testClsFileId = returnParameter('TestClassPreselectionId');
            }
            if (isRollback && !preselectionId && !deletePreselectionId) {
                app.orgMD = app.orgMD || [];
                setWithoutRebinding(app.orgMD, app.grid.allMetaData);
                var selectionFlag = app.grid.reloadSelectionsJSON(app.orgMD, 1);
                selectionFlag && app.grid._reapplyFilters(1);
            } else if (isRollback) {
                app.grid.allMetaData.forEach((metadataItem) => {
                    metadataItem.s = false;
                });
            }
            getPreSelection(preselectionId, isRollback, testClsFileId, deletePreselectionId);
        }
    };

    $(document).ready(() => {
        app.setSVGStruct();
        app.applyRenderSVG();
        app.initJQXDataTable(jqxdatatable_config, false, isRollback);
    });
})(jqx);
