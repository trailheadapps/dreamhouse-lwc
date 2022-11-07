utilsV2 = {
    method: 'GET',
    onSuccessCB: function(res){},
    onFailureCB: function(res){},
    
    getRemote: function(url){
    if(Copado_Licenses.hasMultiLicense && !(Copado_Licenses.hasCopado || Copado_Licenses.hasCCM 
        || Copado_Licenses.hasCST || Copado_Licenses.hasCCH) ) {
            var errorMsgs = 'Your current license does not allow performing this action';
            alert(errorMsgs);
            return false;
        }

        var me = utilsV2;
        console.debug('getRemote', url);
        sforce.connection.remoteFunction({
            url : url,
            requestHeaders: {
                    "Content-Type": "text/json",
                    "userId": _temp_conf.userId,
                    "orgId": _temp_conf.orgId,
                    "token2": _temp_conf.token2
            },
            method: me.method,
            requestData: {},
            onSuccess: function(res) {
                console.debug('getRemote success', String(res).substr(0, 512));
                var obj = $copado.parseJSON(res);
                if(obj && obj.error && obj.error!=''){
                    console.error(obj.error);
                    alert(obj.error);
                    me.onFailureCB(obj);
                }
                else{
                    if(me.onSuccessCB)me.onSuccessCB(res);
                }
            },
            onFailure: function(obj) {
                console.debug('getRemote failure', String(obj).substr(0, 512));
                if(me.onFailureCB){
                    me.onFailureCB(obj);
                }
                else{ 
                    var errorMsgs = (obj.messages && obj.messages.length>0)?obj.messages.join('\n'): copadoLabels.JAVASCRIPT_GENERAL_ERROR;
                    alert(errorMsgs);
                    console.error('Error Messages: ', errorMsgs); 
                }
            },
            timeout: 25000
        });
        return true;
    },
    /**
     * Gets the requested URL parameter.
     * For commit changes
     * @param  {[String]}  sParam       The name of the requested URL parameter
     * @return {[type]}                 Return true if nothing is found else return param value
     */
    getUrlParameter: function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
    
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
};