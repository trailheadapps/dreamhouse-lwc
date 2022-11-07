function PullRequest(config){
    var urlFactory = new this.UrlFactory();
    console.log('config',config);
    if(config === undefined) return;
	this.URL = urlFactory.generateURL(config);
}

PullRequest.prototype.UrlFactory = function(){
	this.generateURL = function(config){
		var path;
        var type = config.type;
        var url = config.url;
		if (type === "Github" || type === "Copado Version Control") {
            path = gitHubURL(config.base,config.compare);
        } else if (type === "GitLab") {
            path = gitLabURL(config.base,config.compare);
        } else if (type === "Bitbucket") {
            path = bitBucketURL(config.base,config.compare);
        } else if (type === "Microsoft Team Service") {
            path = microsoftURL(config.compare,config.base);
        } else if (type === "Others") {
        	return otherURL(url,config.base,config.compare);
        }
        console.log(path);
        console.assert(path, 'path not found for ' + type);
        var pullURL;
        if(url.endsWith('/')) pullURL = url+urlEncode(path);
        else pullURL=  url+'/'+urlEncode(path);
        console.info('pullURL',pullURL);
        return pullURL;
	}
}

var gitHubURL = function(base, compare){
	return 'compare/'+base+'...'+compare+'?expand=1';
}
var gitLabURL = function(base, compare){
	return 'merge_requests/new?merge_request[source_branch]='+compare+'&merge_request[target_branch]='+base;
}
var bitBucketURL = function(base, compare){
	return 'pull-requests/new?source='+compare+'&dest='+base+'&event_source=branch_detail';    
}
var microsoftURL = function(target,source){
	return 'Pullrequestcreate?targetRef='+source+'&sourceRef='+target;
}
var otherURL = function(url,target,source){
    return findReplaceTags(url,target,source);
}

var urlEncode = function(path){
	return encodeURI(path)
}
var isUrlValid = function(url) {
    return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
}

var findReplaceTags = function(url,target,source){
    var targetKey = '[TARGET_BRANCH_NAME]',targetFound = false;
    var sourceKey = '[SOURCE_BRANCH_NAME]',sourceFound = false;

    if (url) {
        var myRegexp = /\[\s*?(\S*?)\s*?\]/g;
        var t;
        while (t = myRegexp.exec(url)) {
            if(t[0] === targetKey){
                targetFound = true;
            } else if(t[0] === sourceKey){
               sourceFound = true;
            } else {
                console.warn('Unknown merge value in pull request base url : ',t[0]);
            }
        }
        if(sourceFound && targetFound){
            return url.replace(targetKey,urlEncode(target)).replace(sourceKey,urlEncode(source));
        }

        alert('Missing parameter in pull request url setup');
        return;
    }
}