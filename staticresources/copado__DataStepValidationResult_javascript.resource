// Data Step Validation Result Javascript
var dsvr = dsvr || {};
var globalSldsResourcePath = globalSldsResourcePath ? globalSldsResourcePath : undefined;

function refreshDataTable() {
    dsvr.startDataTable('validationErrorsTable');
    dsvr.contractDataTable('validationErrorsTable');
}

function openModal() {
    $copado('[id="myModal"]').show();
}
function closeModal() {
    $copado('[id="myModal"]').hide();
}

(app => {
    'use strict';
    var tablesList = ['validationErrorsTable'];
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
                [0, 'asc'],
                [1, 'asc'],
                [2, 'asc']
            ],
            columnDefs: [
                { orderable: true, targets: 0 },
                { orderable: true, targets: 1 },
                { orderable: true, targets: 2 }
            ],
            lengthMenu: [
                [10, 25, 50, -1],
                [10, 25, 50, 'All']
            ],
            language: {
                search: '',
                searchPlaceholder: 'Search...',
                emptyTable: 'No errors found.'
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
        app.expandDataTables();
    };

    app.onCompleteFunctionToreRender = () => {
        dsvr.applyRenderSVG();
        app.startDataTables();
        app.contractDataTables();
    };

    $(document).ready(() => {
        app.setSVGStruct();
        app.applyRenderSVG();
        app.startDataTables();
    });
})(dsvr);
