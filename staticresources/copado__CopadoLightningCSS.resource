/**
 * Stylesheet to update HTML elements to the Lightning look
 *
 * @author David VENEGAS
 * @date 12.10.2017
 */
 button.copado-lightning, a.copado-lightning  {
    -webkit-appearance: none;
    position: relative;
    display: inline-block;
    border: 1px solid transparent;
    padding: 0;font-size: .75rem;
    line-height: 1.875rem;
    text-decoration: none;
    white-space: normal;
    border-radius: .25rem;
    background: transparent;
    background-clip: border-box;
    color: #0070d2;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    transition: color .05s linear,background-color .05s linear;
    padding-left: 1rem;
    padding-right: 1rem;
    text-align: center;
    vertical-align: middle;
    border: 1px solid #dddbda;
    transition: border .15s linear;
    border-color: #dddbda;
    background-color: white;
}

.copado-lightning-container {
    margin:0 12px 12px 12px !important;
}

.bDescription, .bDescriptionUi {
    padding-top:4px !important;
}

.copado-lightning-SLDS {
    margin: 12px;
    background-image: url(/_slds/images/themes/oneSalesforce/banner-brand-default.png?cache=210.2),linear-gradient(to top,rgba(32, 92, 159, 0), rgb(32, 92, 159));
}

.copado-lightning-VF {
    background-image: url(/_slds/images/themes/oneSalesforce/banner-brand-default.png?cache=210.2),linear-gradient(to top,rgba(32, 92, 159, 0), rgb(32, 92, 159));
    padding-top: 12px;
}


.slds-page-header {
    background: #fdfdfd;
    padding-bottom: 10px;
    border-collapse: collapse;
    border-radius: 4px;
}

.copado-lightning-radius {
    background-color: #FFF;
    border-collapse: collapse;
    border-radius: 4px;
}

HTML {
    height: 100%;
}

.rich-tab-header {
    max-width: 100% !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    white-space: nowrap !important;
    display: block !important;
    height: calc(2.5rem - 2px) !important;
    line-height: 2.5rem !important;
    text-decoration: none !important;
    color: currentColor !important;
    cursor: pointer !important;
    font-size: 14px !important;
    padding: 0px !important;
}

.rich-tab-active {
    color: #16325c !important;
    background-image: none !important;
    background-color: transparent !important;
    border: none !important;
}

.rich-tab-inactive {
    position: relative !important;
    top: .125rem !important;
    background-color: transparent !important;
    background-image: none !important;
    border: none !important;
}

.rich-tabhdr-side-cell{
    border:none !important;
}

.rich-tabpanel-content{
    padding:0px !important;
}

.headRow {
    ont-size: 12px !important;
}

.dataCell {
    font-size: 13px !important;
    color : rgb(62, 62, 60) !important;
}

.autoCompleteBoxScrolling {
    transform: translateX(0%) !important;
    width: 45% !important;
}
#cke_publisherRichTextEditor_autoCompleteBoxId{
    width: 45% !important;
}
.mainTitle {
    font-size: 16px !important;
}

.copado-lightning-chatter .bPageTitle {
    padding-bottom: 0 !important;
    margin-bottom: 0 !important;
}
.jqx-widget-header, .jqx-tabs-header, .jqx-grid-column-header, .jqx-grid-cell-pinned, .jqx-fill-state-pressed, .jqx-fill-state-normal, .jqx-grid-cell-filter {      
    background-color: #FFF !important;        
 } 
