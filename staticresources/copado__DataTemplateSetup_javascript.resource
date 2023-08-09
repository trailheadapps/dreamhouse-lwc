// Data Template Setup Javascript
var dts = dts || {};
var globalSldsResourcePath = globalSldsResourcePath ? globalSldsResourcePath : undefined;

(app => {
    'use strict';
    var tablesList = ['objectsTable', 'relatedParentObjectsTable', 'relatedChildObjectsTable'];
    var tableIdPaginationObject = {};

    var iconsList = [
        {
            svgButtonsClass: 'warningToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'warning'
        },
        {
            svgButtonsClass: 'successToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'success'
        },
        {
            svgButtonsClass: 'errorToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'error'
        },
        {
            svgButtonsClass: 'infoToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'check'
        },
        {
            svgButtonsClass: 'closeToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'close'
        },
        {
            svgButtonsClass: 'downIcon',
            styleClass: 'slds-icon_x-small',
            name: 'down'
        },
        {
            svgButtonsClass: 'info-icon',
            styleClass: 'slds-icon_x-small',
            name: 'info'
        },
        {
            svgButtonsClass: 'deleteIcon',
            styleClass: 'slds-icon_x-small',
            name: 'delete'
        },
        {
            svgButtonsClass: 'refreshIcon',
            styleClass: 'slds-icon_x-small',
            name: 'refresh'
        }
    ];

    var svgStruct = [];

    var createTooltip = event => {
        var elem = event.currentTarget;
        var text = elem.getAttribute('tooltip-text');

        elem.setAttribute('tooltip', text);

        var tooltipWrap = document.createElement('div');

        tooltipWrap.className = 'co-tooltip';
        tooltipWrap.appendChild(document.createTextNode(text)); //add the text node to the newly created div.

        var firstChild = document.body.firstChild;
        firstChild.parentNode.insertBefore(tooltipWrap, firstChild);
        var elemHeight = elem.offsetHeight;
        var elemWidth = elem.offsetWidth;

        var offset = 6;
        var linkProps = $copado(elem).offset();
        var leftPosition = linkProps.left - elemWidth / 2 > 0 ? linkProps.left - elemWidth / 2 : linkProps.left;
        var topPosition = linkProps.top - offset;

        tooltipWrap.setAttribute('style', 'top:' + topPosition + 'px;' + 'left:' + leftPosition + 'px;');

        var timeout = setTimeout(() => {
            tooltipWrap.style.transform = 'translateY(-100%) scale(1)';
            clearTimeout(timeout);
        }, 0);
    };

    var destroyTooltip = event => {
        var elem = event.currentTarget;
        elem.removeAttribute('tooltip');
        document.querySelector('.co-tooltip').remove();
    };

    app.tooltipHandler = () => {
        var tooltipList = $copado('.copado-tooltip');
        tooltipList.each((index, tp) => {
            if (tp.getAttribute('tooltip-text') !== '') {
                tp.addEventListener('mouseenter', createTooltip);
                tp.addEventListener('mouseleave', destroyTooltip);
            }
        });
    };

    app.toggleAdvanceDeploymentSettings = event => {
        $copado('#advanceDeploymentSettings')
            .toggleClass('slds-show')
            .toggleClass('slds-hide');
    };

    app.renderSVG = elemId => {
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
            iconsList.forEach(element => {
                app.renderSVG('.' + element.svgButtonsClass);
            });
        }
    };

    app.setSVGStruct = () => {
        var className;
        if (globalSldsResourcePath) {
            iconsList.forEach(item => {
                className = item.styleClass ? `slds-button__icon ${item.styleClass}` : 'slds-button__icon';
                svgStruct['.' + item.svgButtonsClass] = {
                    imageURL: `${globalSldsResourcePath}/icons/utility-sprite/svg/symbols.svg#${item.name}`,
                    class: className
                };
            });
        }
    };

    app.selectUnselectAll = (tableId, elemid) => {
        var table = $copado(`#${tableId}`);
        $copado('.slds-checkbox.row-select', table).prop('checked', $copado(`#${elemid}`).prop('checked'));
    };

    app.expandDataTable = tableId => {
        var rows, activePaginationSelected, table;
        var info = {};
        var currentPage = 0;
        var searchInput = $copado(`#${tableId}_wrapper #${tableId}_filter`).find('input');
        var sortOrderArray = [];
        var searchValue = searchInput.val();

        activePaginationSelected = $copado(`#${tableId}_length`)
            .find('select')
            .val();

        var table = $copado(`#${tableId}`).DataTable();
        // dataTable is the oldschool dataTables constructur, which returns a jQuery object. This jQuery object is enriched with a set of API methods in hungarian notation format, such as fnFilter, fnDeleteRow and so on.
        sortOrderArray = $copado(`#${tableId}`)
            .dataTable()
            .fnSettings().aaSorting;
        var tableData = {
            paginationSize: activePaginationSelected,
            currentPage: table.page.info().page,
            searchValue: searchValue,
            sortOrderArray: sortOrderArray
        };
        table.search('').draw();
        $copado(`#${tableId}_length`)
            .find('select')
            .val(-1)
            .trigger('change');
        tableIdPaginationObject[tableId] = tableData;
    };

    app.expandDataTables = () => {
        tablesList.forEach(tableId => {
            app.expandDataTable(tableId);
        });
    };

    app.contractDataTable = tableId => {
        var table = $copado(`#${tableId}`).DataTable();
        var searchInput = $copado(`#${tableId}_wrapper #${tableId}_filter`).find('input');

        $copado(`#${tableId}_length`)
            .find('select')
            .val(tableIdPaginationObject[tableId].paginationSize)
            .trigger('change');
        // dataTable is the oldschool dataTables constructur, which returns a jQuery object. This jQuery object is enriched with a set of API methods in hungarian notation format, such as fnFilter, fnDeleteRow and so on.
        $copado(`#${tableId}`)
            .dataTable()
            .fnSort(tableIdPaginationObject[tableId].sortOrderArray);

        table
            .page(tableIdPaginationObject[tableId].currentPage)
            .search(tableIdPaginationObject[tableId].searchValue)
            .draw(false);
    };

    app.contractDataTables = () => {
        tablesList.forEach(tableId => {
            app.contractDataTable(tableId);
        });
    };

    app.startDataTable = tableId => {
        $copado(`#${tableId}`).dataTable({
            paging: true,
            scrollCollapse: true,
            order: [
                [1, 'desc'],
                [2, 'asc']
            ],
            columnDefs: [
                { orderable: false, targets: 0 },
                { orderable: false, targets: -1 } // -1 is to remove sorting from last column
            ],
            lengthMenu: [
                [10, 25, 50, -1],
                [10, 25, 50, 'All']
            ],
            language: {
                search: '',
                searchPlaceholder: 'Search...',
                emptyTable: 'Please select the Template Source Org and Main Object before adding related fields and objects.'
            },
            fnPreDrawCallback: () => {
                $copado('#progress').show();
            },
            fnInitComplete: () => {
                $copado(`#${tableId}`).show();
                $copado('#progress').hide();
            },
            dom: '<"top"f>rt<"bottom"ilp><"clear">'
        });
    };

    app.startDataTables = () => {
        tablesList.forEach(tableId => {
            if ($copado(`#${tableId}`).dataTable) {
                app.startDataTable(tableId);
            }
        });
    };

    app.onClickFunction = () => {
        lockScreen();
        app.expandDataTables();
    };

    app.onCompleteFunctionToreRender = () => {
        dts.applyRenderSVG();
        app.startDataTables();
        app.contractDataTables();
        dts.tooltipHandler();
        unlockScreen();
    };

    var getTableId = () => {
        var activeTabId = $copado('.tabs > ul')
            .find('.slds-is-active > a')
            .attr('id');
        var data = {
            tableId: $copado(`#${activeTabId}-content`)
                .find('table')
                .attr('id'),
            selectAllInputId: $copado(`#${activeTabId}-content`)
                .find('table > thead')
                .find('input')
                .attr('id')
        };
        return data;
    };

    app.changeSelectAll = (tableId, elemId) => {
        var table = $copado(`#${tableId}`);
        var lst = $copado('.slds-checkbox.row-select', table);
        var count = 0;
        lst.each(function() {
            if ($copado(this).prop('checked') === true) {
                count++;
            }
        });
        var checkedBool = lst.length === count;
        $copado(`#${elemId}`).prop('checked', checkedBool);
    };

    app.setTab = tab => {
        var tabList = [
            'template-details',
            'object-fields',
            'related-parent-objects',
            'related-child-objects',
            'main-object-filter',
            'deployment-tasks-content'
        ];
        var tabId = tabList[tab];
        var tabs = $copado('.tabs').find('li');

        tabs.each((index, tab) => {
            if ($copado(tab).hasClass('slds-is-active')) {
                $copado(tab).removeClass('slds-is-active');
                $copado(tab)
                    .find('a')
                    .attr('aria-selected', false);
            }
        });

        tabList.forEach(tab => {
            if (tab === tabId) {
                $copado(`#${tab}-content`)
                    .addClass('slds-show')
                    .removeClass('slds-hide');
            } else {
                $copado(`#${tab}-content`)
                    .addClass('slds-hide')
                    .removeClass('slds-show');
            }
        });

        $copado(tabs[tab]).addClass('slds-is-active');
        $copado(tabs[tab])
            .find('a')
            .attr('aria-selected', true);
        $copado(tabs[tab])
            .find('a')
            .attr('aria-selected', true);

        var data = getTableId();
        if (data.tableId) {
            app.expandDataTable(data.tableId);
            app.changeSelectAll(data.tableId, data.selectAllInputId);
            app.contractDataTable(data.tableId);
        }
    };

    app.tabsHandler = () => {
        var tabs = $copado('.tabs').find('li.slds-tabs_default__item');
        var tabId = '';
        var tab = 0;

        // tabs click event
        tabs.click(event => {
            tabId = $copado(event.currentTarget)
                .find('a')
                .attr('id');
            tab = $copado('.tabs')
                .find('li>a')
                .index($copado(`#${tabId}`));
            app.setTab(tab);
        });
    };

    app.handleActiveCheckbox = () => {
        var dataTemplateName = $copado('[id$=dataTemplateName]').val() != null && $copado('[id$=dataTemplateName]').val() != '';
        var mainObject = $copado('[id$=mainObject]').val() != null || $copado('[id$=mainObjOutput]').text() != null;
        var schemaOrg =
            ($copado('[id$=schemaOrg]').val() != null && $copado('[id$=schemaOrg]').val() != '') || $copado('[id$=orgOutput]').text() != null;
        if (dataTemplateName && mainObject && schemaOrg) {
            $copado('[id$=activeTemplate]').prop('disabled', false);
        }
    };

    app.handlePicklist = event => {
        var elem = event.currentTarget;
        var list, elemsList, value;
        var currElem = null;

        if (
            $copado(elem)
                .parent()
                .hasClass('slds-is-open')
        ) {
            $copado(elem)
                .parent()
                .removeClass('slds-is-open');
        } else {
            $copado(elem)
                .parent()
                .addClass('slds-is-open');

            list = $copado(elem).siblings('div');
            elemsList = $copado(elem)
                .siblings()
                .find('li');

            $copado(document).mousedown(e => {
                currElem = null;

                if ($copado(e.target).closest('.slds-dropdown').length > 0) {
                    currElem = $copado(e.target).closest('.slds-dropdown');
                }
            });

            $copado(elem).blur(() => {
                if (currElem === null) {
                    $copado(elem)
                        .parent()
                        .removeClass('slds-is-open');
                }
            });

            $copado(elemsList).click(event => {
                if ($copado(event.currentTarget).hasClass('slds-dropdown__item')) {
                    value = $copado(event.currentTarget)
                        .text()
                        .trim();
                    $copado(elem)
                        .find('span')
                        .text(value);
                    $copado(elem)
                        .parent()
                        .find('input')
                        .val(value);

                    renderRelationAction();
                }

                $copado(elem)
                    .parent()
                    .removeClass('slds-is-open');
            });
        }
    };

    app.openModals = (param, contentValue) => {
        if (contentValue === 'none') {
            return;
        }
        $copado('[id=modal' + param + ']').show();
        $copado('[id=backDrop' + param + ']').show();
    };

    app.closeModals = param => {
        $copado('[id=modal' + param + ']').hide();
        $copado('[id=backDrop' + param + ']').hide();
    };

    app.createAutocomplete = (comboboxId, inputHiddenId) => {
        $copado.widget('custom.combobox', {
            _create: function() {
                this.wrapper = $copado('<span>')
                    .addClass('custom-combobox')
                    .insertAfter(this.element);

                this.element.hide();
                this._createAutocomplete();
            },

            _createAutocomplete: function() {
                var selected = this.element.children(':selected'),
                    value = selected.val() ? selected.text() : '';

                this.input = $copado('<input>')
                    .appendTo(this.wrapper)
                    .val(value)
                    .addClass('slds-select custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left')
                    .autocomplete({
                        delay: 0,
                        minLength: 0,
                        source: $copado.proxy(this, '_source'),
                        appendTo: '#mainObj',
                        open: () => {
                            $copado('ul.ui-menu').width(this.input.innerWidth());
                        },
                        create: function() {
                            $copado(this).data('ui-autocomplete')._renderItem = function(ul, item) {
                                var re = new RegExp('(' + this.term + ')', 'gi'),
                                    cls = 'ui-state-highlight',
                                    template = "<span class='" + (this.term.length > 0 ? cls : '') + "'>$1</span>",
                                    label = item.label.replace(re, template),
                                    $li = $copado('<li/>').appendTo(ul);

                                // Create and return the custom menu item content.
                                $copado('<div>')
                                    .html(label)
                                    .appendTo($li);
                                return $li;
                            };
                        }
                    })
                    .focus(event => {
                        if (event.currentTarget.value === '--None--') {
                            event.currentTarget.value = '';
                        }

                        try {
                            $copado(this.input).autocomplete('search', ' ');
                        } catch (ex) {
                            // nothing to worry about!unhandled part from jquery...'
                        }
                    });

                this._on(this.input, {
                    autocompleteselect: function(event, ui) {
                        ui.item.option.selected = true;
                        this._trigger('select', event, {
                            item: ui.item.option
                        });
                        $copado(`[id$=${inputHiddenId}]`).val(ui.item.option.value);
                        lockScreen();
                        renderTabsAfterObjectSelection();
                        // this.input.blur();
                    },
                    autocompletechange: '_removeIfInvalid'
                });
            },

            _source: function(request, response) {
                var fieldVal = $copado('#mainObject')
                    .siblings('span')
                    .find('.ui-autocomplete-input')
                    .val();

                if (request.term.trim() == '' && fieldVal.length > 0) {
                    request.term = fieldVal;
                }
                var matcher = new RegExp($copado.ui.autocomplete.escapeRegex(request.term), 'i');

                response(
                    this.element.children('option').map(function() {
                        var text = $copado(this).text();
                        if (this.value && (!request.term || matcher.test(text))) {
                            return {
                                label: text,
                                value: text,
                                option: this
                            };
                        }
                    })
                );
            },

            _removeIfInvalid: function(event, ui) {
                // Selected an item, nothing to do
                if (ui.item) {
                    return;
                }

                // Search for a match (case-insensitive)
                var value = this.input.val(),
                    valueLowerCase = value.toLowerCase(),
                    valid = false;
                this.element.children('option').each(function() {
                    if (
                        $copado(this)
                            .text()
                            .toLowerCase() === valueLowerCase
                    ) {
                        this.selected = valid = true;
                        return false;
                    }
                });

                // Found a match, nothing to do
                if (valid) {
                    return;
                }

                // Remove invalid value
                this.input.val('');
                this.element.val('');
                this.input.autocomplete('instance').term = '';
            }
        });

        $copado(`#${comboboxId}`).combobox();
    };

    app.redirectToRelationalDiagramLWC = (dataTemplateId, namespace) => {
        // for dev orgs it need to have c: but for namespace context in managed package it should be copado
        namespace = namespace == '' ? 'c' : 'copado';
        var compDefinition = {
            componentDef: `${namespace}:addRelationalDiagramContainer`,
            attributes: {
                recordId: dataTemplateId
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        window.open(`/one/one.app#${encodedCompDef}`, '_blank');
    };

    var wholeResponse = [];
    var wholeArrayParam = [];
    var exportName = '';

    var exportFinally = () => {
        var dataStr = JSON.stringify(wholeResponse, null, 4);
        var regexValue;
        for (let i = 0; i < wholeResponse.length; i++) {
            var key = wholeResponse[i].templateUUId;
            var newKey = ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
                (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
            );
            regexValue = new RegExp(key, 'g');
            dataStr = dataStr.replace(regexValue, newKey);
        }

        var encodedData = window.btoa(dataStr); // encode a string

        var byteCharacters = atob(encodedData);
        var byteArrays = [];
        var sliceSize = 512;
        var contentType = 'application/json';

        for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);

            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }

            var byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }

        var blob = new Blob(byteArrays, { type: contentType });
        var blobUrl = URL.createObjectURL(blob);
        var exportFileDefaultName = exportName;

        var linkElement = document.createElement('a');
        linkElement.setAttribute('href', blobUrl);
        linkElement.setAttribute('download', exportFileDefaultName);
        linkElement.click();
    };

    var createContentForEachTemplate = content => {
        var newContent = {
            objectFields: [],
            parentObjects: [],
            childObjects: []
        };

        if (content.selectableFieldsMap) {
            var fields = content.selectableFieldsMap;
            var objFields = {};
            for (var key in fields) {
                var parentObjectApiNameMap = fields[key].parentObjectApiNameMap;
                if (fields[key].isSelected && parentObjectApiNameMap && Object.keys(parentObjectApiNameMap).length == 0) {
                    objFields = {
                        name: fields[key].label,
                        apiName: fields[key].name
                    };

                    if (fields[key].useAsExternalId) {
                        objFields['useAsExternalId'] = true;
                    }

                    if (fields[key].contentValueUpdateValues) {
                        objFields['contentValueUpdateValues'] = fields[key].contentValueUpdateValues;
                    }

                    if (fields[key].fieldContentUpdate && fields[key].fieldContentUpdate !== 'none') {
                        objFields['fieldContentUpdate'] = fields[key].fieldContentUpdate;

                        if (fields[key].fieldContentUpdate === 'replace') {
                            if (fields[key].replaceValue) {
                                objFields['replaceValue'] = fields[key].replaceValue;
                            }

                            if (fields[key].replaceValueDate) {
                                objFields['replaceValueDate'] = fields[key].replaceValueDate;
                            }

                            if (fields[key].replaceValueDatetime) {
                                objFields['replaceValueDatetime'] = fields[key].replaceValueDatetime;
                            }

                            if (fields[key].replaceValueNumber && fields[key].replaceValueNumber > 0) {
                                objFields['replaceValueNumber'] = fields[key].replaceValueNumber;
                            }
                        }
                    }
                    newContent.objectFields.push(objFields);
                } else if (
                    fields[key].isSelected &&
                    parentObjectApiNameMap &&
                    Object.keys(parentObjectApiNameMap).length != 0 &&
                    (fields[key].deploymentTemplate !== 'Select Template' || Object.keys(parentObjectApiNameMap).indexOf('User') >= 0)
                ) {
                    objFields = {
                        name: fields[key].label,
                        apiName: fields[key].name
                    };
                    newContent.parentObjects.push(objFields);
                }
            }
            // child object field mapping
            var childRelations = content.selectableChildRelationsMap;
            for (var key in childRelations) {
                if (childRelations[key].isSelected && childRelations[key].deploymentTemplate !== 'Select Template') {
                    objFields = {
                        field: childRelations[key].field,
                        relationshipName: childRelations[key].relationshipName,
                        childSObject: childRelations[key].childSObject,
                        childSObjectLabel: childRelations[key].objectApiNameMap[childRelations[key].childSObject]
                    };
                    newContent.childObjects.push(objFields);
                }
            }
        }
        return newContent;
    };

    var queryAttachment = (param, cbOnEnd) => {
        var returnObj = new Object();
        var wholeObj = new Object();
        sforce.connection.query("SELECT Id,Name,Body FROM Attachment WHERE ParentId='" + param + "' AND Name = 'Template Detail' LIMIT 1", {
            onSuccess: function(res) {
                var contents = null;
                var relations = [];
                var filters = [];
                if (res.records) {
                    contents = JSON.parse(sforce.Base64Binary.prototype.decode(res.records.Body));
                    contents.parentObjectsReferenceList.forEach(function(idElem) {
                        var relationObject = {
                            templateUUId: idElem.templateId,
                            relationName: idElem.relationName
                        };
                        relations.push(relationObject);
                    });
                    contents.childrenObjectsReferenceList.forEach(function(idElem) {
                        var relationObject = {
                            templateUUId: idElem.templateId,
                            relationName: idElem.relationName,
                            childSObject: idElem.childSObject
                        };
                        relations.push(relationObject);
                    });

                    var dataTemplate = {
                        templateName: contents.dataTemplate.templateName,
                        templateMainObject: contents.dataTemplate.templateMainObject,
                        templateQueryLimit: contents.dataTemplate.templateQueryLimit,
                        templateDescription: contents.dataTemplate.templateDescription,
                        templateFilterLogic: contents.dataTemplate.templateFilterLogic,
                        templateAttachmentOptions: contents.dataTemplate.templateAttachmentOption,
                        templateBatchSize: contents.dataTemplate.templateBatchSize,
                        templateMatchOwners: contents.dataTemplate.templateMatchOwners,
                        templateMatchRecordTypes: contents.dataTemplate.templateMatchRecordTypes,
                        templateContinueOnError: contents.dataTemplate.templateContinueOnError,
                        templateActive: contents.dataTemplate.templateActive,
                        templateAttachmentType: contents.dataTemplate.templateSelectedAttachmentType
                    };

                    contents.queryFilterList.forEach(function(filterItem) {
                        var filterObject = {
                            order: filterItem.order,
                            operator: filterItem.operator,
                            fieldName: filterItem.fieldName,
                            fieldType: filterItem.fieldType,
                            finalValue: filterItem.finalValue
                        };

                        if (filterItem.input) {
                            filterObject['input'] = filterItem.input;
                        }
                        if (filterItem.numberInput) {
                            filterObject['numberInput'] = filterItem.numberInput;
                        }
                        if (filterItem.dateInput) {
                            filterObject['dateInput'] = filterItem.dateInput;
                        }
                        if (filterItem.dateTimeInput) {
                            filterObject['dateTimeInput'] = filterItem.dateTimeInput;
                        }

                        filters.push(filterObject);
                    });

                    returnObj.dataTemplate = dataTemplate;
                    returnObj.content = createContentForEachTemplate(contents);
                    returnObj.relationList = relations.length > 0 ? relations : [];
                    returnObj.filterList = filters.length > 0 ? filters : [];

                    wholeObj.templateUUId = param;
                    wholeObj.values = returnObj;

                    wholeResponse.push(wholeObj);

                    cbOnEnd && cbOnEnd();
                }
            },
            onFailure: function(r) {
                console.error(r);
            }
        });
    };

    app.exportTemplate = (arrayParam, mainName) => {
        wholeArrayParam = wholeArrayParam.concat(arrayParam);
        var deferredArray = [];
        if (mainName) {
            exportName = mainName;
        }

        for (let i = 0; i < arrayParam.length; i++) {
            var deferred = new $copado.Deferred();
            deferredArray.push(deferred);
            queryAttachment(arrayParam[i], deferred.resolve);
        }

        //waits for every callout in the for loop to be done via deferred pattern and then calls the final actions
        $copado.when.apply(this, deferredArray).then(() => {
            var nextArrayParam = [];
            for (let i = 0; i < wholeResponse.length; i++) {
                for (let j = 0; j < arrayParam.length; j++) {
                    if (wholeResponse[i].templateUUId == arrayParam[j]) {
                        var values = wholeResponse[i].values;
                        nextArrayParam = nextArrayParam.concat(values.relationList);
                    }
                }
            }

            if (nextArrayParam.length == 0) {
                exportFinally();
            } else {
                var newArrayParam = [];
                for (let i = 0; i < nextArrayParam.length; i++) {
                    if (wholeArrayParam.indexOf(nextArrayParam[i]) == -1) {
                        newArrayParam.push(nextArrayParam[i].templateUUId);
                    }
                }
                app.exportTemplate(newArrayParam);
            }
        });
    };

    $(document).ready(() => {
        app.setSVGStruct();
        app.applyRenderSVG();
        app.setTab(0);
        app.tabsHandler();
        app.startDataTables();
        app.handleActiveCheckbox();
        app.tooltipHandler();
    });
})(dts);
