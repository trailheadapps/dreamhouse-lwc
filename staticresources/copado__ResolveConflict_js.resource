var conversionFunc = conversionFunc || {},
    jsonValidation = jsonValidation || {},
    parseOperations = parseOperations || {},
    modalOperations = modalOperations || {},
    panelFunctions = panelFunctions || {};
(function(self) {
    var spacing = '  ',
        getType = function(obj) {
            var type = typeof obj;
            if (obj instanceof Array) {
                return 'array';
            } else if (type == 'string') {
                return 'string';
            } else if (type == 'boolean') {
                return 'boolean';
            } else if (type == 'number') {
                return 'number';
            } else if (type == 'undefined' || obj === null) {
                return 'null';
            } else {
                return 'hash';
            }
        },
        convert = function(obj, ret) {
            var type = getType(obj);

            switch (type) {
                case 'array':
                    convertArray(obj, ret);
                    break;
                case 'hash':
                    convertHash(obj, ret);
                    break;
                case 'string':
                    convertString(obj, ret);
                    break;
                case 'null':
                    ret.push('null');
                    break;
                case 'number':
                    ret.push(obj.toString());
                    break;
                case 'boolean':
                    ret.push(obj ? 'true' : 'false');
                    break;
            }
        },
        convertArray = function(obj, ret) {
            if (obj.length === 0) {
                ret.push('[]');
            }
            for (var i = 0; i < obj.length; i++) {
                var ele = obj[i];
                var recurse = [];
                convert(ele, recurse);

                for (var j = 0; j < recurse.length; j++) {
                    ret.push((j == 0 ? '- ' : spacing) + recurse[j]);
                }
            }
        },
        convertHash = function(obj, ret) {
            for (var k in obj) {
                var recurse = [];
                if (obj.hasOwnProperty(k)) {
                    var ele = obj[k];
                    convert(ele, recurse);
                    var type = getType(ele);
                    if (type == 'string' || type == 'null' || type == 'number' || type == 'boolean') {
                        ret.push(normalizeString(k) + ': ' + recurse[0]);
                    } else {
                        ret.push(normalizeString(k) + ': ');
                        for (var i = 0; i < recurse.length; i++) {
                            ret.push(spacing + recurse[i]);
                        }
                    }
                }
            }
        },
        normalizeString = function(str) {
            if (str.match(/^[\w]+$/)) {
                return str;
            } else {
                return (
                    '"' +
                    escape(str)
                        .replace(/%u/g, '\\u')
                        .replace(/%U/g, '\\U')
                        .replace(/%/g, '\\x') +
                    '"'
                );
            }
        },
        convertString = function(obj, ret) {
            ret.push(normalizeString(obj));
        };

    self.json2yaml = function(obj) {
        if (obj == '') {
            return '';
        }
        //yaml parser error fix for empty files
        if (typeof obj == 'string') {
            obj = JSON.parse(obj);
        }

        var ret = [];
        convert(obj, ret);
        return ret.join('\n');
    };
})(conversionFunc);

(function(self) {
    var setGlobalErrorMessage = function(message, lineNo) {
            var elt = $copado('#errorMessage');
            elt.text(message);
            elt.data('line', lineNo);
        },
        addLineError = function(lineNo) {
            config.hasError = true;
            config.errorLines.push(lineNo);
            var line = editor.edit.doc.getLineHandle(lineNo);
            if (line) {
                editor.edit.doc.addLineClass(line, 'background', 'line-error');
            }
        },
        removeLineErrors = function(className) {
            config.hasError = false;
            for (var i = 0; i < config.errorLines; i++) {
                var line = editor.edit.doc.getLineHandle(config.errorLines[i]);
                if (line) editor.edit.doc.removeLineClass(line, 'background', 'line-error');
            }
            config.errorLines = [];
        };

    self.parseYaml = function() {
        try {
            if (editor.edit.doc.getValue().length > 0) {
                var doc = jsyaml.load(editor.edit.doc.getValue());
                removeLineErrors('line-error');
            }
            setGlobalErrorMessage('', 0);
            return null;
        } catch (e) {
            removeLineErrors('line-error');
            var lineNo = e.mark.line;
            e.message = e.message.replace('line ' + lineNo, 'line ' + (lineNo + 1));
            setGlobalErrorMessage('ERROR: ' + e.message, lineNo);
            addLineError(lineNo);
            return true;
        }
    };
})(jsonValidation);

(function(self) {
    self.setPreValue = function(sPane, format) {
        att2Res = $copado('[id$=attHiddenInp]').val();

        $copado('#xmlJson>button').removeClass('slds-button_brand');
        if (format) {
            $copado(format).addClass('slds-button_brand');
            currentMode = format = $copado(format).attr('cType');
            jsCookies.set('merge.conflict.format', currentMode);
        } else if (!format && currentMode) {
            $copado('[cType="' + currentMode + '"]').addClass('slds-button_brand');
        } else $copado('[cType="xml"]').addClass('slds-button_brand');

        if (att2Res || (attSource.length > 0 && attTarget.length > 0) || (isRollback && preSourceRollback && preTargetRollback)) {
            var attach = att2Res.length > 0 ? getAttachmentById(config.parentId, att2Res) : '';
            if (!attach && !bundleFlag) {
                if (isRollback) {
                    preSource = preSourceRollback;
                    preTarget = preTargetRollback;
                    if(preTarget && preTarget[0] === 'PREVIEW NOT AVAILABLE'){
                        panes = 1;
                    }
                }
                else{
                    bundleSource = unzip_Decode(attSource);
                    bundleTarget = unzip_Decode(attTarget);
                    if ((bundleSource[1].length == 2 || (bundleSource[1].length == 3 && bundleSource[1][1].indexOf('meta.xml') > -1)) && !attach) {
                        preSource[0] =
                            Object.keys(bundleSource[0].files)[0] != 'package.xml'
                                ? bundleSource[0].file(Object.keys(bundleSource[0].files)[0]).asText()
                                : '';
                        preSource[1] = bundleSource[1][0];
                        preTarget[0] =
                            Object.keys(bundleTarget[0].files)[0] != 'package.xml'
                                ? bundleTarget[0].file(Object.keys(bundleTarget[0].files)[0]).asText()
                                : '';
                        preTarget[1] = bundleTarget[1][0];
                    } else {
                        bundleFlag = true;
                        modalOperations.showFileModal();
                        $copado('.slds-modal__content#modal-content-id-1').prepend('<div id="fs2append"></div>');

                        for (var i = 0; i < bundleSource[1].length; i++) {
                            if (bundleSource[1][i].toLowerCase() != 'package.xml') {
                                /*used single quotes instead of ` since VF acts weird and puts js code directly to the page as visible*/
                                $copado('[id="fs2append"]').append(
                                    '<div class="slds-card__header slds-grid" style="padding: 0 0 0 0;margin: 0 0 .15rem;"><header style="color:black !important;' +
                                        (bundleSource[0].file(bundleSource[1][i]).asText() != bundleTarget[0].file(bundleSource[1][i]).asText()
                                            ? 'background-color: #f4f7fa !important;'
                                            : 'background-color: #FFF !important;') +
                                        '" class="rectangle slds-media slds-media_center slds-has-flexi-truncate"><div class="slds-media__body"><h2><span style="margin-left: 1%;" class="slds-text-heading_small aura-bundle-page-template">' +
                                        bundleSource[1][i] +
                                        '</span></h2></div>' +
                                        (bundleSource[0].file(bundleSource[1][i]).asText() != bundleTarget[0].file(bundleSource[1][i]).asText()
                                            ? '<div class="aura-bundle-view-button slds-no-flex"><div class="slds-form-element__control"><div class="slds-radio_button-group"><span class="slds-button slds-radio_button" onclick="modalOperations.renderBundleSelection(\'' +
                                            bundleSource[1][i] +
                                            '\');"><input id="autoResolveButton-' +
                                            i +
                                            '" name="radio-' +
                                            i +
                                            '"  type="radio" value="on"><label class="slds-radio_button__label slds-button slds-button_neutral" for="autoResolveButton-' +
                                            i +
                                            '"><span class="slds-radio_faux" >' +
                                            viewDifferences +
                                            '</span></label></span></div> </div></div>'
                                            : '<a href="#" onclick="modalOperations.renderBundleSelection(\'' +
                                            bundleSource[1][i] +
                                            '\');">' +
                                            viewFile +
                                            '</a>') +
                                        '</header></div><div class="slds-card__body"></div><footer class="slds-card__footer"></footer>'
                                );
                            }
                        }
                        returnFlag = true;
                    }
                }
                preFlag = true;
            }
            if (((attach && attach.Body.length > 0) || preFlag) && !returnFlag) {
                config.attachName = !preFlag ? attach.Name : preSource[0] > preTarget[0] ? preSource[1] : preTarget[1];
                config.hasError = false;
                config.alreadyChecked = true;
                $copado('#toLineDiv,.CodeMirror-simplescroll,.CodeMirror-merge-2pane,.CodeMirror-merge-3pane,#infoOnMerge').remove();

                if (sPane) panes = sPane;

                var offsetAmount = 120;
                attachmentInfo = !preFlag
                    ? attach.Name.replace('AUTO ', '')
                          .replace('RESOLVED ', '')
                          .split(' ')
                    : config.attachName.split('/');
                //correction for the types which's label and name are not the same hence there might be empty spaces in the label exp:custom object, field, layout etc.
                if (attachmentInfo.length > 2 && !preFlag) {
                    tempAttachments = attachmentInfo;
                    attachmentInfo = [];
                    attachmentInfo.push(tempAttachments[0]);
                    attachmentInfo.push(tempAttachments.slice(1).join(' '));
                }

                pMode = defineMode();
                usName = attachmentInfo[0];

                //$copado('.slds-modal__header:last').append('<center><span id="infoOnMerge"><strong style="font-size: medium;">'+attachmentInfo[1]+'</strong> ');
                var fileName = preSource && preSource.length ? (preSource[0] > preTarget[0] ? preSource[1] : preTarget[1]) : '';
                $copado('.files-to-compare').text(preSource && preSource.length > 0 ? fileName : attachmentInfo[1]);

                if (panes != 1) {
                    if (
                        pMode.toLowerCase().indexOf('xml') > -1 &&
                        (!parseOperations.parseErrorExist(attach ? prapareValue(Base64.decode(attach.Body), format) : preSource[0]) || format)
                    ) {
                        $copado('#xmlJson').css('display', '');
                        format = currentMode;
                        offsetAmount = 30;
                    } else {
                        currentMode = 'xml';
                        $copado('#xmlJson').css('display', 'none');
                    }

                    directValue = false;
                    $copado('#view').css('display', '');
                    $copado('.CodeMirror-simplescroll').css('display', 'none');
                    var value = attach ? prapareValue(Base64.decode(attach.Body), format) : prapareValue(preSource[0], format);
                    var orig1 = attach ? prepareOrig(Base64.decode(attach.Body), format) : prapareValue(preTarget[0], format);

                    editor = CodeMirror.MergeView(document.getElementById('view'), {
                        value: value,
                        origLeft: panes == 3 ? value : null,
                        orig: orig1,
                        lineNumbers: true,
                        mode: format == 'json' ? 'application/json' : pMode,
                        highlightDifferences: true,
                        connect: 'align',
                        collapseIdentical: true,
                        readOnly: attach ? false : true,
                        lineWrapping: true,
                        extraKeys: {
                            'Ctrl-Q': function(cm) {
                                cm.foldCode(cm.getCursor());
                            }
                        },
                        foldGutter: true,
                        gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
                    });

                    $copado('.CodeMirror-merge-editor').prepend(
                        '<div class="panel top" style="background-color:white;"><center><div id="resolutionToolTip" class="slds-popover slds-popover_tooltip slds-nubbin_top-left slds-is-absolute slds-hide toolTipTopHeight" role="tooltip"><div class="slds-popover__body"><div><span>' + resolutionToolTip + '</span></div></div></div><span>' +
                        (attach ? resolution +
                            '</span><div onmouseenter="$copado(\'#resolutionToolTip\').removeClass(\'slds-hide\')" onmouseleave="$copado(\'#resolutionToolTip\').addClass(\'slds-hide\')" class="slds-icon_container slds-icon__svg--default slds-p-left_xx-small informationIcon"><svg class="slds-button__icon"><use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#info"></use></svg></div>' +
                            '</center></div>' : source + jqxdatatable_config.data.orgName)
                    );
                    $copado('.CodeMirror-merge-pane-rightmost').prepend(
                        '<div class="panel top" style="background-color:white;"><center><div id="featureToolTip" class="slds-popover slds-popover_tooltip slds-nubbin_top slds-is-absolute slds-hide toolTipTopHeight" role="tooltip"><div class="slds-popover__body"><div><span>' + featureToolTip + '</span></div></div></div><span>' +
                        (attach ? featureBranch +
                            '</span><div onmouseenter="$copado(\'#featureToolTip\').removeClass(\'slds-hide\')" onmouseleave="$copado(\'#featureToolTip\').addClass(\'slds-hide\')" class="slds-icon_container slds-icon__svg--default slds-p-left_xx-small informationIcon"><svg class="slds-button__icon"><use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#info"></use></svg></div>' +
                            '</center></div>' : target + jqxdatatable_config.data.targetOrgName)
                    );
                    if ($copado('.CodeMirror-merge-left').length > 0) {
                        $copado('.CodeMirror-merge-left').prepend(
                            '<div class="panel top" style="background-color:white;"><center><div id="promotionToolTip" class="slds-popover slds-popover_tooltip slds-nubbin_top slds-is-absolute slds-hide toolTipTopHeight" role="tooltip"><div class="slds-popover__body"><div><span>'+promotionToolTip+'</span></div></div></div><span>' + promotionBranch + '</span>'+
                            '<div onmouseenter="$copado(\'#promotionToolTip\').removeClass(\'slds-hide\')" onmouseleave="$copado(\'#promotionToolTip\').addClass(\'slds-hide\')" class="slds-icon_container slds-icon__svg--default slds-p-left_xx-small informationIcon"><svg class="slds-button__icon"><use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#info"></use></svg></div>'+
                            '</center></div>'
                        );
                    }

                    var gapSize =
                        parseInt(
                            $copado('.CodeMirror-merge-gap')
                                .css('height')
                                .slice(0, -2)
                        ) + 19;
                    $copado('.CodeMirror-merge-gap').css('height', gapSize);
                } else {
                    currentMode = 'xml';
                    $copado('#xmlJson').css('display', 'none');

                    CodeMirror.defineMode('highlightSearch', function(config, parserConfig) {
                        var searchOverlay = {
                            token: function(stream, state) {
                                if (stream.match(keyword)) {
                                    return 'highlightSearch';
                                }
                                while (stream.next() != null && !stream.match(keyword, false)) {}
                                return null;
                            }
                        };
                        return CodeMirror.overlayMode(CodeMirror.getMode(config, parserConfig.backdrop || pMode), searchOverlay);
                    });
                    initEditor2();
                    directValue = true;
                    $copado('#view').css('display', 'none');
                    $copado('.CodeMirror-simplescroll').css('display', '');

                    editor2.focus();
                    editor2.setValue(Base64.decode(attach.Body));
                }
                $copado('#errorMessage').text('');
                modalOperations.toogleLocker(false);
                modalOperations.showFileModal();
            }
        }
    };
    self.classSetValue = function(elem) {
        var index = $copado(elem).attr('panel');
        resolutionToolTip = index === '3' ? resolutionToolTip3panel : resolutionToolTip2panel;
        jsCookies.set('merge.conflict.selection', index);
        $copado('#grp>.slds-button_brand').removeClass('slds-button_brand');
        $copado(elem).addClass('slds-button_brand');
        self.setPreValue(index);
    };
    var unzip_Decode = function(elem) {
            zip = new JSZip(elem, { base64: true });
            return [zip, Object.keys(zip.files)];
        },
        defineMode = function() {
            //last clause(after : ) used to be (attachmentInfo.length > 1 ? attachmentInfo[1].split('.')[0].toLowerCase() : attachmentInfo[0])
            //attachmentInfo.length > 2 is for bundles which is in use on SelectChanges page via compare link
            var aType =
                attachmentInfo.length > 2
                    ? attachmentInfo[2].split('.')[1].toLowerCase()
                    : preFlag
                    ? attachmentInfo[0]
                    : attachmentInfo[1].split('/')[0].toLowerCase();
            if (aType == 'apexclass' || aType == 'apextrigger' || aType == 'classes' || aType == 'triggers') {
                return 'text/x-java';
            } else if (aType == 'apexpage' || aType == 'apexcomponent' || aType == 'cmp' || aType == 'pages' || aType == 'components') {
                return 'text/html';
            } else if (aType == 'css') {
                return 'text/css';
            } else if (aType == 'staticresource' || aType == 'js' || aType == 'staticresources') {
                return 'text/javascript';
            } else return 'application/xml'; //'text/x-yaml'
        },
        prapareValue = function(val, format) {
            if (pMode == 'application/xml') {
                let firstRowEndsAt = val.indexOf('\n');
                firstRow = val.slice(0, firstRowEndsAt);

                // to make it work for yaml we are removing all blank lines
                if(format == 'json') {
                    val = val.replace(/(^[ \t]*\n)/gm, '');
                }
            }
            usName = val.slice(val.indexOf('>>>>>>>'), val.indexOf(usName) + usName.length); //'>>>>>>> feature/'+usName;
            
            var usNameWithMultiLineBreaks = val.match(usName + '(\r\n)');
            var usNameWithLineBreaks = usNameWithMultiLineBreaks ? usName+ '\r\n' : usName+ val.charAt(val.indexOf(usName) + usName.length);
            
            while (val.indexOf(usName) > -1 && usName && usName.length > 0) {
                // find a new line character either \r or \n and append to the end to truncate the values
                val = (val.slice(0, val.indexOf('=======')) + val.slice(val.indexOf(usName) + usNameWithLineBreaks.length, val.length)).replace(/<<<<<<< HEAD(\r\n|\n|\r)/, '');
            }

            var returnVal = format == 'json' ? conversionFunc.json2yaml(parseOperations.convertXml2formattedJSON(val)) : val;
            return unicodeReplacer(returnVal);
        },
        prepareOrig = function(val, format) {
            if (pMode == 'application/xml') {
                // to make it work for yaml we are removing all blank lines
                if(format == 'json') {
                    val = val.replace(/(^[ \t]*\n)/gm, '');
                }
            }
            var usRegex = new RegExp(usName + '(\r\n|\n|\r)');
            
            var multiLineBreaks = val.match('=======' + '(\r\n)');
            var conflictSperatorLineBreaks = multiLineBreaks ? '======='+ '\r\n' : '======='+ val.charAt(val.indexOf(usName) + usName.length);
            
            while (val.indexOf(usName) > -1 && val.indexOf('<<<<<<< HEAD') > -1) {
                // find a new line character either \r or \n and append to the end to truncate the values
                val = val.slice(0, val.indexOf('<<<<<<< HEAD')) + val.slice(val.indexOf('=======') + conflictSperatorLineBreaks.length, val.length);
                val = val.replace(usRegex, '');
            }
            var returnVal = format == 'json' ? conversionFunc.json2yaml(parseOperations.convertXml2formattedJSON(val)) : val;
            return unicodeReplacer(returnVal);
        },
        unicodeReplacer = function(returnVal) {
            while (returnVal.indexOf('\\x0A\\x20\\x20') > -1) {
                returnVal = returnVal.replace('\\x0A\\x20\\x20', '\\x0A\\x20');
            }
            while (returnVal.indexOf('"\\x0A\\x20"') > -1) {
                returnVal = returnVal.replace('"\\x0A\\x20"', '');
            }
            while (returnVal.indexOf('\\x20') > -1) {
                returnVal = returnVal.replace('\\x20', ' ');
            }
            while (returnVal.indexOf('\\x3A') > -1) {
                returnVal = returnVal.replace('\\x3A', ':');
            }
            return returnVal;
        };
})(panelFunctions);

(function(self) {
    self.openModal = function(attachmentId) {
        window.setTimeout(self.lock, 5); // to force redrawing.

        panelFunctions.setPreValue();

        return false;
    };
    self.renderBundleSelection = function(optionName) {
        preSource[0] = bundleSource[0].file(optionName).asText();
        preTarget[1] = preSource[1] = optionName;
        preTarget[0] = bundleTarget[0].file(optionName).asText();

        returnFlag = false;
        $copado('#fs2append').css('display', 'none');
        $copado('#closeFileModalbtn').css('display', 'none');
        $copado('#xmlJson').css('display', 'inline-flex');
        $copado('#backBtn4bundle').css('display', '');
        $copado('#view').css('visibility', '');
        panelFunctions.setPreValue();
    };
    self.backButtonOperation = function() {
        $copado('#xmlJson').css('display', 'none');
        $copado('#fs2append').css('display', '');
        $copado('#closeFileModalbtn').css('display', '');
        $copado('#backBtn4bundle').css('display', 'none');
        $copado('#view').css('visibility', 'hidden');
        $copado('[type=radio]:checked').prop('checked', false);
        $copado('.files-to-compare').text(files2Compare);
    };
    self.showModal = function() {
        setTimeout(function() {
            $copado('#backdrop').addClass('slds-backdrop--open');
            $copado('#modal').addClass('slds-fade-in-open');
            self.unlock();
        }, 500);
    };
    self.closeModal = function() {
        $copado('#modal').removeClass('slds-fade-in-open');
        $copado('#backdrop').removeClass('slds-backdrop--open');
        return false;
    };
    self.showFileModal = function() {
        setTimeout(function() {
            $copado('#fileBackdrop').addClass('slds-backdrop--open');
            $copado('#fileModal').addClass('slds-fade-in-open');
            self.unlock();
        }, 500);
    };
    self.closeFileModal = function() {
        bundleFlag = false;
        returnFlag = false;
        $copado('#backBtn4bundle').css('display', 'none');
        $copado('#fs2append').detach();
        $copado('#fileModal').removeClass('slds-fade-in-open');
        $copado('#fileBackdrop').removeClass('slds-backdrop--open');
        $copado('#screenLockerLightning').hide();
    };
    self.toogleLocker = function(lock) {
        if (lock) {
            $copado('#screenLockerLightning').show();
            return;
        }
        $copado('#screenLockerLightning').hide();
    };
    self.hideLocker = function() {
        setTimeout(function() {
            self.toogleLocker(false);
        }, 500);
    };
    self.unlock = function() {
        $copado('#screenLockerLightning').hide();
    };
    self.lock = function() {
        $copado('#screenLockerLightning').show();
    };
})(modalOperations);

(function(self) {
    var xmlToJson = function(xml) {
            // Changes XML to JSON
            // Modified version from here: http://davidwalsh.name/convert-xml-json
            // Create the return object
            var obj = {};

            if (xml.nodeType == 1) {
                // element
                // do attributes
                if (xml.attributes.length > 0) {
                    obj['@attributes'] = {};
                    for (var j = 0; j < xml.attributes.length; j++) {
                        var attribute = xml.attributes.item(j);
                        obj['@attributes'][attribute.nodeName] = attribute.nodeValue;
                    }
                }
            } else if (xml.nodeType == 3) {
                // text
                obj = xml.nodeValue;
            }

            // do children
            // If just one text node inside
            if (xml.hasChildNodes() && xml.childNodes.length === 1 && xml.childNodes[0].nodeType === 3) {
                obj = xml.childNodes[0].nodeValue;
            } else if (xml.hasChildNodes()) {
                for (var i = 0; i < xml.childNodes.length; i++) {
                    var item = xml.childNodes.item(i);
                    var nodeName = item.nodeName;
                    if (typeof obj[nodeName] == 'undefined') {
                        if (nodeName != '#text') obj[nodeName] = xmlToJson(item);
                    } else {
                        if (typeof obj[nodeName].push == 'undefined') {
                            var old = obj[nodeName];
                            obj[nodeName] = [];
                            obj[nodeName].push(old);
                        }
                        obj[nodeName].push(xmlToJson(item));
                    }
                }
            }
            return obj;
        },
        json2Xml = function(json, node) {
            /**
             * JSON to XML
             * @param {Object} JSON
             */
            var root = false;
            if (!node) {
                node = document.createElement('root');
                root = true;
            }
            for (var x in json) {
                if (json.hasOwnProperty(x)) {
                    if (typeof json == 'string') {
                        // field value char
                        node.appendChild(document.createTextNode(json[x]));
                    } else if (x == '@attributes') {
                        // attributes
                        for (var y in json[x]) {
                            if (json[x].hasOwnProperty(y)) {
                                node.setAttribute(y, json[x][y]);
                            }
                        }
                    } else if (x == '#comment') {
                        // comment
                        // ignore
                    } else {
                        // elements
                        if (json[x] instanceof Array) {
                            // handle arrays
                            for (var i = 0; i < json[x].length; i++) {
                                var str = x;
                                var uppercaseLetters = str.replace(/[a-z]/g, '');
                                let exX = x;
                                var arr = [];
                                if (i == 0) {
                                    for (var l = 0; l < uppercaseLetters.length; l++) {
                                        if (arr.includes(uppercaseLetters[l])) continue;
                                        x = x.replaceAll(uppercaseLetters[l], uppercaseLetters[l] + repWord);
                                        arr.push(uppercaseLetters[l]);
                                    }
                                    json = JSON.parse(JSON.stringify(json).replace(exX, x));
                                }
                                node.appendChild(json2Xml(json[x][i], document.createElement(x)));
                            }
                        } else {
                            if (x.length == 1) continue;

                            try {
                                var str = x;
                                var uppercaseLetters = str.replace(/[a-z]/g, '');
                                let exX = x;
                                var arr = [];
                                for (var l = 0; l < uppercaseLetters.length; l++) {
                                    if (arr.includes(uppercaseLetters[l])) continue;
                                    x = x.replaceAll(uppercaseLetters[l], uppercaseLetters[l] + repWord);
                                    arr.push(uppercaseLetters[l]);
                                }
                                json = JSON.parse(JSON.stringify(json).replace(exX, x));
                                node.appendChild(
                                    this.json2Xml(
                                        typeof json[x] == 'number' || typeof json[x] == 'boolean' ? json[x] + '' : json[x],
                                        document.createElement(x)
                                    )
                                );
                            } catch (e) {}
                        }
                    }
                }
            }
            if (root == true) {
                return node.innerHTML;
            } else {
                return node;
            }
        },
        formatXml = function(xml) {
            var formatted = '';
            var reg = /(>)(<)(\/*)/g; /**/
            xml = xml.replace(reg, '$1\r\n$2$3');
            var pad = 0;
            jQuery.each(xml.split('\r\n'), function(index, node) {
                var indent = 0;
                if (node.match(/.+<\/\w[^>]*>$/)) {
                    indent = 0;
                } else if (node.match(/^<\/\w/)) {
                    if (pad != 0) {
                        pad -= 2;
                    }
                } else if (node.match(/^<\w[^>]*[^\/]>.*$/)) {
                    indent = 2;
                } else {
                    indent = 0;
                }

                var padding = '';
                for (var i = 0; i < pad; i++) {
                    padding += '  ';
                }

                formatted += padding + node + '\r\n';
                pad += indent;
            });
            while (formatted.indexOf(repWord.toLowerCase()) > -1) {
                let matchChar = formatted.indexOf(repWord.toLowerCase()) - 1;
                let char2uppercase = formatted[matchChar];
                formatted = formatted.replace('XXXXX__', 'xxxxx__').replace(char2uppercase + repWord.toLowerCase(), char2uppercase.toUpperCase());
            }
            //firstRow: is the missing first row of XML which is gone after casting xml to json -- exp:<?xml version="1.0" encoding="UTF-8"?>
            return firstRow + '\n' + formatted;
        };

    parseOperations.parseErrorExist = function(body) {
        var xmlDOM = new DOMParser().parseFromString(body, 'text/xml');
        var oSerializer = new XMLSerializer();
        var sXML = oSerializer.serializeToString(xmlDOM);
        return sXML.indexOf('parsererror') > -1;
    };
    parseOperations.convertXml2formattedJSON = function(param) {
        //yaml parser error fix for empty files
        return param.length != '' ? JSON.stringify(xmlToJson(new DOMParser().parseFromString(param, 'text/xml')), null, '\t') : '';
    };
    parseOperations.convertJSON2formattedXml = function(param) {
        return formatXml(jsonToXml(JSON.parse(param)));
    };
    jsonToXml = function (o, tab) {
        var toXml = function (v, name, ind) {
            var xml = "";
            if (v instanceof Array) {
                for (var i = 0, n = v.length; i < n; i++)
                    xml += ind + toXml(v[i], name, ind + "\t") + "\n";
            }
            else if (typeof (v) == "object") {
                var hasChild = false;
                xml += ind + "<" + name;
                for (var m in v) {
                    if (m.charAt(0) == "@") {
                        for (var j in v[m]) {
                            xml += " " + j + "=\"" + v[m][j] + "\"";
                        }
                    }
                    else
                        hasChild = true;
                }
                xml += hasChild ? ">" : "/>";
                if (hasChild) {
                    for (var m in v) {
                        if (m == "#text")
                            xml += v[m];
                        else if (m == "#cdata")
                            xml += "<![CDATA[" + v[m] + "]]>";
                        else if (m.charAt(0) != "@")
                            xml += toXml(v[m], m, ind + "\t");
                    }
                    xml += (xml.charAt(xml.length - 1) == "\n" ? ind : "") + "</" + name + ">";
                }
            }
            else {
                xml += ind + "<" + name + ">" + v.toString() + "</" + name + ">";
            }
            return xml;
        }, xml = "";
        for (var m in o) {
            xml += toXml(o[m], m, "");
        }
        return tab ? xml.replace(/\t/g, tab) : xml.replace(/\t|\n/g, "");
    };
})(parseOperations);
