/* Variables */
:root {
    --main-blue-color: #1589ee;
    --form-text-color: #080707;
    --actions-color: #006dcc;
}

/* Resets */
body {
    background-color: #f3f2f2 !important;
}

/* Container */
.co-dts-container {
    padding: 0 1rem;
    font-family: 'Salesforce Sans';
}

.co-dts-container hr {
    margin: 0 0 2rem 0;
}

.co-dts-container ol {
    display: block;
    list-style-type: decimal;
    margin-block-start: 1em;
    margin-block-end: 1em;
    margin-inline-start: 0px;
    margin-inline-end: 0px;
    padding-inline-start: 0px;
    word-break: break-all;
    margin: 0;
    padding: 0;
}

.co-dts-container .slds-page-header {
    background-color: #f7f9fb;
}

.co-dts-container .slds-page-header .slds-page-header__title {
    color: var(--form-text-color);
    font-size: 18px;
    font-weight: 600;
    line-height: 23px;
}

.co-dts-container .slds-text-title {
    color: #54698d;
    font-size: 12px;
    line-height: 15px;
    margin-bottom: 5px;
}

.co-dts-container .slds-page-header__detail-block .value {
    color: #16325c;
    font-size: 12px;
    line-height: 15px;
}

.co-dts-container .slds-tabs_card.slds-tabs_card {
    padding: 0 1rem 0.75rem 1rem;
}

.co-dts-container .form-wrapper {
    padding: 1.5rem 5rem 1.5rem 1.5rem;
}

.co-dts-container .table-wrapper {
    padding: 0.5rem 1.5rem;
}

.co-dts-container .info-wrapper {
    color: var(--main-blue-color);
    cursor: pointer;
}

.co-dts-container .slds-popover {
    position: absolute;
    left: 25px;
    top: 40px;
}

.co-dts-container .actions {
    color: var(--actions-color);
    font-size: 14px;
    line-height: 20px;
    margin-bottom: 3rem;
}

.co-dw-container .hide,
.slds-modal.hide,
.slds-backdrop.hide {
    display: none;
}

/* Tabs */
.co-dts-container .slds-tabs_default__item {
    font-size: 0.9rem !important;
}

.co-dts-container .slds-tabs_default__item.slds-active:after,
.co-dts-container .slds-tabs_default__item.slds-is-active:after,
.co-dts-container .slds-tabs--default__item.slds-active:after,
.co-dts-container .slds-tabs--default__item.slds-is-active:after {
    background-color: #1588ee;
}

/* Forms */
.co-dts-container .slds-form-element {
    margin-bottom: 20px;
}

.co-dts-container .slds-form-element .slds-form-element__label {
    color: var(--form-text-color);
}

.co-dts-container .slds-form-element span.mandatory {
    color: #f00000;
    margin-left: 5px;
}

.co-dts-container a.slds-input.lookup-adjustment {
    display: table-footer-group;
}

.co-dts-container .filter-value .slds-form-element__control {
    width: 85%;
    float: left;
}

.co-dts-container .slds-form-element span .slds-checkbox_faux {
    /*display: none;*/
}

.co-dts-container .filter-value .delete-icon {
    float: right;
    margin: 4px 0 0 5px;
    color: #f22020;
    cursor: pointer;
}

.co-dts-container .slds-picklist li.link {
    border-top: 1px solid #ccc;
    padding: 10px;
}

.co-dts-container .slds-picklist.relation-picklist {
    margin-right: 5px;
    float: left;
}

.co-dts-container .slds-picklist__label {
    padding-right: 1rem;
}

.co-dts-container .slds-picklist.relation-picklist .picklist-label {
    width: 100%;
    float: left;
}

.co-dts-container .slds-picklist__label .dropdown-arrows {
    position: absolute;
    right: 5px;
    top: 9px;
    width: 6px;
}

.co-dts-container .lookup-images {
    width: 15%;
    float: left;
}

/* UI combobox */
.co-dts-container .custom-combobox {
    position: relative;
    display: inline-block;
    width: 100%;
}

.co-dts-container .custom-combobox-toggle {
    position: absolute;
    top: 0;
    bottom: 0;
    margin-left: -1px;
    padding: 0;
}

.co-dts-container .custom-combobox-input {
    margin: 0;
    padding: 5px 10px;
}

.co-dts-container .ui-autocomplete {
    max-height: 100px !important;
    overflow-y: auto;
    /* prevent horizontal scrollbar */
    overflow-x: hidden;
}

.ui-state-default {
    background-color: white;
}

.ui-menu.ui-autocomplete {
    overflow: auto;
    height: 120px;
}

.ui-state-active,
.ui-widget-content .ui-state-active,
.ui-widget-header .ui-state-active,
a.ui-button:active,
.ui-button:active,
.ui-state-active.ui-button:hover {
    border: 1px solid #ccc;
    background: #ddd;
}

.co-dts-container .ui-state-highlight,
.ui-widget-content .ui-state-highlight,
.ui-widget-header .ui-state-highlight {
    border: 1px solid #b0c4df;
    background-color: #f7f9fb;
    color: #000;
}

.ui-button {
    border: 1px solid #c5c5c5;
    border-top-color: rgb(197, 197, 197);
    border-top-style: solid;
    border-top-width: 1px;
    border-right-color: rgb(197, 197, 197);
    border-right-style: solid;
    border-right-width: 1px;
    border-bottom-color: rgb(197, 197, 197);
    border-bottom-style: solid;
    border-bottom-width: 1px;
    border-image-source: initial;
    border-image-slice: initial;
    border-image-width: initial;
    border-image-outset: initial;
    border-image-repeat: initial;
}

/* OL Lists */

.co-dts-container .copado-query-tips {
    box-sizing: border-box;
    padding: 15px;
    height: auto;
    width: auto;
    max-width: 90%;
    border-radius: 4px;
    background-color: #f7f9fb;
    border: 1px solid rgba(21, 137, 238, 0.2);
    box-shadow: 0 5px 16px 0 rgba(151, 151, 151, 0.15);
}

.co-dts-container .copado-query-tips p {
    color: #16325c;
    font-size: 13px;
    font-weight: 400;
    line-height: 17px;
    margin-bottom: 20px;
}

.co-dts-container .copado-query-tips ol {
    counter-reset: item;
}
.co-dts-container .copado-query-tips ol li {
    display: block;
    color: #333;
    font-size: 11px;
    margin-bottom: 15px;
    list-style-position: inside;
    padding: 0;
    word-break: keep-all;
}

.co-dts-container .copado-query-tips ol li::before {
    content: '';
    width: 1rem;
    display: inline-block;
}

.co-dts-container .copado-query-tips ol li:before {
    content: counter(item) '. ';
    counter-increment: item;
    color: #1588ee;
}

/* Datatables */

.co-dts-container .refresh-link {
    display: flex;
    justify-content: flex-end;
    position: relative;
    top: 29px;
    margin-right: 4px;
    z-index: 999;
    float: right;
}

.co-dts-container .table {
    margin-bottom: 3rem;
}

.co-dts-container .table .dataTables_wrapper .dataTables_length,
.co-dts-container .table .dataTables_wrapper .dataTables_filter {
    margin-bottom: 10px;
}

.co-dts-container .table .dataTables_wrapper .dataTables_filter {
    width: 100%;
}

.co-dts-container .table .dataTables_wrapper .dataTables_filter label {
    width: 100%;
}

.co-dts-container .table .dataTables_wrapper .dataTables_filter label input {
    width: 30%;
    height: 27px;
    margin-left: 0;
    background-image: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTYuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgd2lkdGg9IjUxMnB4IiBoZWlnaHQ9IjUxMnB4IiB2aWV3Qm94PSIwIDAgMzAuMjM5IDMwLjIzOSIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMzAuMjM5IDMwLjIzOTsiIHhtbDpzcGFjZT0icHJlc2VydmUiPgo8Zz4KCTxwYXRoIGQ9Ik0yMC4xOTQsMy40NmMtNC42MTMtNC42MTMtMTIuMTIxLTQuNjEzLTE2LjczNCwwYy00LjYxMiw0LjYxNC00LjYxMiwxMi4xMjEsMCwxNi43MzUgICBjNC4xMDgsNC4xMDcsMTAuNTA2LDQuNTQ3LDE1LjExNiwxLjM0YzAuMDk3LDAuNDU5LDAuMzE5LDAuODk3LDAuNjc2LDEuMjU0bDYuNzE4LDYuNzE4YzAuOTc5LDAuOTc3LDIuNTYxLDAuOTc3LDMuNTM1LDAgICBjMC45NzgtMC45NzgsMC45NzgtMi41NiwwLTMuNTM1bC02LjcxOC02LjcyYy0wLjM1NS0wLjM1NC0wLjc5NC0wLjU3Ny0xLjI1My0wLjY3NEMyNC43NDMsMTMuOTY3LDI0LjMwMyw3LjU3LDIwLjE5NCwzLjQ2eiAgICBNMTguMDczLDE4LjA3NGMtMy40NDQsMy40NDQtOS4wNDksMy40NDQtMTIuNDkyLDBjLTMuNDQyLTMuNDQ0LTMuNDQyLTkuMDQ4LDAtMTIuNDkyYzMuNDQzLTMuNDQzLDkuMDQ4LTMuNDQzLDEyLjQ5MiwwICAgQzIxLjUxNyw5LjAyNiwyMS41MTcsMTQuNjMsMTguMDczLDE4LjA3NHoiIGZpbGw9IiNjZGNkY2QiLz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8L3N2Zz4K');
    background-size: 21px 18px;
    background-repeat: no-repeat;
    background-color: #fff;
    background-position: 0px 3px !important;
    padding-left: 25px;
    float: left;
}

.co-dts-container .table .dataTables_wrapper tr {
    height: 55px;
}

.co-dts-container .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.co-dts-container .table .dataTables_wrapper .dataTables_filter input,
.co-dts-container .table .dataTables_wrapper .dataTables_filter input:focus {
    border-width: 0 0 1px 0;
    border-color: #ccc;
    box-shadow: none;
    border-radius: unset;
}

.co-dts-container .table .dataTables_wrapper .dataTables_filter input:focus {
    outline: none !important;
}

.co-dts-container .table thead tr {
    background-color: #d3edff;
}

.co-dts-container .table tr span.external-ids {
    color: var(--main-blue-color);
}

.co-dts-container .table tr .hide-ordering {
    visibility: hidden;
}

.co-dts-container .table tbody td .lookup-images img {
    width: 20px;
    padding-top: 5px;
    margin-left: 5px;
}

.co-dts-container .table tbody input,
.co-dts-container .table tbody select {
    line-height: normal;
    display: block;
    width: 100%;
    padding: 0.175rem 0.4rem;
    margin: 0 5px 0 5px;
    color: #495057;
    background-color: #fff;
    background-clip: padding-box;
    border: 1px solid #ced4da;
    border-radius: 0.25rem;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.co-dts-container .table tbody .form-action input.slds-input {
    width: 80%;
    margin-right: 0.5rem;
    float: left;
}

.co-dts-container .table tbody input[type='checkbox'] {
    width: 16px;
}

.co-dts-container .table select {
    padding: 0.175rem 0.4rem;
    margin: 0 5px 0 5px;
    color: #495057;
    background-color: #fff;
    background-clip: padding-box;
    border: 1px solid #ced4da;
    border-radius: 0.25rem;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate {
    padding-top: 10px;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.co-dts-container .table .dataTables_wrapper .dataTables_info {
    padding-top: 17px;
    font-size: 0.75rem;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.current,
.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
    border: 1px solid #979797;
    background-color: white;
    z-index: 3;
    color: #fff !important;
    cursor: default;
    background: var(--main-blue-color);
    border-color: var(--main-blue-color);
}

.co-dts-container .table .dataTables_wrapper .dataTables_filter {
    float: left !important;
    margin-bottom: 10px;
}

.co-dts-container .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
    border: 1px solid #ddd;
    z-index: 2;
    background: #eee;
    background-color: #eee;
    border-color: #ddd;
    color: var(--main-blue-color) !important;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled,
.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover,
.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:active {
    color: #777 !important;
    cursor: not-allowed;
    background-color: #fff;
    border-color: #ddd !important;
}

.co-dts-container .table .dataTables_wrapper .dataTables_paginate .paginate_button:active {
    box-shadow: inset 0 0 3px #111;
    background: var(--main-blue-color);
    color: white !important;
}

/* Buttons */
.co-dts-container .buttons {
    text-align: center;
}

.co-dts-container .buttons .slds-button {
    font-weight: bold;
    font-weight: bold;
    width: auto;
    padding: 3px 20px;
    min-width: 160px;
}

.co-dts-container .slds-button + .slds-button {
    margin-left: 1.1rem;
}

.co-dts-container .buttons .slds-button_brand {
    border: 1px solid var(--main-blue-color);
    background-color: var(--main-blue-color);
}

.co-dts-container .buttons .slds-button_brand:hover {
    border: 1px solid #3593c6;
    background-color: #3593c6;
}

.co-dts-container .buttons .slds-button_outline-brand {
    border-color: var(--main-blue-color);
    color: var(--main-blue-color);
}

.co-dts-container .toggle-button {
    padding: 10px 0 43px 0;
    cursor: pointer;
    width: 280px;
}

.co-dts-container .toggle-button span {
    color: var(--actions-color);
    font-size: 14px;
    line-height: 20px;
}

.co-dts-container .filter-main-object .sample-button {
    text-align: left;
    margin-bottom: 3rem;
}

.co-dts-container .custom-cursor {
    cursor: pointer;
}

/* Modals */
.co-dts-container .slds-modal__header .modal-title {
    font-weight: 700;
}

.co-dts-container .slds-modal__content.modal-content {
    overflow: auto;
    padding: 1rem 3rem;
}

.co-dts-container .slds-modal__content.modal-content .warning-icon {
    color: #ffb800;
}

.co-dts-container .slds-modal__content.modal-content .error-icon {
    color: red;
}

.co-dts-container .slds-modal__content.modal-content div {
    margin-bottom: 1rem;
}

.co-dts-container .slds-modal__content.modal-content div.slds-media__body {
    margin-bottom: 0;
}

.co-dts-container .buttons.modal-button {
    text-align: right;
}

.co-dts-container .slds-scoped-notification.modal-warning {
    background-color: #fffadb;
    border: 1px solid #e1b600;
    border-radius: 4px;
}

/* Static Tables */
.co-dts-container .static-table thead th {
    background-color: #d3edff;
    color: #3c3d3e;
    padding: 10px 18px;
}

.co-dts-container .static-table tbody td {
    border: none;
    height: 35px;
}

.co-dts-container .slds-table_striped.static-table tbody tr:nth-of-type(even) > td {
    border-top: none;
    background-color: #f9f9f9;
}

.co-dts-container .slds-table_bordered:not(.slds-no-row-hover).static-table tbody tr:hover > td:not(.slds-is-selected) {
    box-shadow: none;
}

.co-dts-container .slds-table:not(.slds-no-row-hover).static-table tbody tr:hover > td {
    background-color: #f9f9f9;
}

/* Tooltips */
.co-tooltip {
    position: absolute;
    background: #16325c;
    max-width: 20rem;
    line-height: 1.5;
    border-radius: 4px;
    padding: 6px 12px;
    font-size: 0.75rem;
    text-shadow: 0px 1px 1px #000;
    color: #fff;
    transition: transform 0.2s ease-out;
    transform: translateY(-100%) scale(0);
    transform-origin: bottom left;
    z-index: 999;
}

.co-tooltip:before {
    content: ' ';
    width: 0;
    height: 0;
    border-left: 10px solid transparent;
    border-right: 10px solid transparent;
    border-top: 10px solid #16325c;
    position: absolute;
    bottom: -5px;
    left: 5px;
}

/* Warnings */
.co-dts-container .slds-scoped-notification.general-messages {
    margin-left: -1rem;
    margin-right: -1rem;
    overflow: hidden;
    border-top-left-radius: 0.25rem;
    border-top-right-radius: 0.25rem;
}

.co-dts-container .slds-scoped-notification.general-messages.custom-warning {
    background-color: #fff1b3;
}

.co-dts-container .slds-scoped-notification.general-messages.custom-error {
    background-color: #ffb3b3;
}

.co-dts-container .warning-message-body {
    color: #715c04;
}

.co-dts-container .error-message-body {
    color: #931403;
}

.co-dts-container a.warning-link {
    color: #715c04;
    border-bottom: 1px solid #715c04;
}

.co-dts-container a.warning-link:hover {
    border-bottom: 0px;
    border-bottom: 1px solid #715c04;
    text-decoration: none;
}

.co-dts-container a.error-link {
    color: #931403;
    border-bottom: 1px solid #931403;
}

.co-dts-container a.error-link:hover {
    border-bottom: 0px;
    border-bottom: 1px solid #931403;
    text-decoration: none;
}

/* record matching modal */
.co-dts-container .record-matching-modal-container {
    box-sizing: border-box;
    padding: 15px;
    height: auto;
    width: auto;
    border-radius: 4px;
    background-color: #f7f9fb;
    border: 1px solid rgba(21, 137, 238, 0.2);
    box-shadow: 0 5px 16px 0 rgba(151, 151, 151, 0.15);
}

.co-dts-container .record-matching-modal-container .custom-badge-inverse {
    padding: 5px;
    border-radius: 10px;
    margin-right: 10px;
}
