
/* Variables */
:root {
	--main-blue-color: #1589EE;
	--form-text-color: #080707;
	--actions-color: #006DCC;
}

/* Resets */

body {
    overflow: hidden;
}

body .datePicker {
    z-index: 9999;
}

body .slds-form-element {
    padding-top: 0;
    padding-bottom: 0;
}

body .lookupInput > a {
    border: 1px solid rgb(221, 219, 218);
    border-radius: .25rem;
    transition: border .1s linear,background-color .1s linear;
    padding: 0 1rem 0 .75rem;
    line-height: 1.875rem;
    min-height: calc(1.875rem + (1px * 2));
}

/* Container */
.co-pipeline-container {
    padding: 0 1rem;
    font-family: "Salesforce Sans";
    height: calc(100vh - 25px);
}

.co-pipeline-container.classic-container {
    width: 97vw;
    height: calc(100vh - 185px);
}

.co-pipeline-container #pipelineContainer {
    height: calc(100% - 100px);
    width: 100%;
    overflow: hidden;

}

/* Header */

.co-pipeline-container #headerPanel .toggle-pipeline {
    margin-right: 0;
}

.co-pipeline-container #headerPanel .pipeline-picklist {

    border: none;
    background: #F7F9FB;
    width: 200px;
}

.co-pipeline-container #headerPanel button.diagramActionButton {
    height:100%;
}

/* Content */
.co-pipeline-container #pipelineContainer .wrapper {
    width: auto;
    height: 95%;
    z-index: 1;
}

.co-pipeline-container.classic-container #pipelineContainer .wrapper {
    height: 94%;
}

.co-pipeline-container #pipelineContainer .filterOptionsMenu img.settings {
    max-height: 14px;
}

.co-pipeline-container #pipelineContainer .filterOptionsMenu img.down-arrow {
    max-height: 8px;
}

.co-pipeline-container #pipelineContainer .wrapper .pipeline {
    display: flex;
    height: 96%;
    padding: 5px;
    overflow: auto;
}

.co-pipeline-container.classic-container #pipelineContainer .wrapper .pipeline {
    height: 95%;
}

.co-pipeline-container #pipelineContainer .wrapper .pipeline .column {
    width: 310px;
    min-width: 310px;
    padding: 20px;

}

.co-pipeline-container #pipelineContainer .wrapper .pipeline .column .box-container {
    position: relative;
    margin-bottom: 15px;

}

.co-pipeline-container #pipelineContainer .wrapper .pipeline .column .box-container.diagram {
    height: 80px;
    width: 193px;

}

.co-pipeline-container #pipelineContainer .wrapper .pipeline .column .box-container.manager {
    height: 60px;
    width: 183px;
}

.co-pipeline-container .env-box {
    height: auto;
    text-align: left !important;
    background-color: white;
    margin-left: 5px;
    border: 1px solid #dedbda;
    border-radius: 5px;
    -webkit-filter: grayscale(0%);
    filter: grayscale(0%);
}

.co-pipeline-container .env-box hr {
    width: 90%;
    margin: 0 auto;
}

.co-pipeline-container #pipelineContainer .wrapper .pipeline .column .box-container.diagram .env-box {
    min-height: 80px;
    max-height: 80px;
}

.co-pipeline-container #pipelineContainer .wrapper .pipeline .column .box-container.manager .env-box {
    min-height: 60px;
    max-height: 60px;
}

.co-pipeline-container .env-box .info {
    display: flex;
    justify-content: flex-start;
    padding-bottom: 5px;
    cursor: move;
}

.co-pipeline-container .env-box .info .status {
    padding: 4px 0 0 6px;
}

.co-pipeline-container .env-box .info .data {
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
    margin-top: 5px;
    padding-left: 8px;
}

.co-pipeline-container .env-box .info .data .org {
    text-transform: uppercase;
    font-size: 11px;
    color: #080707;
}

.co-pipeline-container .env-box .info .data .branch {
    color: #828282;
    font-size: 12px;
    padding: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.co-pipeline-container .env-box .info .data .branch span {
   margin-left: 1px;
   color: #080707;
}


.co-pipeline-container .env-box .info .status .slds-spinner {
    position: relative;
    z-index: 6;
}

.co-pipeline-container .env-box .info .status img {
    width: 15px;
    height: 15px;
}

.co-pipeline-container .env-box .info .status .spinner {
    height: 15px;
}

.co-pipeline-container .env-box hr {
    clear: none;
}

.co-pipeline-container .slds-dropdown_left {
    transform: translate(67%, -55px);
    width: 250px;
}

.co-pipeline-container .slds-dropdown_actions.actions {
    min-width:160px;

}

.co-pipeline-container .slds-dropdown_actions.actions input {
    border: none;
    background-color: white;
    color: rgb(0, 109, 204);
    padding-left: 0;
    border-radius: unset;
    box-shadow: 0 0 3px #FFF;

}


.co-pipeline-container .create-env-btn {
    margin-left: -11px;
    margin-top: 10px;
    position: absolute;
    top: -4px;
    height: 55%;
}

.co-pipeline-container .env-connection-info {
    display: flex;
    justify-content: left;
    cursor: pointer;
    width: 50%;
    float: left;
}

.co-pipeline-container .env-connection-info .env-connection-behaviour-override {
    display: flex;
    justify-content: left;
    height: 25px;
    width: 80px;
    position: relative;
    text-align: center;
    padding-left: 5px;

}

.co-pipeline-container .connection-info {
    float: right;
    height: 100%;
    width: auto;
    min-width: 56px;
    margin-right: -60px;
}

.co-pipeline-container .connection-info .connection-behaviour-override {
    display: flex;
    justify-content: center;
    height: 21px;
    width: 50px;
    margin-top: 30px;
    position:relative;
    text-align: center;
    padding: 2px;
    border: 1px solid #ebebeb;
    border-radius: 11px;
    background-color: white;
}

.co-pipeline-container .connection-info .connection-behaviour-override.hide {
    visibility: hidden;
    opacity: 0

}

.co-pipeline-container .connection-info .connection-behaviour-override.show {
    cursor: pointer;
    visibility: visible;
    opacity: 1;
    -webkit-transition: visibility 1s ease-out 0.2s, opacity 0.125s linear 0.2s;
    -moz-transition: visibility 1s ease-out 0.2s, opacity 0.125s linear 0.2s;
    -o-transition: visibility 1s ease-out 0.2s, opacity 0.125s linear 0.2s;
    transition: visibility 1s ease-out 0.2s, opacity 0.125s linear 0.2s;
}

.co-pipeline-container .connection-info .connection-behaviour-override .icon {
    padding: 0px 2px;
    cursor: pointer;
}

.co-pipeline-container .connection-info .connection-behaviour-override .icon .image-wrapper,
.co-pipeline-container .connection-info .connection-behaviour-override .icon .image-wrapper-2 {
    display: flex;
    justify-content: center;
    margin-top: -5px;
    cursor: pointer;
}

.co-pipeline-container .connection-info .connection-behaviour-override .icon .image-wrapper-2 img.connection{
    margin-top: 2px;
}

.co-pipeline-container .env-connection-info .env-connection-behaviour-override .icon {
    padding: 5px;
    display: block;
    margin-top: -5px;
}

.co-pipeline-container .env-connection-info .env-connection-behaviour-override .icon > div {
    height: 10px;
}


.co-pipeline-container .env-connection-info .env-connection-behaviour-override img {
    width: auto;
    height: auto;
}

.co-pipeline-container .connection-info .connection-behaviour-override  img.connection {
    width: 11px;
    height: auto;
}

.co-pipeline-container .connection-info .connection-behaviour-override  img.new {
    width: 35px;
    height: auto;
    margin-top: -5px;
}


.co-pipeline-container .connection-info .commits {
    display: flex;
    justify-content: center;
    height: 28px;
    margin-top: 19px;
    margin-left: 0px;
    position: relative;
    text-align: center;
    padding: 0;
    border: 1px solid #ebebeb;
    border-radius: 14px;
    background-color: white;

}


.co-pipeline-container .connection-info .commits .icon:first-of-type {
    margin-right: 5px;
}

.co-pipeline-container .connection-info .commits .disabled {
    opacity: 0.5;
}

.co-pipeline-container .connection-info .commits .button-wrapper {
    height: 16px;
    display: flex;
    justify-content: center;
    margin-top: 1px;
}

.co-pipeline-container .connection-info .commits .image-wrapper {
    display: flex;
    justify-content: center;
}

.co-pipeline-container .connection-info .commits .button-wrapper button {
    padding: 0 3px;
    border: none;
    border-bottom-color: white;
    background: white;
    font-size: 12px;
    color: #1589EE;
}

.co-pipeline-container .connection-info .commits  img {
    width: 11px;
    height: auto;
}

.co-pipeline-container .envActionMenuTrigger {
    float: right;
    padding: 5px 6px;
}

.co-pipeline-container .envActionMenuTrigger button.envActionButton {
    width: 17px;
    height: 17px;
}


.co-pipeline-container .authenticate-icon {
    display: flex;
    justify-content: flex-end;
    padding: 0px 25px 3px 0;
    float: right;
}

.co-pipeline-container .authenticate-icon img {
    cursor: pointer;
    width: 24px;
    height: 24px;
}

.co-pipeline-container .createEnv,
.co-pipeline-container .noCreateEnv {
    font-size: 20px !important;
    width: 50px;
    border-right: none;
    border-bottom: none;
    border-top: none;
    border: none;
    color:white !important;
    background-color: #9ebfd8 !important;
    text-align: left;
    border-radius: 50px;
    padding-left: 4px;
}

.co-pipeline-container .createEnv:hover {
    background-color:#3593c6 !important;
    margin-left: -4px;
}

.co-pipeline-container .forceDetailPanelDesktop .pageLevelErrors {
    outline: none;
}

.co-pipeline-container .forcePageError {
    border-bottom: 1px solid rgb(221, 219, 218);
    margin-bottom: 1rem;
    padding-bottom: .75rem;
}

.co-pipeline-container .forcePageError.desktop .genericNotification {
    font-weight: 300;
    border-radius: .25rem;
    font-size: 1rem;
}

.co-pipeline-container .forcePageError .genericNotification {
    background: rgb(194, 57, 52);
    padding: 1rem;
    color: rgb(255, 255, 255);
    line-height: 1.25;
}

.co-pipeline-container .forcePageError .errorsList {
    list-style: none;
    color: rgb(194, 57, 52);
    line-height: 1.5;
    margin: 0;
    padding: .5rem 1rem .25rem 1rem;
}

.co-pipeline-container .forcePageError.desktop .errorsList {
    font-size: .8125rem;
}


.co-pipeline-container .slds-page-header {
    background-color: #F7F9FB;
}

.co-pipeline-container .slds-page-header .slds-page-header__title {
    color: var(--form-text-color);
	font-size: 14px;
	font-weight: 600;
	line-height: 23px;
	border-bottom: 1px solid gray;
	width: 100%;
}

.co-pipeline-container .slds-text-title {
	color: #54698D;
	font-size: 12px;
    line-height: 15px;
    margin-bottom: 5px;
}

.co-pipeline-container .slds-page-header__detail-block .value {
	color: #16325C;
	font-size: 12px;
	line-height: 15px;
}

.co-pipeline-container  .slds-tabs_card.slds-tabs_card {
    background: transparent;
    padding: 0
}


/* Minimap */
.co-pipeline-container #minimap {
    display: none;
    position: fixed;
    /*overflow: hidden;*/
    width: 175px;
    height: 125px;
    bottom: 50px;
    right: 67px;
    background-color: #FFF;
    border: 2px solid #dedbda;
    border-radius: 10px;
    opacity: 0.9;
    z-index: 999;
}

#minimapHeader {
    padding: 0 10px;
    cursor: move;
    z-index: 10;
    background-color: transparent;
    color: #cecece;
    position: absolute;
    top: -28px;
    right: -11px;
    font-size: 20px;
}

.co-pipeline-container #minimap .minimap-node {
    position: absolute;
    background-color: #C8C8C8;
}

.co-pipeline-container #minimap .minimap-viewport {
    position: absolute;
    box-sizing: border-box;
    background-color: rgba(255,225,157,0.1);
    z-index: 1;
    cursor: move;
    border-radius: 8px;
    border: 1px solid #E6D8A7;
}



/* Connection lines */

.co-pipeline-container  #svgContainer {
    z-index:  0;
    position: relative;
}

.co-pipeline-container  #svgContainer svg {
    position: absolute;
    top: 0px;
    left: 0px;
}

.co-pipeline-container #svgContainer svg path {
    fill:   none;
    stroke: #CDDFEE;
    stroke-width: 1px;
}

.co-pipeline-container #svgContainer svg defs marker path {
    fill: #cedeeb;
}


/* Buttons
.co-pipeline-container .buttons {
    text-align: right;
}

.co-pipeline-container .buttons .slds-button {
    font-weight: bold;
	font-weight: bold;
	width: auto;
	padding: 3px 20px;
	min-width: 160px;
}

.co-pipeline-container .buttons .slds-button+.slds-button {
    margin-left: 1.10rem;
}


*/

.co-pipeline-container .slds-button_brand {
    border: 1px solid var(--main-blue-color);
    background-color: var(--main-blue-color);
}

.co-pipeline-container .slds-button_brand:hover {
    border: 1px solid #3593c6;
    background-color: #3593c6;
}

.co-pipeline-container .slds-button_outline-brand {
    border-color: var(--main-blue-color);
    color: var(--main-blue-color);
}

.co-pipeline-container .toggle-button {
    padding: 10px 0 43px 0;
    cursor: pointer;
    width: 280px;
}

.co-pipeline-container .toggle-button span {
    color: var(--actions-color);
    font-size: 14px;
    line-height: 20px;
}

.co-pipeline-container .filter-main-object {
    background-color: #FFF;
}

.co-pipeline-container .filter-main-object .filter-wrapper {
    padding: .5rem .5rem 1rem .5rem;
    margin: 0;
}

.co-pipeline-container .filter-main-object .filter-wrapper select {
    margin-top: 2px;
}

.co-pipeline-container .filter-main-object .filter-wrapper .sample-button {
    text-align: left;
    margin-bottom: 3rem;
}


.co-pipeline-container .more-options {
    width: 33px;
    height: 23px;
    margin-top: 3px;
}

.co-pipeline-container .more-options button {
    padding: 0;
    width: 30px;
    height: 21px;
}


/*
   This css are for multiselect picklist lookup fields.
   In Salesforce lookup fields some fields can have multiple objects so
   it breaks the html.
*/
.lookupInput {
    padding: 0 !important;
    width: 100%;
}

.hideDropdown select {
    display: none !important;
}

.hideDropdown div {
    border: none;
    padding: 0px;
}

.hideDropdown input {
    width: 100%;
    padding: 0px;
}

.lookupInput a {
    position: absolute;
    height:22px !important;
    width: 33px !important;
    margin-left: -33px;
    background-image: url(/img/setup/search-icon.png) !important;
    background-repeat: no-repeat !important;
    background-position: center !important;
    display: inline-flex !important;
}

.lookupInput a img, .lookupInput a svg{
    display:none !important;
}

.noDisplay {
    display: none !important;
}

.pillBackground {
    background-color: #315575 !important;
    padding: 5px !important;
    margin: 3px;
}

.closeIconBackground {
    background: none;
    color: white;
}

.closeIconBackground2 {
    background: none;
}

.WarningColor {
    background-color: #ffb75d !important;
    border: 1px solid #ffb75d !important;
}

input.toggle {
    border-radius: 3px;
    border: 1px solid #dddbda;
}

.slds-dropdown__item > a[aria-disabled=true] {
    color: rgb(221, 219, 218);
    cursor: not-allowed;
    pointer-events: none;
}

.filterDropdown {
    height: 30px;
    display: flex;
}

.slds-modal__close > img {
    max-height: 30px;
    filter: invert(100%);
    cursor: pointer;
}

.deleteIcon > img {
    width: 27%;
    filter: grayscale(100%) brightness(100%) sepia(100%) hue-rotate(-50deg) saturate(600%) contrast(0.8);
    cursor: pointer;
}

/* Modals */

#filterModalDiv .slds-button_brand,
#confirmDeletePopup .slds-button_brand {
    border: 1px solid var(--main-blue-color);
    background-color: var(--main-blue-color);
}

#filterModalDiv .slds-button_brand:hover,
#confirmDeletePopup .slds-button_brand:hover {
    border: 1px solid #3593c6;
    background-color: #3593c6;
}

#filterModalDiv .slds-button_outline-brand,
#confirmDeletePopup .slds-button_outline-brand {
    border-color: var(--main-blue-color);
    color: var(--main-blue-color);
}

#filterModalDiv .slds-form-element.checkbox {
    margin-top: 0.5rem;
    margin-left: 5rem;
}

#filterModalDiv table.layout button {
    width: 20px;
}

#filterModalDiv .dueling-picklist .multiSelectPicklistRow .slds-input.picklistArrowRight,
#filterModalDiv .dueling-picklist .multiSelectPicklistRow .slds-input.picklistArrowLeft {
    border: none;
    border-radius: 0;
    transition: none;
    display: inline-block;
    padding: 0;
    line-height: 0;
    min-height: 20px;
    width: 20px;
}

#filterModalDiv .dueling-picklist .multiSelectPicklistRow td {
    vertical-align: middle;
}

#confirmDeletePopup > section {
    z-index: 9999;
}

#confirmDeletePopup > div {
    z-index: 9998;
}

