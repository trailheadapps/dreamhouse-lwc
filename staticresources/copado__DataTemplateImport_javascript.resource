// Data Template Import Javascript
var dti = dti || {};
var globalSldsResourcePath = globalSldsResourcePath ? globalSldsResourcePath : undefined;

((app) => {
    'use strict';
    var tablesList = ['dataTemplateTable'];
    var tableIdPaginationObject = {};
    var placeHolder = null;
    var realDataTemplateIdMap = [];
    app.isValidated = false;
    app.totalValidatedTemplate = 0;
    app.totalNotValidatedTemplate = 0;
    var existingGlobalDescribeResult;
    var activeTemplate = false;
    var svgStruct = [];
    var fileReader = new FileReader();


    var iconsList = [{
            svgButtonsClass: 'closeToastIcon',
            styleClass: 'slds-button__icon slds-icon_x-small',
            name: 'close',
            spriteType: 'utility-sprite'
        },
        {
            svgButtonsClass: 'warningToastIcon',
            styleClass: 'slds-button__icon slds-icon_x-small',
            name: 'warning',
            spriteType: 'utility-sprite'
        },
        {
            svgButtonsClass: 'successToastIcon',
            styleClass: 'slds-button__icon slds-icon_x-small',
            name: 'success',
            spriteType: 'utility-sprite'
        },
        {
            svgButtonsClass: 'errorToastIcon',
            styleClass: 'slds-button__icon slds-icon_x-small',
            name: 'error',
            spriteType: 'utility-sprite'
        },
        {
            svgButtonsClass: 'infoToastIcon',
            styleClass: 'slds-button__icon slds-icon_x-small',
            name: 'check',
            spriteType: 'utility-sprite'
        },
        {
            svgButtonsClass: 'approvalActionIcon',
            styleClass: 'slds-button__icon slds-icon slds-icon_x-small',
            name: 'approval',
            spriteType: 'action-sprite'
        },
        {
            svgButtonsClass: 'errorActionIcon',
            styleClass: 'slds-button__icon slds-icon slds-icon_x-small',
            name: 'close',
            spriteType: 'action-sprite'
        },
        {
            svgButtonsClass: 'uploadIcon',
            styleClass: 'slds-button__icon slds-icon_x-small',
            name: 'upload',
            spriteType: 'utility-sprite'
        }
    ];


    app.renderSVG = (elemId) => {
        var elem = $copado(elemId);
        var struct = svgStruct[elemId];
        var imageURL, SVG, SVGUse;

        if (struct) {
            imageURL = struct.imageURL;
            SVG = $copado('<svg/>', {
                class: struct.class,
            });
            SVGUse = $copado('<use/>');

            SVGUse.attr('xlink:href', imageURL);
            elem.prepend(SVG.append(SVGUse));
            elem.html(elem.html());
        }
    };


    app.applyRenderSVG = () => {
        if (iconsList) {
            iconsList.forEach((element) => {
                app.renderSVG('.' + element.svgButtonsClass);
            });
        }
    };


    app.setSVGStruct = () => {
        var className;

        if (globalSldsResourcePath) {
            iconsList.forEach((item) => {
                className = item.styleClass ? `${item.styleClass}` : 'slds-button__icon';
                svgStruct['.' + item.svgButtonsClass] = {
                    imageURL: `${globalSldsResourcePath}/icons/${item.spriteType}/svg/symbols.svg#${item.name}`,
                    class: className
                };
            });
        }
    };


    app.startDataTables = () => {
        tablesList.forEach((tableId) => {
            if ($copado(`#${tableId}`).dataTable) {
                $copado(`#${tableId}`).dataTable({
                    'paging': true,
                    'scrollCollapse': true,
                    'order': [
                        [1, "desc"]
                    ],
                    columnDefs: [{
                        orderable: false,
                        targets: "no-sort"
                    }],
                    'lengthMenu': [
                        [10, 25, 50, -1],
                        [10, 25, 50, 'All']
                    ],
                    'language': {
                        search: '',
                        searchPlaceholder: "Search..."
                    },
                    'fnPreDrawCallback': () => {
                        $copado('#progress').show();
                    },
                    'fnInitComplete': () => {
                        $copado(`#${tableId}`).show();
                        $copado('#progress').hide();
                    },
                    'dom': '<"top"f>rt<"bottom"ilp><"clear">'
                });
            }
        });
    };


    app.expandDataTables = () => {
        var rows, activePaginationSelected, table;
        var info = {};
        var currentPage = 0;

        tablesList.forEach((tableId) => {
            activePaginationSelected = $copado(`#${tableId}_length`).find('select').val();
            $copado(`#${tableId}_length`).find('select').val(-1).trigger('change');
            tableIdPaginationObject[tableId] = activePaginationSelected;
        });
    };


    app.contractDataTables = () => {
        var rows, activePaginationSelected, table;
        var info = {};
        var currentPage = 0;

        tablesList.forEach((tableId) => {
            $copado(`#${tableId}_length`).find('select').val(tableIdPaginationObject[tableId]).trigger('change');
        });
    };


    app.openModals = (param) => {
        $copado('[id=modal' + param + ']').show();
        $copado('[id=backDrop' + param + ']').show();
    };


    app.closeModals = (param) => {
        $copado('[id=modal' + param + ']').hide();
        $copado('[id=backDrop' + param + ']').hide();
    };


    app.changeEventFileUploader = () => {
        document.getElementById('fileUploadInput').addEventListener('change', app.bindFileReader);
    };


    app.hideAndShowButtons = () => {
        $copado('#doneButton').addClass('hide-buttons');
        $copado('#validateButton').removeClass('hide-buttons');
    };


    app.bindFileReader = () => {
        lockScreen();
        var textFromFileLoaded = document.getElementById('fileUploadInput').files[0];
        fileReader.readAsText(textFromFileLoaded);
        setTimeout(() => {
            if (fileReader.result) {
                parseImportedFiles(fileReader.result);
            }
        }, 100);
    };

    app.dropFile = () => {
        $copado('#jsonSelector').on(
            'dragover',
            (event) => {
                event.preventDefault();
                event.stopPropagation();
            }
        );
        $copado('#jsonSelector').on(
            'dragenter',
            (event) => {
                event.preventDefault();
                event.stopPropagation();
                $copado('.slds-file-selector__dropzone').addClass('slds-has-drag-over');
            }
        );
        $copado('#jsonSelector').on(
            'dragleave',
            (event) => {
                $copado('.slds-file-selector__dropzone').removeClass('slds-has-drag-over');
            }
        );
        $copado('#jsonSelector').on(
            'drop',
            (event) => {
                if (event.originalEvent.dataTransfer) {
                    if (event.originalEvent.dataTransfer.files.length) {
                        event.preventDefault();
                        event.stopPropagation();
                        fileReader.readAsText(event.originalEvent.dataTransfer.files[0]);
                        setTimeout(() => {
                            if (fileReader.result) {
                                parseImportedFiles(fileReader.result);
                            }
                        }, 100);
                    }
                }
            }
        );
    };


    app.sendErrorMessageToActionFunction = (error) => {
        var errorMessage = error.message ? error.message : (error.faultstring ? error.faultstring : 'Unknown Error');
        showError(errorMessage);
        console.error(error);
    }


    // it is used to retrieve inserted attachment to update relations in the body
    var retrieveAttachment = (dataObject, cbOnEnd) => {
        sforce.connection.query('SELECT Id,Name,Body FROM Attachment WHERE ParentId=\'' + dataObject.mainObject.id + '\' AND Name = \'Template Detail\' LIMIT 1', {
            onSuccess: (response) => {
                var contents = null;
                var relations = [];
                var newDataTemplateDetails = {};
                var childRelationKey = {};

                if (response.records) {
                    contents = convertBase64toObject(response.records.Body);
                    if (dataObject.importedObject.values.relationList.length > 0) {
                        if (contents.childrenObjectsReferenceList.length > 0) {
                            contents.childrenObjectsReferenceList.forEach((childrenRelation) => {
                                newDataTemplateDetails = realDataTemplateIdMap.find((dataTemplate) => {
                                    return dataTemplate.templateUUId === childrenRelation.templateId;
                                });

                                childrenRelation.templateId = newDataTemplateDetails.id;

                                var childObjectKeys = Object.keys(contents.selectableChildRelationsMap);
                                childRelationKey = childObjectKeys.find((child) => {
                                    return child.endsWith(childrenRelation.relationName);
                                });

                                var newDeploymentTemplateNameMap = {
                                    [newDataTemplateDetails.id]: newDataTemplateDetails.name
                                };

                                contents.selectableChildRelationsMap[childRelationKey].deploymentTemplate = newDataTemplateDetails.name;
                                contents.selectableChildRelationsMap[childRelationKey].deploymentTemplateNameMap = newDeploymentTemplateNameMap;
                            });
                        }

                        if (contents.parentObjectsReferenceList.length > 0) {
                            contents.parentObjectsReferenceList.forEach((parentRelation) => {
                                newDataTemplateDetails = realDataTemplateIdMap.find((dataTemplate) => {
                                    return dataTemplate.templateUUId === parentRelation.templateId;
                                });

                                parentRelation.templateId = newDataTemplateDetails.id;
                                var newDeploymentTemplateNameMap = {
                                    [newDataTemplateDetails.id]: newDataTemplateDetails.name
                                };

                                contents.selectableFieldsMap[parentRelation.relationName].deploymentTemplate = newDataTemplateDetails.name;
                                contents.selectableFieldsMap[parentRelation.relationName].deploymentTemplateNameMap = newDeploymentTemplateNameMap;
                            });
                        }
                    }

                    response.records.Body = convertObjectToBase64(contents);

                    var result = sforce.connection.update([response.records]);
                }
                cbOnEnd && cbOnEnd();
            },
            onFailure: (error) => {
                app.sendErrorMessageToActionFunction(error);
            }
        });
    };

    // it is used to update parent and child relation in each data templates which are inserted before
    var updateRelationTemplates = () => {
        var fileReaderResult = JSON.parse(fileReader.result);
        var newDataTemplateDetails = {};
        var deferredArray = [];

        fileReaderResult.forEach((importedObject) => {
            var deferred = new $copado.Deferred();
            deferredArray.push(deferred);

            newDataTemplateDetails = realDataTemplateIdMap.find((dataTemplate) => {
                return dataTemplate.templateUUId === importedObject.templateUUId;
            });

            var dataObject = {
                importedObject: importedObject,
                mainObject: newDataTemplateDetails
            };

            retrieveAttachment(dataObject, deferred.resolve);
        });

        //waits for every callout in the for loop to be done via deferred pattern and then calls the final actions
        $copado.when.apply(this, deferredArray).then(() => {
            var templateIdArray = [];
            realDataTemplateIdMap.forEach((insertedTemplates) => {
                templateIdArray.push(insertedTemplates.id);
            });

            var templateIdArrayToString = templateIdArray.join(',');
            listImportedTemplates(templateIdArrayToString);
            console.log('everything is done ');
        });
    };


    // it is used to match all imported field result with selected objects describe result and populate attachment body
    var matchCopadoFieldsForDataTemplateAttachment = (resultData) => {
        var relationList = resultData.importedObj.relationList;
        var filterArray = resultData.importedObj.filterList;
        var childObjetcsArray = resultData.importedObj.content.childObjects;
        var objectFieldsArray = resultData.importedObj.content.objectFields;
        objectFieldsArray = objectFieldsArray.concat(resultData.importedObj.content.parentObjects);
        var describeResult = JSON.parse(resultData.describeResult);
        var describeFieldsResult = describeResult.fields;
        var childRelationshipsResult = describeResult.childRelationships;
        var globalDescribe = JSON.parse(resultData.globalDescribe);
        var globalDescribeSobjects = globalDescribe.sobjects;
        var updatedDescribeFieldsResult = {};
        var updatedChildRelationshipResult = {};
        var currentField = {};
        var newDescribeFieldsResult = [];
        var parentObjectsReferenceList = [];
        var childrenObjectsReferenceList = [];
        var queryFilterList = [];
        var objectLabelName;

        // object fields and parent object fields mapping
        describeFieldsResult.forEach((object) => {
            currentField = objectFieldsArray.find((element) => {
                return element.apiName === object.name;
            });

            var isSelected = currentField ? true : false;
            var tempUseAsExternalId = currentField && currentField.useAsExternalId ? currentField.useAsExternalId : false;
            var tempFieldContentUpdate = currentField && currentField.fieldContentUpdate ? currentField.fieldContentUpdate : '';
            var tempReplaceValue = currentField && currentField.replaceValue ? currentField.replaceValue : '';
            var tempReplaceValueNumber = currentField && currentField.replaceValueNumber ? currentField.replaceValueNumber : placeHolder;
            var tempReplaceValueDate = currentField && currentField.replaceValueDate ? currentField.replaceValueDate : placeHolder;
            var tempReplaceValueDatetime = currentField && currentField.replaceValueDatetime ? currentField.replaceValueDatetime : placeHolder;
            var tempContentValueUpdateValues = currentField && currentField.contentValueUpdateValues ? currentField.contentValueUpdateValues : placeHolder;
            var tempParentObjectApiNameMap = {};

            // to populate 'parentObjectApiNameMap' parameter, we will check if the field has reference to any other object
            var currentSObject = {};
            if (object.referenceTo) {
                object.referenceTo.forEach((objectName) => {
                    currentSObject = globalDescribeSobjects.find((element) => {
                        return element.name === objectName;
                    });
                    tempParentObjectApiNameMap[currentSObject.name] = currentSObject.label;
                });
            }

            var copadoFields = {
                isSelected: isSelected,
                useAsExternalId: tempUseAsExternalId,
                externalId: object.externalId,
                label: object.label,
                name: object.name,
                fieldType: object.type,
                contentValueUpdateValues: tempContentValueUpdateValues,
                fieldContentUpdate: tempFieldContentUpdate,
                replaceValue: tempReplaceValue,
                replaceValueNumber: tempReplaceValueNumber,
                replaceValueDate: tempReplaceValueDate,
                replaceValueDatetime: tempReplaceValueDatetime,
                parentObjectApiNameMap: tempParentObjectApiNameMap,
                deploymentTemplateNameMap: placeHolder,
                deploymentTemplate: 'Select Template'
            };

            updatedDescribeFieldsResult[object.name] = copadoFields;

            var newDescribeResultField = {
                autonumber: object.autonumber, 
                calculated: object.calculated,
                custom: object.custom,
                externalId: object.externalId,
                filterable: object.filterable,
                label: object.label,
                length: object.length,
                name: object.name,
                nillable: object.nillable,
                relationshipName: object.relationshipName,
                relationshipOrder: object.relationshipOrder,
                referenceTo: object.referenceTo,
                sortable: object.sortable,
                type: object.type,
                unique: object.unique,
                writeRequiresMasterRead: object.writeRequiresMasterRead,
                replaceValueNumber: tempReplaceValueNumber,
                replaceValueDate: tempReplaceValueDate,
                replaceValueDatetime: tempReplaceValueDatetime
            };
            newDescribeFieldsResult.push(newDescribeResultField);
        });

        var childRelationshipsList = [];
        var innerChildRelationshipsList = [];
        var index = 0;
        // child object mapping
        childRelationshipsResult.forEach((object) => {
            var isSelected = false;
            index = childObjetcsArray.findIndex((element) => {
                if (object.relationshipName) {
                    return (element.field === object.field && element.childSObject === object.childSObject);
                }
            });
            if (index !== -1) {
                isSelected = true;
            }

            objectLabelName = globalDescribeSobjects.find((describeSobject) => {
                return describeSobject.name === object.childSObject;
            });

            var objectLabel = {};
            if (objectLabelName) {
                objectLabel[object.childSObject] = objectLabelName.label;

                var childObjects = {
                    isSelected: isSelected,
                    childSObject: object.childSObject,
                    field: object.field,
                    relationshipName: object.relationshipName,
                    objectApiNameMap: objectLabel,
                    deploymentTemplateNameMap: {},
                    deploymentTemplate: 'Select Template'
                };

                var childRelationKey = object.field + '-' + object.relationshipName;

                updatedChildRelationshipResult[childRelationKey] = childObjects;

                var childDescribeResult = {
                    childSObject: object.childSObject,
                    field: object.field,
                    relationshipName: object.relationshipName,
                };

                innerChildRelationshipsList.push(childDescribeResult);

                if (innerChildRelationshipsList.length === 1000) {
                    childRelationshipsList.push(innerChildRelationshipsList);
                    innerChildRelationshipsList = [];
                }
            }
        });
        childRelationshipsList.push(innerChildRelationshipsList);

        relationList.forEach((object) => {
            var relationDetail = {
                templateId: object.templateUUId,
                relationName: object.relationName,
            };

            if (object.childSObject) {
                relationDetail['childSObject'] = object.childSObject;
                childrenObjectsReferenceList.push(relationDetail);
            } else {
                parentObjectsReferenceList.push(relationDetail);
            }
        });

        var filterObject = {};
        if (filterArray) {
            filterArray.forEach((filters) => {
                filterObject = {
                    order: filters.order,
                    operatorSet: placeHolder,
                    operator: filters.operator,
                    finalValue: filters.finalValue,
                    fieldName: filters.fieldName,
                    fieldType: filters.fieldType,
                    input: filters.input ? filters.input : placeHolder,
                    numberInput: filters.numberInput ? filters.numberInput : placeHolder,
                    dateInput: filters.dateInput ? filters.dateInput : placeHolder,
                    dateTimeInput: filters.dateTimeInput ? filters.dateTimeInput : placeHolder
                };

                queryFilterList.push(filterObject);
            });
        }

        describeResult.fields = newDescribeFieldsResult;
        describeResult.childRelationships = [];
        describeResult.childRelationshipsList = childRelationshipsList;
        var finalMap = {
            fields: updatedDescribeFieldsResult,
            childObjects: updatedChildRelationshipResult,
            describeResult: JSON.stringify(describeResult),
            childrenObjectsReferenceList: childrenObjectsReferenceList,
            parentObjectsReferenceList: parentObjectsReferenceList,
            queryFilterList: queryFilterList
        };
        return finalMap;
    };


    // it is used to populate attachment body for "Template Detail" attachment
    var createDataTemplateAttachmentBody = (attachmentBodyData) => {
        var mainDataTemplate = {
            templateSourceOrg: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Template_Source_Org__c'],
            templateName: attachmentBodyData.templateDetails['Name'],
            templateMatchRecordTypes: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Match_Record_Type__c'],
            templateMainObject: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Main_Object__c'],
            templateMatchOwners: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Match_Owners__c'],
            templateId: attachmentBodyData.parentId,
            templateDescription: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Description__c'],
            templateContinueOnError: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Continue_on_Error__c'],
            templateActive: activeTemplate,
            templateQueryLimit: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Max_Record_Limit__c'],
            templateBatchSize: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Batch_Size__c'],
            templateFilterLogic: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Filter_Logic__c'],
            templateAttachmentOption: attachmentBodyData.templateDetails[attachmentBodyData.namespace + 'Attachment_Options__c'],
            templateSelectedAttachmentType: attachmentBodyData.importedObj.dataTemplate.templateAttachmentType
        };

        var resultData = {
            describeResult: attachmentBodyData.describeResult,
            globalDescribe: attachmentBodyData.globalDescribe,
            importedObj: attachmentBodyData.importedObj,
            templateDetails: attachmentBodyData.templateDetails,
            namespace: attachmentBodyData.namespace
        };

        var populatedData = matchCopadoFieldsForDataTemplateAttachment(resultData);

        var attachmentBody = {
            dataTemplate: mainDataTemplate,
            parentObjectsReferenceList: populatedData.parentObjectsReferenceList,
            childrenObjectsReferenceList: populatedData.childrenObjectsReferenceList,
            selectableFieldsMap: populatedData.fields,
            selectableChildRelationsMap: populatedData.childObjects,
            queryFilterList: populatedData.queryFilterList
        };

        var finalMap = {
            attachmentBody: attachmentBody,
            describeResult: populatedData.describeResult
        };

        return finalMap;
    };


    // it is used to create 3 attachments for each data template record. But if there is already global describe result in org credential, it will only create 2 attachments
    var createAttachments = (attachmentData, cbOnEnd) => {
        var attachmentArray = [];
        var blobValue;

        // Template Detail Attachment Creation
        var templateDetailAttachment = new sforce.SObject("Attachment");
        templateDetailAttachment.ParentId = attachmentData.parentId;
        templateDetailAttachment.Name = 'Template Detail';
        var attachmentBodyData = {
            parentId: attachmentData.parentId,
            describeResult: attachmentData.describeResult,
            globalDescribe: attachmentData.globalDescribe,
            sourceOrgId: attachmentData.sourceOrgId,
            importedObj: attachmentData.importedObj,
            templateDetails: attachmentData.templateDetails,
            namespace: attachmentData.namespace
        }

        var populatedData = createDataTemplateAttachmentBody(attachmentBodyData);
        blobValue = convertObjectToBase64(populatedData.attachmentBody);
        templateDetailAttachment.Body = blobValue;
        attachmentArray.push(templateDetailAttachment);

        // Describe Sobject Attachment Creation
        var sobjectAttachment = new sforce.SObject("Attachment");
        sobjectAttachment.ParentId = attachmentData.parentId;
        sobjectAttachment.Name = 'ADD_Describe_SObject_Result';
        blobValue = convertObjectToBase64(JSON.parse(populatedData.describeResult));
        sobjectAttachment.Body = blobValue;
        attachmentArray.push(sobjectAttachment);

        // Describe Global Attachment Creation
        if (existingGlobalDescribeResult === undefined) {
            var globalAttachment = new sforce.SObject("Attachment");
            globalAttachment.ParentId = attachmentData.parentId;
            globalAttachment.Name = 'ADD_Describe_Global_Result';
            blobValue = convertObjectToBase64(JSON.parse(attachmentData.globalDescribe));
            globalAttachment.Body = blobValue;
            attachmentArray.push(globalAttachment);
        }

        var result = sforce.connection.create(attachmentArray);
        cbOnEnd && cbOnEnd();
    };

    const convertObjectToBase64 = (obj) => {
        return btoa(unescape(encodeURIComponent(JSON.stringify(obj))));
    }

    const convertBase64toObject = (body) => {
        return JSON.parse(decodeURIComponent(escape(sforce.Base64Binary.prototype.decode((body)))));
    }

    // it is used to create data template record for each imported data template json
    var createDataTemplate = (creationData, cbOnEnd) => {
        var dataTemplate = new sforce.SObject(creationData.namespace + "Data_Template__c");
        dataTemplate[creationData.namespace + 'Template_Source_Org__c'] = creationData.sourceOrgId;
        dataTemplate[creationData.namespace + 'Main_Object__c'] = creationData.importedObj.dataTemplate.templateMainObject;
        dataTemplate[creationData.namespace + 'Max_Record_Limit__c'] = creationData.importedObj.dataTemplate.templateQueryLimit;
        dataTemplate[creationData.namespace + 'Description__c'] = creationData.importedObj.dataTemplate.templateDescription;
        dataTemplate[creationData.namespace + 'Filter_Logic__c'] = creationData.importedObj.dataTemplate.templateFilterLogic;
        dataTemplate[creationData.namespace + 'Attachment_Options__c'] = creationData.importedObj.dataTemplate.templateAttachmentOptions;
        dataTemplate[creationData.namespace + 'Batch_Size__c'] = creationData.importedObj.dataTemplate.templateBatchSize;
        dataTemplate[creationData.namespace + 'Match_Owners__c'] = creationData.importedObj.dataTemplate.templateMatchOwners;
        dataTemplate[creationData.namespace + 'Match_Record_Type__c'] = creationData.importedObj.dataTemplate.templateMatchRecordTypes;
        dataTemplate[creationData.namespace + 'Continue_on_Error__c'] = creationData.importedObj.dataTemplate.templateContinueOnError;
        dataTemplate[creationData.namespace + 'Active__c'] = activeTemplate;
        dataTemplate['Name'] = creationData.importedObj.dataTemplate.templateName;

        try {
            var result = sforce.connection.create([dataTemplate]);
            if (result[0].success) {
                var dataId = result[0].id;
                var attachmentData = {
                    parentId: dataId,
                    templateDetails: dataTemplate,
                    describeResult: creationData.describeResult,
                    globalDescribe: creationData.globalDescribe,
                    sourceOrgId: creationData.sourceOrgId,
                    importedObj: creationData.importedObj,
                    namespace: creationData.namespace
                }

                var newTemplateDetails = {
                    templateUUId: creationData.templateUUId,
                    id: dataId,
                    name: dataTemplate.Name
                };
                realDataTemplateIdMap.push(newTemplateDetails);
                createAttachments(attachmentData, cbOnEnd);
            }
        } catch (error) {
            app.sendErrorMessageToActionFunction(error);
        }
    };


    // it is used to make object callout to get describe result from selected org
    // on validation step, it will end at this function
    var objectCallout = (dataObject, cbOnEnd) => {
        var cleanUrl = dataObject.endpoint.replace('copado_objName', dataObject.name);
        var duplicateNameDetected = false;

        try {
            sforce.connection.query('SELECT Id,Name FROM ' + dataObject.namespace + 'Data_Template__c WHERE ' + dataObject.namespace + 'Main_Object__c=\'' + dataObject.name + '\'', {
                onSuccess: (response) => {
                    if (response.records) {
                        if(response.records.length){
                            response.records.forEach((existingTemplateRecords) => {
                                if(existingTemplateRecords.Name == dataObject.values.dataTemplate.templateName) {
                                    duplicateNameDetected = true;
                                }
                            });
                        } else {
                            if(response.records.Name == dataObject.values.dataTemplate.templateName) {
                                duplicateNameDetected = true;
                            }
                        }
                    }
                },
                onFailure: (error) => {
                    app.sendErrorMessageToActionFunction(error);
                }
            });

            sforce.connection.remoteFunction({
                url: cleanUrl,
                requestHeaders: {
                    'userId': dataObject.userId,
                    'orgId': dataObject.organizationId,
                    'token2': dataObject.token2
                },
                method: 'GET',
                onSuccess: (response) => {
                    var res = JSON.parse(response);
                    if (!res.success) {
                        if (res.error) {
                            showError(res.error);
                        } else {
                            var imageId = dataObject.values.dataTemplate.templateName.replace(/[^a-zA-Z0-9]/g, '') + '_cross';
                            $copado(`#${imageId}`).removeClass('cross-images');
                            app.totalNotValidatedTemplate++;
                            cbOnEnd && cbOnEnd();
                        }
                    } else {
                        if (app.isValidated) {
                            var creationData = {
                                namespace: dataObject.namespace,
                                sourceOrgId: dataObject.sourceOrgId,
                                importedObj: dataObject.values,
                                describeResult: response,
                                globalDescribe: dataObject.globalDescribe,
                                index: dataObject.index,
                                templateUUId: dataObject.templateUUId
                            };
                            return createDataTemplate(creationData, cbOnEnd);
                        } else {
                            if(duplicateNameDetected) {
                                var imageId = dataObject.values.dataTemplate.templateName.replace(/[^a-zA-Z0-9]/g, '') + '_warning';
                                $copado(`#${imageId}`).removeClass('warning-images');
                                app.totalNotValidatedTemplate++;
                            } else {
                                var imageId = dataObject.values.dataTemplate.templateName.replace(/[^a-zA-Z0-9]/g, '') + '_confirm';
                                $copado(`#${imageId}`).removeClass('confirm-images');
                                app.totalValidatedTemplate++;
                            }
                            cbOnEnd && cbOnEnd();
                        }
                    }
                },
                onFailure: (error) => {
                    app.sendErrorMessageToActionFunction(error);
                }
            });
        } catch (error) {
            app.sendErrorMessageToActionFunction(error);
        }

    };


    // it is used to prepare necessary information before doing an object callout for imported data templates
    var prepareObjectCallout = (existingDataObject) => {
        var fileReaderResult = JSON.parse(fileReader.result);
        var orgResponse = JSON.parse(existingDataObject.globalDescribe);
        var mainObject = '';
        //var index = 0;
        var dataObject = {};
        var dataTemplate = {};
        var deferredArray = [];
        var importedTemplateCount = fileReaderResult.length;
        app.totalValidatedTemplate = 0;
        app.totalNotValidatedTemplate = 0;

        fileReaderResult.forEach((importedTemplate, indexCounter) => {
            var deferred = new $copado.Deferred();
            deferredArray.push(deferred);
            mainObject = importedTemplate.values.dataTemplate.templateMainObject;

            dataObject = {
                name: mainObject,
                values: importedTemplate.values,
                index: indexCounter,
                templateUUId: importedTemplate.templateUUId,
                sourceOrgId: existingDataObject.sourceOrgId,
                userId: existingDataObject.userId,
                organizationId: existingDataObject.organizationId,
                token2: existingDataObject.token2,
                endpoint: existingDataObject.endpoint,
                globalDescribe: existingDataObject.globalDescribe,
                namespace: existingDataObject.namespace ? existingDataObject.namespace : ''
            };
            objectCallout(dataObject, deferred.resolve);
        });

        //waits for every callout in the for loop to be done via deferred pattern and then calls the final actions
        $copado.when.apply(this, deferredArray).then(() => {
            if (app.isValidated) {
                updateRelationTemplates();
            }
            if (importedTemplateCount === app.totalValidatedTemplate && !app.isValidated) {
                $copado('#doneButton').removeClass('hide-buttons');
                $copado('#validateButton').addClass('hide-buttons');
                app.isValidated = true;
                unlockScreen();
            } else if (importedTemplateCount !== app.totalValidatedTemplate && importedTemplateCount === (app.totalValidatedTemplate + app.totalNotValidatedTemplate) && !app.isValidated) {
                unlockScreen();
            }
        });
    };


    // it is used to check if global describe result is already exists in selected org credential,
    // If it is exists, we will use the existing attachment and not do callout
    var retrieveGlobalDescribeAttachment = (orgId, cbOnEnd) => {
        try {
            sforce.connection.query('SELECT Id,Name,Body FROM Attachment WHERE ParentId=\'' + orgId + '\' AND Name =\'ADD_Describe_Global_Result\' LIMIT 1', {
                onSuccess: (response) => {
                    if (response.records) {
                        existingGlobalDescribeResult = sforce.Base64Binary.prototype.decode(response.records.Body);
                    }
                    cbOnEnd && cbOnEnd();
                },
                onFailure: (error) => {
                    app.sendErrorMessageToActionFunction(error);
                }
            });
        } catch (error) {
            app.sendErrorMessageToActionFunction(error);
        }
    };

    // the main function that is called from visualforce page to start validation and done
    app.orgCallout = (orgCalloutData) => {
        var parsedData = JSON.parse(orgCalloutData);
        if (parsedData.sourceOrgId === null) {
            unlockScreen();
            return;
        }
        activeTemplate = parsedData.isActiveTemplate;

        var deferredArray = [];
        var deferred = new $copado.Deferred();
        deferredArray.push(deferred);
        retrieveGlobalDescribeAttachment(parsedData.sourceOrgId, deferred.resolve);

        //waits for every callout in the for loop to be done via deferred pattern and then calls the final actions
        $copado.when.apply(this, deferredArray).then(() => {
            var dataObject = {
                sourceOrgId: parsedData.sourceOrgId,
                userId: parsedData.userId,
                organizationId: parsedData.organizationId,
                token2: parsedData.token2,
                endpoint: parsedData.objectCalloutEndpoint,
                namespace: parsedData.namespace ? parsedData.namespace : ''
            };

            if (!existingGlobalDescribeResult) {
                try {
                    sforce.connection.remoteFunction({
                        url: parsedData.orgCalloutEndpoint,
                        requestHeaders: {
                            'userId': parsedData.userId,
                            'orgId': parsedData.organizationId,
                            'token2': parsedData.token2
                        },
                        method: 'GET',
                        onSuccess: (response) => {
                            var res = JSON.parse(response);
                            if (!res.success) {
                                showError(res.error);
                            } else {
                                dataObject['globalDescribe'] = response;
                                prepareObjectCallout(dataObject);
                            }
                        },
                        onFailure: (error) => {
                            app.sendErrorMessageToActionFunction(error);
                        }
                    });
                } catch (error) {
                    app.sendErrorMessageToActionFunction(error);
                }
            } else {
                dataObject['globalDescribe'] = existingGlobalDescribeResult;
                prepareObjectCallout(dataObject);
            }
        });
    };


    $(document).ready(() => {
        app.setSVGStruct();
        app.applyRenderSVG();
        app.startDataTables();
        app.openModals('UploadTemplate');
        app.dropFile();
        app.changeEventFileUploader();
    });

})(dti);