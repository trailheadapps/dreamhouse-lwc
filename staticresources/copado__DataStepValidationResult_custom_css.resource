/* Variables */
:root {
    --main-blue-color: #1589ee;
    --form-text-color: #080707;
    --actions-color: #006dcc;
}

.modal {
    display: none;
}

.resultsMessageContainer {
    display: flex; 
    justify-content: flex-start; 
    align-items: center;
}

.resultsIcon {
    width: 20px; 
    margin-right: 5px;
}

.resultsMessage {
    color: #737373;
}

.resultsLink {
    display:inline-block; 
    margin-left: 5px;
}

.slds-modal header {
    background-color: white !important;
}

.modal .table {
    margin-bottom: 3rem;
}

.modal .table .dataTables_wrapper .dataTables_length,
.modal .table .dataTables_wrapper .dataTables_filter {
    margin-bottom: 10px;
}

.modal .table .dataTables_wrapper .dataTables_filter {
    width: 100%;
}

.modal .table .dataTables_wrapper .dataTables_filter label {
    width: 100%;
}

.modal .table .dataTables_wrapper .dataTables_filter label input {
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

.modal .table .dataTables_wrapper tr {
    height: 55px;
}

.modal .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.modal .table .dataTables_wrapper .dataTables_filter input,
.modal .table .dataTables_wrapper .dataTables_filter input:focus {
    border-width: 0 0 1px 0;
    border-color: #ccc;
    box-shadow: none;
    border-radius: unset;
}

.modal .table .dataTables_wrapper .dataTables_filter input:focus {
    outline: none !important;
}

.modal .table thead tr {
    background-color: #d3edff !important;
}

.modal .table tr span.external-ids {
    color: var(--main-blue-color);
}

.modal .table tr .hide-ordering {
    visibility: hidden;
}

.modal .table tbody td .lookup-images img {
    width: 20px;
    padding-top: 5px;
    margin-left: 5px;
}

.modal .table tbody input,
.modal .table tbody select {
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

.modal .table tbody .form-action input.slds-input {
    width: 80%;
    margin-right: 0.5rem;
    float: left;
}

.modal .table tbody input[type='checkbox'] {
    width: 16px;
}

.modal .table select {
    padding: 0.175rem 0.4rem;
    margin: 0 5px 0 5px;
    color: #495057;
    background-color: #fff;
    background-clip: padding-box;
    border: 1px solid #ced4da;
    border-radius: 0.25rem;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.modal .table .dataTables_wrapper .dataTables_paginate {
    padding-top: 10px;
}

.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.modal .table .dataTables_wrapper .dataTables_info {
    padding-top: 17px;
    font-size: 0.75rem;
}

.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button.current,
.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
    border: 1px solid #979797;
    background-color: white;
    z-index: 3;
    color: #fff !important;
    cursor: default;
    background: var(--main-blue-color);
    border-color: var(--main-blue-color);
}

.modal .table .dataTables_wrapper .dataTables_filter {
    float: left !important;
    margin-bottom: 10px;
}

.modal .table .dataTables_wrapper .dataTables_length {
    margin-top: 10px;
    margin-left: 20px;
}

.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button {
    margin-left: -1px;
    line-height: 1.42857143;
    color: var(--main-blue-color) !important;
    border: 1px solid #ddd;
}

.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
    border: 1px solid #ddd;
    z-index: 2;
    background: #eee;
    background-color: #eee;
    border-color: #ddd;
    color: var(--main-blue-color) !important;
}

.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled,
.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover,
.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:active {
    color: #777 !important;
    cursor: not-allowed;
    background-color: #fff;
    border-color: #ddd !important;
}

.modal .table .dataTables_wrapper .dataTables_paginate .paginate_button:active {
    box-shadow: inset 0 0 3px #111;
    background: var(--main-blue-color);
    color: white !important;
}