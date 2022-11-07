(function() {
    var _tmplCache = {};
    this.parseTemplate = function(str, data) {
        /// <summary>
        /// Client side template parser that uses &lt;#= #&gt; and &lt;# code #&gt; expressions.
        /// and # # code blocks for template expansion.
        /// NOTE: chokes on single quotes in the document in some situations
        ///       use &amp;rsquo; for literals in text and avoid any single quote
        ///       attribute delimiters.
        /// </summary>    
        /// <param name="str" type="string">The text of the template to expand</param>    
        /// <param name="data" type="var">
        /// Any data that is to be merged. Pass an object and
        /// that object's properties are visible as variables.
        /// </param>    
        /// <returns type="string" />  
        var err = "";
        try {
            var func = _tmplCache[str];
            if (!func) {
                var strFunc =
                "var p=[],print=function(){p.push.apply(p,arguments);};" +
                            "with(obj){p.push('" +
                str.replace(/[\r\t\n]/g, " ")
                   .replace(/'(?=[^#]*#>)/g, "\t")
                   .split("'").join("\\'")
                   .split("\t").join("'")
                   .replace(/<#==(.+?)#>/g, "',escapeHtml($1),'")
                   .replace(/<#=(.+?)#>/g, "',$1,'")
                   .split("<#").join("');")
                   .split("#>").join("p.push('") + "');}return p.join('');";
                //console.debug("parseTemplate",strFunc);
                func = new Function("obj", strFunc);
                _tmplCache[str] = func;
            }
            return func(data);
        } catch (e) { err = e.message; }
        return "< # ERROR: " + escapeHtml(err) + " # >";
    };
})();

var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;',
    "/": '&#x2F;'
};
function escapeHtml(string) {
    return String(string).replace(/[&<>"'\/]/g, function (s) {
        return entityMap[s];
    });
}
//Artifact Types
var artifactsSelectable = [
    {
        value: "",
        label: "Select Artifact"
    }
];

var gitCommit = gitCommit || {};

//closure
(function(gitCommit){
    // called from gitCommit.doCommit() to determine *IF* this screen should be activated.
    // It returns an empty array if DX is not involved or a list metadata items WITHOUT artifact
    gitCommit.DXArtifact_validateItems = function(selectedObjectsList/*, artifactsSelectable*/) {
        console.log(selectedObjectsList);
        selectedObjectsList = initArtifactLogic(selectedObjectsList);
        // Filter metadata items without Artifact. If any, doCommit() will call DXArtifact_render()
        var itemsWithoutArtifact = [];
        for(var i=0 ; i < selectedObjectsList.length ; i++) {
            console.log('selectedObjectsList[i]===> ',selectedObjectsList[i]);
            if(!selectedObjectsList[i].ai || selectedObjectsList[i].ai === 'Select') {
                itemsWithoutArtifact.push(selectedObjectsList[i]);
            }
        }
        console.info('gitCommit.DXArtifact_validateItems() called', selectedObjectsList, artifactsSelectable, itemsWithoutArtifact);
        // save the 3 lists for later reference
        gitCommit.DXArtifact_selectedObjectsList = selectedObjectsList;
        gitCommit.DXArtifact_itemsWithoutArtifact = itemsWithoutArtifact;
        gitCommit.DXArtifact_artifactsSelectable = artifactsSelectable;

        return itemsWithoutArtifact.length>0;
    };

    // hide the metadata selection and show this grid so the user can select artifacts per metadata item
    gitCommit.DXArtifact_render = function() {
        console.info('gitCommit.DXArtifact_render() called', gitCommit.DXArtifact_itemsWithoutArtifact, gitCommit.DXArtifact_artifactsSelectable);

        $copado('div[id$="DXArtifact_wrapper"').show();
        DXArtifact_showModal();

        var createSelect = function(options, klass) {
            var s, i;
            s = document.createElement('select');
            s.classList.add(klass);
            s.classList.add('slds-select');
            for (i=0; i < options.length; i++) {s.options[i] = new Option(options[i].label, options[i].value);}
            return s;
        };

        // crete the <select class="DXArtifact_choice"><option>...
        var htmlSelectArtifact = createSelect(gitCommit.DXArtifact_artifactsSelectable, "DXArtifact_choice").outerHTML;
        var html = parseTemplate($copado('#DXArtifact_template').html(), {
            items: gitCommit.DXArtifact_itemsWithoutArtifact,
            htmlSelectArtifact: htmlSelectArtifact
        });

        // now render the template
        $copado("#DXArtifact_grid").html(html);
    };

    // validate the items, and if all is ok, call gitCommit.doCommit() to continue committing.
    gitCommit.DXArtifact_submit = function() {
        //var rows = gitCommit.DXArtifact_grid.jqxGrid('getboundrows');
        //console.debug('DXArtifact_submit()', rows);

        // Collect every select, for validation (allElementsAreSelected) and storing the selection in
        // gitCommit.DXArtifact_selectedObjectsList
        var allElementsAreSelected = true;
        $copado('select.DXArtifact_choice').each(function(idx, elt) {
            var val = $copado(elt).val();
            allElementsAreSelected = allElementsAreSelected && val;
            console.log(gitCommit.DXArtifact_itemsWithoutArtifact[idx].ai);
            console.log(val);
            //gitCommit.DXArtifact_selectedObjectsList[idx].ai = val;
            gitCommit.DXArtifact_itemsWithoutArtifact[idx].ai = val;
            //console.debug(allElementsAreSelected, idx, elt, val);
        });
        if(allElementsAreSelected) {
            DXArtifact_closeModal();
            console.log(gitCommit.DXArtifact_selectedObjectsList);
            gitCommit.doCommit(gitCommit.DXArtifact_selectedObjectsList);

        }else{
            alert("Please select the remaining artifacts for the metadata items");
        }
        return false;
    };

}(gitCommit)); //end closure

function DXArtifact_showModal() {
    setTimeout(function() {
        $copado('#DXArtifact_backdrop').addClass('slds-backdrop--open');
        $copado('#DXArtifact_modal').addClass('slds-fade-in-open');
    }, 10);
}

//Modal Close
function DXArtifact_closeModal() {
    $copado('#DXArtifact_modal').removeClass('slds-fade-in-open');
    $copado('#DXArtifact_backdrop').removeClass('slds-backdrop--open');
    return false;
}

/**
 * Prepoluate artifacts on metadata, also Set (value, label) list - Map
 * Get supported types and create the grid.
 * @param  {[type]} datasource  [All the metadata from the org]
 * @param  {[type]} force [description]
 * @return {[type]} datasource  [same datasource containing related Artifacts]
 */
    initArtifactLogic = function(datasource){
        console.log(datasource);
        console.log(_config);
        console.log(_config.data.artifactsParentOrgId);
        if(datasource && _config && _config.data.artifactsParentOrgId && _config.data.artifactsParentOrgId !== ''){
            try {
                var qA = "SELECT Id, Name FROM "+_config.ns + "Artifact__c WHERE "+_config.ns +"Org_Credential__c = '"+_config.data.artifactsParentOrgId+"'";
                var r = sforce.connection.query(qA);
                var artifacts = r.getArray("records");
                for(var i = 0; i < artifacts.length; i++) {
                    if(artifactsSelectable.length<=artifacts.length){
                        var a = [];
                        a.value = artifacts[i].Id;
                        a.label = artifacts[i].Name;
                        artifactsSelectable.push(a);
                    }
                    var q = "SELECT Body FROM Attachment WHERE Name='ArtifactMetadata' AND parentId = '" + artifacts[i].Id + "' order by LastModifiedDate DESC limit 1";
                    var result = sforce.connection.query(q);
                    var records = result.getArray("records");
                    console.log(records);
                    if (records.length === 0) continue;
                        //decode the attach body
                        var res = Base64.decode(records[0].Body);
                        //parse json
                        var selectedMetadata = $copado.parseJSON(res);
                        console.log(datasource);
                        console.log(selectedMetadata);
                        for (var j = 0; j < datasource.length; j++) {
                            for (var k = 0; k < selectedMetadata.length; k++) {
                                if(datasource[j].t == selectedMetadata[k].t && datasource[j].n == selectedMetadata[k].n){
                                    //Metadata contained in Artifact Already
                                    datasource[j].ai = artifacts[i].Id;
                                }else if(datasource[j].ai === undefined || datasource[j].ai === ' '){
                                    datasource[j].ai = 'Select';
                                }
                            }
                        }
                }
            }catch (e) {
                console.warn('Exception Retrieving Artifact Information:', e);
            }
        }
        return datasource;
    };