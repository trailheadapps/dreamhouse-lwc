var gitCommitDX = gitCommitDX || {};
(function(app) {
    var _tmplCache = {};

    app.startCommit = function(callback) {
        //console.log('callback===> ',callback);
        //app.commitButton = button; // TODO initialize the commit button for DOM operations.
        if(!gitCommitCommons){
            alert('Invalid structure for main git commit operations. Please contact Copado support.');
            return;
        }
        // gather all the FORM data, and create a formData={name: value, name: value,...}
        var commitData = gitCommitCommons.conf.jsonData;
        commitData.formData = $copado(gitCommitCommons.conf.elts.gitCommitMainForm).serializeArray().reduce(function(obj, item) {
            var itemNormalizedName =  item.name.indexOf(':') >= 0 ? item.name.split(':').slice(-1).pop()  : item.name;
            obj[itemNormalizedName] = item.value;
            return obj;
        }, {});

        // validate all the info previous to committing
        if( !commitData.formData.copadoCommitMessage ) {
            alert('You need to set a message');
            return unlockScreen();
        }
        if( !gitCommitCommons.conf.jsonData.selectedMetadata || !gitCommitCommons.conf.jsonData.selectedMetadata.length ) {
            alert('You need to select at least one item to commit');
            return unlockScreen();
        }

        // cut the commit message length to < 80 chars.
        commitData.formData.copadoCommitMessage = commitData.formData.copadoCommitMessage.substring(0,80);

        //validate start
        //console.log('gitCommitCommons.conf===> ',gitCommitCommons.conf);
        if(gitCommitCommons.conf && gitCommitCommons.conf.data.artifactsParentOrgId && gitCommitCommons.conf.data.artifactsParentOrgId !== '' && gitCommitCommons.conf.data.type != 'GitDeletion'){
            console.log("Scratch Org From Artifacts");
            //console.log("gitCommitCommons.conf.jsonData.selectedMetadata ==> ",gitCommitCommons.conf.jsonData.selectedMetadata);
            if(DXArtifact_validateItems(gitCommitCommons.conf.jsonData.selectedMetadata)) {
                console.log("validateItems");
                unlockScreen();
                DXArtifact_render();
                return false;
            }
        }
        //validate end

        if(callback) {
            callback(commitData.formData.copadoCommitMessage,gitCommitCommons.conf.data.orgId,gitCommitCommons.conf.data.snapshotId,gitCommitCommons.conf.data.operationLabel);
            unlockScreen();
        } else {
            unlockScreen();
        }
    };

    // called from doCommit() to determine *IF* this screen should be activated.
    // It returns an empty array if DX is not involved or a list metadata items WITHOUT artifact
    var DXArtifact_validateItems = function(selectedObjectsList) {
        //console.log('selectedObjectsList===> ',selectedObjectsList);
        selectedObjectsList = initArtifactLogic(selectedObjectsList);
        // Filter metadata items without Artifact. If any, doCommit() will call DXArtifact_render()
        var itemsWithoutArtifact = [];
        for(var i=0 ; i < selectedObjectsList.length ; i++) {
            //console.log('selectedObjectsList[i]===> ',selectedObjectsList[i]);
            if(!selectedObjectsList[i].ai || selectedObjectsList[i].ai === 'Select') {
                itemsWithoutArtifact.push(selectedObjectsList[i]);
            }
        }
        console.info('DXArtifact_validateItems() called', selectedObjectsList, artifactsSelectable, itemsWithoutArtifact);
        // save the 3 lists for later reference
        DXArtifact_selectedObjectsList = selectedObjectsList;
        DXArtifact_itemsWithoutArtifact = itemsWithoutArtifact;
        DXArtifact_artifactsSelectable = artifactsSelectable;

        return itemsWithoutArtifact.length>0 && (continueWithoutAllArtifacts === false);
    };

    // hide the metadata selection and show this grid so the user can select artifacts per metadata item
    var DXArtifact_render = function() {
        console.info('DXArtifact_render() called', DXArtifact_itemsWithoutArtifact, DXArtifact_artifactsSelectable);

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
        var htmlSelectArtifact = createSelect(DXArtifact_artifactsSelectable, "DXArtifact_choice").outerHTML;
        var html = parseTemplate($copado('#DXArtifact_template').html(), {
            items: DXArtifact_itemsWithoutArtifact,
            htmlSelectArtifact: htmlSelectArtifact
        });

        // now render the template
        $copado("#DXArtifact_grid").html(html);
    };

    // validate the items, and if all is ok, call doCommit() to continue committing.
    app.DXArtifact_submit = function() {
        //var rows = DXArtifact_grid.jqxGrid('getboundrows');
        //console.debug('DXArtifact_submit()', rows);

        // Collect every select, for validation (allElementsAreSelected) and storing the selection in
        // DXArtifact_selectedObjectsList
        var allElementsAreSelected = true;
        $copado('select.DXArtifact_choice').each(function(idx, elt) {
            var val = $copado(elt).val();
            allElementsAreSelected = allElementsAreSelected && val;
            //DXArtifact_selectedObjectsList[idx].ai = val;
            DXArtifact_itemsWithoutArtifact[idx].ai = val;

        });
        if(allElementsAreSelected || (!allElementsAreSelected && confirm("Do you want to continue without selecting artifacts for all the metadata items?"))) {
            continueWithoutAllArtifacts = true;
            gitCommitDX.DXArtifact_closeModal();
            gitCommitCommons.startCommit(DXArtifact_selectedObjectsList);
        }
        return false;
    };

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
                   .replace(/<#==(.+?)#>/g, "',gitCommitDX.escapeHtml($1),'")
                   .replace(/<#=(.+?)#>/g, "',$1,'")
                   .split("<#").join("');")
                   .split("#>").join("p.push('") + "');}return p.join('');";

                func = new Function("obj", strFunc);
                _tmplCache[str] = func;
            }
            return func(data);
        } catch (e) { err = e.message; }
        return "< # ERROR: " + gitCommitDX.escapeHtml(err) + " # >";
    };
    app.entityMap = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': '&quot;',
        "'": '&#39;',
        "/": '&#x2F;'
    };
    app.escapeHtml = function(string) {
        return String(string).replace(/[&<>"'\/]/g, function (s) {
            return gitCommitDX.entityMap[s];
        });
    };
    //Artifact Types
    var artifactsSelectable = [
        {
            value: "",
            label: "Select Artifact"
        }
    ];

    var continueWithoutAllArtifacts = false;

    var DXArtifact_showModal = function() {
        setTimeout(function() {
            $copado('#DXArtifact_backdrop').addClass('slds-backdrop--open');
            $copado('#DXArtifact_modal').addClass('slds-fade-in-open');
        }, 10);
    };

    //Modal Close
    app.DXArtifact_closeModal = function() {
        $copado('#DXArtifact_modal').removeClass('slds-fade-in-open');
        $copado('#DXArtifact_backdrop').removeClass('slds-backdrop--open');
        return false;
    };

    app.autoSelect = function(){
        var gitOperation = gitCommitCommons.conf.data.type;
        //console.log(gitOperation);
        var dC = false;
        if(gitOperation === 'Destructive Changes'){
            dC = true;
        }
        gitCommitCommons.loadSourceStatus(dC);
    }

    /**
     * Prepoluate artifacts on metadata, also Set (value, label) list - Map
     * Get supported types and create the grid.
     * @param  {[type]} datasource  [All the metadata from the org]
     * @param  {[type]} force [description]
     * @return {[type]} datasource  [same datasource containing related Artifacts]
     */
    var initArtifactLogic = function(datasource){
        //console.log(datasource);
        //console.log(gitCommitCommons.conf);
        //console.log(gitCommitCommons.conf.data.artifactsParentOrgId);
        if(datasource && gitCommitCommons.conf && gitCommitCommons.conf.data.artifactsParentOrgId && gitCommitCommons.conf.data.artifactsParentOrgId !== ''){
            try {
                var qA = "SELECT Id, Name FROM "+gitCommitCommons.conf.ns + "Artifact__c WHERE "+gitCommitCommons.conf.ns +"Org_Credential__c = '"+gitCommitCommons.conf.data.artifactsParentOrgId+"'";
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
                    //console.log(records);
                    if (records.length === 0) continue;
                        //decode the attach body
                        var res = Base64.decode(records[0].Body);
                        //parse json
                        var selectedMetadata = $copado.parseJSON(res);
                        //console.log(datasource);
                        //console.log(selectedMetadata);
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
})(gitCommitDX);