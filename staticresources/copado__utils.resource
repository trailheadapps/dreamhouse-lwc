var Base64 = {
    _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
    _MINSIZEFORBTOA: 10485760, // minimum size to siwtch to BOTA/ATOB native functions ( 200x faster, but not unicode-friendly )
    encode: function(c) {
        console.debug('Base64.encode.length', c.length, c.length > Base64._MINSIZEFORBTOA ? 'using btoa' : 'using unicode-safe');
        // Comment for Changes.
        // NR: there is  issue in btoa/atob: https://developer.mozilla.org/en/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
        // the std solution is too slow, so the fallback is the original code.
        // NR: btoa/atob sometimes fails, but silently, so, we get mangled characters... so, alternative: over 10mb of attachment, switch to native, otherwise, local
        try {
            if (c.length > Base64._MINSIZEFORBTOA)
                return window.btoa(c);
        } catch (e) {
            console.debug('btoa did not work. Falling back to Base64.encode because', e);
        }

        var a = "",
            d, b, f, g, h, e, j = 0;
        for (c = Base64._utf8_encode(c); j < c.length;) d = c.charCodeAt(j++), b = c.charCodeAt(j++), f = c.charCodeAt(j++), g = d >> 2, d = (d & 3) << 4 | b >> 4, h = (b & 15) << 2 | f >> 6, e = f & 63, isNaN(b) ? h = e = 64 : isNaN(f) && (e = 64), a = a + this._keyStr.charAt(g) + this._keyStr.charAt(d) + this._keyStr.charAt(h) + this._keyStr.charAt(e);
        return a
    },
    decode: function(c) {
        console.debug('Base64.decode.length', c.length, c.length > Base64._MINSIZEFORBTOA ? 'using atob' : 'using unicode-safe');

        // NR: there is  issue in btoa/atob: https://developer.mozilla.org/en/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
        // the std solution is too slow, so the fallback is the original code.
        // NR: btoa/atob sometimes fails, but silently, so, we get mangled characters... so, alternative: over 10mb of attachment, switch to native, otherwise, local
        try {
            if (c.length > Base64._MINSIZEFORBTOA)
                return window.atob(c);
        } catch (e) {
            console.debug('atob did not work. Falling back to Base64.encode because', e);
        }

        var a = "",
            d, b, f, g, h, e = 0;
        for (c = c.replace(/[^A-Za-z0-9\+\/\=]/g, ""); e < c.length;) d = this._keyStr.indexOf(c.charAt(e++)), b = this._keyStr.indexOf(c.charAt(e++)), g = this._keyStr.indexOf(c.charAt(e++)), h = this._keyStr.indexOf(c.charAt(e++)), d = d << 2 | b >> 4, b = (b & 15) << 4 | g >> 2, f = (g & 3) << 6 | h, a += String.fromCharCode(d), 64 != g && (a += String.fromCharCode(b)), 64 != h && (a += String.fromCharCode(f));
        a = Base64._utf8_decode(a);
        return a;
    },
    _utf8_encode: function(c) {
        c = c.replace(/\r\n/g, "\n");
        for (var a = "", d = 0; d < c.length; d++) {
            var b = c.charCodeAt(d);
            128 > b ? a += String.fromCharCode(b) : (127 < b && 2048 > b ? a += String.fromCharCode(b >> 6 | 192) : (a += String.fromCharCode(b >> 12 | 224), a += String.fromCharCode(b >> 6 & 63 | 128)), a += String.fromCharCode(b & 63 | 128))
        }
        return a
    },
    _utf8_decode: function(c) {
        for (var a = "", d = 0, b = c1 = c2 = 0; d < c.length;) b = c.charCodeAt(d), 128 > b ? (a += String.fromCharCode(b), d++) : 191 < b && 224 > b ? (c2 = c.charCodeAt(d + 1), a += String.fromCharCode((b & 31) << 6 | c2 & 63), d += 2) : (c2 = c.charCodeAt(d + 1), c3 = c.charCodeAt(d + 2), a += String.fromCharCode((b & 15) << 12 | (c2 & 63) << 6 | c3 & 63), d += 3);
        return a
    }
};

//IE helper
!window.console && (window.console = {
    log: function() {},
    error: function() {}
});

// parses an ISO date only (ignores ms and tz) "2018-04-25T13:24:39.000Z" and returns a LOCAL date.
Date.fromISOString = function(input) {
  return new Date(Date.UTC(
    parseInt(input.slice(0, 4), 10),
    parseInt(input.slice(5, 7), 10) - 1,
    parseInt(input.slice(8, 10), 10),
    parseInt(input.slice(11, 13), 10),
    parseInt(input.slice(14, 16), 10),
    parseInt(input.slice(17,19), 10)
  ));
};



//namespace
var dw = dw || {};
dw.u = {
    conf: {
        retryLimit: 300,
        retryUISelector: '#retry-label',
        fields2prevent: '==SetupOwnerId==, ==s==, ==Name==, ==type==, ==LastModifiedDate==, ==SystemModstamp==, ==IsDeleted==, ==CreatedById==, ==CreatedDate==, ==Id==, ==LastModifiedById=='
    }
};

dw.u.retry = function(url, cb, postData, avoidRetry, onError) {
    if (dw.u.getRemote.attempts < dw.u.conf.retryLimit) {
        dw.u.getRemote(url, cb, postData, avoidRetry, onError);
        //ﬁdw.u.conf.retryUISelector).append('...');
    } else {
        console.log('retry fail', dw.u.getRemote.attempts, dw.u.conf.retryLimit)
        alert(copadoLabels.OOPS_SOMETHING_WENT_WRONG_GETTING_ORG_REMOTE_DATA);
        return false;
    }
};

dw.u.getRemote = function(url, cb, postData, avoidRetry, onError, cbOnOk) {
    if(Copado_Licenses.hasMultiLicense && !(Copado_Licenses.hasCopado ||Copado_Licenses.hasCCM ||Copado_Licenses.hasCST || Copado_Licenses.hasCCH) ) {
        var errorMsgs = 'Your current license does not allow performing this action.';
        alert(errorMsgs);
        return;
    }

    dw.u.getRemote.attempts++;
    sforce.connection.remoteFunction({
        url: url,
        requestHeaders: {
            "Content-Type": "text/json",
            "userId": _temp_conf.userId,
            "orgId": _temp_conf.orgId,
            "sessionId": _temp_conf.sessionId,
            "token2": _temp_conf.token2
        },
        method: postData ? 'POST' : "GET",
        requestData: postData ? postData : {},
        onSuccess: function(res) {
            //check response
            try {
                !res && console.log('No response');
                var obj = $copado.parseJSON(res.replace(/(\r\n|\n|\r)/gm, ' '));
                console.log('obj utils ===> ',obj);
                if(obj && typeof obj === 'object' && obj.length>0){
                    obj = preventXSSonJQXGrid(obj);
                }
                console.log('object:::',obj);


                //FIXME: understand why parse is giving an string
                if (typeof obj === 'string') {
                    obj = $copado.parseJSON(obj.replace(/(\r\n|\n|\r)/gm, ' '));
                }

                if (obj.ok && !avoidRetry) {
                    console.log('calling api in two secs...');
                    setTimeout(function() {
                        dw.u.retry(url, cb, postData, avoidRetry, onError);
                    }, 2000);
                    if(cbOnOk){
                        cb && cb(obj);
                    }
                    return;
                }

                if (obj.error) {
                    console.error('Remote Error: ', obj.error);
                    avoidRetry = true;
                    alert(obj.error);
                    throw obj.error;
                }
                console.log('obj.messages utils ===> ',obj.messages);
                if (obj.messages && obj.messages.length > 0) {
                    var errorMsgs = obj.messages.join('\n');
                    alert(errorMsgs);
                    console.error('Error Messages: ', errorMsgs);
                    throw errorMsgs;
                }
                console.log('cb in utilss....',cb);
                cb && cb(obj);

            } catch (e) {
                console.log('dw.u.getRemote() remote error', e);
                if (avoidRetry) {
                    var loadingPanels =  $copado('#loading,#screenLocker');
                    if(loadingPanels.length){
                        loadingPanels.hide();
                    }
                    var gridCheck =  $copado('#jqxgrid');
                    if(gridCheck.length){
                        gridCheck.html(e);
                    }
                }

                if (onError) {
                    onError(res);
                    return;
                }

                if(avoidRetry) {
                    // there was no error handler, and there is no retry. Notify the customer
                    var errMsg = ''+res;
                    try {
                        errMsg = JSON.stringify(e);
                    } catch(e1) {
                        console.error('Couldnt parse error json'+e1);
                    }
                    alert('There was an exception trying to contact Copado API: '+errMsg);
                }else{
                    setTimeout(function() {
                        dw.u.retry(url, cb, postData, avoidRetry, onError);
                    }, 2000);
                }
            }
        },
        onFailure: function(response) {
            console.log('dw.u.getRemote() onFailure', onError, response);
            if (onError) {
                onError(response);
                return;
            }
            if(avoidRetry) {
                // there was no error handler, and there is no retry. Notify the customer
                var errMsg = ''+response;
                if(!errMsg)
                alert('There was an error trying to contact Copado API: '+errMsg);
            }else{
                setTimeout(function() {
                    dw.u.retry(url, cb, postData, avoidRetry, onError);
                }, 2000);
            }
        },
        timeout: 250000
    });

};
dw.u.getRemote.attempts = 0;

dw.u.deleteAttach = function(parentId, name) {
    console.info('deleting attachments from '+parentId+'...');
    var result = sforce.connection.query("Select Id From Attachment where Name='" + name + "' and parentId = '" + parentId + "'");
    var rv = {};
    if(result.size > 0){
        try{
            var records = result.getArray("records");
            var idsForDeletion = [];
            for(var i=0; i<records.length; i++){
                idsForDeletion.push(records[i].Id);
            }
            var delRes = sforce.connection.deleteIds(idsForDeletion);

            for(var i = 0; i<delRes.length; i++){

                if(delRes[i].success == "false"){
                    throw delRes[i].errors.message;
                    break;
                }
            }
            rv.success = true;
            rv.id = parentId;
            return rv;
        }catch(e){
            rv.success = false;
            rv.id = parentId;
            rv.message = 'Exception while deleting metadata attachment : '+e;
            console.warn('Exception while deleting metadata attachment : '+e);
            return rv;
        }
    }else{
        rv.success = false;
        rv.id = parentId;
        rv.message = 'No attachment found to delete';
        console.warn('no attachment found');
        return rv;
    }

}

function htmlEntities(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

dw.u.upsertFile = function(parentId, filename, data) {
    var cv = new sforce.SObject("ContentVersion");
    cv.Title=filename;
    cv.PathOnClient= filename+'.json';
    cv.VersionData= Base64.encode(data);

    var existingFile = dw.u.getFile(parentId, filename);
    if (existingFile && existingFile[0]) {
        //cv.ContentDocumentId = getContentDocuments(parentId)[0].ContentDocumentId;
        cv.ContentDocumentId = existingFile[0].ContentDocumentId;
    } else {
        cv.FirstPublishLocationId = parentId;
    }
    sforce.connection.create([cv]);
}

dw.u.getFile = function(parentId, fileName) {
    var documents = getContentDocuments(parentId);
    if(documents.length == 0) {
        return null;
    }
    var documentIds = new Set();
    for(var i = 0; i < documents.length; i++) {
        documentIds.add(documents[i].ContentDocumentId);
    }
    var versions = getContentVersion([...documentIds].join("','"), fileName);
    return versions;
};

dw.u.getFileById = function(Id) {
    var versions = getContentVersionById(Id);
    return versions;
};

dw.u.removeDiacritics = function(str) {
    var defaultDiacriticsRemovalMap = [
        { 'base': 'A', 'letters': /[\u0041\u24B6\uFF21\u00C0\u00C1\u00C2\u1EA6\u1EA4\u1EAA\u1EA8\u00C3\u0100\u0102\u1EB0\u1EAE\u1EB4\u1EB2\u0226\u01E0\u00C4\u01DE\u1EA2\u00C5\u01FA\u01CD\u0200\u0202\u1EA0\u1EAC\u1EB6\u1E00\u0104\u023A\u2C6F]/g },
        { 'base': 'AA', 'letters': /[\uA732]/g },
        { 'base': 'AE', 'letters': /[\u00C6\u01FC\u01E2]/g },
        { 'base': 'AO', 'letters': /[\uA734]/g },
        { 'base': 'AU', 'letters': /[\uA736]/g },
        { 'base': 'AV', 'letters': /[\uA738\uA73A]/g },
        { 'base': 'AY', 'letters': /[\uA73C]/g },
        { 'base': 'B', 'letters': /[\u0042\u24B7\uFF22\u1E02\u1E04\u1E06\u0243\u0182\u0181]/g },
        { 'base': 'C', 'letters': /[\u0043\u24B8\uFF23\u0106\u0108\u010A\u010C\u00C7\u1E08\u0187\u023B\uA73E]/g },
        { 'base': 'D', 'letters': /[\u0044\u24B9\uFF24\u1E0A\u010E\u1E0C\u1E10\u1E12\u1E0E\u0110\u018B\u018A\u0189\uA779]/g },
        { 'base': 'DZ', 'letters': /[\u01F1\u01C4]/g },
        { 'base': 'Dz', 'letters': /[\u01F2\u01C5]/g },
        { 'base': 'E', 'letters': /[\u0045\u24BA\uFF25\u00C8\u00C9\u00CA\u1EC0\u1EBE\u1EC4\u1EC2\u1EBC\u0112\u1E14\u1E16\u0114\u0116\u00CB\u1EBA\u011A\u0204\u0206\u1EB8\u1EC6\u0228\u1E1C\u0118\u1E18\u1E1A\u0190\u018E]/g },
        { 'base': 'F', 'letters': /[\u0046\u24BB\uFF26\u1E1E\u0191\uA77B]/g },
        { 'base': 'G', 'letters': /[\u0047\u24BC\uFF27\u01F4\u011C\u1E20\u011E\u0120\u01E6\u0122\u01E4\u0193\uA7A0\uA77D\uA77E]/g },
        { 'base': 'H', 'letters': /[\u0048\u24BD\uFF28\u0124\u1E22\u1E26\u021E\u1E24\u1E28\u1E2A\u0126\u2C67\u2C75\uA78D]/g },
        { 'base': 'I', 'letters': /[\u0049\u24BE\uFF29\u00CC\u00CD\u00CE\u0128\u012A\u012C\u0130\u00CF\u1E2E\u1EC8\u01CF\u0208\u020A\u1ECA\u012E\u1E2C\u0197]/g },
        { 'base': 'J', 'letters': /[\u004A\u24BF\uFF2A\u0134\u0248]/g },
        { 'base': 'K', 'letters': /[\u004B\u24C0\uFF2B\u1E30\u01E8\u1E32\u0136\u1E34\u0198\u2C69\uA740\uA742\uA744\uA7A2]/g },
        { 'base': 'L', 'letters': /[\u004C\u24C1\uFF2C\u013F\u0139\u013D\u1E36\u1E38\u013B\u1E3C\u1E3A\u0141\u023D\u2C62\u2C60\uA748\uA746\uA780]/g },
        { 'base': 'LJ', 'letters': /[\u01C7]/g },
        { 'base': 'Lj', 'letters': /[\u01C8]/g },
        { 'base': 'M', 'letters': /[\u004D\u24C2\uFF2D\u1E3E\u1E40\u1E42\u2C6E\u019C]/g },
        { 'base': 'N', 'letters': /[\u004E\u24C3\uFF2E\u01F8\u0143\u00D1\u1E44\u0147\u1E46\u0145\u1E4A\u1E48\u0220\u019D\uA790\uA7A4]/g },
        { 'base': 'NJ', 'letters': /[\u01CA]/g },
        { 'base': 'Nj', 'letters': /[\u01CB]/g },
        { 'base': 'O', 'letters': /[\u004F\u24C4\uFF2F\u00D2\u00D3\u00D4\u1ED2\u1ED0\u1ED6\u1ED4\u00D5\u1E4C\u022C\u1E4E\u014C\u1E50\u1E52\u014E\u022E\u0230\u00D6\u022A\u1ECE\u0150\u01D1\u020C\u020E\u01A0\u1EDC\u1EDA\u1EE0\u1EDE\u1EE2\u1ECC\u1ED8\u01EA\u01EC\u00D8\u01FE\u0186\u019F\uA74A\uA74C]/g },
        { 'base': 'OI', 'letters': /[\u01A2]/g },
        { 'base': 'OO', 'letters': /[\uA74E]/g },
        { 'base': 'OU', 'letters': /[\u0222]/g },
        { 'base': 'P', 'letters': /[\u0050\u24C5\uFF30\u1E54\u1E56\u01A4\u2C63\uA750\uA752\uA754]/g },
        { 'base': 'Q', 'letters': /[\u0051\u24C6\uFF31\uA756\uA758\u024A]/g },
        { 'base': 'R', 'letters': /[\u0052\u24C7\uFF32\u0154\u1E58\u0158\u0210\u0212\u1E5A\u1E5C\u0156\u1E5E\u024C\u2C64\uA75A\uA7A6\uA782]/g },
        { 'base': 'S', 'letters': /[\u0053\u24C8\uFF33\u1E9E\u015A\u1E64\u015C\u1E60\u0160\u1E66\u1E62\u1E68\u0218\u015E\u2C7E\uA7A8\uA784]/g },
        { 'base': 'T', 'letters': /[\u0054\u24C9\uFF34\u1E6A\u0164\u1E6C\u021A\u0162\u1E70\u1E6E\u0166\u01AC\u01AE\u023E\uA786]/g },
        { 'base': 'TZ', 'letters': /[\uA728]/g },
        { 'base': 'U', 'letters': /[\u0055\u24CA\uFF35\u00D9\u00DA\u00DB\u0168\u1E78\u016A\u1E7A\u016C\u00DC\u01DB\u01D7\u01D5\u01D9\u1EE6\u016E\u0170\u01D3\u0214\u0216\u01AF\u1EEA\u1EE8\u1EEE\u1EEC\u1EF0\u1EE4\u1E72\u0172\u1E76\u1E74\u0244]/g },
        { 'base': 'V', 'letters': /[\u0056\u24CB\uFF36\u1E7C\u1E7E\u01B2\uA75E\u0245]/g },
        { 'base': 'VY', 'letters': /[\uA760]/g },
        { 'base': 'W', 'letters': /[\u0057\u24CC\uFF37\u1E80\u1E82\u0174\u1E86\u1E84\u1E88\u2C72]/g },
        { 'base': 'X', 'letters': /[\u0058\u24CD\uFF38\u1E8A\u1E8C]/g },
        { 'base': 'Y', 'letters': /[\u0059\u24CE\uFF39\u1EF2\u00DD\u0176\u1EF8\u0232\u1E8E\u0178\u1EF6\u1EF4\u01B3\u024E\u1EFE]/g },
        { 'base': 'Z', 'letters': /[\u005A\u24CF\uFF3A\u0179\u1E90\u017B\u017D\u1E92\u1E94\u01B5\u0224\u2C7F\u2C6B\uA762]/g },
        { 'base': 'a', 'letters': /[\u0061\u24D0\uFF41\u1E9A\u00E0\u00E1\u00E2\u1EA7\u1EA5\u1EAB\u1EA9\u00E3\u0101\u0103\u1EB1\u1EAF\u1EB5\u1EB3\u0227\u01E1\u00E4\u01DF\u1EA3\u00E5\u01FB\u01CE\u0201\u0203\u1EA1\u1EAD\u1EB7\u1E01\u0105\u2C65\u0250]/g },
        { 'base': 'aa', 'letters': /[\uA733]/g },
        { 'base': 'ae', 'letters': /[\u00E6\u01FD\u01E3]/g },
        { 'base': 'ao', 'letters': /[\uA735]/g },
        { 'base': 'au', 'letters': /[\uA737]/g },
        { 'base': 'av', 'letters': /[\uA739\uA73B]/g },
        { 'base': 'ay', 'letters': /[\uA73D]/g },
        { 'base': 'b', 'letters': /[\u0062\u24D1\uFF42\u1E03\u1E05\u1E07\u0180\u0183\u0253]/g },
        { 'base': 'c', 'letters': /[\u0063\u24D2\uFF43\u0107\u0109\u010B\u010D\u00E7\u1E09\u0188\u023C\uA73F\u2184]/g },
        { 'base': 'd', 'letters': /[\u0064\u24D3\uFF44\u1E0B\u010F\u1E0D\u1E11\u1E13\u1E0F\u0111\u018C\u0256\u0257\uA77A]/g },
        { 'base': 'dz', 'letters': /[\u01F3\u01C6]/g },
        { 'base': 'e', 'letters': /[\u0065\u24D4\uFF45\u00E8\u00E9\u00EA\u1EC1\u1EBF\u1EC5\u1EC3\u1EBD\u0113\u1E15\u1E17\u0115\u0117\u00EB\u1EBB\u011B\u0205\u0207\u1EB9\u1EC7\u0229\u1E1D\u0119\u1E19\u1E1B\u0247\u025B\u01DD]/g },
        { 'base': 'f', 'letters': /[\u0066\u24D5\uFF46\u1E1F\u0192\uA77C]/g },
        { 'base': 'g', 'letters': /[\u0067\u24D6\uFF47\u01F5\u011D\u1E21\u011F\u0121\u01E7\u0123\u01E5\u0260\uA7A1\u1D79\uA77F]/g },
        { 'base': 'h', 'letters': /[\u0068\u24D7\uFF48\u0125\u1E23\u1E27\u021F\u1E25\u1E29\u1E2B\u1E96\u0127\u2C68\u2C76\u0265]/g },
        { 'base': 'hv', 'letters': /[\u0195]/g },
        { 'base': 'i', 'letters': /[\u0069\u24D8\uFF49\u00EC\u00ED\u00EE\u0129\u012B\u012D\u00EF\u1E2F\u1EC9\u01D0\u0209\u020B\u1ECB\u012F\u1E2D\u0268\u0131]/g },
        { 'base': 'j', 'letters': /[\u006A\u24D9\uFF4A\u0135\u01F0\u0249]/g },
        { 'base': 'k', 'letters': /[\u006B\u24DA\uFF4B\u1E31\u01E9\u1E33\u0137\u1E35\u0199\u2C6A\uA741\uA743\uA745\uA7A3]/g },
        { 'base': 'l', 'letters': /[\u006C\u24DB\uFF4C\u0140\u013A\u013E\u1E37\u1E39\u013C\u1E3D\u1E3B\u017F\u0142\u019A\u026B\u2C61\uA749\uA781\uA747]/g },
        { 'base': 'lj', 'letters': /[\u01C9]/g },
        { 'base': 'm', 'letters': /[\u006D\u24DC\uFF4D\u1E3F\u1E41\u1E43\u0271\u026F]/g },
        { 'base': 'n', 'letters': /[\u006E\u24DD\uFF4E\u01F9\u0144\u00F1\u1E45\u0148\u1E47\u0146\u1E4B\u1E49\u019E\u0272\u0149\uA791\uA7A5]/g },
        { 'base': 'nj', 'letters': /[\u01CC]/g },
        { 'base': 'o', 'letters': /[\u006F\u24DE\uFF4F\u00F2\u00F3\u00F4\u1ED3\u1ED1\u1ED7\u1ED5\u00F5\u1E4D\u022D\u1E4F\u014D\u1E51\u1E53\u014F\u022F\u0231\u00F6\u022B\u1ECF\u0151\u01D2\u020D\u020F\u01A1\u1EDD\u1EDB\u1EE1\u1EDF\u1EE3\u1ECD\u1ED9\u01EB\u01ED\u00F8\u01FF\u0254\uA74B\uA74D\u0275]/g },
        { 'base': 'oi', 'letters': /[\u01A3]/g },
        { 'base': 'ou', 'letters': /[\u0223]/g },
        { 'base': 'oo', 'letters': /[\uA74F]/g },
        { 'base': 'p', 'letters': /[\u0070\u24DF\uFF50\u1E55\u1E57\u01A5\u1D7D\uA751\uA753\uA755]/g },
        { 'base': 'q', 'letters': /[\u0071\u24E0\uFF51\u024B\uA757\uA759]/g },
        { 'base': 'r', 'letters': /[\u0072\u24E1\uFF52\u0155\u1E59\u0159\u0211\u0213\u1E5B\u1E5D\u0157\u1E5F\u024D\u027D\uA75B\uA7A7\uA783]/g },
        { 'base': 's', 'letters': /[\u0073\u24E2\uFF53\u00DF\u015B\u1E65\u015D\u1E61\u0161\u1E67\u1E63\u1E69\u0219\u015F\u023F\uA7A9\uA785\u1E9B]/g },
        { 'base': 't', 'letters': /[\u0074\u24E3\uFF54\u1E6B\u1E97\u0165\u1E6D\u021B\u0163\u1E71\u1E6F\u0167\u01AD\u0288\u2C66\uA787]/g },
        { 'base': 'tz', 'letters': /[\uA729]/g },
        { 'base': 'u', 'letters': /[\u0075\u24E4\uFF55\u00F9\u00FA\u00FB\u0169\u1E79\u016B\u1E7B\u016D\u00FC\u01DC\u01D8\u01D6\u01DA\u1EE7\u016F\u0171\u01D4\u0215\u0217\u01B0\u1EEB\u1EE9\u1EEF\u1EED\u1EF1\u1EE5\u1E73\u0173\u1E77\u1E75\u0289]/g },
        { 'base': 'v', 'letters': /[\u0076\u24E5\uFF56\u1E7D\u1E7F\u028B\uA75F\u028C]/g },
        { 'base': 'vy', 'letters': /[\uA761]/g },
        { 'base': 'w', 'letters': /[\u0077\u24E6\uFF57\u1E81\u1E83\u0175\u1E87\u1E85\u1E98\u1E89\u2C73]/g },
        { 'base': 'x', 'letters': /[\u0078\u24E7\uFF58\u1E8B\u1E8D]/g },
        { 'base': 'y', 'letters': /[\u0079\u24E8\uFF59\u1EF3\u00FD\u0177\u1EF9\u0233\u1E8F\u00FF\u1EF7\u1E99\u1EF5\u01B4\u024F\u1EFF]/g },
        { 'base': 'z', 'letters': /[\u007A\u24E9\uFF5A\u017A\u1E91\u017C\u017E\u1E93\u1E95\u01B6\u0225\u0240\u2C6C\uA763]/g }
    ];

    defaultDiacriticsRemovalMap.forEach((mapItem) => {
        str = str.replace(mapItem.letters, mapItem.base);
    });

    return str;
};

function getContentDocuments(parentId) {
    var query = "SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = '" + htmlEntities(parentId).replace(/'/g, "\\'") + "'";
    var documents = sforce.connection.query(query);
    return documents.getArray("records");
}

function getContentVersion(documentIds, fileName) {
    var query = "SELECT VersionData,ContentDocumentId FROM ContentVersion WHERE PathOnClient = '" + htmlEntities(fileName).replace(/'/g, "\\'") + "' AND ContentDocumentId IN ('" + documentIds + "') AND IsLatest = true ORDER BY LastModifiedDate DESC LIMIT 1";
    var versions = sforce.connection.query(query);
    return versions.getArray("records");
}

function getContentVersionById(Id) {
    var query = "SELECT VersionData FROM ContentVersion WHERE Id = '" + Id + "'";
    var versions = sforce.connection.query(query);
    return versions.getArray("records");
}

dw.u.getDecodedFileContent = function(parentId, name) {
    var file = dw.u.getFile(parentId, name);
    if (!file || !file.length) {
        return null;
    }
    var content = Base64.decode(file[0].VersionData);
    //below replaces opening and closing tags based on xss concerns
    while(content.indexOf('<') > -1 || content.indexOf('>') > -1) {
        content = content.replace('<','').replace('>','');
    }
    return content;
};

dw.u.getHtmlDecodedString = function(input) {
    var e = document.createElement('textarea');
    e.innerHTML = input;
    // handle case of empty input
    return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
};

dw.u.getFileContent = function(parentId, name) {
    var file = dw.u.getFile(parentId, name);
    if (!file || !file.length) {
        return null;
    }
    var content = file[0].VersionData;
    //below replaces opening and closing tags based on xss concerns
    while(content.indexOf('<') > -1 || content.indexOf('>') > -1) {
        content = content.replace('<','').replace('>','');
    }
    return content;
};

dw.u.getAttach = function(parentId, name) {
    var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Name='" + name + "' and parentId = '" + parentId + "' order by LastModifiedDate DESC limit 1",
        result = sforce.connection.query(q),
        records = result.getArray("records");
    return records;
};

dw.u.getAttachById = function(attachmentId) {
    var q = "Select Id, Body, LastModifiedDate, Name, ParentId From Attachment where Id='" + attachmentId + "'",
        result = sforce.connection.query(q),
        records = result.getArray("records");
    return records;
};

dw.u.getDecodedAttach = function(parentId, name) {
    var a = dw.u.getAttach(parentId, name);
    if (!a.length) return null;
    a.Body = Base64.decode(a[0].Body);
    //below replaces opening and closing tags based on xss concerns
    while(a.Body.indexOf('<') > -1 || a.Body.indexOf('>') > -1){
             a.Body = a.Body.replace('<','').replace('>','');
         }
    return a;
};


//upsert
dw.u.upsertAttach = function(parentId, name, body, alreadyCheck, newName) {


    var Id = false;
    if (!alreadyCheck) {
        var attach = dw.u.getAttach(parentId, name);
        if (attach.length) {
            Id = attach[0].Id;
        }

    }
    var att = new sforce.SObject("Attachment");
    att.parentId = parentId;
    if(newName) {
        att.name = newName;
    } else {
        att.name = name;
    }

    att.body = Base64.encode(body);

    if (Id) {
        att.Id = Id;
    }

    var result = sforce.connection.upsert("Id", [att]);


};
//added this function to be able to prevent Stored XSS Vulnerability based on Salesforce security report - UCU
preventXSSonJQXGrid = function(objectArray){
    //below return all fields of the current object to check on the loop
    if(typeof objectArray == undefined || objectArray.length === 0) return; // added this condition, because it was throwing error if the objectArray was null or undefined

    var fields = Object.keys(objectArray[0]);
    for(var i=0;i<objectArray.length;i++){
            for(var c=0;c<fields.length;c++){
                var currentValue = objectArray[i][fields[c]];
                if(currentValue && typeof currentValue === 'string'){
                    while(currentValue.indexOf('<') > -1 || currentValue.indexOf('>') > -1){
                        currentValue = currentValue.replace('<','').replace('>','');
                    }
                    objectArray[i][fields[c]] = currentValue;
                }
            }
        }

    return objectArray;
};

//this function try to recover the data from cached attach
//if is not cached it get from remote source and save it in attach
dw.u.getCachedRemote = function(opt) {
    /*
    opt sample
    {
        url: remoteUrl,
        parentId: ':)',
        name: 'Metadata' ,
        postData:data
        success:function(){},
        error:function(){},

    };*/

    var attach = dw.u.getAttach(opt.parentId, opt.name);
    console.log('attach=1==> ',attach);
    if (opt.force || attach.length != 1) {

        //get remote and save
        dw.u.getRemote.attempts = 0;

        dw.u.getRemote(opt.url, function(res) {
                console.log('getRemote ok', res);

                //save as attach
                dw.u.upsertAttach(opt.parentId, opt.name, JSON.stringify(res), !opt.force);
                var attachLocal = dw.u.getAttach(opt.parentId, opt.name);
                console.log('attachLocal===> ',attachLocal);
                //format date
                var date = Date.fromISOString(attachLocal[0].LastModifiedDate);
                //added by UCU to be able update Refresh Cache date-time for the new attachments on Grid
                opt.success(preventXSSonJQXGrid(res),  date.toLocaleString());
            },
            opt.postData ? opt.postData : null
        );

    } else {
         try{
            //decode the attach body
            console.log('attach==2=> ',attach);
            var res = decodeURIComponent(escape(window.atob( attach[0].Body )));
            

            //format date
            var date = Date.fromISOString(attach[0].LastModifiedDate);
            //parse json
            opt.success(preventXSSonJQXGrid($copado.parseJSON(res)), date.toLocaleString());

        }catch(e){
            //console.log(Base64.decode(attach[0].Body));
            console.error('Exception on saved data:',e);
            opt.error();
            throw e;
        }
    }

};

dw.u.getSavedStepData = function(type, isNotJSON) {
    if (!rock.stepId) return false;
    return dw.u.getSavedData(rock.stepId, type, isNotJSON);
};


dw.u.getSavedData = function(id, type, isNotJSON, isRollback) {
    if (isRollback) {
        var file = dw.u.getFileContent(id, type);
        return file;
    } else {
        var attach = dw.u.getAttach(id, type);
        if (attach.length > 0) {
            try {
                // Save the last modified date of this attachment in case the caller needs it ( scratch org.resource needs it )
                dw.u.getSavedData_AttachmentLastModifiedDate = attach[0].LastModifiedDate;
                //decode the attach body
                var res = Base64.decode(attach[0].Body);
                //parse json
                return isNotJSON ? res : $copado.parseJSON(res);

            } catch (e) {
                console.log('Exception on saved data:', e);
            }
        }
    }
    return false;
};

// JS Upload files
var coUploadAttachment = {
     maxStringSize: 6000000,    //Maximum String size is 6,000,000 characters
     maxFileSize : 4350000,    //After Base64 Encoding, this is the max file size
     chunkSize : 950000,       //Maximum Javascript Remoting message size is 1,000,000 characters
     attachment : {},
     attachmentName : '',
     attachmentBody : '',
     fileSize : 0,
     positionIndex : 0,
     doneUploading : false,
     parentId : '', // If doDML is enabled this should not be empty
     doDML : false,
    //Method to prepare a file to be attached to the Account bound to the page by the standardController
    uploadFile : function(inputName, callback){

        var that = this;
        console.log(that);
        if(!document.getElementById(inputName)) {
            alert("You must choose a file before trying to upload it");
            return; // TODO: add error message
        }
        var file = document.getElementById(inputName).files[0];
              if(file) {
                 console.log('coUploadAttachment:::uploadFile',file);
                 if(file.size <= that.maxFileSize) {
                    if(that.attachmentName.length <= 0)that.attachmentName = file.name;
                    var fileReader = new FileReader();
                    fileReader.onloadend = function(e) {
                        that.attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                        that.positionIndex=0;
                        that.fileSize = that.attachment.length;
                        console.log("coUploadAttachment:::uploadFile Total Attachment Length: " + that.fileSize);
                        that.doneUploading = false;
                        if(that.fileSize < that.maxStringSize) {
                          that.uploadAttachment(null,that.doDML,callback); // null param is for fileId this may change
                        } else {
                          alert("Base 64 Encoded file is too large.  Maximum size is " + that.maxStringSize + " your file is " + that.fileSize + ".");
                        }
                    }
                    fileReader.onerror = function(e) {
                        alert("There was an error reading the file.  Please try again.");
                    }
                    fileReader.onabort = function(e) {
                        alert("There was an error reading the file.  Please try again.");
                    }
                    fileReader.readAsBinaryString(file);  //Read the body of the file

              }else {
                alert("File must be under 4.3 MB in size.  Your file is too large.  Please try again.");
              }
        }else {
          alert("You must choose a file before trying to upload it");
        }
    },
    //Method to send a file to be attached to the Account bound to the page by the standardController
    //Sends parameters: Account Id, Attachment (body), Attachment Name, and the Id of the Attachment if it exists to the controller
    uploadAttachment : function(fileId, doDML,callback) {
        var that = this;
        if(that.fileSize <= that.positionIndex + that.chunkSize) {
          that.attachmentBody = that.attachment.substring(that.positionIndex);
          console.log('attachmentBody = that.attachment.substring(that.positionIndex) ===>',Base64.decode(that.attachment.substring(that.positionIndex)));
          that.doneUploading = true;
        } else {
          that.attachmentBody = that.attachment.substring(that.positionIndex, that.positionIndex + that.chunkSize);
        }
        console.log("coUploadAttachment:::uploadAttachment Uploading " + that.attachmentBody.length + " chars of " + that.fileSize);
        //TODO : Replace with dynamic one without standard controller

        if(doDML && doDML === true) {
        if(!JsRemotingController) return; // TODO: add error message
            JsRemotingController.doUploadAttachment(
                that.parentId, that.attachmentBody, that.attachmentName, fileId,
                function(result, event) {
                    console.log(result);
                    if(event.type === 'exception') {
                        console.log("exception");
                        console.log(event);
                    } else if(event.status) {
                        if(result.substring(0,3) == '00P') {
                            if(that.doneUploading == true) {
                                console.log('coUploadAttachment:::uploadAttachment UPLOAD COMPLETED');
                            } else {
                                that.positionIndex += that.chunkSize;
                                uploadAttachment(result);
                            }
                        }
                    } else {
                        console.log(event.message);
                    }
                },
                {buffer: true, escape: true, timeout: 120000}
            );
        }
        if(callback) callback();
    }
};


function reformatMilliseconds(milliseconds) {

    var d = parseInt(milliseconds) / 1000;
    x = d
    seconds = x % 60
    x /= 60
    minutes = x % 60
    x /= 60
    hours = x % 24
    x /= 24
    days = x

    var output = (Math.floor(hours) > 0) ? Math.floor(hours) + ' ' + copadoLabels.HOURS + ' ' : '';
    output += (Math.floor(minutes) > 0) ? Math.floor(minutes) + ' ' + copadoLabels.MINUTES + ' ' : '';
    output += (Math.floor(seconds) > 0) ? Math.floor(seconds) + ' ' + copadoLabels.SECONDS + ' ' : '';
    output += (milliseconds > 0 && milliseconds < 1000) ? milliseconds + ' ' + copadoLabels.MILLISECONDS : '';
    return output;
};

/*************************************************
Generic Grid Helper
*************************************************/
var coGridHelper = {
    /**
     * Merge selected items from 2 sources. using the "s" attribute
     * @param  {[type]} metaOrgData [description]
     * @param  {[type]} dataStep    [description]
     * @return {[type]}             [description]
     */
    mergeSavedData: function(metaOrgData, dataStep) {

        var len = dataStep.length;

        while (len--) {
            if (typeof dataStep[len] !== 'object') {
                delete dataStep[len];
            } else {
                dataStep[len].s = true;
            }
        }

        var len2 = dataStep.length;
        for (var i = 0; i < len2; i++) {
            var el = dataStep[i];

            var index = coGridHelper.getIndexByNT(metaOrgData, el.n, (el.t || el.ns));
            if (index > -1) {
                metaOrgData[index].s = true;
            } else {
                if (typeof(window._errNotFoundShown) == 'undefined') {
                    window._errNotFoundShown = true;
                    alert(copadoLabels.missing_element_msg + (el.t || el.ns) + ' - ' + el.n);
                }
            }
        }

        return metaOrgData;
    },

    /**
     * get selected items from the datasource
     * @return {[type]} [description]
     */
    getSelectedObj: function(isRollback) {
        // NR: when there is no coGridHelper (because it is not a partial selection), we return empty array
        if (!coGridHelper.datasource)
            return [];
        var data = coGridHelper.datasource.localdata,
            len = data.length;

        coGridHelper._selectedNames = [];

        while (len--) {
            var o = {
                n: data[len].n,
                s: true,
                d: data[len].d,
                b: data[len].b,
                cd: data[len].cd,
                cb: data[len].cb,
                ai: data[len].ai,
                vk: data[len].vk,
                a: data[len].a,
                f: data[len].f
            };

            if (typeof data[len].r !== 'undefined') {
                o.r = data[len].r;
            } else {
                //MY: When retrieve only is undefined set it as false by default. Backend depends on the parameter so it
                //should never be undefined in the attachment that we create for backend to use
                o.r = false;
            }

            if (typeof data[len].ns != 'undefined') {
                o.ns = data[len].ns;
            } else {
                o.t = data[len].t;
            }

            data[len].s && coGridHelper._selectedNames.push(o);
        }
        return coGridHelper._selectedNames;
    },

    //selected "Names"
    _selectedNames: [],

    /**
     * helper to find index items by name, namespace and type
     * @param  {[type]} arr [description]
     * @param  {[type]} n   [description]
     * @param  {[type]} t   [description]
     * @return {[type]}     [description]
     */
    getIndexByNT: function(arr, n, t) {

        var initialIndex = 0; // todo improve index change >> this.initialIndex || 0,
        len = arr.length;

        for (initialIndex; initialIndex < len; initialIndex++) {
            var el = arr[initialIndex];
            try {
                if (el.n === n && (el.t === t || el.ns === t)) {
                    this.initialIndex = initialIndex;
                    return initialIndex;
                }
            } catch (e) {
                console.error(e);
                return -1;
            }
        }
        return -1;
    },

    /**
     * Save in attachment the selected items of the grid
     * @param  {[type]} id                   parentId
     * @param  {[type]} type                 Attachment Name
     * @param  {[type]} additionalValidation function for additional validations
     * @param  {[type]} allowEmpty           skip length validation
     * @param  {[type]} callcack
     * @return {[type]}                      false
     */
    saveSelected: function(id, type, additionalValidation, allowEmpty, callback, sel, isRollback) {
        console.debug('... Saving Attachment');
        var me = coGridHelper;
        //validations
        //check global selected items
        me.getSelectedObj();
        if (!allowEmpty && !me._selectedNames.length) {
            //check if copadoApp showmessage is active
            if (copadoApp.showMessage) {
                copadoApp.showMessage('ERROR', copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY, 0);
            } else {
                alert(copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY);
            }
            return false;
        }
        var valid = !additionalValidation ? true : additionalValidation(me._selectedNames);
        valid && me.remoteSaveMeta(id, sel || me._selectedNames, type, callback, isRollback);

        return false;
    },

    /**
     * save an attachment
     * @param  {[type]} id       parentId
     * @param  {[type]} items    data for stringify
     * @param  {[type]} type     attachment name
     * @param  {[type]} callcack function on callback
     * @return {[type]}          void
     */
    // write
    remoteSaveMeta: function(id, items, type, callback, isRollback) {
        if (isRollback) {
            if (type === 'Selected items to rollback') {
                var deletedItems=[];
                var createdUpdatedItems=[];
                items.forEach((item) => {
                    if(item.a === 'create'){
                        deletedItems.push(item);
                    }
                    else{
                        createdUpdatedItems.push(item);
                    }
                });
                if (createdUpdatedItems.length) {
                    dw.u.upsertFile(id, type+'_Git Promotion', JSON.stringify(createdUpdatedItems));
                }

                if (deletedItems.length) {
                    dw.u.upsertFile(id, type+'_Delete Metadata', JSON.stringify(deletedItems));
                }
            }
            else {
                dw.u.upsertFile(id, type, JSON.stringify(items));
            }
        } else {
            dw.u.upsertAttach(id, type, JSON.stringify(items));
        }
        callback && callback();
    }
};

// taken directly from copado-commons/copado-metadata-service/src/main/resources/metadataTypes.json ... update when necessary.
var metadataTypes = {
    "ext:actionLinkGroupTemplate": "ActionLinkGroupTemplate",
    "ext:ai": "AIApplication",
    "ext:aiapplicationconfig": "AIApplicationConfig",
    "ext:animationRule": "AnimationRule",
    "ext:app": "CustomApplication",
    "ext:appMenu": "AppMenu",
    "ext:approvalProcess": "ApprovalProcess",
    "ext:asset": "ContentAsset",
    "ext:assignmentRules": "AssignmentRules",
    "ext:assistantRecommendationType": "AssistantRecommendationType",
    "ext:authprovider": "AuthProvider",
    "ext:autoResponseRules": "AutoResponseRules",
    "ext:blacklistedConsumer": "BlacklistedConsumer",
    "ext:bot": "EinsteinBot",
    "ext:brandingSet": "BrandingSet",
    "ext:cachePartition": "PlatformCachePartition",
    "ext:callCenter": "CallCenter",
    "ext:callCoachingMediaProvider": "CallCoachingMediaProvider",
    "ext:campaignInfluenceModel": "CampaignInfluenceModel",
    "ext:Canvas": "CanvasMetadata",
    "ext:CaseSubjectParticle": "CaseSubjectParticle",
    "ext:channelLayout": "ChannelLayout",
    "ext:ChatterExtension": "ChatterExtension",
    "ext:cleanDataService": "CleanDataService",
    "ext:cls": "ApexClass",
    "ext:community": "Community",
    "ext:communityTemplateDefinition": "CommunityTemplateDefinition",
    "ext:communityThemeDefinition": "CommunityThemeDefinition",
    "ext:component": "ApexComponent",
    "ext:config": "NotificationTypeConfig",
    "ext:connectedApp": "ConnectedApp",
    "ext:corsWhitelistOrigin": "CorsWhitelistOrigin",
    "ext:crt": "Certificate",
    "ext:cspTrustedSite": "CspTrustedSite",
    "ext:customApplicationComponent": "CustomApplicationComponent",
    "ext:customHelpMenuSection": "CustomHelpMenuSection",
    "ext:customPermission": "CustomPermission",
    "ext:dashboard": "Dashboard",
    "ext:datacategorygroup": "DataCategoryGroup",
    "ext:dataSource": "ExternalDataSource",
    "ext:delegateGroup": "DelegateGroup",
    "ext:delivery": "EventDelivery",
    "ext:deployment": "RecordActionDeployment",
    "ext:duplicateRule": "DuplicateRule",
    "ext:email": "EmailTemplate",
    "ext:EmbeddedServiceBranding": "EmbeddedServiceBranding",
    "ext:EmbeddedServiceConfig": "EmbeddedServiceConfig",
    "ext:EmbeddedServiceFlowConfig": "EmbeddedServiceFlowConfig",
    "ext:EmbeddedServiceMenuSettings": "EmbeddedServiceMenuSettings",
    "ext:entitlementProcess": "EntitlementProcess",
    "ext:entitlementTemplate": "EntitlementTemplate",
    "ext:entityImplements": "EntityImplements",
    "ext:escalationRules": "EscalationRules",
    "ext:externalServiceRegistration": "ExternalServiceRegistration",
    "ext:feedFilter": "CustomFeedFilter",
    "ext:flexipage": "FlexiPage",
    "ext:flow": "Flow",
    "ext:flowCategory": "FlowCategory",
    "ext:flowDefinition": "FlowDefinition",
    "ext:geodata": "EclairGeoData",
    "ext:globalValueSet": "GlobalValueSet",
    "ext:globalValueSetTranslation": "GlobalValueSetTranslation",
    "ext:group": "Group",
    "ext:homePageComponent": "HomePageComponent",
    "ext:homePageLayout": "HomePageLayout",
    "ext:iframeWhiteListUrlSettings": "IframeWhiteListUrlSettings",
    "ext:inboundNetworkConnection": "InboundNetworkConnection",
    "ext:indx": "CustomIndex",
    "ext:installedPackage": "InstalledPackage",
    "ext:keywords": "KeywordList",
    "ext:labels": "CustomLabels",
    "ext:layout": "Layout",
    "ext:LeadConvertSetting": "LeadConvertSettings",
    "ext:letter": "Letterhead",
    "ext:lightningBolt": "LightningBolt",
    "ext:lightningExperienceTheme": "LightningExperienceTheme",
    "ext:lightningOnboardingConfig": "LightningOnboardingConfig",
    "ext:liveChatAgentConfig": "LiveChatAgentConfig",
    "ext:liveChatButton": "LiveChatButton",
    "ext:liveChatDeployment": "LiveChatDeployment",
    "ext:liveChatSensitiveDataRule": "LiveChatSensitiveDataRule",
    "ext:managedContentType": "ManagedContentType",
    "ext:managedTopics": "ManagedTopics",
    "ext:matchingRule": "MatchingRules",
    "ext:md": "CustomMetadata",
    "ext:messageChannel": "LightningMessageChannel",
    "ext:milestoneType": "MilestoneType",
    "ext:mlDataDefinition": "MLDataDefinition",
    "ext:mlPrediction": "MLPredictionDefinition",
    "ext:MobileApplicationDetail": "MobileApplicationDetail",
    "ext:mutingpermissionset": "MutingPermissionSet",
    "ext:myDomainDiscoverableLogin": "MyDomainDiscoverableLogin",
    "ext:namedCredential": "NamedCredential",
    "ext:network": "Network",
    "ext:networkBranding": "NetworkBranding",
    "ext:notifications": "ApexEmailNotifications",
    "ext:notiftype": "CustomNotificationType",
    "ext:null": "Document",
    "ext:oauthcustomscope": "OauthCustomScope",
    "ext:object": "CustomObject",
    "ext:objectTranslation": "CustomObjectTranslation",
    "ext:orchestrationContext": "OrchestrationContext",
    "ext:outboundNetworkConnection": "OutboundNetworkConnection",
    "ext:page": "ApexPage",
    "ext:pathAssistant": "PathAssistant",
    "ext:permissionset": "PermissionSet",
    "ext:permissionsetgroup": "PermissionSetGroup",
    "ext:platformEventChannel": "PlatformEventChannel",
    "ext:platformEventChannelMember": "PlatformEventChannelMember",
    "ext:platformEventSubscriberConfig": "PlatformEventSubscriberConfig",
    "ext:portal": "Portal",
    "ext:postTemplate": "PostTemplate",
    "ext:presenceDeclineReason": "PresenceDeclineReason",
    "ext:presenceUserConfig": "PresenceUserConfig",
    "ext:profile": "Profile",
    "ext:profilePasswordPolicy": "ProfilePasswordPolicy",
    "ext:profileSessionSetting": "ProfileSessionSetting",
    "ext:prompt": "Prompt",
    "ext:queue": "Queue",
    "ext:queueRoutingConfig": "QueueRoutingConfig",
    "ext:quickAction": "QuickAction",
    "ext:recommendationStrategy": "RecommendationStrategy",
    "ext:redirectWhitelistUrl": "RedirectWhitelistUrl",
    "ext:remoteSite": "RemoteSiteSetting",
    "ext:report": "Report",
    "ext:reportType": "ReportType",
    "ext:resource": "StaticResource",
    "ext:role": "Role",
    "ext:rule": "ModerationRule",
    "ext:samlssoconfig": "SamlSsoConfig",
    "ext:scf": "Scontrol",
    "ext:serviceChannel": "ServiceChannel",
    "ext:servicePresenceStatus": "ServicePresenceStatus",
    "ext:settings": "Settings",
    "ext:sharingRules": "SharingRules",
    "ext:sharingSet": "SharingSet",
    "ext:site": "SiteDotCom",
    "ext:skill": "Skill",
    "ext:snapshot": "AnalyticSnapshot",
    "ext:standardValueSet": "StandardValueSet",
    "ext:standardValueSetTranslation": "StandardValueSetTranslation",
    "ext:subscription": "EventSubscription",
    "ext:synonymDictionary": "SynonymDictionary",
    "ext:tab": "CustomTab",
    "ext:territory2Model": "Territory2Model",
    "ext:territory2Type": "Territory2Type",
    "ext:testSuite": "ApexTestSuite",
    "ext:topicsForObjects": "TopicsForObjects",
    "ext:transactionSecurityPolicy": "TransactionSecurityPolicy",
    "ext:translation": "Translations",
    "ext:trigger": "ApexTrigger",
    "ext:userCriteria": "UserCriteria",
    "ext:userProvisioningConfig": "UserProvisioningConfig",
    "ext:wapp": "WaveApplication",
    "ext:wdash": "WaveDashboard",
    "ext:wdf": "WaveDataflow",
    "ext:wds": "WaveDataset",
    "ext:weblink": "CustomPageWebLink",
    "ext:wlens": "WaveLens",
    "ext:workflow": "Workflow",
    "ext:workSkillRouting": "WorkSkillRouting",
    "ext:xmd": "WaveXmd",
    "ext:xml": "EmailServicesFunction",
    "type:ActionLinkGroupTemplate": "actionLinkGroupTemplates:actionLinkGroupTemplate",
    "type:AIApplication": "aiApplications:ai",
    "type:AIApplicationConfig": "aiApplicationConfigs:aiapplicationconfig",
    "type:AnalyticSnapshot": "analyticSnapshots:snapshot",
    "type:AnimationRule": "animationRules:animationRule",
    "type:ApexClass": "classes:cls",
    "type:ApexComponent": "components:component",
    "type:ApexEmailNotifications": "apexEmailNotifications:notifications",
    "type:ApexPage": "pages:page",
    "type:ApexTestSuite": "testSuites:testSuite",
    "type:ApexTrigger": "triggers:trigger",
    "type:AppMenu": "appMenus:appMenu",
    "type:ApprovalProcess": "approvalProcesses:approvalProcess",
    "type:AssignmentRules": "assignmentRules:assignmentRules",
    "type:AssistantRecommendationType": "assistantRecommendationTypes:assistantRecommendationType",
    "type:AuraDefinitionBundle": "aura:null",
    "type:AuthProvider": "authproviders:authprovider",
    "type:AutoResponseRules": "autoResponseRules:autoResponseRules",
    "type:BlacklistedConsumer": "blacklistedConsumers:blacklistedConsumer",
    "type:Bot": "bots:bot",
    "type:BrandingSet": "brandingSets:brandingSet",
    "type:CallCenter": "callCenters:callCenter",
    "type:CallCoachingMediaProvider": "callCoachingMediaProviders:callCoachingMediaProvider",
    "type:CampaignInfluenceModel": "campaignInfluenceModels:campaignInfluenceModel",
    "type:CanvasMetadata": "Canvases:Canvas",
    "type:CaseSubjectParticle": "CaseSubjectParticles:CaseSubjectParticle",
    "type:Certificate": "certs:crt",
    "type:ChannelLayout": "channelLayouts:channelLayout",
    "type:ChatterExtension": "ChatterExtensions:ChatterExtension",
    "type:ChatterExtensions": "ChatterExtensions:ChatterExtension",
    "type:CleanDataService": "cleanDataServices:cleanDataService",
    "type:Community": "communities:community",
    "type:CommunityTemplateDefinition": "communityTemplateDefinitions:communityTemplateDefinition",
    "type:CommunityThemeDefinition": "communityThemeDefinitions:communityThemeDefinition",
    "type:ConnectedApp": "connectedApps:connectedApp",
    "type:ContentAsset": "contentassets:asset",
    "type:CorsWhitelistOrigin": "corsWhitelistOrigins:corsWhitelistOrigin",
    "type:CspTrustedSite": "cspTrustedSites:cspTrustedSite",
    "type:CustomApplication": "applications:app",
    "type:CustomApplicationComponent": "customApplicationComponents:customApplicationComponent",
    "type:CustomFeedFilter": "feedFilters:feedFilter",
    "type:CustomHelpMenuSection": "customHelpMenuSections:customHelpMenuSection",
    "type:CustomIndex": "customindex:indx",
    "type:CustomLabels": "labels:labels",
    "type:CustomMetadata": "customMetadata:md",
    "type:CustomNotificationType": "notificationtypes:notiftype",
    "type:CustomObject": "objects:object",
    "type:CustomObjectTranslation": "objectTranslations:objectTranslation",
    "type:CustomPageWebLink": "weblinks:weblink",
    "type:CustomPermission": "customPermissions:customPermission",
    "type:CustomSite": "sites:site",
    "type:CustomTab": "tabs:tab",
    "type:Dashboard": "dashboards:dashboard",
    "type:DataCategoryGroup": "datacategorygroups:datacategorygroup",
    "type:DelegateGroup": "delegateGroups:delegateGroup",
    "type:Document": "documents:null",
    "type:DuplicateRule": "duplicateRules:duplicateRule",
    "type:EclairGeoData": "eclair:geodata",
    "type:EmailServicesFunction": "emailservices:xml",
    "type:EmailTemplate": "email:email",
    "type:EmbeddedServiceBranding": "EmbeddedServiceBranding:EmbeddedServiceBranding",
    "type:EmbeddedServiceConfig": "EmbeddedServiceConfig:EmbeddedServiceConfig",
    "type:EmbeddedServiceFlowConfig": "EmbeddedServiceFlowConfig:EmbeddedServiceFlowConfig",
    "type:EmbeddedServiceMenuSettings": "EmbeddedServiceMenuSettings:EmbeddedServiceMenuSettings",
    "type:EntitlementProcess": "entitlementProcesses:entitlementProcess",
    "type:EntitlementTemplate": "entitlementTemplates:entitlementTemplate",
    "type:EntityImplements": "entityImplements:entityImplements",
    "type:EscalationRules": "escalationRules:escalationRules",
    "type:EventDelivery": "eventDeliveries:delivery",
    "type:EventSubscription": "eventSubscriptions:subscription",
    "type:ExternalDataSource": "dataSources:dataSource",
    "type:ExternalServiceRegistration": "externalServiceRegistrations:externalServiceRegistration",
    "type:FlexiPage": "flexipages:flexipage",
    "type:Flow": "flows:flow",
    "type:FlowCategory": "flowCategories:flowCategory",
    "type:FlowDefinition": "flowDefinitions:flowDefinition",
    "type:GlobalValueSet": "globalValueSets:globalValueSet",
    "type:GlobalValueSetTranslation": "globalValueSetTranslations:globalValueSetTranslation",
    "type:Group": "groups:group",
    "type:HomePageComponent": "homePageComponents:homePageComponent",
    "type:HomePageLayout": "homePageLayouts:homePageLayout",
    "type:IframeWhiteListUrlSettings": "iframeWhiteListUrlSettings:iframeWhiteListUrlSettings",
    "type:InboundNetworkConnection": "inboundNetworkConnections:inboundNetworkConnection",
    "type:InstalledPackage": "installedPackages:installedPackage",
    "type:KeywordList": "moderation:keywords",
    "type:Layout": "layouts:layout",
    "type:LeadConvertSettings": "LeadConvertSettings:LeadConvertSetting",
    "type:Letterhead": "letterhead:letter",
    "type:LightningBolt": "lightningBolts:lightningBolt",
    "type:LightningComponentBundle": "lwc:null",
    "type:LightningExperienceTheme": "lightningExperienceThemes:lightningExperienceTheme",
    "type:LightningMessageChannel": "messageChannels:messageChannel",
    "type:LightningOnboardingConfig": "lightningOnboardingConfigs:lightningOnboardingConfig",
    "type:LiveChatAgentConfig": "liveChatAgentConfigs:liveChatAgentConfig",
    "type:LiveChatButton": "liveChatButtons:liveChatButton",
    "type:LiveChatDeployment": "liveChatDeployments:liveChatDeployment",
    "type:LiveChatSensitiveDataRule": "liveChatSensitiveDataRule:liveChatSensitiveDataRule",
    "type:ManagedContentType": "managedContentTypes:managedContentType",
    "type:ManagedTopics": "managedTopics:managedTopics",
    "type:MatchingRules": "matchingRules:matchingRule",
    "type:MilestoneType": "milestoneTypes:milestoneType",
    "type:MLDataDefinition": "mlDataDefinitions:mlDataDefinition",
    "type:MLPredictionDefinition": "mlPredictions:mlPrediction",
    "type:MobileApplicationDetail": "MobileApplicationDetails:MobileApplicationDetail",
    "type:ModerationRule": "moderation:rule",
    "type:MutingPermissionSet": "mutingpermissionsets:mutingpermissionset",
    "type:MyDomainDiscoverableLogin": "myDomainDiscoverableLogins:myDomainDiscoverableLogin",
    "type:NamedCredential": "namedCredentials:namedCredential",
    "type:NetworkBranding": "networkBranding:networkBranding",
    "type:Network": "networks:network",
    "type:NotificationTypeConfig": "notificationTypeConfig:config",
    "type:OauthCustomScope": "oauthcustomscopes:oauthcustomscope",
    "type:OrchestrationContext": "iot:orchestrationContext",
    "type:OutboundNetworkConnection": "outboundNetworkConnections:outboundNetworkConnection",
    "type:PathAssistant": "pathAssistants:pathAssistant",
    "type:PermissionSet": "permissionsets:permissionset",
    "type:PermissionSetGroup": "permissionsetgroups:permissionsetgroup",
    "type:PlatformCachePartition": "cachePartitions:cachePartition",
    "type:PlatformEventChannel": "platformEventChannels:platformEventChannel",
    "type:PlatformEventChannelMember": "platformEventChannelMembers:platformEventChannelMember",
    "type:PlatformEventSubscriberConfig": "PlatformEventSubscriberConfigs:platformEventSubscriberConfig",
    "type:Portal": "portals:portal",
    "type:PostTemplate": "postTemplates:postTemplate",
    "type:PresenceDeclineReason": "presenceDeclineReasons:presenceDeclineReason",
    "type:PresenceUserConfig": "presenceUserConfigs:presenceUserConfig",
    "type:Profile": "profiles:profile",
    "type:ProfilePasswordPolicy": "profilePasswordPolicies:profilePasswordPolicy",
    "type:ProfileSessionSetting": "profileSessionSettings:profileSessionSetting",
    "type:Prompt": "prompts:prompt",
    "type:Queue": "queues:queue",
    "type:QueueRoutingConfig": "queueRoutingConfigs:queueRoutingConfig",
    "type:QuickAction": "quickActions:quickAction",
    "type:RecommendationStrategy": "recommendationStrategies:recommendationStrategy",
    "type:RecordActionDeployment": "recordActionDeployments:deployment",
    "type:RedirectWhitelistUrl": "redirectWhitelistUrls:redirectWhitelistUrl",
    "type:RemoteSiteSetting": "remoteSiteSettings:remoteSite",
    "type:Report": "reports:report",
    "type:ReportType": "reportTypes:reportType",
    "type:Role": "roles:role",
    "type:SamlSsoConfig": "samlssoconfigs:samlssoconfig",
    "type:Scontrol": "scontrols:scf",
    "type:ServiceChannel": "serviceChannels:serviceChannel",
    "type:ServicePresenceStatus": "servicePresenceStatuses:servicePresenceStatus",
    "type:Settings": "settings:settings",
    "type:SharingRules": "sharingRules:sharingRules",
    "type:SharingSet": "sharingSets:sharingSet",
    "type:SiteDotCom": "siteDotComSites:site",
    "type:Skill": "skills:skill",
    "type:StandardValueSet": "standardValueSets:standardValueSet",
    "type:StandardValueSetTranslation": "standardValueSetTranslations:standardValueSetTranslation",
    "type:StaticResource": "staticresources:resource",
    "type:SynonymDictionary": "synonymDictionaries:synonymDictionary",
    "type:Territory2Type": "territory2Types:territory2Type",
    "type:TopicsForObjects": "topicsForObjects:topicsForObjects",
    "type:UserProvisioningConfig": "userProvisioningConfigs:userProvisioningConfig",
    "type:TransactionSecurityPolicy": "transactionSecurityPolicies:transactionSecurityPolicy",
    "type:Translations": "translations:translation",
    "type:UserCriteria": "userCriteria:userCriteria",
    "type:WaveApplication": "wave:wapp",
    "type:WaveDashboard": "wave:wdash",
    "type:WaveDataflow": "wave:wdf",
    "type:WaveDataset": "wave:wds",
    "type:WaveLens": "wave:wlens",
    "type:WaveXmd": "wave:xmd",
    "type:Workflow": "workflows:workflow",
    "type:WaveRecipe": "wave:wdpr",
    "type:WorkSkillRouting": "workSkillRoutings:workSkillRouting"
  }
