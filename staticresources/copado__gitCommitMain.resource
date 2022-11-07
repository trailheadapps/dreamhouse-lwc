
var gitCommitMain = gitCommitMain || {};
var metadataGrid2;
//closure
(function(app){
    // start the commit operation, do checks, etc
    app.startCommit = function(callback) {
        console.log('callback===> ',callback);
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

        // cut the commit message length to < 255 chars.
        commitData.formData.copadoCommitMessage = commitData.formData.copadoCommitMessage.substring(0,255);

        if(callback) {
            callback(commitData.formData.copadoCommitMessage,gitCommitCommons.conf.data.orgId,gitCommitCommons.conf.data.snapshotId,gitCommitCommons.conf.data.operationLabel);
        } else {
            unlockScreen();
        }
    };
}(gitCommitMain)); //end closure