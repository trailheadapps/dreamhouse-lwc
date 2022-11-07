/* Variables */
:root {
	--main-blue-color: #1589EE;
	--form-text-color: #080707;
	--actions-color: #006DCC;
}

/* Resets */

body {
    background-color: #F3F2F2 !important;
}


/* Container */
.co-dti-container {
	padding: 1rem;
    font-family: "Salesforce Sans";
}

.co-dti-container .slds-page-header {
    background-color: #FFF;
}

.co-dti-container .slds-tabs_card.slds-tabs_card {
    padding: 3rem 5rem;
    min-height: 30rem;
}

/* Forms */
.co-dti-container .slds-form-element {
    margin-bottom: 20px;
}

.co-dti-container .slds-form-element .slds-form-element__label {
    color: var(--form-text-color);
}

.co-dti-container .slds-form-element span.mandatory {
	color: #F00000;
	margin-left: 5px;
}

.co-dti-container a.slds-input.lookup-adjustment {
    display: table-footer-group;
}

.co-dti-container .filter-value .slds-form-element__control {
    width: 85%;
    float: left;
}

.co-dti-container .slds-form-element span .slds-checkbox_faux {
    //display: none;
}

.co-dti-container .filter-value .delete-icon {
    width: 10%;
    float: right;
    margin: 4px 0 0 5px;
    color: #f22020;
    cursor: pointer;
}

.co-dti-container .slds-picklist li.link {
    border-top: 1px solid #CCC;
    padding: 10px
}

.co-dti-container .slds-picklist.relation-picklist {
    margin-right: 5px;
    float: left;
}

.co-dti-container .slds-picklist.relation-picklist .picklist-label {
    width: 85%;
    float: left;
}

.co-dti-container .slds-picklist__label .dropdown-arrows {
    position: absolute;
    right: 5px;
    top: 9px;
    width: 6px;
}

.co-dti-container .lookup-images {
    width: 15%;
    float: left
}

/* Datatables */

.co-dti-container .table {
	margin-bottom: 3rem;
}

.co-dti-container .table .dataTables_wrapper .dataTables_length,
.co-dti-container .table .dataTables_wrapper .dataTables_filter {
    margin-bottom: 10px;
}

.co-dti-container .table .dataTables_wrapper .dataTables_filter {
    width: 100%;
}

.co-dti-container .table .dataTables_wrapper .dataTables_filter label {
    width: 100%;
}

.co-dti-container .table .dataTables_wrapper .dataTables_filter label input {
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

.co-dti-container .table .dataTables_wrapper tr {
    height: 55px;
}

.co-dti-container .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.co-dti-container .table .dataTables_wrapper .dataTables_filter input,
.co-dti-container .table .dataTables_wrapper .dataTables_filter input:focus {
    border-width: 0 0 1px 0;
    border-color: #CCC;
    box-shadow: none;
    border-radius: unset;
}

.co-dti-container .table .dataTables_wrapper .dataTables_filter input:focus {
    outline: none !important;
}

.co-dti-container .table thead tr {
    background-color: #d3edff;
}selectedSourceType

.co-dti-container .table tr span.external-ids {
	color: var(--main-blue-color);
}

.co-dti-container .table tr .hide-ordering {
    visibility: hidden;
}

.co-dti-container .table tbody td .lookup-images img {
    width: 20px;
    cursor: pointer;
}

.co-dti-container .table tbody .data-template-name {
    float: left;
    margin-right: 15px;
}

.co-dti-container .table tbody input,
.co-dti-container .table tbody select {
    line-height: normal;
    display: block;
    width: 100%;
    padding: .175rem .4rem;
    margin: 0 5px 0 5px;
    color: #495057;
    background-color: #fff;
    background-clip: padding-box;
    border: 1px solid #ced4da;
    border-radius: .25rem;
    transition: border-color .15s ease-in-out,box-shadow .15s ease-in-out;
}


.co-dti-container .table tbody .form-action input.slds-input {
    width: 80%;
    margin-right: 0.5rem;
    float: left;
}

.co-dti-container .table tbody input[type="checkbox"] {
    width: auto;

}

.co-dti-container .table select {
    padding: .175rem .4rem;
    margin: 0 5px 0 5px;
    color: #495057;
    background-color: #fff;
    background-clip: padding-box;
    border: 1px solid #ced4da;
    border-radius: .25rem;
    transition: border-color .15s ease-in-out,box-shadow .15s ease-in-out;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate {
    padding-top: 10px;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.co-dti-container .table .dataTables_wrapper .dataTables_info {
    padding-top: 17px;
    font-size: 0.75rem;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.current,
.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
    border: 1px solid #979797;
    background-color: white;
    z-index: 3;
    color: #fff !important;
    cursor: default;
    background: var(--main-blue-color);
    border-color: var(--main-blue-color);
}

.co-dti-container .table .dataTables_wrapper .dataTables_filter {
	float: left !important;
    margin-bottom: 10px;
}

.co-dti-container .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
    border: 1px solid #ddd;
    z-index: 2;
    background: #eee;
    background-color: #eee;
    border-color: #ddd;
    color: var(--main-blue-color) !important;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled,
.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover,
.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:active {
    color: #777 !important;
    cursor: not-allowed;
    background-color: #fff;
    border-color: #ddd !important;
}

.co-dti-container .table .dataTables_wrapper .dataTables_paginate .paginate_button:active {
    box-shadow: inset 0 0 3px #111;
    background: var(--main-blue-color);
    color: white !important;
}


/* Buttons */
.co-dti-container .buttons {
    text-align: center;
}

.co-dti-container .buttons .slds-button {
    font-weight: bold;
	font-weight: bold;
	width: auto;
	padding: 3px 20px;
	min-width: 160px;
}

.co-dti-container .slds-button+.slds-button {
    margin-left: 1.10rem;
}

.co-dti-container .buttons .slds-button_brand {
    border: 1px solid var(--main-blue-color);
    background-color: var(--main-blue-color);
}

.co-dti-container .hide-buttons {
    display: none;
}

.co-dti-container .buttons .slds-button_brand:hover {
    border: 1px solid #3593c6;
    background-color: #3593c6;
}

.co-dti-container .buttons .slds-button_outline-brand {
    border-color: var(--main-blue-color);
    color: var(--main-blue-color);
}

.co-dti-container .toggle-button {
    padding: 10px 0 43px 0;
    cursor: pointer;
    width: 280px;
}

.co-dti-container .toggle-button span {
    color: var(--actions-color);
    font-size: 14px;
    line-height: 20px;
}

.co-dti-container .filter-main-object .sample-button {
    text-align: left;
    margin-bottom: 3rem;
}

.co-dti-container .confirm-images,
.co-dti-container .warning-images,
.co-dti-container .cross-images {
    display: none;
}


/* Modals */
.co-dti-container .slds-modal__header .modal-title {
    font-weight: 700;
}

.co-dti-container .slds-modal__content.modal-content {
    overflow: auto;
    padding: 1rem 3rem;
}

.co-dti-container .slds-modal__content.modal-content .warning-icon {
    color: #ffb800;
}

.co-dti-container .slds-modal__content.modal-content .error-icon {
    color: red;
}

.co-dti-container .buttons.modal-button {
    text-align: right;
}

#modalUploadTemplate .slds-card__header {
    border-radius: 10px;
    border: 1px solid #DDD;
    background-color: #f7f9fb;
    padding: 0.5rem 1rem;
}

#modalUploadTemplate .slds-card__body {
    margin-top: 20px;
    margin-bottom: 20px;
}

#modalUploadTemplate .modal-content .file-uploader {
    width: 25rem;
    margin: 1rem auto;
}

#modalUploadTemplate .modal-content .file-uploader .upload-icon-title {
    margin-left: 10px;
}

#modalUploadTemplate .slds-card__body .templates-list {
    margin-bottom: 20px;
    max-height: 160px;
    overflow-x: hidden;
    overflow-y: scroll;
}

#modalUploadTemplate .slds-card__body .templates-list .templates-list-row {
    height: 25px;
}

#modalUploadTemplate .slds-card__body .templates-list .result-icons img {
    width: 20px;
}

#modalUploadTemplate .slds-card .slds-grid {
    display: flex;
    align-items: center;
}

#modalUploadTemplate .slds-card .slds-grid p {
   margin: 0;
}

#modalUploadTemplate .slds-card .slds-grid span.attachmentDocumentIcon {
   cursor: pointer;
}

#modalUploadTemplate .slds-card .slds-grid .slds-progress-bar {
    background: transparent;
}

#modalUploadTemplate .slds-card .slds-grid .slds-progress-bar span {
    border-radius: 5px;
}

#modalUploadTemplate .slds-card .slds-grid .icon {
    margin-left: 10px;
}

#modalUploadTemplate .slds-card .slds-grid .icon span {
    padding: 4px;
}

#modalUploadTemplate .lookupInput {
    width: 50%;
}