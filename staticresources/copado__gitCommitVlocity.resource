var gitCommitVlocity = gitCommitVlocity || {};
(function(app) {
    app.getVlocityDependencies = function(){
        var sel = gitCommitCommons.grid.selectedMetadata;
        console.log('sel : ',sel);
        if(sel.length === 0){
            alert('Please select at least one metadata to retrieve dependencies for.');
            unlockScreen();
            return;
        }

        JsRemoting.vlocity.getDependencies(
            gitCommitCommons.conf.data.userStoryId,
            JSON.stringify(sel),
            gitCommitCommons.conf.ns,
            function(result) {
                // start the polling
                rerenderPoller();
            },
            function(event) {
                //console.warn('optionalCallout() gitcommit #1 Exception', event);
                alert('Exception: ' + event.message);
                unlockScreen();
            }
        );
    };

    app.forceVlocitySelections = function(results){
        if(!results) return;
        var resultArray = results;
        for(var i = 0; i<resultArray.length; i++){
            resultArray[i].s = true;
        }
        $copado('[id="notificationModal"]').hide();
        $copado('[id="backDropM"]').hide();
        return resultArray;
    };

})(gitCommitVlocity);