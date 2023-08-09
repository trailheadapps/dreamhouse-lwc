/* Variables */
:root {
	--main-blue-color: #1589EE;
	--secondary-blue-color: #3593c6;
	--form-text-color: #080707;
	--progress-background-color: #f3f9fc;
}

/* Resets */
.noSidebarCell {
    padding: 0 !important;
}

.skiplink,
.preventGhost {
    display: none;
}

body .stage.panelSlide {
    background-color: white;
}

.slds-form-element {
    margin-bottom: 3rem;
}

.slds-scope .slds-form-element__legend {
    font-weight: inherit;
}

.slds-scope .slds-p-around_x-small, .slds-scope .slds-p-around--x-small {
    padding: .0rem;
}

.slds-modal header {
	background-color: var(--secondary-blue-color) !important;
	color: white;
}

/* Progress bar */
.co-progress-bar {
    height: 110px;
    padding: 3.9rem 1rem 0;
    background-color: var(--progress-background-color);
    border-bottom: 2px solid #00a3e0;
}

.co-progress-bar .slds-progress {
    max-width: 50%;
}

.co-progress-bar .indicator-progress-tooltip {
    position: absolute;
    top: -50px;
    transform: translateX(-25%);
    display: none;
}

.co-progress-bar .slds-popover_tooltip {
    background: none;
}

.co-progress-bar .indicator-progress-tooltip .tooltip {
    color: #13aae2;
    border: 2px solid #00a3e0;
    border-radius: 5px;
    background-color: var(--progress-background-color);
    text-transform: uppercase;
    padding: 6px 10px;
    width: 160px;
    text-align: center;
    z-index: 0;
}

.co-progress-bar .slds-nubbin_bottom:before {
    background-color: var(--progress-background-color);
    border: 2px solid #00a3e0;
    z-index: 1;
    border-top: 0;
    border-left: 0;
}

.co-progress-bar .slds-nubbin_bottom:after {
    background-color: var(--progress-background-color);
}


/* Container */
.co-dw-container {
    padding: 2rem 0;
    font-family: "Salesforce Sans";
}

.co-dw-container h1 {
    text-align: center;
	color: #828282;
	font-size: 18px;
	line-height: 35px;
	font-weight: 500;
}

.co-dw-container .subtitle {
	height: 35px;
	color: #003B5C;
	font-size: 30px;
	font-weight: 300;
	line-height: 35px;
	text-align: center;
	margin-bottom: 2rem;
}

.subtitle-warning{
    height: 35px;
    color: #dc0f0f;
    font-size: 30px;
    font-weight:bolder;
    line-height: 35px;
    text-align: center;
    margin-bottom: 2rem;
}

.co-dw-container .hide,
.slds-modal.hide,
.slds-backdrop.hide {
	display: none;
}

/* deployment flow step */
.co-dw-container .deployment-flow-step {
	display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f4f6f9;
    width: 70%;
    height: 85px;
    margin: 3rem auto 1rem auto;
    border-radius: 10px;
}

.co-dw-container .deployment-flow-step .wrapper {
	font-size: 14px;
}

.co-dw-container .deployment-flow-step .wrapper .source {
    display: flex;
    float: left;
	margin-right: 15px;
    align-items: center;
	max-width: 48%;
}

.co-dw-container .deployment-flow-step .wrapper .icon {
    float: left;
    margin-right: 15px;
}

.co-dw-container .deployment-flow-step .wrapper .target {
    display: flex;
	margin-left: 10px;
    align-items: center;
    max-width: 48%;
}

.co-dw-container .deployment-flow-step .wrapper .target img {
	margin-left: 10px;
}

.co-dw-container .deployment-flow-step .wrapper .source .text-wrapper,
.co-dw-container .deployment-flow-step .wrapper .target .text-wrapper {
	width: auto;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.co-dw-container .credits {
	text-align: center;
	margin-bottom: 4rem;
	height: 15px;
	color: #a6b4c7;
	font-size: 14px;
	font-weight: 600;
	letter-spacing: 1.17px;
	line-height: 15px;
	text-transform: uppercase;
}


.co-dw-container .credits span {
	letter-spacing: normal;
	color: var(--form-text-color);
	font-weight: initial;
}
/* pills */
.co-dw-container .pill {
    box-shadow: none;
    border-radius: 10px;
    width: 65px;
    height: 23px;
    background-color: white;
    margin: 0 10px;
}
.co-dw-container .pill.source {
    color: #dd1044;
    border: 1px solid #dd1044;
}
.co-dw-container .pill.target {
    color: #0086b3;
    border: 1px solid #0086b3;
}
.co-dw-container .pill .slds-card__header {
    padding: .25rem .9rem;
}
.co-dw-container .pill .slds-card__header h2.slds-card__header-title {
    font-size: 9px;
    font-weight: bold;
    margin-top: 13px;
    text-transform: uppercase;
}
.co-dw-container .deployment-flow-step .wrapper .icon {
    float: left;
    margin: 0 15px;
}
.co-dw-container .deployment-flow-step .wrapper .target {
    display: flex;
    align-items: center;
    max-width: 60%;
}
.co-dw-container .deployment-flow-step .wrapper .target img {
    margin-left: 10px;
}
.co-dw-container .deployment-flow-step .wrapper .source .text-wrapper,
.co-dw-container .deployment-flow-step .wrapper .target .text-wrapper {
    width: auto;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Icons */
.co-dw-container .search {
    color: #d0d9e2;
}

.co-dw-container .salesforce {
    color: var(--main-blue-color);
}

.co-dw-container .toast-message {
	margin-left:10px;
	text-align: left;
}

.co-dw-container .error-panel {
	height: 4rem;
}

/* Forms */
.co-dw-container .slds-input,
.co-dw-container .slds-combobox__input,
.co-dw-container .slds-input:focus,
.co-dw-container .slds-combobox__input:focus,
.co-dw-container .slds-select,
 .co-dw-container .slds-select:focus {
    border-width: 0 0 1px 0;
    border-color: #000000;
    box-shadow: none;
    border-radius: unset;
}

.co-dw-container .slds-form-element__label {
    color: var(--form-text-color) !important;
    color: var(--form-text-color) !important;
	margin-bottom: 1rem;
}

.co-dw-container .slds-input.slds-has-focus,
.co-dw-container .slds-combobox__input.slds-has-focus {
    border-color: #2A9FD8;
}


.co-dw-container .slds-input::-webkit-input-placeholder,
.co-dw-container .slds-combobox__input::-webkit-input-placeholder {
    /* Chrome/Opera/Safari */
    color: #979797;
    font-size: 14px;
    line-height: 18px;
}

.co-dw-container .slds-input::-moz-placeholder,
.co-dw-container .slds-combobox__input::-moz-placeholder {
    /* Firefox 19+ */
    color: #979797;
    font-size: 14px;
    line-height: 18px;
}

.co-dw-container .slds-input:-ms-input-placeholder,
.co-dw-container .slds-combobox__input:-ms-input-placeholder {
    /* IE 10+ */
    color: #979797;
    font-size: 14px;
    line-height: 18px;
}

.co-dw-container .slds-input:-moz-placeholder,
.co-dw-container .slds-combobox__input:-moz-placeholder {
    /* Firefox 18- */
    color: #979797;
    font-size: 14px;
    line-height: 18px;
}

.co-dw-container .slds-dropdown {
    border: 0;
    border-radius: none;
    box-shadow: none;

}

.co-dw-container .slds-dropdown ul li {
    border-bottom: 1px solid #d0d9e2;
    color: #3a3c3d;
    height: 50px;
    padding-top: 10px;
}

.co-dw-container .slds-dropdown ul li:hover {
    background-color: #c4e8f5;
}

.co-dw-container .slds-listbox_vertical .slds-listbox__option:hover {
    background-color: transparent;
}

.co-dw-container .slds-dropdown ul li label {
    cursor: pointer;
}

.co-dw-container .test-level-dropdown {
	width: 40%;
	margin-bottom: 2rem;
}

.co-dw-container .mandatory {
	color: #C23934;
	margin-left: 5px;
}

.co-dw-container div.visual-options {
	display: flex;
    justify-content: center;
}

.co-dw-container  .slds-visual-picker {
    width: 100%;
}

.co-dw-container .slds-visual-picker__figure {
    height: 68px !important;
    width: 100% !important;
    border-radius: 6px !important;
    background-color: #F4F6F9;
    display: flex;
    justify-content: left;
    align-items: center;
}

.co-dw-container .slds-visual-picker__figure span {
	font-size: 1rem;
	font-weight: 200;
}

.co-dw-container .slds-visual-picker input:not(:disabled)~label:hover .slds-visual-picker__figure {
    border: 1px solid #0070D2;

}

.co-dw-container .slds-visual-picker .slds-visual-picker__icon {
	height: 5rem !important;
}

.co-dw-container .slds-visual-picker input:checked~label .slds-visual-picker__icon {
    background-color: #F4F6F9;
    border: 1px solid #0070D2;
    padding-top: 10px;
	padding-bottom: 10px;

}

.co-dw-container .slds-visual-picker .slds-visual-picker__icon .slds-is-selected div,
.co-dw-container .slds-visual-picker .slds-visual-picker__icon .slds-is-not-selected div {
    margin-bottom: 5px;
}

.co-dw-container .slds-visual-picker input:checked~label .slds-visual-picker__icon .slds-is-selected span {
    font-weight: 700;
}

.co-dw-container .slds-visual-picker input:checked~label .slds-visual-picker__figure {
    box-shadow: none;
}

.co-dw-container .pinIcon {
    color: var(--main-blue-color) !important;
}

/* DataTables */
.co-dw-container .table {
	margin-bottom: 3rem;
}

.co-dw-container .orgtable-wrapper {
    padding: 0 5rem;
}

.co-dw-container .table thead tr {
    background-color: #d3edff;
}

.co-dw-container .table tbody tr {
	cursor: pointer;
}

.co-dw-container .table tbody tr td.description {
	max-width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.co-dw-container .table .dataTables_wrapper .dataTables_info {
    padding-top: 17px;
    font-size: 0.75rem;
}

.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.current,
.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
    border: 1px solid #979797;
    background-color: white;
    z-index: 3;
    color: #fff !important;
    cursor: default;
    background: var(--main-blue-color);
    border-color: var(--main-blue-color);
}

.co-dw-container .table .dataTables_wrapper .dataTables_length,
.co-dw-container .table .dataTables_wrapper .dataTables_filter {
    margin-bottom: 10px;
}

.co-dw-container .table .dataTables_wrapper .dataTables_filter {
    width: 100%;
}

.co-dw-container .table .dataTables_wrapper .dataTables_filter label {
    width: 100%;
}

.co-dw-container .table .dataTables_wrapper .dataTables_filter label input {
    width: 100%;
    height: 27px;
    margin-left: 0;
    background-image: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pgo8IS0tIEdlbmVyYXRvcjogQWRvYmUgSWxsdXN0cmF0b3IgMTYuMC4wLCBTVkcgRXhwb3J0IFBsdWctSW4gLiBTVkcgVmVyc2lvbjogNi4wMCBCdWlsZCAwKSAgLS0+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgdmVyc2lvbj0iMS4xIiBpZD0iQ2FwYV8xIiB4PSIwcHgiIHk9IjBweCIgd2lkdGg9IjUxMnB4IiBoZWlnaHQ9IjUxMnB4IiB2aWV3Qm94PSIwIDAgMzAuMjM5IDMwLjIzOSIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMzAuMjM5IDMwLjIzOTsiIHhtbDpzcGFjZT0icHJlc2VydmUiPgo8Zz4KCTxwYXRoIGQ9Ik0yMC4xOTQsMy40NmMtNC42MTMtNC42MTMtMTIuMTIxLTQuNjEzLTE2LjczNCwwYy00LjYxMiw0LjYxNC00LjYxMiwxMi4xMjEsMCwxNi43MzUgICBjNC4xMDgsNC4xMDcsMTAuNTA2LDQuNTQ3LDE1LjExNiwxLjM0YzAuMDk3LDAuNDU5LDAuMzE5LDAuODk3LDAuNjc2LDEuMjU0bDYuNzE4LDYuNzE4YzAuOTc5LDAuOTc3LDIuNTYxLDAuOTc3LDMuNTM1LDAgICBjMC45NzgtMC45NzgsMC45NzgtMi41NiwwLTMuNTM1bC02LjcxOC02LjcyYy0wLjM1NS0wLjM1NC0wLjc5NC0wLjU3Ny0xLjI1My0wLjY3NEMyNC43NDMsMTMuOTY3LDI0LjMwMyw3LjU3LDIwLjE5NCwzLjQ2eiAgICBNMTguMDczLDE4LjA3NGMtMy40NDQsMy40NDQtOS4wNDksMy40NDQtMTIuNDkyLDBjLTMuNDQyLTMuNDQ0LTMuNDQyLTkuMDQ4LDAtMTIuNDkyYzMuNDQzLTMuNDQzLDkuMDQ4LTMuNDQzLDEyLjQ5MiwwICAgQzIxLjUxNyw5LjAyNiwyMS41MTcsMTQuNjMsMTguMDczLDE4LjA3NHoiIGZpbGw9IiNjZGNkY2QiLz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8Zz4KPC9nPgo8L3N2Zz4K');
    background-size: 21px 18px;
	background-repeat: no-repeat;
	background-color: #fff;
	background-position: 0px 3px !important;
	padding-left: 25px;

}

.co-dw-container .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.co-dw-container .table .dataTables_wrapper .dataTables_filter input,
.co-dw-container .table .dataTables_wrapper .dataTables_filter input:focus {
    border-width: 0 0 1px 0;
    border-color: #000000;
    box-shadow: none;
    border-radius: unset;
}

.co-dw-container .table .dataTables_wrapper .dataTables_filter input:focus {
    outline: none !important;
}

.co-dw-container .table .dataTables_wrapper .dataTables_paginate {
    padding-top: 10px;
}

.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
    border: 1px solid #ddd;
    z-index: 2;
    background: #eee;
    background-color: #eee;
    border-color: #ddd;
    color: var(--main-blue-color) !important;
}

.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled,
.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover,
.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:active {
    color: #777 !important;
    cursor: not-allowed;
    background-color: #fff;
    border-color: #ddd !important;
}

.co-dw-container .table .dataTables_wrapper .dataTables_filter input:focus {
    outline: none !important;
}

.co-dw-container .table .dataTables_wrapper .dataTables_paginate .paginate_button:active {
    box-shadow: inset 0 0 3px #111;
    background: var(--main-blue-color);
    color: white !important;
}

.co-dw-container .filter-container .slds-input, .co-dw-container .filter-container .slds-combobox__input, .co-dw-container .filter-container .slds-input:focus, .co-dw-container .filter-container .slds-combobox__input:focus, .co-dw-container .filter-container .slds-select, .co-dw-container .filter-container .slds-select:focus {
    border-width: unset;
    border: 1px solid rgb(221, 219, 218);
    border-radius: .25rem;
}

.co-dw-container .filter-container .criteria-order {
    padding-top: 6px;
}

/* JQX tables */

.co-dw-container .jqx-table ul.tabs {
	margin-left: 20px;
}

.co-dw-container .jqx-table .scale-filter-frame {
	padding: 5px;
}

.co-dw-container .jqx-table .scale-filter-frame .scale-filter {
	margin-bottom: 10px;
}

[id$="editorValuePanel"],.CodeMirror-merge-copy{
    display:none;
}
.CodeMirror-merge, .CodeMirror-merge .CodeMirror, .CodeMirror-merge-pane, .CodeMirror-merge-gap {
    height: 100vh !important;
}

.co-dw-container .success-image {
	display: flex;
	justify-content: center;
	margin: 3rem auto 13rem auto;
}
.co-dw-container .error-image {
    display: flex;
    justify-content: center;
    margin: 3rem auto 3em auto;
}

.co-dw-container .metadata-div {
    margin-right: 0;
}

.co-dw-container .metadata-div .metadata-div-title {
    margin-top: 20px;
}

.co-dw-container .metadata-div .metadata-div-refresh {
	margin-top: 20px;
	margin-right: 0;
	color: var(--secondary-blue-color);
}

.co-dw-container .metadata-div .metadata-div-refresh a {
	color: var(--secondary-blue-color);
}

/* Modal */

.slds-media__body .toast-message .slds-m-left {
    margin-left: 15px;
}

/* Templates list */

.co-dw-container .data-template-wrapper {
    width: 70%;
    margin: 3rem auto 1rem auto;
}

.co-dw-container .data-template-wrapper .summary-info .line-item {
    padding: .75rem .25rem .5rem .35rem;
    border-bottom: 1px solid rgb(221, 219, 218);
    width: 100%;
}

.co-dw-container .data-template-wrapper .summary-info .line-item span.value {
    float: right;
    margin-right: 1rem;
}

.co-dw-container .data-templates {
   margin: 3rem 0 1rem 0;
}

.co-dw-container .data-templates .name {
    margin-bottom: 0.5rem;
    font-size: 15px;
}

.co-dw-container .data-templates .info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 1rem;
    color: #666;
}

.co-dw-container .data-templates .summary-info {
    justify-content: normal;
    display: flex;
    margin-bottom: 1rem;
    color: #666;
}

.co-dw-container .data-templates .summary-info .deployed-objects {
    flex-grow: 2;
    margin-left: 2rem;
}

.co-dw-container .data-templates .templates-list {
    padding: 0.5rem 5rem 0.5rem 5rem;
    background: #f7f7f7;
    border-top: 1px solid #CCC;
    border-bottom: 1px solid #CCC;
    margin-bottom: 3rem;
    max-height: 300px;
    overflow-y: auto;

}


.co-dw-container .data-templates .templates-list ul div.template {
    display: flex;
    justify-content: space-between;
    color: #666;
}

.co-dw-container .data-templates .templates-list ul li {
   padding: 0.4rem 1rem 0.4rem 0;
   border-bottom: 1px solid #CCC;

}

.co-dw-container .data-templates .templates-list ul li:last-child {
    border: none
}


.co-dw-container .data-templates .name span,
.co-dw-container .data-templates .info span,
.co-dw-container .data-templates .templates-list ul div.template span {
    font-weight: 700;
    color: var(--form-text-color);
}

.co-dw-container .data-templates .name img {
    width: 16px;
    margin-left: 5px;
    margin-top: -3px;
}

/* Buttons */
.co-dw-container .buttons {
    text-align: center;
    margin-top: 2rem;
}

.co-dw-container .buttons .slds-button {
    font-weight: bold;
	font-weight: bold;
	width: auto;
	padding: 3px 20px;
	min-width: 160px;
}

.co-dw-container .slds-button+.slds-button {
    margin-left: 1.10rem;
}

.co-dw-container .buttons .slds-button_brand {
    border: 1px solid var(--main-blue-color);
    background-color: var(--main-blue-color);

}

.co-dw-container .buttons .slds-button_brand:hover {
    border: 1px solid var(--secondary-blue-color);
    background-color: var(--secondary-blue-color);
}

.disabled {
    opacity:0.5;
}

.co-dw-container .buttons .slds-button_outline-brand {
    border-color: var(--main-blue-color);
    color: var(--main-blue-color);
}

/*tabs*/
.co-dw-container .top2P {
    margin-top:2%;
}

.co-dw-container .disabled-tab {
    opacity: 0.3;
    cursor: not-allowed;
}

.co-dw-container .enabled-tab {
    opacity: 1;
    cursor: pointer;
}
/*icons*/
.slds-scope img {
    height:18px !important;
    margin-right: 10px;
}

.slds-scope .deployment-img {
    height:80px !important;
    margin-right: 10px;
}



