
.rectangle {
    height: 50px;
    width: 100%;
    box-shadow: 0 1px 0 0 #BDBDBD;
}

.aura-bundle-page-template {
    height: 18px;
    color: #080707;
    font-family: "Salesforce Sans";
    font-size: 14px !important;
    line-height: 18px;
}

.aura-bundle-view-button{
    border-radius: 4px;
    background-color: #FFF;
    border: 1px solid #DDDBDA;
}

.files-to-compare {
    margin-left: 1%;
    float:left;
    height: 23px;
    color: #080707;
    font-family: "Salesforce Sans";
    font-size: 18px;
    line-height: 23px;
}

#fs2append{
    width: 98%;
    margin-left: 1%;
}

#fileModalHeader{
    border-bottom: 2px solid #3593c6;
    background-color: white !important;
}

#fileResolveModal #view{
    height:100% !important;
}

.line-item {
  height: 50px;
  width: 100%;
}

.noSidebarCell {
    padding: 0px !important;
}
.outerNoSidebar {
    padding: 0px !important;
}

.CodeMirror-merge-copy{
    font-size:0px;
}

.CodeMirror {
    font-family: SFMono-Regular,Consolas,Liberation Mono,Menlo,Courier,monospace;
    font-size: 12px;
    //text-indent: -7px;
    line-height: 20px;
}
.CodeMirror-linenumber{
    top: -3px;
}
.CodeMirror-linenumber{
    background-color:#ffffff !important;
}

.CodeMirror-merge-r-deleted{
    background-color:#acf2bd !important;
}

.CodeMirror-merge-r-inserted{
    background-color:#fdb8c0 !important;
}

.CodeMirror-merge-pane-rightmost .CodeMirror-merge-r-chunk {
    background: #ecfdf0 !important;
}
.CodeMirror-merge-pane-rightmost .CodeMirror-merge-r-chunk-end {
    border-bottom: 1px solid #c7f0d2 !important;
}
.CodeMirror-merge-pane-rightmost .CodeMirror-merge-r-chunk-start {
    border-top: 1px solid #c7f0d2 !important;
}

.CodeMirror-merge-r-chunk {
    background: #fbe9eb !important;
}
.CodeMirror-merge-r-chunk-end {
    border-bottom: 1px solid #fac5cd !important;
}
.CodeMirror-merge-r-chunk-start {
    border-top: 1px solid #fac5cd !important;
}

.line-error {
    background-color: red !important;
}

.slds-scope .slds-page-header__detail-row {
    background-color: white !important;
}

.CodeMirror-simplescroll{
    margin-top: 10px !important;
    height:100% !important;
    display:flex;
}

.CodeMirror-linenumbers, .CodeMirror-merge-gap{
    background-color:white !important;
}

.CodeMirror {
    border-top: 1px solid black;
    border-bottom: 1px solid black;
    height: 100% !important;
 }
 .CodeMirror-merge,.CodeMirror-merge .CodeMirror,.CodeMirror-merge-pane{
     height: 100% !important;
 }
.cm-highlightSearch {
    background: yellow !important;
}
.CodeMirror-selection-highlight-scrollbar {
    background-color: green !important;
}
.CodeMirror-simplescroll .CodeMirror-scroll{
    width:100%;
}

#screenLockerLightning{
    position: fixed;
    top: 0;
    left: 0;
    height: 100%;
    width: 100%;
    z-index: 10000;
    background-color: rgba(33,33,33,0.2);
}
.slds-screenlocker div{
    position: absolute;
    top: 50%;
    left: 50%;
    margin-right: -50%;
    transform: translate(-50%, -50%);
    padding-top: 15px;
    padding: 30px;
    background-color: transparent;
    z-index: 9999;
}

.round {
    border-radius: 50%;
}
.slds-scope .slds-modal__content{
    overflow-y : hidden !important;
}
body label.slds-radio_button__label{
    margin-right: .0rem;
    border: 0px !important;
}


@media only screen and (max-width: 1440px)  {
   #modal-content-id-1{
       min-height: 84% !important;
   }

   .slds-modal__container>header, .slds-modal__container>footer{
       height:8%;
   }
}

@media only screen and (min-width: 1441px)  {
   #modal-content-id-1{
       min-height: 88% !important;
   }

   .slds-modal__container>header, .slds-modal__container>footer{
       height:6%;
   }
}