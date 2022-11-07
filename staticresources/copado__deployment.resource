//todo move this to external:
var stepDataForOverrideFilter;
var copadoApp = {
    //attr
    selectedStep: false,
    selectedJob: false,

    ns: '',
    lockers: {},
    ui: {
        blockSelector: {
            steps: '[id$=pbSteps]',
            detail: '[id$=pbStepDetail]',
            status: '[id$=pbStatus]'
        }
    },

    data: {
        dep: null,
        jobs: null,
        destinations: null,
        attachSuccessNames: [],
        jobIdsToSkipRedraw: []
    },

    SourceOrgNotRequired: ['Git MetaData', 'Git Promotion', 'Apex', 'URL Callout', 'Manual Task', 'Salesforce Flow'],
    sourceOrgRequiredForStep: function (type) {
        return copadoApp.SourceOrgNotRequired.indexOf(type) > -1 ? false : true;
    },
    StepTypesAllowingEarlyCompletion: ['Manual Task'],
    earlyCompletionAllowed: function (type) {
        return copadoApp.StepTypesAllowingEarlyCompletion.indexOf(type) > -1 ? true : false;
    },
    stepTypesOneDestinationOrgLimit: ['URL Callout', 'External CI'],
    isLimitedToOneDestinationOrg: function (type) {
        return copadoApp.stepTypesOneDestinationOrgLimit.indexOf(type) > -1 ? true : false;
    },
    getNamespaceArray: function (type) {
        if (type == 'Manual Task') return copadoMTStep;
        if (type == 'Salesforce Flow') return copadoSalesforceFlowStep;
        if (type == 'URL Callout') return copadoCalloutStep;
        return null;
    },

    paintSelectedSep: function ($el) {
        $copado('.dataRow', 'table[id$="tSteps"]').removeClass('co-SelectedStep');
        $el.closest('.dataRow').addClass('co-SelectedStep');
    },

    cancel: function () {
        if (rock.config.cancel_url) {
            if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
                sforce.one.navigateToURL(rock.config.cancel_url);
            } else {
                location.href = rock.config.cancel_url;
            }
        } else {
            if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
                sforce.one.back();
            } else {
                window.history.back();
            }
        }
    },

    /**
     * logic copy from standard button
     * The idea is update all pending jobs to cancelled and reload
     *
     */
    cancelDeploy: function () {
        copadoApp.lock();
        copadoApp.disabledBtn('[id$=btnCancelDeploy]', copadoLabels.CANCELLING);

        var updateRecords = sforce.connection
            .query(
                'select id from ' +
                copadoApp.ns +
                'Deployment_Job__c where ' +
                copadoApp.ns +
                'Step__r.' +
                copadoApp.ns +
                "Deployment__c = '" +
                copadoApp.data.dep.Id +
                "' and " +
                copadoApp.ns +
                "Status__c in ('Pending','Not started')"
            )
            .getArray('records');
        if (updateRecords == null || updateRecords.length == 0) {
            copadoApp.showMessage('ERROR', copadoLabels.NOTHING_TO_CANCEL);
        } else {
            for (var i = 0; i < updateRecords.length; i++) {
                updateRecords[i][copadoApp.ns + 'Status__c'] = 'Cancelled';
            }
            var result = sforce.connection.update(updateRecords);
        }

        copadoApp.disabledBtn('[id$=btnCancelDeploy]', copadoLabels.CANCELLED);
        copadoApp.enabledBtn('[id$=btnDeploy]', copadoLabels.DEPLOY);
        copadoApp.unlock();
        ga('send', 'event', 'Deployment', 'deploy', 'cancel');
    },

    /**
     * function to disabled a btn
     * @param  {jquery obj or selector} sel   selector
     * @param  {[type]} label [description]
     */
    disabledBtn: function (sel, label) {
        copadoApp.setBtn(false, sel, label);
    },
    /**
     * enabled a button
     * @param  {jquery obj or selector} sel   selector
     * @param  {[type]} label [description]
     */
    enabledBtn: function (sel, label) {
        copadoApp.setBtn(true, sel, label);
    },
    setBtn: function (action, sel, label) {
        setTimeout(function () {
            var $btn = $copado(sel);

            if (action) {
                $btn.attr('disabled', null).removeClass('btnDisabled');
            } else {
                $btn.attr('disabled', 'disabled').addClass('btnDisabled');
            }

            //set label
            $btn.prop('tagName') === 'INPUT' ? $btn.val(label) : $btn.html(label);
        }, 1);
    },

    showJobResult: function () {
        var me = copadoApp,
            $el = $copado(this),
            jobId = $el.attr('data-jobId'),
            stepName = $el.attr('data-stepName'),
            stepId = $el.attr('data-stepId'),
            resultId = $el.attr('data-resultId');
        me.paintSelectedSep($el);

        if (me.selectedJob == jobId) {
            return;
        }
        //clean prev interface
        me.selectedStepId != stepId && me.setStepDetail(stepName, 1);

        me.selectedStepId = stepId;
        me.selectedJob = jobId;
        //get attach and render
        ga('send', 'event', 'Deployment', 'result', 'view');
        if (resultId != 'null' && resultId) {
            me.openResultRecord(resultId);
        } else {
            me.getJobResult(jobId, $el.attr('data-destination'), stepName);
        }
    },

    openResultRecord: function (resultId) {
        if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
            return window.open('/lightning/r/' + resultId + '/view', '_blank');
        } else {
            return window.open('/' + resultId, '_blank');
        }
    },

    setStepDetail: function (stepName, cleanDetail) { },

    linkForJob: function (styleClass, job, showResult, force) {
        if (typeof job[copadoApp.ns + 'Destination_Org__r'] === 'undefined' || typeof job[copadoApp.ns + 'Step__r'] === 'undefined') return;
        var destinationOrg = htmlEntities(job[copadoApp.ns + 'Destination_Org__r'][copadoApp.ns + 'To_Org__r'].Name); // undefined check control and special character escape done via htmlEntities
        var stepName = htmlEntities(job[copadoApp.ns + 'Step__r'].Name);
        return (
            '<i class="jobIcon ' +
            styleClass +
            '" data-destination="' +
            destinationOrg +
            '" data-stepName="' +
            stepName +
            '" data-stepId="' +
            job[copadoApp.ns + 'Step__c'] +
            '" data-jobId="' +
            job.Id +
            '" data-resultId="' +
            job[copadoApp.ns + 'Last_Result__c'] +
            '">' +
            (showResult
                ? '<i class="jobIconText" ' + (force ? 'style="display:block;width:80px;"' : '') + '> ' + copadoLabels.VIEW_RESULTS + '</i>'
                : '') +
            '</i>'
        );
    },
    htmlForJob: function (job) {
        var html = '',
            showResult = true,
            styleClass = false;

        switch (job[copadoApp.ns + 'Status__c']) {
            case 'Failed':
                styleClass = 'job-failed';
                break;
            case 'In progress':
                styleClass = 'job-in-progress';
                showResult = false;
                break;
            case 'Success':
                // check if there is an attachmend called jobId.json, in that case set "partial"
                styleClass = copadoApp.data.attachSuccessNames.indexOf(job.Id) == -1 ? 'job-success' : 'job-partial';
                break;
            case 'Cancelled':
                styleClass = 'job-cancelled';
                break;
        }
        var jobStepType = job[copadoApp.ns + 'Step__r'][copadoApp.ns + 'Type__c'];
        var stepTypeObject = copadoApp.getNamespaceArray(jobStepType);
        var thisJobStatus = job[copadoApp.ns + 'Status__c'];
        var thisJobEarlyCompletionStatus = job[copadoApp.ns + 'Early_Completion_Status__c'];
        if (copadoApp.earlyCompletionAllowed(jobStepType)) {
            if (thisJobStatus == 'Failed' || thisJobStatus == 'In progress') {
                if (thisJobStatus == 'Failed') {
                    html = copadoApp.linkForJob(styleClass, job, showResult, true);
                }
                html += ' ' + stepTypeObject.getStatusHTML(thisJobStatus, job.Id);
            }
            if (thisJobStatus == 'Pending') {
                styleClass = thisJobEarlyCompletionStatus == 'Failed' ? 'job-failed' : '';
                styleClass = thisJobEarlyCompletionStatus == 'Success' ? 'job-success' : styleClass;
                if (thisJobEarlyCompletionStatus == 'Success' || thisJobEarlyCompletionStatus == 'Failed') {
                    html = copadoApp.linkForJob(styleClass, job, true, true);
                }
                html += ' ' + stepTypeObject.getPendingStatusHTML(thisJobEarlyCompletionStatus, job.Id);
            }
            if (thisJobStatus == 'Success') {
                html = copadoApp.linkForJob('job-success', job, showResult);
            }
        } else {
            if (
                stepTypeObject &&
                stepTypeObject.allowManualCompletion &&
                stepTypeObject.allowManualCompletion(job) &&
                thisJobStatus == 'In progress'
            ) {
                html += ' ' + stepTypeObject.getStatusHTML(job[copadoApp.ns + 'Status__c'], job.Id);
            } else {
                if (styleClass) html = copadoApp.linkForJob(styleClass, job, showResult);
            }
        }
        return html;
    },

    renderJobs: function () {
        var len = copadoApp.data.jobs.length;
        while (len--) {
            var job = copadoApp.data.jobs[len];
            if (copadoApp.data.jobIdsToSkipRedraw.indexOf(job.Id) == -1) {
                html = copadoApp.htmlForJob(job);
                $copado('.js-step-destination-job-' + job[copadoApp.ns + 'External_Id__c']).html(html);
            }
        }
    },

    getJobs: function () {
        if (copadoApp.data.dep.Id) {
            var query =
                'Select Id, Name, ' +
                copadoApp.ns +
                'Step__r.' +
                copadoApp.ns +
                'dataJson__c, ' +
                copadoApp.ns +
                'Early_Completion_Status__c, ' +
                copadoApp.ns +
                'Step__r.' +
                copadoApp.ns +
                'Type__c ,' +
                copadoApp.ns +
                'Step__r.Name,' +
                copadoApp.ns +
                'Destination_Org__r.' +
                copadoApp.ns +
                'To_Org__r.Name, ' +
                copadoApp.ns +
                'Deployed__c, ' +
                copadoApp.ns +
                'Destination_Org__c, ' +
                copadoApp.ns +
                'External_Id__c, ' +
                copadoApp.ns +
                'Last_Result__c, ' +
                copadoApp.ns +
                'Status__c, ' +
                copadoApp.ns +
                'Status_Flag__c, ' +
                copadoApp.ns +
                'Step__c, ' +
                copadoApp.ns +
                'To_Org_Name__c from ' +
                copadoApp.ns +
                'Deployment_Job__c where ' +
                copadoApp.ns +
                'Step__r.' +
                copadoApp.ns +
                "deployment__c = '" +
                copadoApp.data.dep.Id +
                "' limit 1000";

            var result = sforce.connection.query(query, {
                onSuccess: function (res) {
                    if (res.records) {
                        copadoApp.data.jobs = res.size == 1 ? [res.records] : res.records;
                        if (copadoApp.data.jobs.length) {
                            //Get attachments to compare later job vs attachment name
                            //And define if Partial Deployment
                            //IMPROVE ME: remove this and use step flag set by heroku
                            sforce.connection.query(
                                "SELECT Id,Name FROM Attachment WHERE ParentId='" + copadoApp.data.dep.Id + "' AND ( Name like '%.json' ) LIMIT 200",
                                {
                                    onSuccess: function (res) {
                                        if (res.records) {
                                            copadoApp.data.attachs = res.size == 1 ? [res.records] : res.records;
                                            //normalize attachnames
                                            copadoApp.data.attachSuccessNames = [];
                                            var len = copadoApp.data.attachs.length;
                                            while (len--) {
                                                //remove .json from attach name for faster search during rendering
                                                copadoApp.data.attachSuccessNames.push(copadoApp.data.attachs[len].Name.replace('.json', ''));
                                            }
                                        }
                                        copadoApp.renderJobs();
                                    },
                                    onFailure: function (r) {
                                        console.error(r);
                                        copadoApp.renderJobs();
                                    }
                                }
                            );
                        }
                    }
                },
                onFailure: function (res) {
                    console.log('failure', res);
                }
            });
        }
    },

    createResultTable: function (res, $container) {
        var source2 = {
            localdata: res,
            datafields: [
                {
                    name: 'l',
                    type: 'string'
                },
                {
                    name: 'm',
                    type: 'string'
                },
                {
                    name: 't',
                    type: 'string'
                }
            ],
            datatype: 'array'
        },
            //adapter wrapper
            dataAdapter2 = new $copado.jqx.dataAdapter(source2),
            //keep jquery pointer for performance query
            $grid2 = $copado('<div>');

        $container.append($grid2);

        var preRender = function (row, column, value) {
            return '<pre class="co-preCell">' + value + '</pre>';
        };
        $grid2.jqxGrid({
            width: '100%',
            source: dataAdapter2,
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: false,
            scrollmode: 'logical',
            selectionmode: 'none',
            enablebrowserselection: true,
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '200', '500', '1000', '2000', '5000'],
            pagesize: 20,
            sortable: true,
            columnsresize: true,
            autorowheight: true,
            autoheight: true,
            altrows: true,
            localization: localizationobj,
            columns: [
                {
                    text: 'Level',
                    columntype: 'textbox',
                    filtertype: 'input',
                    datafield: 'l',
                    width: '5%'
                },
                {
                    text: 'Message',
                    filtertype: 'input',
                    datafield: 'm',
                    width: '70%',
                    cellsrenderer: preRender
                },
                {
                    text: 'Copado Tip',
                    datafield: 't',
                    filtertype: 'input',
                    columntype: 'textbox',
                    cellsrenderer: preRender,
                    width: '25%'
                }
            ]
        });

        ga('send', 'event', 'Deployment', 'result', 'render', res.length);
    },

    createDataTemplateResultTable: function (res, $container, sourceDomain, targetDomain) {
        var source2 = {
            localdata: res,
            datafields: [
                {
                    name: 'totalRecords',
                    type: 'integer'
                },
                {
                    name: 'deployedRecords',
                    type: 'integer'
                },
                {
                    name: 'failedRecords',
                    type: 'integer'
                },
                {
                    name: 'objectName',
                    type: 'string'
                },
                {
                    name: 'templateId',
                    type: 'string'
                },
                {
                    name: 'templateName',
                    type: 'string'
                },
                {
                    name: 'attachmentSize',
                    type: 'integer'
                },
                {
                    name: 'generatedIds',
                    type: 'integer'
                }
            ],
            datatype: 'array'
        },
            //adapter wrapper
            dataAdapter2 = new $copado.jqx.dataAdapter(source2),
            //keep jquery pointer for performance query
            $grid2 = $copado('<div>');

        $container.append($grid2);

        var sumSuccessAndFailRecords = function (row, column, value, defaultHtml) {
            value =
                $copado('.jqx-grid').jqxGrid('getCell', row, 'deployedRecords').value +
                $copado('.jqx-grid').jqxGrid('getCell', row, 'failedRecords').value;

            var _namespace = copadoApp.ns != '' ? copadoApp.ns + '__' : '';
            var templateId = $copado('.jqx-grid').jqxGrid('getCell', row, 'templateId').value;
            var templateName = $copado('.jqx-grid').jqxGrid('getCell', row, 'templateName').value;
            var element = $copado(defaultHtml);
            var resultPageUrl =
                '/apex/' +
                _namespace +
                'DataTemplateObjectResult?templateId=' +
                templateId +
                '&templateName=' +
                encodeURIComponent(templateName) +
                '&deploymentId=' +
                copadoApp.data.dep.Id +
                '&stepId=' +
                copadoApp.selectedStepId +
                '&sourceDomain=' +
                sourceDomain +
                '&targetDomain=' +
                targetDomain;
            element.html('<a href="javascript:void()" onClick="window.open(\'' + resultPageUrl + '\');">' + value + '</a>');

            return element[0].outerHTML;
        };

        downloadRecordMatchingCSV = elem => {
            var templateName = elem.split(',')[0];
            var deploymentId = elem.split(',')[1];
            templateName = templateName + '.csv';
            var contentDocumentId = '';

            sforce.connection.query("SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN ('" + deploymentId + "')", {
                onSuccess: response => {
                    var records = response.getArray('records');
                    if (records) {
                        records.forEach(contentDocumentLink => {
                            contentDocumentId = contentDocumentLink.ContentDocumentId;

                            sforce.connection.query(
                                "SELECT VersionData,Title FROM Contentversion WHERE ContentDocumentId ='" + contentDocumentId + "'",
                                {
                                    onSuccess: response => {
                                        var records = response.getArray('records');
                                        if (records) {
                                            var versionData;
                                            records.forEach(contentVersionItem => {
                                                if (contentVersionItem.Title === templateName) {
                                                    versionData = contentVersionItem.VersionData;
                                                }
                                            });

                                            versionData = Base64.decode(versionData);
                                            let csvContent = 'data:text/csv;charset=utf-8,' + versionData;
                                            var encodedUri = encodeURI(csvContent);
                                            var link = document.createElement('a');
                                            link.setAttribute('href', encodedUri);
                                            link.setAttribute('download', templateName);
                                            document.body.appendChild(link); // Required for FF

                                            link.click();
                                        }
                                    },
                                    onFailure: error => { }
                                }
                            );
                        });
                    }
                },
                onFailure: error => { }
            });
        };

        var generatedIdsCount = function (row, column, value, defaultHtml) {
            var element = $copado(defaultHtml);
            var templateId = $copado('.jqx-grid').jqxGrid('getCell', row, 'templateId').value;
            var templateName = $copado('.jqx-grid').jqxGrid('getCell', row, 'templateName').value;
            element.html(
                '<a href="javascript:void();" onClick="downloadRecordMatchingCSV(\'' +
                copadoApp.selectedStepId +
                '_' +
                templateName +
                '_' +
                templateId +
                ',' +
                copadoApp.data.dep.Id +
                '\');" >' +
                value +
                '</a>'
            );
            return element[0].outerHTML;
        };

        var preRender = function (row, column, value) {
            return '<pre class="co-preCell">' + value + '</pre>';
        };
        $grid2.jqxGrid({
            width: '100%',
            source: dataAdapter2,
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: false,
            scrollmode: 'logical',
            selectionmode: 'none',
            enablebrowserselection: true,
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '200', '500', '1000', '2000', '5000'],
            pagesize: 20,
            sortable: true,
            columnsresize: true,
            autorowheight: true,
            autoheight: true,
            altrows: true,
            localization: localizationobj,
            columns: [
                {
                    text: 'Object Name',
                    columntype: 'textbox',
                    filtertype: 'input',
                    datafield: 'objectName',
                    width: '25%'
                },
                {
                    text: 'Template Id',
                    filtertype: 'input',
                    columntype: 'textbox',
                    datafield: 'templateId',
                    hidden: true
                },
                {
                    text: 'Template Name',
                    filtertype: 'input',
                    columntype: 'textbox',
                    datafield: 'templateName',
                    width: '25%'
                },
                {
                    text: 'Total Record Count',
                    datafield: 'totalRecords',
                    filterable: false,
                    columntype: 'textbox',
                    width: '10%',
                    cellsrenderer: sumSuccessAndFailRecords
                },
                {
                    text: 'Success Record Count',
                    datafield: 'deployedRecords',
                    filterable: false,
                    columntype: 'textbox',
                    width: '10%'
                },
                {
                    text: 'Failed Record Count',
                    datafield: 'failedRecords',
                    filterable: false,
                    columntype: 'textbox',
                    width: '10%'
                },
                {
                    text: 'Attachments (mb)',
                    datafield: 'attachmentSize',
                    filterable: false,
                    columntype: 'textbox',
                    width: '10%'
                },
                {
                    text: 'Generated IDs',
                    datafield: 'generatedIds',
                    filterable: false,
                    columntype: 'textbox',
                    width: '10%',
                    cellsrenderer: generatedIdsCount
                }
            ]
        });

        ga('send', 'event', 'Deployment', 'result', 'render', res.length);
    },

    renderJobsResult: function (res, destination, stepName, jobId) {
        var $container = $copado('#stepResult');
        var _namespace = copadoApp.ns != '' ? copadoApp.ns + '__' : '';

        var newWindowUrl =
            '/apex/' +
            _namespace +
            'DeploymentJobResults?jobId=' +
            jobId +
            '&deploymentId=' +
            copadoApp.data.dep.Id +
            '&stepName=' +
            stepName +
            '&orgName=' +
            destination;

        var buttonLabel = copadoLabels.showResult;

        var resultsNewWindowLink =
            '&nbsp;&nbsp;<button id="btnShowResultsPopout" class="copado-lightning" onclick="window.open(\'' +
            encodeURI(newWindowUrl) +
            '\');" >' +
            buttonLabel +
            '</button>';

        var m = '<div class="co-stepResultTitle">' + copadoLabels.RESULTS_FOR_STEP_AND_DESTINATION_ORG + resultsNewWindowLink + '</div>';
        m = m.replace('STEP_NAME', stepName).replace('DESTINATION_ORG', destination);
        $container.html(m);

        if (res.records) {
            // transform and create result table
            res = Base64.decode(res.records.Body);
            res = $copado.parseJSON(res);
            var records = res.results ? res.results : res;
            var sourceDomain = res.sourceDomain ? res.sourceDomain : '';
            var targetDomain = res.targetDomain ? res.targetDomain : '';

            if (records[0] && records[0].m && (records[0].m.templateId || records[0].m.exception)) {
                if (!records[0].m.exception) {
                    var newResultArray = [];
                    records.forEach(function (element) {
                        var newResult = {
                            deployedRecords: element.m.deployedRecords,
                            failedRecords: element.m.failedRecords,
                            objectName: element.m.objectName,
                            templateId: element.m.templateId,
                            templateName: element.m.templateName,
                            attachmentSize: element.m.attachmentSize,
                            generatedIds: element.m.generatedIds
                        };
                        newResultArray.push(newResult);
                    });

                    copadoApp.createDataTemplateResultTable(newResultArray, $container, sourceDomain, targetDomain);
                } else {
                    var newResult = [
                        {
                            l: records[0].l,
                            m: records[0].m.exception,
                            t: records[0].t
                        }
                    ];
                    copadoApp.createResultTable(newResult, $container);
                }
                $copado('#btnShowResultsPopout').remove();
            } else {
                copadoApp.createResultTable(res, $container);
            }
        } else {
            //set tab content not log found
            $container.append('<center><i class="empty-msg">' + copadoLabels.NO_STEP_RESULTS_FOUND + '</i></center>');
        }
        //select tab
        copadoApp.unlock();
        $copado('#tab-stepResult').click();
    },

    getJobResult: function (jobId, destination, stepName) {
        copadoApp.lock();
        var result = sforce.connection.query(
            "SELECT Id, Body, BodyLength, ContentType, Name, ParentId FROM Attachment where Name = '" +
            jobId +
            ".json' order by createdDate DESC limit 1",
            {
                onSuccess: function (r) {
                    copadoApp.renderJobsResult(r, destination, stepName, jobId);
                },
                onFailure: function (res) {
                    copadoApp.showMessage('INFO', copadoLabels.NO_STEP_RESULTS_FOUND);
                    copadoApp.unlock();
                }
            }
        );
    },

    getDestinationsCount: function () {
        return copadoApp.data.destinations.filter(function (d) {
            return d.Id;
        }).length;
    },

    /**
     * check the deployment stage to enabled or disabled modules.
     * @return {[type]} [description]
     */
    checkDeploymentStage: function () {
        var me = copadoApp;

        if (!copadoApp.data.dep.Id) {
            me.lockSection(me.ui.blockSelector.steps);
            me.lockSection(me.ui.blockSelector.detail);
            me.lockSection(me.ui.blockSelector.status);
        } else {
            me.unlockSection(me.ui.blockSelector.steps);
            me.unlockSection(me.ui.blockSelector.detail);

            if (me.getStepsCount() && me.getDestinationsCount()) {
                me.unlockSection(me.ui.blockSelector.status);
            } else {
                me.lockSection(me.ui.blockSelector.status);
            }
        }
    },

    unlockSection: function (s) {
        typeof copadoApp.lockers[s] != 'undefined' && copadoApp.lockers[s].hide();
    },

    /**
     * Create a overlay over the given element
     * This method use cache
     * @param  {[type]} s [description]
     * @return {[type]}   [description]
     */
    lockSection: function (s) {
        if (typeof copadoApp.lockers[s] == 'undefined') {
            var html = '<div class="co-lockerBlock"></div>',
                $locker = $copado(html);

            $copado(s)
                .css({
                    position: 'relative'
                })
                .append($locker);

            copadoApp.lockers[s] = $locker;
        }
        copadoApp.lockers[s].show();
    },

    //methods
    /**
     * [showMessage description]
     * @param  {[type]} type CONFIRM, WARNING, ERROR
     * @param  {[type]} msg  [description]
     * @return {[type]}      [description]
     */
    showMessage: function (type, msg) {
        var panelHtml = msg
            ? $copado('[id$=js-msg-' + type + ']')
                .html()
                .replace('__MSG__', msg)
            : $copado('[id$=js-msg-' + type + ']').html();
        $copado('.fixedMsg')
            .html(panelHtml)
            .fadeIn('slow');
        setTimeout(function () {
            $copado('.fixedMsg').fadeOut('slow');
        }, 30000); // Increased deployment page message to 30 seconds from 7 seconds
        if (typeof reloadHistory == 'function') reloadHistory();
    },
    showMessageCallBack: function () {
        //$copado('.fixedMsg').fadeIn('slow');
    },
    toggleChatter: function () {
        loadChatter();
        //todo:
        // hightlight link
        //
    },

    resetStepResultContainer: function (m) {
        m = m || '<center><i class="empty-msg">' + copadoLabels.CLICK_DEPLOYMENT_JOB_TO_VIEW_RESULTS + '</i></center>';
        $copado('#stepResult').html(m);
    },
    resetStepDetailContainer: function (m) {
        m = m || copadoLabels.loading;
        copadoStep.hideAll();
    },
    resetStepContainers: function (m) {
        copadoApp.resetStepDetailContainer();
        copadoApp.resetStepResultContainer();
        copadoApp.selectedStepId = false;
    },

    onChangeCheck: function (el) {
        var $input = $copado(this);
        if ($input.attr('disabled') != 'disabled') {
            copadoStep.dirty = true;
        }
    },

    onChangeStepType: function (el) {
        var me = copadoApp;
        $copado(this)
            .closest('.dataRow')
            .find('.js-action-selectStep')
            .click();
    },

    apexMessagesShown: 0,
    consumeApexMessageQueue: function (queue) {
        var len = queue.length,
            me = copadoApp;
        for (var i = me.apexMessagesShown; i < len; i++) {
            me.showMessage(queue[i].s, queue[i].m);
        }
        me.apexMessagesShown = i;
    },

    mirrorBlockHeight: function () {
        var statusHeight = $copado('div[id$="pbStatus"]').height();
        var infoHeight = $copado('div[id$="pbInformation"]').height();
        if (parseInt(statusHeight) <= parseInt(infoHeight)) {
            $copado('div[id$="pbStatus"]').height($copado('div[id$="pbInformation"]').height());
        } else {
            $copado('div[id$="pbInformation"]').height($copado('div[id$="pbStatus"]').height());
        }
    },

    getStepDataFromEl: function ($el) {
        var $row = $el.closest('.dataRow');
        return {
            name: $row.find('input.js-step-name').val(),
            type: $row.find('.js-step-type').val(),
            check: $row.find('.js-step-check').is(':checked'),
            deploymentId: rock.deploymentId
        };
    },

    resetSelectedStep: function () {
        $copado('.dataRow', 'table#tSteps-tb').removeClass('co-SelectedStep');
        copadoApp.resetStepResultContainer('Select any step');
        copadoApp.resetStepDetailContainer('Select any step');
        copadoApp.selectedStepId = false;
    },

    removeNewStep: function () {
        $copado('[data-stepId=""]')
            .closest('.dataRow')
            .remove();
        copadoApp.isNewStepActive = false;
    },

    gotoStepRecord: function (elem) {
        var stepId = $copado(elem)
            .closest('div')
            .data('stepid');
        if (!stepId) {
            copadoApp.showMessage('WARNING', copadoLabels.savefirst);
        } else {
            if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
                sforce.one.navigateToSObject(stepId, 'detail');
            } else {
                window.open('/' + stepId, '_blank');
            }
        }
    },

    deleteStep: function ($el) {
        var me = copadoApp;

        if (confirm(copadoLabels.ARE_YOU_SURE)) {
            var stepId = me.getStepIdFromActionAttr($el);
            me.lock();
            $el.closest('.dataRow').remove();
            me.mirrorBlockHeight();

            if (me.selectedStepId == stepId) {
                me.selectedStepId = false;
                me.resetSelectedStep();
            }

            if (me.isNewStepActive && !stepId) {
                me.isNewStepActive = false;
            }

            //remove local
            me.data.steps = $copado.grep(me.data.steps, function (e) {
                return e.Id != stepId;
            });

            //remote deletion
            var core = copadoApp.ns ? window[copadoApp.ns.split('__')[0]] : window;
            stepId &&
                core.DeploymentExt.deleteStep(stepId, function (result, event) {
                    // Check the event status before any action
                    if (event.status == true) {
                        $el.closest('.dataRow').remove();
                        reloadHistory();
                        me.showMessage('CONFIRM', copadoLabels.STEP_DELETED);
                    } else {
                        // Delete failed so throw and error to UI
                        me.showMessage('ERROR', event.message);
                        return false;
                    }
                });

            if (!me.getStepsCount()) {
                $copado('#js-action-AddStep').click();
            }
            me.unlock();
            ga('send', 'event', 'Deployment', 'steps', 'delete');
            //if was a new step reset flag
        }
    },

    getStepIdFromActionAttr: function ($el) {
        return $el.closest('.js-col-actions').attr('data-stepid');
    },
    /**
     * [updateLocalStep description]
     * @type {[type]}
     */
    updateLocalStep: function (id, newStep) {
        //search local
        for (var i in copadoApp.data.steps) {
            if (copadoApp.data.steps[i].Id == id) {
                var step = copadoApp.data.steps[i],
                    pos = i;
                break;
            }
        }
        //
        var hasChanged =
            step.Name != newStep.name || step[copadoApp.ns + 'Type__c'] != newStep.type || step[copadoApp.ns + 'CheckOnly__c'] != newStep.check;

        if (hasChanged) {
            //updating local data by reference
            step.Name = newStep.name;
            step[copadoApp.ns + 'Type__c'] = newStep.type;
            step[copadoApp.ns + 'CheckOnly__c'] = newStep.check;
        }

        return hasChanged;
    },

    saveStepFailure: function () {
        copadoApp.unlock();
    },
    /**
     * update local list of steps
     * @param  {[type]} step [description]
     * @return {[type]}      [description]
     */
    saveStepCallback: function (step) {
        copadoApp.showMessage('CONFIRM', copadoLabels.SAVE_SUCCESS);

        //was new
        if (!copadoApp.selectedStepId) {
            copadoApp.selectedStepId = step.Id;
            $copado('[data-stepId=""]').attr('data-stepId', copadoApp.selectedStepId);
            copadoApp.data.steps.push(step);
            if (copadoApp.data.steps.length > 1) {
                copadoApp.reorderStepsController();
            }
        } else {
            //update local list
            stepObj = copadoApp.getStepSObjectById(step.Id);
            stepObj[copadoApp.ns + 'dataJson__c'] = step[copadoApp.ns + 'dataJson__c'];
        }

        copadoStep.stepObj = step;
        copadoApp.checkDeploymentStage();

        $copado('.js-col-actions[data-stepId="' + copadoApp.selectedStepId + '"]')
            .find('.js-action-selectStep')
            .removeClass('co-ico-saveStep')
            .addClass('co-ico-viewStep')
            .attr('src', copadoApp.res.imgs.view);

        copadoApp.unlock();
    },

    getStepDataFromUI: function (id) {
        var selectedStep = copadoApp.getStepDataFromEl($copado('[data-stepId="' + id + '"]'));
        selectedStep.Id = id;
        return selectedStep;
    },

    toogleStepName: function ($el) {
        $copado('input.js-step-check').attr('disabled', 'disabled');
        $el.closest('.js-row')
            .find('input.js-step-check')
            .removeAttr('disabled');
    },

    getStepSObjectById: function (id) {
        var len = copadoApp.data.steps.length;
        while (len--) {
            if (copadoApp.data.steps[len].Id === id) {
                return copadoApp.data.steps[len];
            }
        }
        return {};
    },

    selectStepController: function ($el) {
        var me = copadoApp;

        var stepId = me.getStepIdFromActionAttr($el);
        selectedStep = me.getStepDataFromEl($el);

        //avoid select same step and ID
        if (stepId && stepId == me.selectedStepId && copadoStep.stepType == selectedStep.type) {
            me.unlock();
            return false;
        }

        me.selectedJob = 0;
        me.paintSelectedSep($el);
        me.resetStepContainers();
        me.toogleStepName($el);
        me.selectedStepId = stepId;

        selectedStep.Id = stepId;

        // Check if type is allowed for multi destination org deployments.
        if (me.data.destinations.length > 1 && me.isLimitedToOneDestinationOrg(selectedStep.type)) {
            me.showMessage('WARNING', copadoLabels.STEP_TYPE_REQUIRES_1_DESTINATION_ORG.replace('__TYPE__', selectedStep.type));
            me.unlock();
            return false;
        }

        //check if not from Org Only GIT METADATA
        if (!me.data.dep[copadoApp.ns + 'From_Org__c'] && me.sourceOrgRequiredForStep(selectedStep.type)) {
            // NR: If there is an ID, it means it's already created, and we're trying to update the step. This should be allowed, even without Source Org
            if (!(selectedStep.Id && (selectedStep.type === 'Delete MetaData' || selectedStep.type === 'Rollback'))) {
                me.showMessage('WARNING', copadoLabels.STEP_TYPE_REQUIRES_SOURCE_ORG.replace('__TYPE__', selectedStep.type));
                me.unlock();
                return false;
            }
        }

        if (selectedStep.type === '0') {
            me.showMessage('WARNING', copadoLabels.SELECT_STEP_TYPE_FIRST);
            me.unlock();
            return false;
        } else {
            var $check = $el.closest('.js-row').find('.js-step-check');
            //check if step type is in the list of checkonly types
            if (['MetaData', 'Git MetaData', 'Rollback', 'Git Promotion', 'Delete MetaData', 'Quick Actions'].indexOf(selectedStep.type) != -1) {
                $check.show();
            } else {
                $check.hide();
            }
            if (['Data Template'].indexOf(selectedStep.type) != -1) {
                $copado('.js-validateStep').css('visibility', 'visible');
            } else {
                $copado('.js-validateStep').css('visibility', 'hidden');
            }
        }
        $copado('.js-saveStep').css('visibility', $copado(`div[data-stepid="${selectedStep.Id}"]`).css('visibility') == 'hidden' ? 'hidden' : '');

        me.selectedStepId = stepId;
        copadoStep.init(rock.org__c, selectedStep.type, stepId, me.getStepSObjectById(stepId), function () {
            copadoApp.selectStepCallback();
        });

        ga('send', 'event', 'Deployment', 'step', 'detail');
        ga('send', 'event', 'Deployment', 'step', 'detail-' + selectedStep.type);
    },

    //try to show step detail when user is viewing results
    switchDetail: function () {
        $copado('.co-SelectedStep')
            .find('td')
            .eq(0)
            .click();
    },

    selectRow: function (e) {
        var $target = $copado(e.target);
        if ($target.prop('tagName') == 'TD' || $target.prop('tagName') == 'DIV' || $target.prop('tagName') == 'SPAN') {
            $target
                .closest('tr.js-row')
                .find('.js-action-selectStep')
                .click();
        }
    },

    restorePrevStep: function () {
        var me = copadoApp,
            $row = $copado('.co-SelectedStep'),
            step = me.getStepSObjectById(me.selectedStepId);

        $row.find('input.js-step-name').val(step.Name);
        $row.find('input.js-step-check').prop('checked', step[copadoApp.ns + 'CheckOnly__c']);
        $row.find('.js-step-type').val(step[copadoApp.ns + 'Type__c']);

        $row.find('.js-action-selectStep')
            .removeClass('co-ico-saveStep')
            .addClass('co-ico-viewStep');
    },

    selectStep: function (el) {
        //get img el
        var $el = $copado(this),
            //is selected new?
            isSelectedNew = !copadoApp.getStepIdFromActionAttr($el);

        if (!isSelectedNew && copadoStep.dirty && !confirm(copadoLabels.UNSAVED_CHANGES)) {
            copadoApp.unlock();
            return false;
        }

        if (copadoStep.dirty) {
            !isSelectedNew && copadoApp.restorePrevStep();
            copadoStep.dirty = false;
        }

        copadoApp.lock();

        //this call is made async in order to lock the screen during hard js dml interactions
        setTimeout(function () {
            copadoApp.selectStepController($el);
        }, 10);
    },

    checkOneNewDestination: function () {
        if (!copadoApp.data.dep.Id) {
            copadoApp.showMessage('ERROR', copadoLabels.SELECT_STEP_TYPE_FIRST);
            return false;
        }

        if ($copado('.js-new-destination').length) {
            copadoApp.showMessage('ERROR', copadoLabels.NEW_DESTINATION_ORG_PENDING);
            return false;
        }

        for (var i = 0; i < copadoApp.data.steps.length; i++) {
            if (copadoApp.data.destinations.length == 1 && copadoApp.data.steps[i][copadoApp.ns + 'Type__c'] == 'URL Callout') {
                copadoApp.showMessage('WARNING', 'Deployments that contain a "URL Callout" step, cannot have more than one Destination Org.');
                return false;
            }
        }

        copadoApp.lock();
        addDestination();
        copadoApp.mirrorBlockHeight();
        return true;
    },

    selectStepCallback: function () {
        !$copado('#stepDetail').is(':visible') && $copado('#tab-stepDetail').click();
        //only unlock if SM is not in progress
        !statusManager.operationInProgress && copadoApp.unlock();
    },
    stepDetailCallback: function () {
        console.log('stepDetailCallback');
    },
    bindTabs: function (st) {
        $copado('#tab-container').easytabs({
            panelActiveClass: 'tab-selected',
            defaultTab: st
        });
    },
    unlock: function () {
        $copado('#screenLocker').hide();
    },
    lock: function () {
        $copado('#screenLocker').show();
    },

    deploy: function () {
        var _namespace = copadoApp.ns != '' ? copadoApp.ns + '__' : '';
        if (copadoApp.dirty) {
            copadoApp.redirectToDeploy = true;
            saveDeployment();
            copadoApp.dirty = false;
        } else {
            //copadoApp.lock();
            ga('send', 'event', 'Deployment', 'deploy');
            //change to popup)
            var url =
                '/apex/' +
                _namespace +
                'deploymentWizard?_ui=2&gotoStep=deploynow&id=' +
                copadoApp.data.dep.Id +
                '&jobsManagerMatchingKey=' +
                encodeURIComponent(copadoApp.jobsManagerMatchingKey);
            if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
                sforce.one.navigateToURL(url, true);
            } else {
                window.open(url, '_self');
            }
        }
    },

    jobColHTML: '<td class="dataCell js-col-job" colspan="1"><div class="jobDiv js-step-destination-job-STEPID_DESTINATIONID"></div></td>',
    jobHeaderHTML: '<th class="headerRow" scope="col" colspan="1"><div >NAME</div></th>',

    refreshDestinationHeaders: function () {
        var me = copadoApp,
            $header = $copado('#tSteps').find('tr.headerRow');
        for (var d in me.data.destinations) {
            me.data.destinations[d][copadoApp.ns + 'To_Org_Name__c'] &&
                $header.append(me.jobHeaderHTML.replace('NAME', me.data.destinations[d][copadoApp.ns + 'To_Org_Name__c']));
        }
    },
    renderStep: function (step) {
        var me = copadoApp,
            $new = me.ui.$cleanStep.clone();

        var readOnly =
            (step[copadoApp.ns + 'Read_Only__c'] === 'true' || step[copadoApp.ns + 'Read_Only__c'] === true) && rock.EditQualityGate !== 'true';
        //set values
        $new.find('input.js-step-name').val(step.Name);
        $new.find('.js-step-type').val(step[copadoApp.ns + 'Type__c']);
        $new.find('.js-step-check')
            .prop('checked', JSON.parse(step[copadoApp.ns + 'CheckOnly__c']))
            .hide();
        $new.find('.js-col-actions').attr('data-stepid', step.Id);
        $new.find('.js-step-type').attr('data-stepid', step.Id);
        if (readOnly) {
            $new.find('.js-col-actions').css('visibility', 'hidden');
            $new.find('.js-step-name').prop('disabled', true);
            $new.find('.js-step-type').prop('disabled', true);
        }

        // check if we should render the "check only" checkbox.
        var type = step[copadoApp.ns + 'Type__c'];
        ['MetaData', 'Delete MetaData', 'Rollback', 'Git MetaData', 'Git Promotion', 'Quick Actions'].indexOf(type) > -1 && $new.find('.js-step-check').show();

        // Disable all other options for a Git Promotion, so the user cannot change it
        if (type === 'Git Promotion') {
            $new.find('.js-step-type option').prop('disabled', 'disabled');
            $new.find('.js-step-type option[valUE="Git Promotion"]').prop('disabled', false);
        }
        if (type === 'Rollback') {
            $new.find('.js-step-type option').prop('disabled', 'disabled');
            $new.find('.js-step-type option[valUE="Rollback"]').prop('disabled', false);
        }

        //add destinations
        for (var d in me.data.destinations) {
            me.data.destinations[d][copadoApp.ns + 'To_Org_Name__c'] &&
                $new.append(me.jobColHTML.replace('STEPID', step.Id).replace('DESTINATIONID', me.data.destinations[d].Id));
        }

        $new.show();

        me.ui.$stepTable.append($new);

        return $new;
    },

    renderSteps: function () {
        var me = copadoApp,
            len = me.data.steps.length;

        //refresh destination headers
        me.refreshDestinationHeaders();

        //render steps
        for (var i = 0; i < me.data.steps.length; i++) {
            me.renderStep(me.data.steps[i]);
            me.renderedSteps.push(me.data.steps[i].Id);
        }
        ga('send', 'event', 'Deployment', 'steps', 'render', len);
    },

    renderedSteps: [],
    renderInsertedStep: function (messageData) {
        var me = copadoApp;
        var data = messageData.sobject ? messageData.sobject : messageData;
        if ($copado('.co-lockerBlock').length > 0) {
            $copado('.co-lockerBlock').remove();
        }
        if (!me.renderedSteps.includes(data.Id) && $copado('[data-stepId="' + data.Id + '"]').length == 0) {
            me.renderedSteps.push(data.Id);
            var thisStep = {};
            thisStep.Name = data.Name;
            thisStep.Id = data.Id;
            var fieldsArray = Object.keys(data);

            for (var i = 0; i < fieldsArray.length; i++) {
                if (fieldsArray[i] != 'Name' && fieldsArray[i] != 'Id') {
                    thisStep[fieldsArray[i]] = data[fieldsArray[i]];
                }
            }
            if (!thisStep[copadoApp.ns + 'dataJson__c']) {
                var query = 'SELECT ' + copadoApp.ns + 'dataJson__c FROM ' + copadoApp.ns + "Step__c WHERE Id ='" + data.Id + "' limit 1";

                var result = sforce.connection.query(query, {
                    onSuccess: function (res) {
                        if (res.records) {
                            thisStep[copadoApp.ns + 'dataJson__c'] = res.records[copadoApp.ns + 'dataJson__c'];
                        }
                    },
                    onFailure: function (res) {
                        console.log('renderInsertedStep failure', res);
                    }
                });
            }
            var $el = me.renderStep(thisStep);
            me.toogleStepName($el);

            me.data.steps.push(thisStep);
        } else {
            var moveToIndex = data[copadoApp.ns + 'Order__c'];
            if (moveToIndex.indexOf('.') > -1 || moveToIndex.indexOf(',')) {
                moveToIndex = moveToIndex.substring(0, moveToIndex.indexOf('.') > -1 ? moveToIndex.indexOf('.') : moveToIndex.indexOf(','));
            }

            var moveFromIndex = me.renderedSteps.indexOf(data.Id) + 1;
            if (moveFromIndex != moveToIndex) {
                var $move2Item = $copado('tbody.tSteps2Drag tr:eq(' + moveToIndex + ')');
                var $moveItem = $copado('tbody.tSteps2Drag tr:eq(' + moveFromIndex + ')');
                if (moveToIndex > moveFromIndex) {
                    $copado($move2Item).after($moveItem);
                } else {
                    $copado($move2Item).before($moveItem);
                }
            }

            me.renderedSteps = [];
            $copado('div[data-stepId]').each(function () {
                me.renderedSteps.push($copado(this).attr('data-stepId'));
            });
        }
    },

    createStepRow: function () {
        var me = copadoApp;

        //init step table
        if (!me.ui.$stepTable) {
            me.ui.$stepTable = $copado('#tSteps-tb');
        }

        if (!me.ui.$cleanStep) {
            //clone
            var $stepRow = me.ui.$stepTable
                .find('tr.dataRow')
                .eq(0)
                .clone();

            //clean
            $stepRow.find('.js-col-job').empty();

            $stepRow.find('.js-col-actions').attr('data-stepid', '');
            $stepRow.find('.js-step-type').attr('data-stepid', '');

            $stepRow.show();

            me.ui.$cleanStep = $stepRow;
        }

        copadoApp.isNewStepActive = $copado('.js-stepList')
            .find('.js-col-actions')
            .attr('data-stepId');
    },
    getStepsCount: function () {
        return copadoApp.data.steps.length; //copadoApp.ui.$stepTable.find('tr.dataRow').length - (copadoApp.isNewStepActive ? 1:0);
    },
    getNewStepName: function () {
        return 'Step ' + (copadoApp.getStepsCount() + 1);
    },

    addStep: function () {
        var me = copadoApp;

        //if has a new pending to save show alert
        if ($copado('[data-stepId=""]').length > 0) {
            me.showMessage('WARNING', copadoLabels.SAVE_NEW_STEP_FIRST_TO_ADD_NEW_STEP);
            return false;
        }

        me.isNewStepActive = true;

        var thisStep = {};
        thisStep.Name = me.getNewStepName();
        thisStep[copadoApp.ns + 'CheckOnly__c'] = false;
        var $el = me.renderStep(thisStep);
        me.toogleStepName($el);

        if (me.selectedStepId) {
            me.resetSelectedStep();
        }

        ga('send', 'event', 'Deployment', 'steps', 'add');
    },

    bindActions: function () {
        $copado('.js-stepList')
            .off('click', '.jobIcon', copadoApp.showJobResult)
            .off('click', '.js-action-selectStep', copadoApp.selectStep)
            .off('click', 'tr.js-row', copadoApp.selectRow)
            .off('change', '.js-step-type', copadoApp.onChangeStepType)
            .off('change', '.js-step-check', copadoApp.onChangeCheck);
        //.off('change', 'input.js-step-name', copadoApp.onChangeName);

        $copado('.js-stepList')
            .on('click', '.jobIcon', copadoApp.showJobResult)
            .on('click', '.js-action-selectStep', copadoApp.selectStep)
            .on('click', 'tr.js-row', copadoApp.selectRow)
            .on('change', '.js-step-type', copadoApp.onChangeStepType)
            .on('change', '.js-step-check', copadoApp.onChangeCheck);
        //.on('change', 'input.js-step-name', copadoApp.onChangeName);

        $copado('#js-action-AddStep').off('click');
        $copado('#js-action-AddStep').click(copadoApp.addStep);

        $copado('[id$=ifName],[id$=ifSendDeploymentCompleteEmail]').off('change');
        $copado('[id$=ifName],[id$=ifSendDeploymentCompleteEmail]').on('change', function () {
            copadoApp.dirty = true;
        });

        $copado('.orgIcon').off('click');
        $copado('.orgIcon').click(function () {
            var m = $copado(this).attr('title');
            m && copadoApp.showMessage('WARNING', m);
        });
        $copado('#tab-stepDetail').off('click', copadoApp.switchDetail);
        $copado('#tab-stepDetail').on('click', copadoApp.switchDetail);
    },
    updateDeployment: function (cb) {
        //query remote deployment
        var query =
            'SELECT ' +
            copadoApp.ns +
            'Completed__c,' +
            copadoApp.ns +
            'Count_Completed__c,' +
            copadoApp.ns +
            'Date__c,' +
            copadoApp.ns +
            'Deployed__c,' +
            copadoApp.ns +
            'Deployment_Jobs_Count__c,' +
            copadoApp.ns +
            'Flag_Status__c,' +
            copadoApp.ns +
            'From_Org__c,' +
            copadoApp.ns +
            'Schedule__c,' +
            copadoApp.ns +
            'Status__c,' +
            copadoApp.ns +
            'SUM_Deployed__c, Id FROM ' +
            copadoApp.ns +
            "Deployment__c WHERE Id ='" +
            copadoApp.data.dep.Id +
            "' limit 1";

        var result = sforce.connection.query(query, {
            onSuccess: function (res) {
                if (res.records) {
                    copadoApp.data.dep = res.records;
                    $copado('[id$=ofStatus]').html(copadoApp.data.dep[copadoApp.ns + 'Status__c']);
                    $copado('[id$=ofCompleted]').html(copadoApp.data.dep[copadoApp.ns + 'Completed__c'] + ' %');
                    $copado('.js-status-icon').attr('src', copadoApp.data.dep[copadoApp.ns + 'Flag_Status__c']);

                    if (copadoApp.data.dep[copadoApp.ns + 'Status__c'].indexOf('Completed') === 0) {
                        copadoApp.enabledBtn('[id$=btnDeploy]', copadoLabels.DEPLOY);
                    } else if (copadoApp.data.dep[copadoApp.ns + 'Status__c'] == 'In Progress') {
                        copadoApp.disabledBtn('[id$=btnDeploy]', copadoLabels.DEPLOYING);
                    }

                    if (copadoApp.data.dep[copadoApp.ns + 'Status__c'] != '' || copadoApp.data.dep[copadoApp.ns + 'Status__c'] != 'Draft') {
                        $copado('#btnViewStatus').show();
                        copadoApp.mirrorBlockHeight();
                    } else {
                        $copado('#btnViewStatus').hide();
                        copadoApp.mirrorBlockHeight();
                    }
                    cb && cb();
                }
            },
            onFailure: function (res) {
                console.log('failure', res);
            }
        });
    },

    statusCheckerTimer: false,

    startStatusChecker: function (dontDisableButton) {
        if (!copadoApp.statusCheckerTimer) {
            if (!dontDisableButton) {
                copadoApp.disabledBtn('[id$=btnDeploy]', copadoLabels.DEPLOYING);
            }
            copadoApp.statusCheckerTimer = setInterval(copadoApp.statusChecker, 30000);
        }
    },

    stopStatusChecker: function () {
        copadoApp.statusCheckerTimer && clearInterval(copadoApp.statusCheckerTimer);
        copadoApp.statusCheckerTimer = false;
        copadoApp.enabledBtn('[id$=btnDeploy]', copadoLabels.DEPLOY);
    },

    statusChecker: function (avoidStatusRefresh) {
        if (!avoidStatusRefresh) {
            copadoApp.updateDeployment(copadoApp.statusCheckerCallBack);
        } else {
            copadoApp.statusCheckerCallBack();
        }
    },
    statusCheckerCallBack: function () {
        var me = copadoApp;

        switch (me.data.dep[copadoApp.ns + 'Status__c']) {
            case 'Draft':
                if (me.ccdEnabled && deploymentStreamingService.calloutCounter < deploymentStreamingService.maxAllowedCallout) {
                    deploymentStreamingService.initPoller();
                    me.startStatusChecker(true);
                }
                break;
            case 'In progress':
                me.startStatusChecker();
                me.getJobs();
                break;
            case 'Scheduled':
                //incremental interval solution for callout instead of staticly 2 seconds
                me.statusCheckerInterval = me.statusCheckerInterval < 256000 ? me.statusCheckerInterval * 2 : 300000;
                if (me.data.dep[copadoApp.ns + 'Schedule__c'] === 'Deploy now') {
                    //force update status
                    //to show a cool
                    setTimeout(function () {
                        copadoApp.updateDeployment(copadoApp.statusCheckerCallBack);
                    }, me.statusCheckerInterval);
                }
                break;
            default:
                me.stopStatusChecker();
                me.getJobs();
                break;
        }
    },
    statusCheckerInterval: 2000,

    /**
     * dont use this if validation are remote
     * @return {[type]} [description]
     */
    save: function () {
        copadoApp.lock();
        setTimeout(function () {
            //trick to avoid html validation
            $copado('input[name$=Name]', '[id$=pbInformation]').attr('required', false);
            //apex remote action
            saveDeployment();
            copadoApp.dirty = false;

            ga('send', 'event', 'Deployment', 'save');

            copadoApp.unlock();
        }, 66);
    },

    checkDirty: function () {
        if ($copado('.co-ico-saveStep').length || copadoStep.dirty || copadoApp.dirty) {
            return copadoLabels.UNSAVED_CHANGES;
        } else {
            //return true;
        }
    },

    sortTimer: false,
    remoteSort: function () {
        var me = copadoApp;

        var core = copadoApp.ns ? window[copadoApp.ns.split('__')[0]] : window;
        core.DeploymentExt.sortSteps(me.stepsIdsSorted, function () {
            me.showMessage('CONFIRM', copadoLabels.NEW_STEP_ORDER_SAVED);
            me.sortTimer = false;
        });
    },
    reorderStepsController: function () {
        var me = copadoApp;
        me.stepsIdsSorted = [];
        //get order from ui
        $copado('#tSteps-tb tr.js-row:visible').each(function (i) {
            var id = $copado(this)
                .find('.js-col-actions')
                .attr('data-stepId');
            id && copadoApp.stepsIdsSorted.push(id);
        });
        //update local
        var len = me.data.steps.length;
        me.renderedSteps = [];
        while (len--) {
            var s = me.data.steps[len];
            s[copadoApp.ns + 'Order__c'] = me.stepsIdsSorted.indexOf(s.Id) + 1;
            me.renderedSteps[len] = s.Id;
        }
        //remote action on timer to avoid flooding
        clearTimeout(me.sortTimer);
        me.sortTimer = setTimeout(me.remoteSort, 3000);
    },

    reorderSteps: function (event, ui) {
        copadoApp.reorderStepsController();
        ga('send', 'event', 'Deployment', 'reorder');
    },

    sortable: function () {
        $copado('tbody.tSteps2Drag').sortable({
            handle: '.iconDrag',
            itemSelector: 'tr.js-row',
            stop: copadoApp.reorderSteps
        });
    },

    start: function (dep, steps) {
        var me = copadoApp;
        //TODO replace this by json deployment obj
        me.data.dep = dep;
        me.data.steps = steps;

        if (me.data.dep.Id) {
            me.statusChecker(true);
            ga('send', 'event', 'Deployment', 'edit');
        } else {
            copadoApp.isNewStepActive = true;
            copadoApp.isNewDestinationActive = true;
            ga('send', 'event', 'Deployment', 'new');
        }

        me.mirrorBlockHeight();
        me.bindActions();
        me.bindTabs();
        me.createStepRow();
        me.renderSteps();
        me.checkDeploymentStage();
        me.starded = true;
        me.unlock();

        me.sortable();

        // if deployment has a from org valid defined, preload the metadata for grid
        // TODO: add logic of readonly to avoid
        if (!rock.scalable) {
            var hasFromOrg = me.data.dep[copadoApp.ns + 'From_Org__c'];
            var disableValidation = hasFromOrg && me.data.dep[copadoApp.ns + 'From_Org__r'][copadoApp.ns + 'Disable_Validation__c'];
            var hasOauthSignature = hasFromOrg && me.data.dep[copadoApp.ns + 'From_Org__r'][copadoApp.ns + 'Oauth_Signature__c'];
            hasFromOrg && !disableValidation && hasOauthSignature && copadoGrid.preloadMetadata(me.data.dep[copadoApp.ns + 'From_Org__c']);
        }

        $copado(window).on('beforeunload', me.checkDirty);
    }
};

//TODO: move to external js in page
//
/**
 * [copadoStep description]
 * @type {Object}
 */
var copadoStep = {
    // methods
    // ************************

    /**
     * Validate everything is Ok before save
     * @return {[type]} [description]
     */
    validate: function () {
        var res = true;
        return res;
    },

    loading: function () {
        copadoGrid.loading();
        copadoStep.hideAll();
    },

    dirty: false,
    bound: false,

    bindInputs: function () {
        copadoStep.bound = true;
        $copado('input:not(.jqx-widget),textarea:not(.jqx-widget),select:not(.jqx-widget)', '[id$=pbStepDetailComponent]').on('change', function () {
            copadoStep.dirty = true;
        });
    },

    resetDOM: function (type) {
        if (type == 'MetaData') {
            $copado('[id=findReplaceArrayPlaceholder]').html('');
        }
    },

    init: function (orgId, stepType, stepId, stepObj, cb) {
        var me = copadoStep;
        if (!me.bound) {
            me.bindInputs();
        }
        me.loading();
        me.dirty = false;
        me.orgId = orgId;
        me.stepType = stepType;
        me.stepId = stepId;
        me.stepObj = stepObj;

        /*****************/
        //for support previous grid
        rock.orgId = orgId;
        rock.stepType = stepType;
        rock.stepId = stepId;
        /*****************/

        ga('send', 'event', 'Step', 'view', stepType);

        me.showBlockByType(stepType);

        me.resetDOM(stepType);

        copadoGrid.isActive = me.uiBlockByType[stepType].grid;
        me.uiBlockByType[stepType].grid && copadoGrid.init(false);
        if (me.uiBlockByType[stepType].qb) {
            if (me.stepObj[copadoApp.ns + 'dataJson__c']) {
                try {
                    dw.qb.preQuery = JSON.parse(me.stepObj[copadoApp.ns + 'dataJson__c']);
                } catch (e) {
                    console.error('wrong saved json dataJson__c', me.stepObj[copadoApp.ns + 'dataJson__c']);
                }
            } else {
                dw.qb.preQuery = false;
            }
            dw.qb.init(false, orgId);
        }

        //init cs step
        if (me.uiBlockByType[stepType].cs) {
            copadoCSStep.init(stepObj);
        }

        //Git metadata step
        if (me.uiBlockByType[stepType].git) {
            copadoGitMetadataStep.init(stepObj);
        }

        //Git promotion step
        if (me.uiBlockByType[stepType].gitpromotion) {
            copadoGitPromotionStep.init(stepObj);
        }

        //External CI step
        if (me.uiBlockByType[stepType].xci) {
            copadoExternalCIJobStep.init(stepObj);
        }

        //Data Template step
        if (me.uiBlockByType[stepType].dti) {
            setStepIdInDataStepValidationResultCtrl(stepObj.Id);
            copadoDataTemplateStep.init(stepObj);
        }

        //Automation step
        if (me.uiBlockByType[stepType].automation) {
            copadoAutomationStep.init(stepObj);
        }

        //Quick Actions step
        if (me.uiBlockByType[stepType].qa) {
            copadoQAStep.init(stepObj);
        }

        if (stepId) {
            me.loadSavedData(stepType);
        } else {
            //reset inputs on new
            me.setSavedData(stepType, false);
        }
        cb && cb();
    },

    loadSavedData: function (type) {
        var dataStep;
        //load saved by type
        if (type == 'Apex') {
            dataStep = dw.u.getSavedStepData(type, true);
        }

        if (type == 'Users') {
            dataStep = usersStep.savedData; //dw.u.getSavedStepData(type,true);
        }

        if (type == 'Custom Settings') {
            dataStep = dw.u.getSavedStepData(type, true);
        }

        if (type == 'Manual Task' || type == 'Quick Actions') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'Git MetaData') {
            dataStep = copadoStep.stepObj;
        }

        if (type == 'Git Promotion') {
            dataStep = copadoStep.stepObj;
        }

        if (type == 'MetaData') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }
        //UCU to be able load current test level for delete metadata test level picklist
        if (type == 'Delete MetaData') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'URL Callout') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'External CI') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'Data Template') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'Salesforce Flow') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'Function') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'Automation') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        if (type == 'Test') {
            dataStep = copadoStep.stepObj[copadoApp.ns + 'dataJson__c'];
        }

        copadoStep.setSavedData(type, dataStep);
    },

    /**
     * Parse the json saved and fill the inputs
     *
     * @param {string} data [description]
     */
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        $copado('[id=js-TestLevel]').val(data ? data.testLevel : 'NoTestRun');
        metadataReplace.findReplaceArray = data && data.replacements ? data.replacements : [];
        if (data && data.replacements) metadataReplace.findReplace.decode();
        metadataReplace.createChildRows(data.replacements);
    },

    setSavedData: function (type, dataStep) {
        if (type == 'Apex') {
            $copado('.js-apex').val(dataStep ? dataStep : '');
            return;
        }

        if (type == 'Users') {
            usersStep.initUI();
            usersStep.ui.$toSuffix.val(dataStep ? dataStep.toSuffix : '');
            usersStep.ui.$fromSuffix.val(dataStep ? dataStep.fromSuffix : '');
            usersStep.ui.$actives.attr('checked', dataStep ? dataStep.active : true);
            usersStep.ui.$useTerritories.attr('checked', dataStep ? dataStep.userTerritories : false);
        }

        if (type == 'Custom Settings') {
            copadoCSStep.setPrevData(dataStep);
        }

        if (type == 'Manual Task') {
            copadoMTStep.setPrevData(dataStep);
        }

        if (type == 'Delete MetaData') {
            data = dataStep;
            data = typeof data === 'string' ? JSON.parse(data) : data || false;
            $copado('[id=js-TestLevel]').val(data ? data.testLevel : 'NoTestRun');
        }

        if (type == 'Git MetaData') {
            copadoGitMetadataStep.setObjValues(dataStep);
            // NR: setPrevData expects dataJson__c, not the whole dataStep that the caller sends for this type.
            // Also, for some reason the value may be false when init() calls
            copadoGitMetadataStep.setPrevData(dataStep ? dataStep[copadoApp.ns + 'dataJson__c'] : false);
        }

        if (type == 'Git Promotion') {
            copadoGitPromotionStep.setObjValues(dataStep);
            // NR: setPrevData expects dataJson__c, not the whole dataStep that the caller sends for this type.
            // Also, for some reason the value may be false when init() calls
            copadoGitPromotionStep.setPrevData(dataStep ? dataStep[copadoApp.ns + 'dataJson__c'] : false);
        }

        if (type == 'MetaData') {
            copadoStep.setPrevData(dataStep);
        }

        if (type == 'Quick Actions') {
            copadoQAStep.setPrevData(dataStep);
        }

        if (type == 'URL Callout') {
            copadoCalloutStep.setPrevData(dataStep);
        }

        if (type == 'External CI') {
            copadoExternalCIJobStep.setPrevData(dataStep);
        }

        if (type == 'Data Template') {
            copadoDataTemplateStep.setPrevData(dataStep);
        }

        if (type == 'Salesforce Flow') {
            copadoSalesforceFlowStep.setPrevData(dataStep);
        }

        if (type == 'Function') {
            copadoFunctionStep.setPrevData(dataStep);
        }

        if (type == 'Automation') {
            copadoAutomationStep.setPrevData(dataStep);
        }

        if (type == 'Test') {
            copadoTestStep.setPrevData(dataStep);
        }
    },
    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        return JSON.stringify({
            testLevel: $copado('[id=js-TestLevel]').val(),
            replacements: metadataReplace.findReplaceArray
        });
    },
    mapAttachNameSource: {
        MetaData: 'MetaData',
        'Delete MetaData': 'MetaData',
        Translations: 'MetaData',
        'Full Profiles': 'MetaData',
        'Full Permission Sets': 'MetaData',
        //        'Custom Settings': 'MetaData', NR: duplicated key... is it data or metadata.
        Users: 'Users',
        'Custom Settings': 'Data',
        Data: 'Data',
        'Bulk Data': 'Data',
        Apex: false,
        'Manual Task': false,
        'Git MetaData': false,
        'Git Promotion': false,
        'Quick Actions': 'MetaData',
        'URL Callout': 'Callout',
        'Salesforce Flow': 'Flow'
    },

    uiBlockByType: {
        MetaData: {
            grid: 1,
            custom: 0,
            qb: 0
        },
        'Delete MetaData': {
            grid: 1,
            custom: 0,
            qb: 0
        },
        Translations: {
            grid: 1,
            custom: 0,
            qb: 0
        },
        'Full Profiles': {
            grid: 1,
            custom: 0,
            qb: 0
        },
        'Full Permission Sets': {
            grid: 1,
            custom: 0,
            qb: 0
        },
        Users: {
            grid: 1,
            custom: 'Users',
            qb: 0
        },
        'Custom Settings': {
            grid: 0,
            custom: 'CustomSettings',
            qb: 0,
            cs: 1
        },
        Data: {
            grid: 0,
            custom: 0,
            qb: 1
        },
        'Bulk Data': {
            grid: 0,
            custom: 0,
            qb: 1
        },
        Apex: {
            grid: 0,
            custom: 'Apex',
            qb: 0
        },
        'Manual Task': {
            grid: 0,
            custom: 'ManualTask',
            qb: 0
        },
        'Git MetaData': {
            grid: 0,
            custom: 'Git-MetaData',
            qb: 0,
            git: 1
        },
        'Git Promotion': {
            grid: 0,
            custom: 'Git-Promotion',
            qb: 0,
            gitpromotion: 1
        },
        'Rollback': {
            grid: 0
        },
        'Quick Actions': {
            grid: 0,
            custom: 'QuickActions',
            qb: 0,
            qa: 1
        },
        'URL Callout': {
            grid: 0,
            custom: 'UrlCallout',
            qb: 0,
            qa: 0,
            git: 0
        },
        'External CI': {
            grid: 0,
            custom: 'ExternalCI',
            qb: 0,
            git: 0,
            xci: 1
        },
        'Data Template': {
            grid: 0,
            custom: 'DataTemplate',
            qb: 0,
            git: 0,
            dti: 1
        },
        'Salesforce Flow': {
            grid: 0,
            custom: 'SalesforceFlow',
            qb: 0
        },
        Function: {
            grid: 0,
            custom: 'Function',
            qb: 0
        },
        Automation: {
            grid: 0,
            custom: 'Automation',
            qb: 0,
            git: 0,
            automation: 1
        },
        Test: {
            grid: 0,
            custom: 'Test',
            qb: 0
        }
    },

    showBlockByType: function (type) {
        var conf = copadoStep.uiBlockByType[type];
        if (conf.grid) $copado('[id$=js-stepBlock-Grid]').fadeIn();
        if (conf.qb) $copado('[id$=js-stepBlock-QB]').fadeIn();
        if (conf.custom) $copado('[id$=js-stepBlock-' + conf.custom + ']').fadeIn();
        //show container
        $copado('[id=mainblock]').show();
        $copado('[id$=pbStepDetailComponent]').show();

        if (type == 'MetaData' || type == 'Git MetaData' || type == 'Git Promotion') {
            $copado('[id=js-TestLevelContainer]').show();
            $copado('[id=js-FindReplaceContainer]').show();
        } else if (type == 'Delete MetaData') {
            //UCU - to be able to add test level for delete metadata option
            $copado('[id=js-TestLevelContainer]').show();
        } else if (type == 'Rollback') {
            $copado('[id=rollback-container]').show();
            $copado('[id=mainblock]').hide();
        }
    },

    hideAll: function () {
        $copado(
            '[id=js-FindReplaceContainer],[id=js-stepBlock-UrlCallout-ResumeUrl],[id$=js-stepBlock-UrlCallout],[id=js-TestLevelContainer],[id$=js-stepBlock-ManualTask],[id$=js-stepBlock-Apex],[id$=pbStepDetailComponent],[id$=rollback-container],[id$=js-stepBlock-Grid],[id$=js-stepBlock-Users],[id$=js-stepBlock-QB],[id$=js-stepBlock-CustomSettings],[id$=js-stepBlock-QuickActions],[id$=js-stepBlock-Git-MetaData],[id$=js-stepBlock-Git-Promotion],[Id$=js-stepBlock-ExternalCI],[Id$=js-stepBlock-DataTemplate],[Id$=js-stepBlock-SalesforceFlow],[Id$=js-stepBlock-Function],[Id$=js-stepBlock-Automation],[Id$=js-stepBlock-Test]'
        ).hide();
    },

    cancel: function () {
        //todo: define
        copadoStep.dirty = false;
        copadoApp.resetStepContainers();
        if (!copadoStep.stepId) copadoApp.removeNewStep();
    },
    redirectToRollbackWizard: function () {
        var namespace = copadoApp.ns != '' ? copadoApp.ns : '';
        var sfQquery = `SELECT Id,${namespace}Deployment_Last_Step__c FROM ${namespace}Deployment__c WHERE Id='${copadoApp.data.dep.Id}'`;
        var deploymentRecord = sforce.connection
            .query(sfQquery)
            .getArray('records');

        if (Array.isArray(deploymentRecord) && deploymentRecord.length) {
            let lastStep = deploymentRecord[0][`${namespace}Deployment_Last_Step__c`];
            return window.open(
                `/apex/${namespace}${lastStep}?Id=${copadoApp.data.dep.Id}`,
                '_blank'
            );
        }

    },
    saveCallback: function (s, fail) {
        copadoStep.dirty = false;
        copadoApp.enabledBtn('.js-saveStep', 'Save');
        if (!fail) {
            copadoApp.saveStepCallback(s);
        } else {
            copadoApp.saveStepFailure(s);
        }
        ga('send', 'event', 'Step', 'save - ' + (fail ? 'error' : 'ok'), copadoStep.stepType);
    },

    defaultHandler: {
        getStepListData: function () {
            return rock.getSelectedObj();
        },
        hasError: function (stepListData) {
            return !stepListData.length ? copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY : false;
        },
        saveList: function (step, list, cb) {
            dw.u.upsertAttach(step.Id, step[copadoApp.ns + 'Type__c'] || step.type, JSON.stringify(list));
            if (cb) cb();
        },
        hasToSaveList: true,
        hasSaveCallback: false,
        hasValidateStep: false
    },

    handlers: false,

    buildHandlers: function () {
        var me = copadoStep;

        //default
        me.handlers = {
            MetaData: $copado.extend({}, me.defaultHandler),
            'Delete MetaData': $copado.extend({}, me.defaultHandler),
            Translations: $copado.extend({}, me.defaultHandler),
            'Full Profiles': $copado.extend({}, me.defaultHandler),
            'Full Permission Sets': $copado.extend({}, me.defaultHandler),
            Users: $copado.extend({}, me.defaultHandler),
            'Custom Settings': $copado.extend({}, me.defaultHandler),
            Data: $copado.extend({}, me.defaultHandler),
            'Bulk Data': $copado.extend({}, me.defaultHandler),
            'Manual Task': $copado.extend({}, me.defaultHandler),
            Apex: $copado.extend({}, me.defaultHandler),
            'Git MetaData': $copado.extend({}, me.defaultHandler),
            'Git Promotion': $copado.extend({}, me.defaultHandler),
            'Rollback': $copado.extend({}, me.defaultHandler),
            'Quick Actions': $copado.extend({}, me.defaultHandler),
            'URL Callout': $copado.extend({}, me.defaultHandler),
            'External CI': $copado.extend({}, me.defaultHandler),
            'Data Template': $copado.extend({}, me.defaultHandler),
            'Salesforce Flow': $copado.extend({}, me.defaultHandler),
            Function: $copado.extend({}, me.defaultHandler),
            Automation: $copado.extend({}, me.defaultHandler),
            Test: $copado.extend({}, me.defaultHandler)
        };

        //Delete Metadata Handler - UCU to be able to save selected test level to step
        me.handlers['Delete MetaData'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = copadoStep.getObjToSave();
            return step;
        };
        me.handlers['Delete MetaData'].forceSaveBoth = true; //UCU to update new test level selection

        //Rollback Handler - UCU to be able to save selected test level to step
        me.handlers['Rollback'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'CheckOnly__c'] = copadoStep.getObjToSave();
            return step;
        };
        me.handlers['Rollback'].forceSaveBoth = true; //UCU to update new test level selection

        //Metadata Handler
        me.handlers['MetaData'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = copadoStep.getObjToSave();
            return step;
        };
        me.handlers['MetaData'].forceSaveBoth = true;

        //Git MetaData Handlers
        me.handlers['Git MetaData'].saveList = function (step, list, cb) {
            //update step data for commit and repository
            //copadoStep
            //update metadata selected attach
            dw.u.upsertAttach(copadoStep.stepId, 'MetaData', JSON.stringify(list));
            cb && cb();
        };
        me.handlers['Git MetaData'].updateStepFields = function (step, obj) {
            var cGMS = copadoGitMetadataStep;
            step[copadoApp.ns + 'Branch__c'] = cGMS.data.branch;
            step[copadoApp.ns + 'Commit_Id__c'] = cGMS.data.commitId;
            step[copadoApp.ns + 'Commit_Name__c'] = cGMS.data.name;
            step[copadoApp.ns + 'Git_Repository__c'] = cGMS.data.repositoryId;
            step[copadoApp.ns + 'Git_Repository__r'] = {
                Name: cGMS.data.repository
            };
            step[copadoApp.ns + 'dataJson__c'] = cGMS.getObjToSave();
            return step;
        };
        me.handlers['Git MetaData'].forceSaveBoth = true;

        //Git Promotion Handlers
        me.handlers['Git Promotion'].saveList = function (step, list, cb) {
            //update step data for commit and repository
            //copadoStep
            //update metadata selected attach
            dw.u.upsertAttach(copadoStep.stepId, 'MetaData', JSON.stringify(list));
            cb && cb();
        };
        me.handlers['Git Promotion'].updateStepFields = function (step, obj) {
            var cGMS = copadoGitMetadataStep;
            step[copadoApp.ns + 'Branch__c'] = cGMS.data.branch;
            step[copadoApp.ns + 'Commit_Id__c'] = cGMS.data.commitId;
            step[copadoApp.ns + 'Commit_Name__c'] = cGMS.data.name;
            step[copadoApp.ns + 'Git_Repository__c'] = cGMS.data.repositoryId;
            step[copadoApp.ns + 'Git_Repository__r'] = {
                Name: cGMS.data.repository
            };
            step[copadoApp.ns + 'dataJson__c'] = cGMS.getObjToSave();
            return step;
        };
        me.handlers['Git Promotion'].forceSaveBoth = true;

        //Apex Handlers
        me.handlers['Apex'].getStepListData = function () {
            return $copado('.js-apex').val();
        };
        me.handlers['Apex'].hasError = function (script) {
            return !script ? 'The Apex Script is Required.' : false;
        };
        me.handlers['Apex'].saveList = function (step, script, cb) {
            dw.u.upsertAttach(copadoStep.stepId, 'Apex', script);
            cb && cb();
        };

        //Users Handler
        me.handlers['Users'].getStepListData = function () {
            return usersStep.isValid();
        };
        me.handlers['Users'].hasError = function (obj) {
            return !obj.userIds.length ? copadoLabels.FIRST_SELECT_A_USER : false;
        };
        me.handlers['Users'].saveList = function (step, obj, cb) {
            dw.u.upsertAttach(copadoStep.stepId, 'Users', JSON.stringify(obj));
            cb && cb();
        };

        //Users Data
        me.handlers['Data'].getStepListData = function () {
            return dw.qb.getDataJson();
        };
        me.handlers['Data'].hasError = function (obj) {
            return !dw.qb.objectSelected || !dw.qb.queryTested || !dw.qb.externalId ? copadoLabels.MUST_BUILD_VALID_AND_TESTED_QUERY : false;
        };
        me.handlers['Data'].saveList = function (step, obj, cb) {
            console.error('saveList in DATA, this shoulnt be called');
        };

        me.handlers['Data'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };

        me.handlers['Data'].hasToSaveList = false;
        me.handlers['Bulk Data'] = me.handlers['Data'];

        me.handlers['Custom Settings'].getStepListData = function () {
            return copadoCSStep.getObjToSave();
        };
        me.handlers['Custom Settings'].hasError = function (obj) {
            return !obj.settings.length ? copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY : false;
        };
        me.handlers['Custom Settings'].saveList = function (step, obj, cb) {
            dw.u.upsertAttach(copadoStep.stepId, 'Custom Settings', JSON.stringify(obj));
            //copadoCSStep
            cb && cb();
        };

        me.handlers['Manual Task'].getStepListData = function () {
            return copadoMTStep.getObjToSave();
        };
        me.handlers['Manual Task'].hasError = function (obj) {
            return copadoMTStep.isValid() ? false : copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY;
        };
        me.handlers['Manual Task'].saveList = function (step, obj, cb) {
            //this should not be called
        };
        me.handlers['Manual Task'].hasToSaveList = false;
        me.handlers['Manual Task'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };

        me.handlers['Quick Actions'].getStepListData = function () {
            return copadoQAStep.getObjToSave();
        };
        me.handlers['Quick Actions'].hasError = function (obj) {
            return !obj.settings.length ? copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY : false;
        };
        me.handlers['Quick Actions'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = JSON.stringify(obj);
            return step;
        };
        me.handlers['Quick Actions'].saveList = function (step, obj, cb) {
            dw.u.upsertAttach(copadoStep.stepId, 'MetaData', JSON.stringify(obj.settings));
            //copadoCSStep
            cb && cb();
        };
        //this flag is forcing to save list and step
        me.handlers['Quick Actions'].forceSaveBoth = true;

        //URL Callout
        me.handlers['URL Callout'].getStepListData = function () {
            return copadoCalloutStep.getObjToSave();
        };
        me.handlers['URL Callout'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };
        me.handlers['URL Callout'].hasError = function (obj) {
            if (copadoCalloutStep.isValid() == false) {
                return copadoLabels.URL_CALLOUT_REQUIRED_FIELDS_MESSAGE;
            } else if (urlCallout.param.validate() == false) {
                return 'Please ensure that all URL parameters have a name and value.';
            } else if (urlCallout.header.validate() == false) {
                return 'Please ensure that all Header parameters have a name and value.';
            }
            return false;
        };
        me.handlers['URL Callout'].hasToSaveList = false;
        me.handlers['URL Callout'].saveList = function (step, obj, cb) {
            //this should not be called
        };
        //XCI Data
        me.handlers['External CI'].getStepListData = function () {
            return copadoExternalCIJobStep.getObjToSave();
        };
        me.handlers['External CI'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };
        me.handlers['External CI'].hasError = function (obj) {
            return copadoExternalCIJobStep.isValid() ? false : 'Please select an External CI Job';
        };
        me.handlers['External CI'].forceSaveBoth = true;

        // Data Template
        me.handlers['Data Template'].getStepListData = function () {
            return copadoDataTemplateStep.getObjToSave();
        };
        me.handlers['Data Template'].hasSaveCallback = true;
        me.handlers['Data Template'].saveCallback = function (step) {
            setStepIdInDataStepValidationResultCtrl(step.Id);
            return step;
        };
        me.handlers['Data Template'].hasValidateStep = true;
        me.handlers['Data Template'].validateStep = function (step) {
            validateDataTemplate(step.Id);
            return step;
        };
        me.handlers['Data Template'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'ParentId__c'] = copadoDataTemplateStep.getParentId();
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };
        me.handlers['Data Template'].hasError = function (obj) {
            return copadoDataTemplateStep.isValid() ? false : 'Please configure all required fields';
        };
        me.handlers['Data Template'].forceSaveBoth = true;

        //Salesforce Flow
        me.handlers['Salesforce Flow'].getStepListData = function () {
            return copadoSalesforceFlowStep.getObjToSave();
        };
        me.handlers['Salesforce Flow'].hasError = function (obj) {
            return copadoSalesforceFlowStep.isValid() ? false : copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY;
        };
        me.handlers['Salesforce Flow'].saveList = function (step, obj, cb) {
            //this should not be called
        };
        me.handlers['Salesforce Flow'].hasToSaveList = false;
        me.handlers['Salesforce Flow'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };

        //Function
        me.handlers['Function'].getStepListData = function () {
            return copadoFunctionStep.getObjToSave();
        };
        me.handlers['Function'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };
        me.handlers['Function'].hasError = function (obj) {
            return copadoFunctionStep.isValid() ? false : copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY;
        };
        me.handlers['Function'].forceSaveBoth = true;

        // Automation
        me.handlers['Automation'].getStepListData = function () {
            return copadoAutomationStep.getObjToSave();
        };
        me.handlers['Automation'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };
        me.handlers['Automation'].hasError = function (obj) {
            return copadoAutomationStep.isValid() ? false : copadoLabels.AUTOMATION_EMPTY_MESSAGE;
        };
        me.handlers['Automation'].forceSaveBoth = true;

        // Test
        me.handlers['Test'].getStepListData = function () {
            return copadoTestStep.getObjToSave();
        };
        me.handlers['Test'].updateStepFields = function (step, obj) {
            step[copadoApp.ns + 'dataJson__c'] = obj;
            return step;
        };
        me.handlers['Test'].hasError = function (obj) {
            return copadoTestStep.isValid() ? false : copadoLabels.SPECIFY_AT_LEAST_ONE_ITEM_TO_DEPLOY;
        };
        me.handlers['Test'].forceSaveBoth = true;
    },

    validateStep: function () {
        copadoApp.disabledBtn('.js-validateStep', 'Validating...');
        // define a callback for each step
        //timeout inorder to rerender part of the interface
        setTimeout(function () {
            var me = copadoStep;
            if (!me.handlers) {
                me.buildHandlers();
            }
            //get values to save step using JS
            var type = me.stepType;
            var stepHandler = me.handlers[type];
            if (!me.stepId) {
                copadoApp.showMessage('ERROR', 'Save the step before validating');
            }
            if (stepHandler.hasValidateStep) {
                stepHandler.validateStep(me.stepObj);
            }
            copadoApp.enabledBtn('.js-validateStep', 'Validate');
            return false;
        }, 10);
        return false;
    },
    //po
    save: function () {
        copadoApp.disabledBtn('.js-saveStep', 'Saving...');
        copadoApp.lock();

        //timeout inorder to rerender part of the interface
        setTimeout(function () {
            var me = copadoStep;
            if (!me.handlers) {
                me.buildHandlers();
            }
            var type;
            var rollback;
            var step;
            if (me.stepType == 'Rollback') {
                step = copadoApp.getStepDataFromUI(me.stepId);
                type = me.stepType,
                    stepHandler = me.handlers[type];
                rollback = true;
            }
            else {
                type = me.stepType,
                    stepHandler = me.handlers[type],
                    stepListData = stepHandler.getStepListData(),
                    error = stepHandler.hasError(stepListData);
            }
            if (!rollback && error) {
                copadoApp.showMessage('ERROR', error);
                copadoApp.enabledBtn('.js-saveStep', 'Save');
                copadoApp.unlock();
                ga('send', 'event', 'Step', 'saving - error ', copadoStep.stepType + ' - ' + error);
                return false;
            } else {
                if (!rollback) {
                    step = copadoApp.getStepDataFromUI(me.stepId);
                }
                var dirty = me.stepId ? copadoApp.updateLocalStep(me.stepId, step) : true;
                //if step has changed/new or has not savelist method.
                //that means that save values in same record step
                if (rollback || dirty || !stepHandler.hasToSaveList || stepHandler.forceSaveBoth) {
                    //we have to update the step obj using stepType info like DATA
                    if (!rollback && stepHandler.updateStepFields) {
                        step = stepHandler.updateStepFields(step, stepListData);
                    }

                    me.upsertSObjectStep(step, function (s, fail) {
                        if (fail) {
                            copadoStep.saveCallback(s, fail);
                        } else {
                            copadoStep.stepId = s.Id;
                            if (!rollback && stepHandler.hasToSaveList) {
                                stepHandler.saveList(s, stepListData, function () {
                                    copadoStep.saveCallback(s);
                                });
                            } else {
                                copadoStep.saveCallback(s);
                            }
                            if (stepHandler.hasSaveCallback) {
                                stepHandler.saveCallback(s);
                            }
                        }
                    });
                } else {
                    // step has not changed
                    // so save just the list
                    stepHandler.saveList(step, stepListData, function () {
                        copadoStep.saveCallback(step);
                    });
                }
            }
        }, 10);

        return false;
    },
    upsertSObjectStep: function (s, cb) {
        var step = new sforce.SObject(copadoApp.ns + 'Step__c');
        step.Name = s.name;
        step[copadoApp.ns + 'Type__c'] = s.type;
        step[copadoApp.ns + 'Deployment__c'] = s.deploymentId;
        step[copadoApp.ns + 'CheckOnly__c'] = s.check;
        step.Id = s.Id;
        var isNew = !s.Id;

        if (s[copadoApp.ns + 'dataJson__c']) {
            step[copadoApp.ns + 'dataJson__c'] = s[copadoApp.ns + 'dataJson__c'];
        }

        if (s[copadoApp.ns + 'Commit_Id__c']) {
            step[copadoApp.ns + 'Commit_Id__c'] = s[copadoApp.ns + 'Commit_Id__c'];
            step[copadoApp.ns + 'Commit_Name__c'] = s[copadoApp.ns + 'Commit_Name__c'];
            step[copadoApp.ns + 'Git_Repository__c'] = s[copadoApp.ns + 'Git_Repository__c'];
            step[copadoApp.ns + 'Branch__c'] = s[copadoApp.ns + 'Branch__c'];
        }

        if (s[copadoApp.ns + 'ParentId__c']) {
            step[copadoApp.ns + 'ParentId__c'] = s[copadoApp.ns + 'ParentId__c'];
        }
        // this will insert or update an step
        var result = sforce.connection.upsert('Id', [step]);

        if (result[0].getBoolean('success')) {
            step.Id = result[0].id;
            rock.stepId = step.Id;
            stepDataForOverrideFilter = step;
            $copado('[id$=editTemplateFilter]').show();
            cb && cb(step);
        } else {
            result[0].errors && copadoApp.showMessage('ERROR', 'Unexpected Error: ' + result[0].errors.message);
            cb && cb(step, true);
        }
    },

    /**
     * returns the heroku url to get remote data by step type.
     * @param  {[type]} type [description]
     * @return {[type]}      [description]
     */
    getRemoteUrlByType: function (type) {
        switch (type) {
            case 'Users':
                return rock.config.users_url;
                break;
            default:
                return rock.config.metadata_url;
                break;
        }
    }
};

var metadataGrid2,
    getMetadataGrid2 = function (type) {
        var conf = rock.config;
        conf.gridMode = copadoStep.stepType;
        conf.isScalable = rock.scalable && (copadoStep.stepType == 'MetaData' || copadoStep.stepType == 'Delete MetaData');
        conf.data = conf.data || {};
        conf.data.orgId = rock.orgId;
        conf.server = {};
        conf.server.metadataUrl = rock.config.metadata_url;
        conf.attachmentName = 'MetaData';
        console.info('buildGrid() start ', type, conf);

        if (metadataGrid2 && metadataGrid2.conf) {
            metadataGrid2.resetGrid(conf);
        } else {
            metadataGrid2 = new MetadataGrid2(conf);
        }

        metadataGrid2.loadSelectedMetaData = function (callbackFinished) {
            var selectedMetadata = dw.u.getSavedStepData(copadoStep.stepType);
            if (selectedMetadata === false) {
                console.debug('MetadataGrid2.loadSelectedMetaData(): no data for', copadoStep.stepType, 'rock.stepId=', rock.stepId);
                if (callbackFinished) callbackFinished();
                return;
            }
            setWithoutRebinding(this.selectedMetadata, selectedMetadata);
            console.debug('MetadataGrid2.loadSelectedMetaData()', this.selectedMetadata.length);
            if (callbackFinished) callbackFinished();
        };

        metadataGrid2.render(function () {
            console.info('MetadataGrid2:init grid rendered');
            // leave the datasource available for save
            rock.datasource = metadataGrid2.datasource;

            // NR: workaround, since deploymentstep.unlock() gets called, unlocking the screen almost right away
            window.setTimeout(function () {
                copadoApp.unlock();
                metadataGrid2.loadData(function () {
                    metadataGrid2.render();
                    copadoApp.unlock();

                    console.info('MetadataGrid2:init done', metadataGrid2.allMetaData_cachedDate, metadataGrid2.filterByType);
                    rock.createCacheDeleteButton(metadataGrid2.allMetaData_cachedDate, metadataGrid2.filterByType);
                    rock.showGetVlocityDependenciesButton();

                    // listen to any change in the selection
                    document.addEventListener('copadoMetadataGrid2Changed', function (e) {
                        copadoStep.dirty = true;
                    });

                    // listen to any change in the selection
                    document.addEventListener('copadoMetadataGrid2TypeChanged', function (e) {
                        console.info('MetadataGrid2:type changed', metadataGrid2.allMetaData_cachedDate, metadataGrid2.filterByType);
                        rock.createCacheDeleteButton(metadataGrid2.allMetaData_cachedDate, metadataGrid2.filterByType);
                        rock.showGetVlocityDependenciesButton();
                    });
                });
            }, 50);
        });

        console.info('buildGrid() end ', type);
        return metadataGrid2;
    };

/**
 * [copadoGrid complete controller for jqx-grid]
 * @type {Object}
 */
var copadoGrid = {
    //true is has previous selected items
    hasPreviousSelected: false,

    isActive: false,

    loading: function () {
        var loadingHTML = '<center><img src="/img/loading.gif" /> <i>' + copadoLabels.loading + '<span id="retry-label"></span></i></center>';
        $copado('#jqxgrid').html(loadingHTML);
    },

    setOrgFilteredLink: function (orgFiltered, orgId) {
        if (orgFiltered) {
            $copado('#link-org-filtered')
                .attr('href', '/' + orgId + '?_mtf=1')
                .show();
        } else {
            $copado('#link-org-filtered').hide();
        }
    },

    gridByType: {},

    startGrid: function (type, metaOrgData) {
        if (copadoGrid.gridByType[type]) {
            if (copadoStep.stepType == 'MetaData' || copadoStep.stepType == 'Delete MetaData') {
                rock.datasource = metadataGrid2.datasource;
                getMetadataGrid2(type);
                return;
            }
            copadoGrid.refreshGrid(type, metaOrgData);
        } else {
            copadoGrid.initGrid(type, metaOrgData);
        }
    },

    initGrid: function (type, metaOrgData) {
        copadoGrid.gridByType[type] = copadoGrid.buildGrid(type, metaOrgData);
    },

    addSelectAll: function ($grid) {
        var selectAll = function (sel) {
            $grid.jqxGrid('beginupdate');

            var list = $grid.jqxGrid('getrows');
            for (var i in list) {
                rock.datasource.localdata[list[i].dataindex || i].s = sel;
            }

            $grid.jqxGrid('endupdate');
            setTimeout(function () {
                $grid.jqxGrid('updatebounddata', 'cells');
            }, 222);

            copadoStep.dirty = true;
        },
            $unselectAll = $copado('<button id="js-jqxGrid-unselectAll">' + copadoLabels.unselect_all + '</button>').on('click', function (e) {
                e.preventDefault();
                selectAll(false);
            }),
            $selectAll = $copado('<button id="js-jqxGrid-selectAll">' + copadoLabels.select_all + '</button>').on('click', function (e) {
                e.preventDefault();
                selectAll(true);
            });

        $copado('.jqx-grid-pager > div', $grid)
            .prepend($unselectAll)
            .prepend($selectAll);
    },

    buildGrid: function (type, data) {
        if (copadoStep.stepType == 'MetaData' || copadoStep.stepType == 'Delete MetaData') {
            return getMetadataGrid2(type);
        }
        copadoGrid.isActive = true;

        try {
            //keep jquery pointer for performance query
            var $grid = $copado('<div>');

            $copado('#jqxgrid').empty();
            $copado('#jqxgrid').html($grid);
            
            var params = copadoGrid.getBasicParams();
            params.source = copadoGrid.makeSource(type, data);
            params.columns = copadoGrid.getColumnsByType(type);

            console.time('Grid created time');
            copadoGrid.$currentGrid = $grid.jqxGrid(params);
            var countries = [],
                profiles = [],
                types = [];
            console.debug('type==> ', type);
            console.debug('data==> ', data);

            for (var i = 0; i < data.length; i++) {
                if (!countries.includes(data[i].c) && data[i].c) {
                    countries.push(data[i].c);
                }
                if (!profiles.includes(data[i].p) && data[i].p) {
                    profiles.push(data[i].p);
                }
            }
            if (countries.length > 0) {
                copadoGrid.$currentGrid.jqxGrid('setcolumnproperty', 'c', 'filteritems', countries);
            }
            if(profiles.length > 0){
                copadoGrid.$currentGrid.jqxGrid('setcolumnproperty', 'p', 'filteritems', profiles);
            }

            if (type == 'Full Profiles') {
                types.push('Profile');
            } else if (type == 'Full Permission Sets') {
                types.push('PermissionSet');
            }
            if (types && types.length > 0) {
                setTimeout(function () {
                    copadoGrid.$currentGrid.jqxGrid('setcolumnproperty', 't', 'filteritems', types);
                }, 3000);
            }

            console.timeEnd('Grid created time');
        } catch (e) {
            console.error(e);
            throw e;
        }

        copadoGrid.addSelectAll($grid);

        return $grid;
    },

    getBasicParams: function () {
        return {
            width: '100%',
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: true,
            selectionmode: 'none',
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '500'],
            pagesize: 20,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            enablebrowserselection: true,
            ready: function () {
                copadoGrid.$currentGrid = $copado('#jqxgrid > div');
                //show selected if is edition
                copadoGrid.hasPreviousSelected && copadoGrid.addSelectedFilter(copadoGrid.$currentGrid);
            }
        };
    },

    addSelectedFilter: function ($grid) {
        try {
            var filtergroup2 = new $copado.jqx.filter();
            var filter2 = filtergroup2.createfilter('booleanfilter', true, 'EQUAL');
            filtergroup2.addfilter(1, filter2);
            $grid.jqxGrid('clearfilters');
            $grid.jqxGrid('addfilter', 's', filtergroup2);
            $grid.jqxGrid('applyfilters');
        } catch (e) {
            console.error('addfilter', e);
        }
    },

    getColumnsByType: function (type) {
        if (type == 'Users') {
            var columns = [
                {
                    text: copadoLabels.selected,
                    columntype: 'checkbox',
                    filtertype: 'bool',
                    datafield: 's',
                    width: 60
                },
                {
                    text: copadoLabels.name,
                    filtertype: 'input',
                    columntype: 'textbox',
                    editable: false,
                    datafield: 'n'
                },
                {
                    text: copadoLabels.country,
                    datafield: 'c',
                    filtertype: 'checkedlist',
                    editable: false,
                    columntype: 'textbox',
                    width: 70
                },
                {
                    text: copadoLabels.profile,
                    datafield: 'p',
                    filtertype: 'checkedlist',
                    editable: false,
                    columntype: 'textbox'
                },
                {
                    text: copadoLabels.role,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'r'
                },
                {
                    text: copadoLabels.username,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'u'
                },
                {
                    text: copadoLabels.isactive,
                    datafield: 'a',
                    filtertype: 'bool',
                    editable: false,
                    columntype: 'checkbox',
                    width: 70
                }
            ];

            if (usersStep.hasTerritories) {
                columns.push({
                    text: 'Territory',
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 't'
                });
            }
            return columns;
        } else {
            return [
                {
                    text: copadoLabels.selected,
                    columntype: 'checkbox',
                    filtertype: 'bool',
                    datafield: 's',
                    width: 60
                },
                {
                    text: copadoLabels.name,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'n',
                    width: '40%'
                },
                {
                    text: copadoLabels.type,
                    datafield: 't',
                    filtertype: 'checkedlist',
                    editable: false,
                    columntype: 'textbox'
                },
                {
                    text: copadoLabels.LastModifiedById,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'b',
                    width: 220
                },
                {
                    text: copadoLabels.LastModifiedDate,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'd',
                    width: 120
                }
            ];
        }
    },

    refreshGrid: function (type, data) {
        //TODO: hide during rebuild $copado("#jqxgrid").hide();
        copadoGrid.loading();

        var $grid = copadoGrid.gridByType[type];
        $copado('#jqxgrid')
            .empty()
            .html($grid);
        //get data source for data
        //get columns by config
        //preselect data
        var params = copadoGrid.getBasicParams();
        params.source = copadoGrid.makeSource(type, data);
        params.columns = copadoGrid.getColumnsByType(type);
        console.time('Grid refresh time');
        copadoGrid.$currentGrid = $grid.jqxGrid(params);
        console.timeEnd('Grid refresh time');
        copadoGrid.addSelectAll($grid);
    },

    filterMap: {
        'Full Profiles': 'Profile',
        Translations: 'Translations',
        'Full Permission Sets': 'PermissionSet',
        'Custom Settings': 'CustomObject'
    },

    makeSource: function (type, data) {
        //data = [{"t":"InstalledPackage","n":"sf_chttr_apps","b":"Proceso automatizado","d":"2014-10-21"}];
        //normalize data
        var len = data.length;
        var hasFilter = copadoGrid.filterMap[type];

        if (hasFilter) {
            var newData = [];
        }

        while (len--) {
            data[len].s = data[len].s || false;
            data[len].b = data[len].b || '';
            data[len].d = data[len].d || '';
            //if filtered by type remove other types.
            if (hasFilter && data[len].t == hasFilter) {
                newData.unshift(data[len]);
            }

            //for user type
            if (type == 'Users') {
                data[len].c = data[len].c || '--';
                if (data[len].t) {
                    usersStep.hasTerritories = 1;
                }
            }
        }
        if (hasFilter) {
            data = newData;
        }
        var source = {
            localdata: data,
            datafields:
                type != 'Users'
                    ? [
                        {
                            name: 's',
                            type: 'bool'
                        },
                        {
                            name: 't',
                            type: 'string'
                        },
                        {
                            name: 'n',
                            type: 'string'
                        },
                        {
                            name: 'b',
                            type: 'string'
                        },
                        {
                            name: 'd',
                            type: 'string'
                        }
                    ]
                    : [
                        {
                            name: 's',
                            type: 'bool'
                        },
                        {
                            name: 'u',
                            type: 'string'
                        },
                        {
                            name: 't',
                            type: 'string'
                        },
                        {
                            name: 'e',
                            type: 'string'
                        },
                        {
                            name: 'r',
                            type: 'string'
                        },
                        {
                            name: 'c',
                            type: 'string'
                        },
                        {
                            name: 'p',
                            type: 'string'
                        },
                        {
                            name: 'n',
                            type: 'string'
                        },
                        {
                            name: 'i',
                            type: 'string'
                        },
                        {
                            name: 'a',
                            type: 'bool'
                        }
                    ],
            datatype: 'array',
            updaterow: function (rowid, rowdata, commit) {
                commit(true);
                data[rowid] = rowdata;
                copadoStep.dirty = true;
            }
        };
        //TODO: replace me by copadoGrid.activeDS
        rock.datasource = source;
        //adapter wrapper
        return new $copado.jqx.dataAdapter(source);
    },

    /**
     * Local cache of metadata get from attach
     * @type {Boolean}
     */
    metaDataCache: false,
    metaDataDateCache: false,

    usersDataCache: false,
    usersDataDateCache: false,

    initCallBack: function (metaOrgData, cachedDate) {
        if (metaOrgData === undefined) {
            console.warn('Deployment.Metadata initCallBack(): no metaOrgData? correcting');
            metaOrgData = [];
        }
        var dataStep = dw.u.getSavedStepData(copadoStep.stepType);

        if (dataStep) {
            if (copadoStep.stepType == 'Delete MetaData') {
                metaOrgData = dataStep;
            } else {
                if (copadoStep.stepType == 'Users') {
                    usersStep.savedData = dataStep;
                    metaOrgData = usersStep.mergeSavedMeta(metaOrgData, dataStep);
                } else {
                    metaOrgData = rock.mergeSavedMeta(metaOrgData, dataStep);
                }
            }
        } else {
            if (copadoStep.stepType == 'Users') {
                usersStep.savedData = false;
            }
        }
        rock.createCacheDeleteButton(cachedDate);
        rock.showGetVlocityDependenciesButton();
        copadoGrid.setOrgFilteredLink(copadoApp.orgFiltered, copadoStep.orgId);
        copadoGrid.startGrid(copadoStep.stepType, metaOrgData);
    },

    resetCache: function (data) {
        var len = data.length;
        while (len--) {
            data[len].s = false;
        }
    },

    preloadMetadata: function (orgId) {
        setTimeout(function () {
            dw.u.getCachedRemote({
                url: copadoStep.getRemoteUrlByType('MetaData'),
                name: copadoStep.mapAttachNameSource['MetaData'],
                parentId: orgId,
                force: false,
                success: function (metaOrgData, cachedDate) {
                    copadoGrid.metaDataCache = metaOrgData;
                    copadoGrid.metaDataDateCache = cachedDate;
                },
                error: function (r) {
                    console.log('Error: ', r);
                }
            });
        }, 1000);
    },

    init: function (force) {
        console.time('get meta data');
        //reset
        copadoGrid.hasPreviousSelected = false;

        if (copadoStep.stepType == 'MetaData' || copadoStep.stepType == 'Delete MetaData') {
            $copado('#jqxgrid').hide();
            $copado('#metadataGrid2').show();
        } else {
            $copado('#jqxgrid').show();
            $copado('#metadataGrid2').hide();
        }

        //check browser cache
        if (copadoStep.stepType == 'Users') {
            var data = copadoGrid.usersDataCache;
            var date = copadoGrid.usersDataDateCache;
        } else {
            var data = copadoGrid.metaDataCache;
            var date = copadoGrid.metaDataDateCache;
        }

        if (!force && data) {
            copadoGrid.resetCache(data);
            copadoGrid.initCallBack(data, date);
        } else if (copadoStep.stepType === 'Delete MetaData') {
            // NR: this else if is a no-op, since the delete metadata never has a url.
            //copadoGrid.initCallBack([], {});
            var conf = rock.config;
            conf.gridMode = copadoStep.stepType;
            conf.isScalable = rock.scalable && copadoStep.stepType == 'Delete MetaData';
            conf.data = conf.data || {};
            conf.data.orgId = rock.orgId;
            conf.server = {};
            conf.server.metadataUrl = rock.config.metadata_url;
            conf.attachmentName = 'MetaData';

            if (metadataGrid2 && metadataGrid2.conf) {
                metadataGrid2.resetGrid(conf);
            } else {
                metadataGrid2 = new MetadataGrid2(conf);
            }
            metadataGrid2.loadSelectedMetaData = function (callbackFinished) {
                var selectedMetadata = dw.u.getSavedStepData(copadoStep.stepType);
                if (selectedMetadata === false) {
                    console.debug('MetadataGrid2.loadSelectedMetaData(): no data for', copadoStep.stepType, 'rock.stepId=', rock.stepId);
                    if (callbackFinished) callbackFinished();
                    return;
                }
                setWithoutRebinding(this.selectedMetadata, selectedMetadata);
                console.debug('MetadataGrid2.loadSelectedMetaData()', this.selectedMetadata.length);
                if (callbackFinished) callbackFinished();
            };
            metadataGrid2._setGridData(dw.u.getSavedStepData('Delete MetaData'));
            metadataGrid2.render();
            metadataGrid2.refreshDeletedMetadataCache(function (cachedDate) {
                metadataGrid2.eltTabs.jqxTabs('select', 0);
                rock.createCacheDeleteButton(cachedDate);
                rock.showGetVlocityDependenciesButton();
            });
        } else {
            if (copadoStep.stepType == 'MetaData' || copadoStep.stepType == 'Delete MetaData') {
                if (metadataGrid2) {
                    metadataGrid2.refreshCache(function () {
                        copadoGrid.initCallBack([], {});
                    });
                } else {
                    copadoGrid.initCallBack([], {});
                }
                return;
            }

            //start component
            dw.u.getCachedRemote({
                url: copadoStep.getRemoteUrlByType(copadoStep.stepType),
                name: copadoStep.mapAttachNameSource[copadoStep.stepType],
                parentId: copadoStep.orgId,
                force: force,
                success: function (metaOrgData, cachedDate) {
                    if (copadoStep.stepType == 'Users') {
                        copadoGrid.usersDataCache = metaOrgData;
                        copadoGrid.usersDataDateCache = cachedDate;
                    } else {
                        copadoGrid.metaDataCache = metaOrgData;
                        copadoGrid.metaDataDateCache = cachedDate;
                    }
                    copadoGrid.initCallBack(metaOrgData, cachedDate);
                },
                error: function (r) {
                    console.log('Error: ', r);
                }
            });
        }
    }
};

/**************************************************************************************/
//      GIT METADATA STEP
/**************************************************************************************/
var copadoGitMetadataStep = {
    ui: {},
    data: {
        commitId: '',
        repository: '',
        branch: '',
        repositoryId: '',
        name: ''
    },
    stepObj: false,
    init: function (stepObj) {
        copadoApp.lock();

        console.info('copadoGitMetadataStep init', stepObj);
        var me = copadoGitMetadataStep,
            ns = copadoApp.ns;
        me.stepObj = stepObj;

        //init ui
        me.ui.$gitRepository = $copado('.js-gitRepository').html('');
        me.ui.$gitBranch = $copado('.js-gitBranch').html('');
        me.ui.$gitName = $copado('.js-gitName').html('');
        me.ui.$gitCommit = $copado('.js-gitCommit').val('');
        me.ui.$gitCommitLookup = $copado('.js-gitCommit-lookup');
        me.ui.$testLevel = $copado('[id=js-TestLevel]');

        me.setPrevData(stepObj[copadoApp.ns + 'dataJson__c']);

        //bind
        me.bindAction();

        if (!me.stepObj.Id) {
            //clean form and grid
            me.data.repository = '';
            me.data.branch = '';
            me.data.commitId = '';
            me.data.repositoryId = '';
            me.data.name = '';
            me.data.testLevel = '';
            $copado('#jqxgrid-git-metadata').html('');
            me.data.metadata = [];
            return;
        }

        //set data
        me.setData(
            me.stepObj[ns + 'Git_Repository__r'] ? me.stepObj[ns + 'Git_Repository__r'].Name : '',
            me.stepObj[ns + 'Branch__c'],
            me.stepObj[ns + 'Commit_Id__c'],
            me.stepObj[ns + 'Git_Repository__c'],
            me.stepObj[ns + 'Commit_Name__c']
        );

        //check or ask for metadata
        me.data.commitId && me.getMetadata(me.createGrid);
    },

    /**
     * Create the grid
     * @param  {[type]} res  data to show
     * @param  {[type]} prev prev selected items
     * @return {[type]}      [description]
     */
    createGrid: function (res, prev) {
        copadoApp.lock();
        var me = copadoGitMetadataStep;

        //reset flag
        copadoGrid.hasPreviousSelected = false;
        //merge previous selected
        me.data.metadata = rock.mergeSavedMeta(res, prev);

        //fix undefined selected field
        var len = me.data.metadata.length;
        while (len--) {
            var e = me.data.metadata[len];
            e.s = e.s || false;
        }
        //create datasource
        var source2 = {
            localdata: res,
            datafields: [
                {
                    name: 's',
                    type: 'bool'
                },
                {
                    name: 'cmm',
                    type: 'string'
                },
                {
                    name: 'n',
                    type: 'string'
                },
                {
                    name: 't',
                    type: 'string'
                },
                {
                    name: 'vk',
                    type: 'string'
                }
            ],
            datatype: 'array',
            updaterow: function (rowid, rowdata, commit) {
                commit(true);
                rock.datasource.localdata[rowid] = rowdata;
                copadoStep.dirty = true;
            }
        };

        //adapter wrapper
        dataAdapter2 = new $copado.jqx.dataAdapter(source2);

        //keep jquery pointer for performance query
        $grid2 = $copado('<div>');

        $copado('#jqxgrid-git-metadata').html($grid2);

        //keep generic data source for later save and validate functions
        rock.datasource = source2;

        /**
         * Helper to colored status cell by status
         * @param  {[type]} row         [description]
         * @param  {[type]} column      [description]
         * @param  {[type]} value       [description]
         * @param  {[type]} defaultHtml [description]
         * @return {[type]}             [description]
         */
        var cellsrenderer = function (row, column, value, defaultHtml) {
            var color = false;
            if (value == 'deleted') {
                color = '#FFC6C6';
            } else if (value == 'updated') {
                color = '#FFFFE3';
            } else if (value == 'created') {
                color = '#CCFFCC';
            }

            if (color) {
                var element = $copado(defaultHtml);
                element.css({
                    'background-color': color,
                    'text-align': 'center'
                });
                return element[0].outerHTML;
            }
            return defaultHtml;
        };
        $grid2.jqxGrid({
            width: '100%',
            source: dataAdapter2,
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: true,
            selectionmode: 'none',
            enablebrowserselection: true,
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '200'],
            pagesize: 50,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            columns: [
                {
                    text: copadoLabels.selected,
                    columntype: 'checkbox',
                    filtertype: 'bool',
                    datafield: 's',
                    width: 60
                },
                {
                    text: 'Commit Info.',
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    datafield: 'cmm',
                    width: 120,
                    editable: false,
                    cellsrenderer: cellsrenderer
                },
                {
                    text: copadoLabels.name,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'n'
                },
                {
                    text: copadoLabels.type,
                    filtertype: 'checkedlist',
                    editable: false,
                    datafield: 't'
                }
            ],
            ready: function () {
                //show selected if is edition
                copadoGrid.hasPreviousSelected && copadoGrid.addSelectedFilter($grid2);
                copadoApp.unlock();
            }
        });
        copadoGrid.addSelectAll($grid2);
    },

    /**
     * Get remote metadata from commit
     * Save it in attachment related to repository
     * @param  {Function} cb [description]
     * @return {[type]}      [description]
     */
    getMetadata: function (cb) {
        copadoApp.lock();

        var me = copadoGitMetadataStep;
        //get from Attachment
        var att = dw.u.getDecodedAttach(me.data.repositoryId, me.data.commitId + '.json');
        if (att) {
            //parse and cb
            var att = att ? JSON.parse(att.Body) : [];
            //get saved data
            if (me.stepObj.Id) {
                var prev = dw.u.getDecodedAttach(me.stepObj.Id, 'MetaData');
                if (prev) {
                    me.data.prevAttId = prev.Id;
                }
            }

            prev = prev ? JSON.parse(prev.Body) : [];

            setTimeout(function () {
                cb && cb(att, prev);
            }, 33);
        } else {
            copadoApp.parentId = me.data.repositoryId;
            copadoApp.startStatusManager();

            statusManager.successFunction = function () {
                me.getMetadata(me.createGrid);
            };
            statusManager.initialise();

            //remote
            var uri = rock.config.git_metadata_url
                .replace('{branch}', me.data.branch)
                .replace('{repositoryId}', me.data.repositoryId)
                .replace('{commitId}', me.data.commitId);
            statusManager.parentId = me.data.repositoryId;
            statusManager.startProcess(function () {
                utilsV2.onSuccessCB = function (res) {
                    var obj = $copado.parseJSON(res);
                    if (obj.copadoJobId) {
                        statusManager.copadoJobId = obj.copadoJobId;
                        statusManager.startStatusChecker();
                    }
                };
                utilsV2.getRemote(uri);
            });
        }
    },

    /**
     * bind ui actions
     * @return {[type]} [description]
     */
    bindAction: function () {
        var me = copadoGitMetadataStep;

        if (me._bound) return;
        me._bound = true;

        me.ui.$gitCommitLookup.on('click', me.openLookupPopup);
    },

    /**
     * Sel local data
     * @param {[type]} repository   [description]
     * @param {[type]} branch       [description]
     * @param {[type]} commitId     [description]
     * @param {[type]} repositoryId [description]
     */
    setData: function (repository, branch, commitId, repositoryId, name) {
        var me = copadoGitMetadataStep;

        me.data.repository = repository;
        me.data.branch = branch;
        me.data.commitId = commitId;
        me.data.repositoryId = repositoryId;
        me.data.name = name;
    },

    /**
     * Parse the json saved and fill the inputs
     *
     * @param {string} data [description]
     */
    setPrevData: function (data) {
        console.info('DATA: ', data);
        data = typeof data === 'string' ? JSON.parse(data) : data || false;
        $copado('[id=findReplaceArrayPlaceholder]').html('');
        metadataReplace.findReplaceArray = [];
        $copado('[id=js-TestLevel]').val(data ? data.testLevel : 'NoTestRun');
        metadataReplace.findReplaceArray = data && data.replacements ? data.replacements : [];
        if (data && data.replacements) metadataReplace.findReplace.decode();
        metadataReplace.createChildRows(data.replacements);
    },

    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        return JSON.stringify({
            testLevel: $copado('[id=js-TestLevel]').val(),
            replacements: metadataReplace.findReplaceArray
        });
    },

    /**
     * This is called from the commit lookup
     * @param  {[type]} obj the object result
     * @return {[type]}     [description]
     */
    lookupCB: function (obj) {
        var me = copadoGitMetadataStep;

        //if diff commit
        //
        if (obj.commitId == me.data.commitId) return;

        copadoApp.lock();

        //update obj + ui
        me.setData(obj.repository, obj.branch, obj.commitId, obj.repositoryId, obj.name);

        var ns = copadoApp.ns;

        me.stepObj[ns + 'Branch__c'] = obj.branch;
        me.stepObj[ns + 'Commit_Id__c'] = obj.commitId;
        me.stepObj[ns + 'Git_Repository__c'] = obj.repositoryId;
        me.stepObj[ns + 'Commit_Name__c'] = obj.name;
        me.stepObj[ns + 'Git_Repository__r'] = {
            Name: obj.repository
        };

        //ui
        me.setObjValues();

        //set dirty
        copadoStep.dirty = true;

        //clean grid
        me.data.prevAttId && sforce.connection.deleteIds([me.data.prevAttId]);
        $copado('#jqxgrid-git-metadata').html('');
        me.getMetadata(me.createGrid);
    },

    /**
     * Call Commit custom lookup
     * @return {[type]} [description]
     */
    openLookupPopup: function () {
        var me = copadoGitMetadataStep,
            ns = copadoApp.ns;
        var _namespace = copadoApp.ns != '' ? copadoApp.ns + '__' : '';

        //prepare url parameters
        var url = '/apex/' + _namespace + 'GitCommitLookup?from=Deployment&callback=copadoGitMetadataStep.lookupCB';
        url += '&repository=' + me.data.repository;
        url += '&branch=' + me.data.branch;
        url += '&commitId=' + me.data.commitId;

        var popupParams = 'width=1024,height=530,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no';
        window.open(url, 'lookup', popupParams, true);
    },

    /**
     * Set UI data
     * @param {[type]} obj [description]
     */
    setObjValues: function (obj) {
        var me = copadoGitMetadataStep,
            ns = copadoApp.ns;

        me.ui.$gitRepository.html(me.data.repository);
        me.ui.$gitBranch.html(me.data.branch);
        me.ui.$gitCommit.val(me.data.commitId);
        me.ui.$gitName.html(me.data.name);
    }
};

/**************************************************************************************/
//      USER STEP
/**************************************************************************************/
var usersStep = {
    ui: {},
    initUI: function () {
        usersStep.ui = {
            $fromSuffix: $copado('.js-fromSuffix'),
            $toSuffix: $copado('.js-toSuffix'),
            $actives: $copado('.js-actives'),
            $useTerritories: $copado('.js-useTerritories')
        };

        if (usersStep.hasTerritories) {
            usersStep.ui.$useTerritories
                .show()
                .parent()
                .prev('th')
                .show();
        } else {
            usersStep.ui.$useTerritories
                .hide()
                .parent()
                .prev('th')
                .hide();
        }
    },

    hasTerritories: false,

    getUserIds: function () {
        var data = rock.datasource.localdata,
            len = data.length,
            res = [];

        while (len--) {
            data[len].s && res.push(data[len].i);
        }
        return res;
    },

    normalizeSuffix: function (val) {
        return val.replace(' ', '').substring(0, 10);
    },

    isValid: function () {
        this.initUI();

        var me = this,
            //makes object
            obj = {
                userIds: me.getUserIds(),
                fromSuffix: me.normalizeSuffix(me.ui.$fromSuffix.val()),
                toSuffix: me.normalizeSuffix(me.ui.$toSuffix.val()),
                active: me.ui.$actives.is(':checked'),
                userTerritories: me.ui.$useTerritories.is(':checked')
            };

        return obj;
    },

    mergeSavedMeta: function (res, dataStep) {
        var len = res.length;
        copadoGrid.hasPreviousSelected = len;
        while (len--) {
            if (dataStep.userIds.indexOf(res[len].i) !== -1) {
                res[len].s = true;
            }
        }
        return res;
    }
};

// *********************************
//namespace
var rock = rock || {};
rock.showVlocityButton;
rock.stepType = copadoStep.stepType;
rock.stepId = copadoStep.stepId;

rock.createCacheDeleteButton = function (date, metadataType) {
    try {
        if (!date) {
            $copado('[id*=removeCacheContainer]').hide();
        } else {
            var $btn = $copado('[id$=removeCache]');
            rock.createCacheDeleteButton_message = rock.createCacheDeleteButton_message || $btn.html();
            metadataType = metadataType ? ' for ' + metadataType : '';
            $btn.html(rock.createCacheDeleteButton_message.replace('__DATE__', date).replace('__METATYPE__', metadataType)).show();
            $copado('#removeCacheContainer').show();
        }
    } catch (e) { }
};

rock.removeCached = function () {
    $copado('[id*=removeCacheContainer]').hide();

    if (copadoStep.stepType == 'Users') {
        // remove local cached data
        copadoGrid.metaDataCache = false;
        copadoGrid.metaDataDateCache = false;
    } else {
        copadoGrid.usersDataCache = false;
        copadoGrid.usersDataDateCache = false;
    }

    //hide
    copadoGrid.loading();

    //reload
    copadoGrid.init(true);

    return false;
};

rock.showGetVlocityDependenciesButton = function () {
    if (rock.showVlocityButton == 'true') $copado('[id$=vlocityMetadata]').show();
};

rock.getSelectedObj = function () {
    var data = rock.datasource.localdata,
        len = data.length;

    rock.selectedNames = [];

    while (len--) {
        data[len].s &&
            rock.selectedNames.push({
                t: data[len].t,
                n: data[len].n,
                vk: data[len].vk,
                s: true
            });
    }

    return rock.selectedNames;
};

//selected "Names"
rock.selectedNames = rock.selectedNames || [];

rock.mergeSavedMeta = function (metaOrgData, dataStep) {
    if (!metaOrgData.length) {
        console.warn('No metadata loaded, so no need to merge anything');
        return [];
    }

    var len = dataStep.length;

    copadoGrid.hasPreviousSelected = len;

    while (len--) {
        if (typeof dataStep[len] !== 'object') {
            delete dataStep[len];
        } else {
            dataStep[len].s = true;
        }
    }

    //merge org and saved step data
    function getIndexByNT(arr, n, t) {
        var initialIndex = 0; // todo improve index chache >> this.initialIndex || 0,
        len = arr.length;

        for (initialIndex; initialIndex < len; initialIndex++) {
            var el = arr[initialIndex];
            // NR: added .toLowerCase() to make a case insensitve name comparison
            if (el.n.toLowerCase() === n.toLowerCase() && el.t === t) {
                this.initialIndex = initialIndex;
                return initialIndex;
            }
        }
        return -1;
    }

    var len2 = dataStep.length;
    for (var i = 0; i < len2; i++) {
        var el = dataStep[i],
            index = getIndexByNT(metaOrgData, el.n, el.t);
        if (index > -1) {
            metaOrgData[index].s = true;
            //rock.selectedNames.push(data[index]);
        } else {
            console.log('Not found:', el);
            if (typeof window._errNotFoundShown == 'undefined') {
                window._errNotFoundShown = true;
                copadoApp.showMessage('WARNING', copadoLabels.missing_element_msg + el.t + ' - ' + el.n);
            }
        }
    }
    return metaOrgData;
};

/*************** from wizard ******************/
//save data
//TODO: move to external file and improve this code
//helper
rock.el = function (id) {
    return document.getElementById(id);
};

rock.goto_stepsList = function () {
    rock.stepId = '';
};

//get query from query-builder and make the json object
rock.getDataJson = function () {
    var obj = {
        o: dw.qb.objectSelected,
        q: dw.qb.query,
        f: dw.qb.externalId,
        rb: dw.qb.getObjectToRebuild()
    };
    return JSON.stringify(obj); //$copado(rock.el(rock.stepUI.data)).val();
};

rock.upsertStep = function (cb) {
    var step = new sforce.SObject(copadoApp.ns + 'Step__c');

    //get field values from DOM inputs
    step.Id = rock.stepId;

    var type = step[copadoApp.ns + 'Type__c'];
    if (type == 'Data' || type == 'Bulk Data' || type == 'Quick Actions') {
        step[copadoApp.ns + 'dataJson__c'] = rock.getDataJson();
    }

    // this will insert or update an step
    var result = sforce.connection.upsert('Id', [step]);

    if (result[0].getBoolean('success')) {
        step.Id = result[0].id;
        rock.stepId = step.Id;
        cb && cb(step);
    } else {
        result[0].errors && copadoApp.showMessage('ERROR', 'Unexpected Error: ' + result[0].errors.message);
    }
};

rock.remoteSaveMeta = function (items, type) {
    dw.u.upsertAttach(rock.stepId, type, JSON.stringify(items));
};

/**************************************************************************************/
//      MANUAL TASK STEP
/**************************************************************************************/
var copadoMTStep = {
    doStopStatusChecker: function (job) {
        //For manual tasks we also stop the status checker.
        return true;
    },
    /**
     * Parse the json saved and fill the inputs
     *
     * @param {string} data [description]
     */
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        $copado('[id=jsTaskOwner_lkid]').val(data ? data.Task_Owner : null);

        if (data) {
            sforce.connection.query("SELECT id, FirstName, LastName FROM User WHERE Id = '" + data.Task_Owner + "' LIMIT 1", {
                onSuccess: function (result) {
                    var records = result.getArray('records');

                    if (records.length == 1) {
                        var firstname = records[0].FirstName;
                        var lastname = records[0].LastName;
                        $copado('[id=jsTaskOwner_lkold]').val(firstname + ' ' + lastname);
                        $copado('[id=jsTaskOwner]').val(firstname + ' ' + lastname);
                    }
                },
                onFailure: function (error) {
                    console.error('An error has occurred ' + error);
                }
            });
        } else {
            $copado('[id$=jsTaskOwner]').val(null);
        }

        //fill or reset if field is empty
        $copado('[id$=jsTaskDesc]').val(data ? data.Task_Description : '');
        $copado('[id$=jsPerformInSource]').prop('checked', data ? data.Perform_in_Source_Org : false);
        $copado('[id$=jsPerformInDestinations]').prop('checked', data ? data.Perform_in_Destination_Orgs : true);
        $copado('[id$=jsNotifyTaskOwner]').val(data ? data.Notify_Task_Owner : 'None');
    },

    /**
     * validation of Manual task Field
     * Check if at least one org was checked
     *
     * @return {Boolean} [description]
     */
    isValid: function () {
        return $copado('[id$=jsPerformInDestinations]').is(':checked') || $copado('[id$=jsPerformInSource]').is(':checked');
    },

    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        return JSON.stringify({
            Perform_in_Destination_Orgs: $copado('[id$=jsPerformInDestinations]').is(':checked'),
            Perform_in_Source_Org: $copado('[id$=jsPerformInSource]').is(':checked'),
            Task_Description: $copado('[id$=jsTaskDesc]').val(),
            Task_Owner: $copado('[id$=jsTaskOwner_lkid]').val(),
            Notify_Task_Owner: $copado('[id$=jsNotifyTaskOwner]').val()
        });
    },

    updateJobStatus: function (jobId) {
        try {
            job = new sforce.SObject(copadoApp.ns + 'Deployment_Job__c');
            var $statusPicklist = $copado('#js-jobStatus-' + jobId);
            var $tmpStatusPicklist = $copado('#js-PendingStatus-' + jobId);
            if ($statusPicklist.length) {
                job[copadoApp.ns + 'Status__c'] = $statusPicklist.val();
            }
            if ($tmpStatusPicklist.length) {
                job[copadoApp.ns + 'Status__c'] = $tmpStatusPicklist.val();
            }

            job.Id = jobId;
            var result = sforce.connection.update([job]);
            if (!result[0].getBoolean('success')) {
                copadoApp.showMessage('ERROR', result[0].errors.message);
                throw result[0].errors.message;
            }
            copadoApp.getJobs();
            copadoApp.startStatusChecker();
            copadoApp.showMessage('CONFIRM', 'Manual Task updated.');

            ga('send', 'event', 'Step', 'Manual Task ', 'Updated - ' + job[copadoApp.ns + 'Status__c']);
        } catch (e) {
            console.error(e);
        }
    },

    commentPopupHTML:
        '<div style="text-align:center" > <b>__LEAVE_A_COMMENT__</b> </div> <div> <textarea id=mt-comment cols="28" style="margin:5px; height:60px" placeholder="__LEAVE_A_COMMENT_PLASEHOLDER__ "></textarea> <div style="text-align:center" ><button class="copado-lightning" id=mt-comment-ok>__SAVE_AND_CLOSE__</button> </div> </div>',

    openCommentPopup: function (jobId) {
        copadoApp.data.jobIdsToSkipRedraw.push(jobId);

        //reset popup
        $copado('#mt-comment-popup').remove();

        //create container
        $copado('body').append('<div id=mt-comment-popup />');
        $copado('#mt-comment-popup').on('close', function (event) {
            console.info(event);
            copadoApp.data.jobIdsToSkipRedraw.splice(0, 1);
        });

        //create popup content
        $copado('#mt-comment-popup').html(
            copadoMTStep.commentPopupHTML
                .replace('__LEAVE_A_COMMENT__', copadoLabels.LEAVE_A_COMMENT)
                .replace('__SAVE_AND_CLOSE__', copadoLabels.SAVE_AND_CLOSE)
                .replace('__LEAVE_A_COMMENT_PLASEHOLDER__', copadoLabels.LEAVE_A_COMMENT_PLASEHOLDER)
        );

        var $btnOk = $copado('#mt-comment-ok');

        //bind
        $btnOk.on('click', function () {
            copadoMTStep.saveComment(jobId);
        });

        //open
        $copado('#mt-comment-popup')
            .jqxWindow({
                isModal: true,
                width: 320,
                height: 160,
                showCloseButton: false,
                draggable: false
            })
            .css({
                position: 'fixed'
            });
    },
    saveComment: function (jobId) {
        var m = $copado('#mt-comment').val(),
            status = $copado('#js-jobStatus-' + jobId).val();

        var $statusPicklist = $copado('#js-jobStatus-' + jobId);
        var $tmpStatusPicklist = $copado('#js-PendingStatus-' + jobId);
        if ($statusPicklist.length) {
            status = $statusPicklist.val();
        }
        if ($tmpStatusPicklist.length) {
            status = $tmpStatusPicklist.val();
        }

        //validate comment on status failed
        if (!m && status == 'Failed') {
            alert(copadoLabels.MUST_LEAVE_A_COMMENT_ERROR);
            return false;
        }

        $copado('#mt-comment-popup').jqxWindow('close');
        //update job
        copadoMTStep.updateJobStatus(jobId);

        if (m) {
            //save comment async
            var obj = {
                m: 'NEW STATUS: ' + status + ' on ' + JSON.stringify(new Date()) + ' : Comment: ' + m,
                l: 'INFO',
                t: ''
            };
            dw.u.upsertAttach(jobId, jobId + '.json', JSON.stringify([obj]));

            ga('send', 'event', 'Step', 'Manual Task ', 'Leave a comment');
        }
        var tmp_index = copadoApp.data.jobIdsToSkipRedraw.indexOf(jobId);
        if (tmp_index > -1) copadoApp.data.jobIdsToSkipRedraw.splice(tmp_index, 1);
        return true;
    },

    getStatusHTML: function (status, jobId) {
        var html = '<select id="js-jobStatus-' + jobId + '">';
        html += '<option value="In progress" ' + (status === 'In progress' ? 'selected=selected' : '') + '>Pending</option>';
        html += '<option value="Success" ' + (status === 'Success' ? 'selected=selected' : '') + '>Complete</option>';
        html += '<option value="Failed" ' + (status === 'Failed' ? 'selected=selected' : '') + '>Incomplete</option>';
        html += '</select> ';
        html +=
            '<button class="copado-lightning" onclick="copadoMTStep.openCommentPopup(\'' +
            jobId +
            '\');return false;">' +
            copadoLabels.UPDATE_BUTTON +
            '</button>';

        return html;
    },
    getPendingStatusHTML: function (status, jobId) {
        var html = '<select id="js-PendingStatus-' + jobId + '">';
        html += '<option value="In progress" ' + (status === 'In progress' ? 'selected=selected' : '') + '>Pending</option>';
        html += '<option value="Success" ' + (status === 'Success' ? 'selected=selected' : '') + '>Complete</option>';
        html += '<option value="Failed" ' + (status === 'Failed' ? 'selected=selected' : '') + '>Incomplete</option>';
        html += '</select> ';
        html +=
            '<button class="copado-lightning" onclick="copadoMTStep.openCommentPopup(\'' +
            jobId +
            '\');return false;">' +
            copadoLabels.UPDATE_BUTTON +
            '</button>';
        return html;
    }
};

/**************************************************************************************/
//      EXTERNAL CI STEP
/**************************************************************************************/
var copadoExternalCIJobStep = {
    data: {
        xciJobId: ''
    },

    init: function (step) {
        var me = copadoExternalCIJobStep;
        if (me.started) {
            me.reset();
        } else {
            me.started = true;
        }
    },

    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;

        $copado('[id=XCI_INPUT_lkid]').val(data ? data.xciJobId : '000000000000000');

        if (data) {
            sforce.connection.query('select id,name from ' + copadoApp.ns + "External_CI_Job__c where Id = '" + data.xciJobId + "' LIMIT 1", {
                onSuccess: function (result) {
                    var records = result.getArray('records');

                    if (records.length == 1) {
                        var name = records[0].Name;
                        $copado('[id=XCI_INPUT_lkold]').val(name);
                        $copado('[id=XCI_INPUT]').val(name);
                    }
                },
                onFailure: function (error) {
                    console.error('An error has occurred ' + error);
                }
            });
        } else {
            var me = copadoExternalCIJobStep;
            me.reset();
        }
    },
    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        return JSON.stringify({
            xciJobId: $copado('#XCI_INPUT_lkid').val()
        });
    },
    reset: function () {
        copadoExternalCIJobStep.data.xciJobId = '';
        $copado('[id=XCI_INPUT_lkid]').val('000000000000000');
        $copado('[id=XCI_INPUT_lkold]').val('');
        $copado('[id=XCI_INPUT]').val('');
    },
    isValid: function () {
        return $copado('[id=XCI_INPUT]').val() == '' ? false : true;
    }
};

/**************************************************************************************/
//     DATA TEMPLATE
/**************************************************************************************/
var copadoDataTemplateStep = {
    data: {
        dataTemplateId: '',
        source: {},
        destination: {}
    },
    parentId: undefined,
    init: function (step) {
        stepDataForOverrideFilter = step;
        var me = copadoDataTemplateStep;
        if (me.started) {
            me.reset();
        } else {
            me.started = true;
        }
        if (step[copadoApp.ns + 'ParentId__c']) {
            copadoDataTemplateStep.parentId = step[copadoApp.ns + 'ParentId__c'];
        }
    },
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        if (data) {
            copadoDataTemplateStep.data = data;
        } else {
            var me = copadoDataTemplateStep;
            me.reset();
            me.resetDefaults();
        }
        // set selected data source
        if (
            copadoDataTemplateStep.data.source &&
            copadoDataTemplateStep.data.source.type &&
            copadoDataTemplateStep.data.source.type === 'DATASET' &&
            document.getElementById('DATASET')
        ) {
            document.getElementById('DATASET').checked = true;
        } else if (copadoDataTemplateStep && copadoDataTemplateStep.dataTemplateId != '' && document.getElementById('ENVIRONMENT')) {
            document.getElementById('ENVIRONMENT').checked = true;
        }

        copadoDataTemplateStep.toggleHtmlElementsVisibility();
        copadoDataTemplateStep.getDataTemplateDetails(data);
        copadoDataTemplateStep.getDataSetDetails(data);
    },
    resetDefaults: function () {
        copadoDataTemplateStep.data.dataTemplateId = '';
        copadoDataTemplateStep.data.source = undefined;
        copadoDataTemplateStep.data.destination = undefined;
        copadoDataTemplateStep.parentId = undefined;
    },
    getDataTemplateDetails: function (data) {
        if (data.dataTemplateId) {
            let dataTemplates = sforce.connection.query(
                'SELECT Id, Name, ' +
                copadoApp.ns +
                'Template_Source_Org__r.Name, ' +
                copadoApp.ns +
                'Batch_Size__c, ' +
                copadoApp.ns +
                'Max_Record_Limit__c, ' +
                copadoApp.ns +
                'Main_Object__c FROM ' +
                copadoApp.ns +
                "Data_Template__c WHERE Id = '" +
                data.dataTemplateId +
                "' LIMIT 1"
            );
            let dataTemplateRecords = dataTemplates.getArray('records');
            if (dataTemplateRecords && dataTemplateRecords.length > 0) {
                let recordData = dataTemplateRecords[0];
                let name = recordData.Name;
                let header = name + ' | ' + recordData[copadoApp.ns + 'Main_Object__c'];
                let btchrec = recordData[copadoApp.ns + 'Batch_Size__c'] ? recordData[copadoApp.ns + 'Batch_Size__c'] : 0;
                $copado('[id$=SourceDataTemplate_lkid]').val(copadoDataTemplateStep.data.dataTemplateId);
                $copado('[id$=SourceDataTemplate_lkold]').val(name);
                $copado('[id$=SourceDataTemplate]').val(name);
                $copado('[id$=headerDataTemplate]').text(header);
                $copado('[id$=headerDataTemplate]').data('recordid', recordData.Id);
                $copado('[id$=sourceOrg]').text(recordData[copadoApp.ns + 'Template_Source_Org__r'].Name);

                $copado('[id$=batchSize]').text(btchrec);
                $copado('[id$=maxRecordLimit]').text(recordData[copadoApp.ns + 'Max_Record_Limit__c']);
                $copado('[id$=opentemplate]').show();
                $copado('[id$=openRelationshipDiagram]').show();

                if (stepDataForOverrideFilter && stepDataForOverrideFilter.Id) {
                    $copado('[id$=editTemplateFilter]').show();
                }
            }
            copadoDataTemplateStep.getDataTemplateFilterInformation(data.dataTemplateId, data);
        }
    },
    getDataSetDetails: function (data) {
        let dataSetRecord;
        if (data.source && data.source.type === 'DATASET' && data.source.id) {
            dataSetRecord = copadoDataTemplateStep.getDataSetDetailsById(data.source.id, data);
            if (dataSetRecord) {
                $copado('[id$=SourceDataSet]').val(dataSetRecord.Name);
                $copado('[id$=SourceDataSet_lkid]').val(dataSetRecord.Id);
                $copado('[id$=SourceDataSet_lkold]').val(dataSetRecord.Name);
            }
        } else if (data.destination && data.destination.type === 'DATASET' && data.destination.id) {
            dataSetRecord = copadoDataTemplateStep.getDataSetDetailsById(data.destination.id, data);
            if (dataSetRecord) {
                $copado('[id$=DestinationDataSet]').val(dataSetRecord.Name);
                $copado('[id$=DestinationDataSet_lkid]').val(dataSetRecord.Id);
                $copado('[id$=DestinationDataSet_lkold]').val(dataSetRecord.Name);
            }
        }
        return dataSetRecord;
    },
    getDataSetDetailsById: function (dataSetId, data) {
        let dataSets = sforce.connection.query(
            'SELECT Id, Name, ' +
            copadoApp.ns +
            'Data_Template__c, ' +
            copadoApp.ns +
            'Data_Template__r.Name, ' +
            copadoApp.ns +
            'Description__c FROM ' +
            copadoApp.ns +
            "Data_Set__c WHERE Id = '" +
            dataSetId +
            "'"
        );
        let dataSetRecords = dataSets.getArray('records');
        if (dataSetRecords.length > 0) {
            let record = dataSetRecords[0];
            let recordName = record.Name;
            let recordId = record.Id;
            let dataSetDataTemplateId = record[copadoApp.ns + 'Data_Template__c'];
            let dataSetDataTemplateName = record[copadoApp.ns + 'Data_Template__r'].Name;
            let description = record[copadoApp.ns + 'Description__c'];
            $copado('[id$=openDataSet]').show();
            $copado('[id$=headerDataSet]').text(recordName);
            $copado('[id$=headerDataSet]').data('recordid', recordId);
            $copado('[id$=dataSetTemplate]').text(dataSetDataTemplateName);
            $copado('[id$=dataSetTemplate]').data('recordid', dataSetDataTemplateId);
            $copado('[id$=description]').text(description);
            let contentDocuments = sforce.connection.query(
                'SELECT ContentDocumentId ' + 'FROM ContentDocumentLink ' + "WHERE LinkedEntityId = '" + dataSetId + "'"
            );
            let contentDocumentRecords = contentDocuments.getArray('records');
            let contentDocumentIds = contentDocumentRecords.map(record => record.ContentDocumentId);
            let contentDocumentIdsQueryParameter = "'" + contentDocumentIds.toString().replace(/,/g, "','") + "'";
            let contentVersions = sforce.connection.query(
                'SELECT Id, ContentSize ' + 'FROM ContentVersion ' + 'WHERE ContentDocumentId IN (' + contentDocumentIdsQueryParameter + ')'
            );
            let files = contentVersions.getArray('records');
            $copado('[id$=numberOfFiles]').text(files.length);
            let sizeInBytes = 0;
            files.forEach(file => {
                sizeInBytes += parseInt(file.ContentSize);
            });
            let sizeInKB = sizeInBytes > 0 ? (sizeInBytes / 1024).toFixed(2) : 0;
            $copado('[id$=totalFileSize]').text(sizeInKB + ' KB');

            if (data.destination && data.destination.type === 'DATASET' && data.destination.id) {
                $copado('[id$=dataSetFilter]').show();
                copadoDataTemplateStep.getDataTemplateFilterInformation(dataSetDataTemplateId, data);
            } else {
                $copado('[id$=dataSetFilter]').hide();
            }

            return record;
        }
        return null;
    },
    getDataTemplateFilterInformation: function (dataTemplateId, dataJson) {
        var objectsCount = 0;
        var filterLogic = '';
        var editIconText = '';
        var templateDetails = {};
        let attachments = sforce.connection.query(
            'SELECT Id, Name, Body ' + 'FROM Attachment ' + "WHERE ParentId='" + dataTemplateId + "' " + "AND Name = 'Template Detail' LIMIT 1"
        );
        let attachmentRecords = attachments.getArray('records');
        if (attachmentRecords && attachmentRecords.length > 0) {
            let attachmentRecord = attachmentRecords[0];
            var contents = JSON.parse(sforce.Base64Binary.prototype.decode(attachmentRecord.Body));
            objectsCount += contents.childrenObjectsReferenceList.length;
            objectsCount += contents.parentObjectsReferenceList.length;
            templateDetails['count'] = objectsCount;
            var queryFilters = contents.queryFilterList;
            filterLogic = contents.dataTemplate.templateFilterLogic;
            // checking if step datajson is already have filter overriden
            if (dataJson.queryFilterList && dataJson.queryFilterList.length > 0) {
                queryFilters = dataJson.queryFilterList;
                filterLogic = dataJson.filterLogic;
            }

            // first we will replace the number with specific key, to prevent id issue while replacing, becuase id can contain numbers and it will cause a replace problem
            queryFilters.forEach(function (filterItem) {
                filterLogic = filterLogic.replace(filterItem.order, filterItem.order + filterItem.fieldaName);
            });

            // now we can replace with the correct values, we have specific key for each filterlogic
            queryFilters.forEach(function (filterItem) {
                filterLogic = filterLogic.replace(filterItem.order + filterItem.fieldaName, filterItem.finalValue);
            });

            if (!dataJson.queryFilterList && filterLogic === '1') {
                filterLogic = '';
            }

            if (filterLogic == '') {
                editIconText = 'No Filter';
            }

            templateDetails['filterLogic'] = filterLogic;
            templateDetails['editIconText'] = editIconText;
        }
        $copado('[id$=totalObjects]').text(templateDetails.count);
        $copado('[id$=objectFilter]').text(templateDetails.filterLogic);
        $copado('[id$=editFilterIconText]').text(templateDetails.editIconText);
    },
    getObjToSave: function () {
        return JSON.stringify(copadoDataTemplateStep.data);
    },
    getParentId: function () {
        return copadoDataTemplateStep.parentId;
    },
    reset: function () {
        $copado('[id$=SourceDataTemplate_lkid]').val('000000000000000');
        $copado('[id$=SourceDataTemplate_lkold]').val('');
        $copado('[id$=SourceDataTemplate]').val('');
        $copado('[id$=headerDataTemplate]').text('');
        $copado('[id$=headerDataTemplate]').data('recordid', '');
        $copado('[id$=sourceOrg]').text('');
        $copado('[id$=totalObjects]').text('');
        $copado('[id$=objectFilter]').text('');
        $copado('[id$=editFilterIconText]').text('');
        $copado('[id$=batchSize]').text('');
        $copado('[id$=maxRecordLimit]').text('');
        $copado('[id$=opentemplate]').hide();
        $copado('[id$=openRelationshipDiagram]').hide();
        $copado('[id$=editTemplateFilter]').hide();
        // new properties for datasets
        $copado('[id$=ENVIRONMENT]').prop('checked', true);
        $copado('[id$=SourceDataSet]').val('');
        $copado('[id$=SourceDataSet_lkid]').val('');
        $copado('[id$=SourceDataSet_lkold]').val('');
        $copado('[id$=DestinationType]').val('');
        $copado('[id$=DestinationDataSet]').val('');
        $copado('[id$=DestinationDataSet_lkid]').val('');
        $copado('[id$=DestinationDataSet_lkold]').val('');
        $copado('[id$=openDataSet]').hide();
        $copado('[id$=headerDataSet]').text('');
        $copado('[id$=headerDataSet]').data('recordid', '');
        $copado('[id$=dataSetTemplate]').text('');
        $copado('[id$=dataSetTemplate]').data('recordid', '');
        $copado('[id$=numberOfFiles]').text('');
        $copado('[id$=description]').text('');
        $copado('[id$=totalFileSize]').text('');
    },
    isValid: function () {
        if (!copadoDataTemplateStep.data.source) {
            return copadoDataTemplateStep.data.dataTemplateId && copadoDataTemplateStep.data.dataTemplateId !== '000000000000000';
        }
        let templateSelected = copadoDataTemplateStep.data.source.type == 'ENVIRONMENT' && !(copadoDataTemplateStep.data.dataTemplateId && copadoDataTemplateStep.data.dataTemplateId !== '000000000000000') ? false : true;
        let sourceSelected = copadoDataTemplateStep.data.source.type == 'DATASET' && !copadoDataTemplateStep.data.source.id ? false : true;
        return templateSelected && sourceSelected;
    },
    openRelationDataTemplate: function (elementId) {
        let templateId = $copado('[id$=' + elementId + ']').data('recordid');
        if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
            return window.open('/lightning/r/' + templateId + '/view', '_blank');
        } else {
            return window.open('/apex/' + copadoApp.ns + 'DataTemplateSetup?id=' + templateId, '_blank');
        }
    },
    redirectToRelationalDiagramLWC: function () {
        var templateId = copadoDataTemplateStep.data.dataTemplateId;

        // for dev orgs it need to have c: but for namespace context in managed package it should be copado
        var namespace = copadoApp.ns == '' ? 'c' : 'copado';

        var compDefinition = {
            componentDef: `${namespace}:addRelationalDiagramContainer`,
            attributes: {
                recordId: templateId
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        window.open(`/one/one.app#${encodedCompDef}`, '_blank');
    },
    openOverrideFilterPage: function () {
        return window.open(
            '/one/one.app#/alohaRedirect/apex/' +
            copadoApp.ns +
            'OverrideTemplateFilters?deploymentId=' +
            stepDataForOverrideFilter[copadoApp.ns + 'Deployment__c'] +
            '&stepId=' +
            stepDataForOverrideFilter.Id,
            '_parent'
        );
    },
    openRelationDataSet: function (elementId) {
        let datasetId = $copado('[id$=' + elementId + ']').data('recordid');
        if (datasetId) {
            return window.open('/lightning/r/' + datasetId + '/view', '_blank');
        }
    },
    setTemplate: function () {
        copadoDataTemplateStep.data.dataTemplateId = $copado('[id$=SourceDataTemplate_lkid]').val();
        copadoDataTemplateStep.data.source = undefined;
        copadoDataTemplateStep.data.destination = undefined;
        copadoDataTemplateStep.parentId = undefined;
        // refresh data template information
        copadoDataTemplateStep.toggleSourceElements('ENVIRONMENT');
        copadoDataTemplateStep.getDataTemplateDetails(copadoDataTemplateStep.data);
    },
    handleChangeSourceType: function (sourceType) {
        this.setSourceType(sourceType);
        switch (sourceType) {
            case 'ENVIRONMENT':
                copadoDataTemplateStep.setTemplate();
                break;
            case 'DATASET':
                copadoDataTemplateStep.setSourceId();
                break;
        }
        this.toggleSourceElements(sourceType);
    },
    setSourceType: function (sourceType) {
        if (!copadoDataTemplateStep.data.source) {
            copadoDataTemplateStep.data.source = {};
        }
        copadoDataTemplateStep.data.source.type = sourceType;
    },
    toggleSourceElements: function (sourceType) {
        let sourceDataTemplatePanel = document.getElementById('dataTemplateSourcePanel');
        let sourceDataSetPanel = document.getElementById('dataSetSourcePanel');
        let templateDetailsBlock = document.getElementById('dataTemplateInformation');
        let datasetDetailsBlock = document.getElementById('dataSetInformation');
        if (sourceDataTemplatePanel && sourceDataSetPanel && templateDetailsBlock && datasetDetailsBlock) {
            switch (sourceType) {
                case 'ENVIRONMENT':
                case undefined:
                    sourceDataTemplatePanel.style.display = 'block';
                    sourceDataSetPanel.style.display = 'none';
                    if (copadoDataTemplateStep.data.dataTemplateId) {
                        templateDetailsBlock.style.display = 'block';
                    } else {
                        templateDetailsBlock.style.display = 'none';
                    }
                    datasetDetailsBlock.style.display = 'none';
                    break;
                case 'DATASET':
                    sourceDataTemplatePanel.style.display = 'none';
                    sourceDataSetPanel.style.display = 'block';
                    templateDetailsBlock.style.display = 'none';
                    if (copadoDataTemplateStep.data.source.id) {
                        datasetDetailsBlock.style.display = 'block';
                    } else {
                        datasetDetailsBlock.style.display = 'none';
                    }
                    break;
            }
        }
    },
    setSourceId: function () {
        copadoDataTemplateStep.data.dataTemplateId = undefined;
        copadoDataTemplateStep.data.source = { type: 'DATASET' };
        let selectedDataSet = $copado('[id$=SourceDataSet_lkid]').val();
        if (selectedDataSet != '' && selectedDataSet != '000000000000000') {
            copadoDataTemplateStep.data.source.id = selectedDataSet;
        }
        copadoDataTemplateStep.data.destination = { type: 'ENVIRONMENT' };
        copadoDataTemplateStep.toggleSourceElements(copadoDataTemplateStep.data.source.type);
        // refresh data set information
        let dataSetRecord = copadoDataTemplateStep.getDataSetDetails(copadoDataTemplateStep.data);
        if (dataSetRecord) {
            copadoDataTemplateStep.parentId = dataSetRecord.Id;
        }
    },
    toggleDestinationElements: function (destinationType) {
        let sourceDataTemplatePanel = document.getElementById('dataTemplateSourcePanel');
        let destinationDataSetPanel = document.getElementById('dataSetDestinationPanel');
        let templateDetailsBlock = document.getElementById('dataTemplateInformation');
        let datasetDetailsBlock = document.getElementById('dataSetInformation');

        let dataSourceTypeEnvironment = document.getElementById('ENVIRONMENT');
        let dataSourceTypeDataSet = document.getElementById('DATASET');
        let destinationDataSetLookup = $copado('[id$=DestinationDataSet]');

        if (
            sourceDataTemplatePanel &&
            destinationDataSetLookup &&
            templateDetailsBlock &&
            datasetDetailsBlock &&
            dataSourceTypeEnvironment &&
            dataSourceTypeDataSet &&
            destinationDataSetLookup
        ) {
            switch (destinationType) {
                case 'ENVIRONMENT':
                case undefined:
                    destinationDataSetPanel.style.display = 'none';

                    dataSourceTypeEnvironment.disabled = false;
                    dataSourceTypeDataSet.disabled = false;
                    destinationDataSetLookup.attr('disabled', false);
                    break;
                case 'DATASET':
                    sourceDataTemplatePanel.style.display = 'none';
                    destinationDataSetPanel.style.display = 'block';
                    templateDetailsBlock.style.display = 'none';
                    if (copadoDataTemplateStep.data.destination.id) {
                        datasetDetailsBlock.style.display = 'block';
                    }

                    dataSourceTypeEnvironment.disabled = true;
                    dataSourceTypeDataSet.disabled = true;
                    destinationDataSetLookup.attr('disabled', true);
                    break;
            }
        }
    },
    toggleHtmlElementsVisibility() {
        let sourceType =
            copadoDataTemplateStep.data.source && copadoDataTemplateStep.data.source.type ? copadoDataTemplateStep.data.source.type : undefined;
        let destinationType =
            copadoDataTemplateStep.data.destination && copadoDataTemplateStep.data.destination.type
                ? copadoDataTemplateStep.data.destination.type
                : undefined;
        copadoDataTemplateStep.toggleSourceElements(sourceType);
        copadoDataTemplateStep.toggleDestinationElements(destinationType);
    }
};

/**************************************************************************************/
//     AUTOMATION
/**************************************************************************************/
var copadoAutomationStep = {
    data: {
        automationId: ''
    },
    init: function (step) {
        var me = copadoAutomationStep;
        if (me.started) {
            me.reset();
        } else {
            me.started = true;
        }
    },
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        $copado('[id$=auxAutomationId_lkid]').val(data ? data.automationId : '000000000000000');
        if (data) {
            sforce.connection.query('SELECT Id, Name FROM ' + copadoApp.ns + "Deployment__c WHERE Id = '" + data.automationId + "' LIMIT 1", {
                onSuccess: function (result) {
                    var records = result.getArray('records');
                    if (records.length == 1) {
                        var recordData = records[0];
                        var recordName = recordData.Name;
                        var recordId = recordData.Name;
                        $copado('[id$=auxAutomationId_lkold]').val(recordName);
                        $copado('[id$=auxAutomationId]').val(recordId);
                    }
                },
                onFailure: function (error) {
                    console.error('An error has occurred ' + error);
                }
            });
        } else {
            var me = copadoAutomationStep;
            me.reset();
        }
    },
    getObjToSave: function () {
        return JSON.stringify({
            automationId: $copado('[id$=auxAutomationId_lkid]').val()
        });
    },
    reset: function () {
        copadoAutomationStep.data.automationId = '';
        $copado('[id$=auxAutomationId_lkid]').val('000000000000000');
        $copado('[id$=auxAutomationId_lkold]').val('');
        $copado('[id$=auxAutomationId]').val('');
        $copado('[id$=headerAutomation]').text('');
    },
    isValid: function () {
        return $copado('[id$=auxAutomationId]').val() == '' ? false : true;
    }
};

/**************************************************************************************/
//      URL CALLOUT STEP
/**************************************************************************************/
var copadoCalloutStep = {
    allowManualCompletion: function (job) {
        var data = job ? JSON.parse(job[copadoApp.ns + 'Step__r'][copadoApp.ns + 'dataJson__c']) : false;
        if (data.type == 'wait') return true;
        return false;
    },

    doStopStatusChecker: function (job) {
        var data = job ? JSON.parse(job[copadoApp.ns + 'Step__r'][copadoApp.ns + 'dataJson__c']) : false;
        var returnValue = data && data.type == 'wait' ? true : false;
        return returnValue;
    },
    /**
     * Parse the json saved and fill the inputs
     *
     * @param {string} data [description]
     */
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        //fill or reset if field is empty
        $copado('[id=jsUrlCalloutType]').val(data ? data.type : '');
        $copado('[id=jsUrlCalloutMethod]').val(data ? data.method : '');
        $copado('[id$=jsUrlCalloutUrl]').val(data ? data.url : '');
        $copado('[id$=jsUrlCalloutBody]').val(data ? data.body : '');
        urlCallout.url = data && data.url ? data.url : '';
        urlCallout.urlParams = data && data.queryParameters ? data.queryParameters : [];
        urlCallout.headers = data && data.headers ? data.headers : [];
        if (data && data.headers) urlCallout.header.decode();
        urlCallout.createChildRows(urlCallout.urlParams, 'param');
        urlCallout.createChildRows(urlCallout.headers, 'header');
        urlCallout.hookUrl.toggleVisibility();
    },
    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        var h = urlCallout.header.encode();
        return JSON.stringify({
            type: $copado('#jsUrlCalloutType').val(),
            method: $copado('#jsUrlCalloutMethod').val(),
            url: $copado('[id$=jsUrlCalloutUrl]').val(),
            body: $copado('[id$=jsUrlCalloutBody]').val(),
            queryParameters: urlCallout.urlParams,
            headers: urlCallout.headers
        });
    },
    /**
     * Verify that the information in the form is complete
     * @return { boolean } true if valid, false if not.
     */
    isValid: function () {
        return $copado('#jsUrlCalloutMethod option:selected').length > 0 && $copado('[id$=jsUrlCalloutUrl]').val().length > 0;
    },
    updateJobStatus: function (jobId) {
        try {
            job = new sforce.SObject(copadoApp.ns + 'Deployment_Job__c');
            var $statusPicklist = $copado('#js-jobStatus-' + jobId);
            var $tmpStatusPicklist = $copado('#js-PendingStatus-' + jobId);
            if ($statusPicklist.length) {
                job[copadoApp.ns + 'Status__c'] = $statusPicklist.val();
            }
            if ($tmpStatusPicklist.length) {
                job[copadoApp.ns + 'Early_Completion_Status__c'] = $tmpStatusPicklist.val();
            }

            job.Id = jobId;
            var result = sforce.connection.update([job]);
            copadoApp.getJobs();
            copadoApp.startStatusChecker();
            copadoApp.showMessage('CONFIRM', 'URL Callout updated.');

            ga('send', 'event', 'Step', 'URL Callout', 'Updated - ' + job[copadoApp.ns + 'Status__c']);
        } catch (e) {
            console.error(e);
        }
    },

    commentPopupHTML:
        '<div style="text-align:center"> <b>__LEAVE_A_COMMENT__</b> </div> <div> <textarea id="url-comment" cols="40" style="margin:5px; height:60px" placeholder="__LEAVE_A_COMMENT_PLASEHOLDER__"></textarea> <br /> <div style="text-align:center" ><button id=url-comment-ok>__SAVE_AND_CLOSE__</button> </div> </div>',

    openCommentPopup: function (jobId) {
        //reset popup
        $copado('#url-comment-popup').remove();
        //create container
        $copado('body').append('<div id=url-comment-popup />');
        //create popup content
        $copado('#url-comment-popup').html(
            copadoCalloutStep.commentPopupHTML
                .replace('__LEAVE_A_COMMENT__', copadoLabels.LEAVE_A_COMMENT)
                .replace('__SAVE_AND_CLOSE__', copadoLabels.SAVE_AND_CLOSE)
                .replace('__LEAVE_A_COMMENT_PLASEHOLDER__', copadoLabels.LEAVE_A_COMMENT_PLASEHOLDER)
        );

        var $btnOk = $copado('#url-comment-ok');

        //bind
        $btnOk.on('click', function () {
            copadoCalloutStep.saveComment(jobId);
        });

        //open
        $copado('#url-comment-popup')
            .jqxWindow({
                isModal: true,
                width: 320,
                height: 140,
                showCloseButton: false,
                draggable: false
            })
            .css({
                position: 'fixed'
            });
    },
    saveComment: function (jobId) {
        var m = $copado('#url-comment').val(),
            status = $copado('#js-jobStatus-' + jobId).val();

        var $statusPicklist = $copado('#js-jobStatus-' + jobId);
        var $tmpStatusPicklist = $copado('#js-PendingStatus-' + jobId);
        if ($statusPicklist.length) {
            status = $statusPicklist.val();
        }
        if ($tmpStatusPicklist.length) {
            status = $tmpStatusPicklist.val();
        }

        //validate comment on status failed
        if (!m && status == 'Failed') {
            alert(copadoLabels.MUST_LEAVE_A_COMMENT_ERROR);
            return false;
        }

        $copado('#url-comment-popup').jqxWindow('close');
        //update job
        copadoCalloutStep.updateJobStatus(jobId);

        if (m) {
            var obj = {
                m: 'NEW STATUS: ' + status + ' on ' + JSON.stringify(new Date()) + ' : Comment: ' + m,
                l: 'INFO',
                t: ''
            };
            dw.u.upsertAttach(jobId, jobId + '.json', JSON.stringify([obj]));
            ga('send', 'event', 'Step', 'URL Callout', 'Leave a comment');
        }
        return true;
    },
    getStatusHTML: function (status, jobId) {
        var html = '<select id="js-jobStatus-' + jobId + '">';
        html += '<option value="In progress" ' + (status === 'In progress' ? 'selected=selected' : '') + '>In progress</option>';
        html += '<option value="Success" ' + (status === 'Success' ? 'selected=selected' : '') + '>Complete</option>';
        html += '<option value="Failed" ' + (status === 'Failed' ? 'selected=selected' : '') + '>Incomplete</option>';
        html += '</select> ';
        html += '<button onclick="copadoCalloutStep.openCommentPopup(\'' + jobId + '\');return false;">' + copadoLabels.UPDATE_BUTTON + '</button>';
        var flag = status === 'In progress' ? '<span class="jobIcon job-in-progress"> </span>' : '';
        return flag + html;
    }
};

/**************************************************************************************/
//      QUICK ACTION STEP
/**************************************************************************************/
var copadoQAStep = {
    data: {
        objSelected: 0,
        completeObjSelected: 0,
        step: false,
        values: []
    },

    init: function (step) {
        console.time('qa build');
        var me = copadoQAStep;
        me.data.step = step;
        //get obj data
        me.getObjects(step, me.getObjectsCB);
        //build select
        //
        //bind button to get
        //
        if (me.started) {
            me.reset();
        } else {
            me.started = true;
            $copado('#qa-toggle-all').on('click', me.toggleAll);
            $copado('#getQuickActions').on('click', me.getQAValues); //me.getQAValues
        }
        console.timeEnd('qa build');
    },
    getObjects: function (step, cb, force) {
        var me = copadoQAStep;
        if (me.data.objects) {
            cb();
            copadoApp.unlock();
            return;
        }
        dw.u.getCachedRemote({
            url: rock.config.sobjects_url,
            name: 'Data',
            force: force,
            parentId: copadoStep.orgId,
            success: function (res, date) {
                copadoQAStep.data.objects = res;
                cb && cb();
                copadoApp.unlock();
            },
            error: function (r) {
                console.error('Error: ', r);
            }
        });
    },
    getObjectsCB: function () {
        var me = copadoQAStep;

        //add global
        !me._globalAdded &&
            me.data.objects.unshift({
                L: 'Global Actions',
                N: 'Global'
            });
        me._globalAdded = true;

        //create select
        dw.qb.createObjectSelector('#objectsQA', me.data.objects, me.onSelectObject);
    },
    onSelectObject: function (name, label) {
        var me = copadoQAStep;
        me.data.objSelected = name;
        me.data.completeObjSelected = label;
        copadoApp.enabledBtn('#getQuickActions', 'Get Quick Actions');

        return false;
    },
    toggleAll: function () {
        var $btn = $copado('#qa-toggle-all'),
            prev = $btn.attr('data-all');

        $btn.attr('data-all', !prev).html(prev ? copadoLabels.unselect_all : copadoLabels.select_all);

        var options = $copado('#qa-values').find('option');

        options.attr('selected', !prev ? 'selected' : false);

        return false;
    },
    getQAValues: function (ev) {
        ev && ev.preventDefault();
        var me = copadoQAStep;
        if (!me.data.objSelected) {
            copadoApp.showMessage('WARNING', 'Select first a custom object');
            return false;
        }

        me.getRemoteQuickActions();
        return false;
    },
    getRemoteQuickActions: function () {
        copadoApp.lock();
        var me = copadoQAStep;
        dw.u.getRemote(
            rock.config.quick_actions_url.replace('{sobject}', me.data.objSelected),
            function (res) {
                me.data.values = res.sort(function (a, b) {
                    if (a.Name < b.Name) return -1;
                    if (a.Name > b.Name) return 1;
                    return 0;
                });
                me.prepareGrid();
            },
            false,
            true,
            function (res) {
                res && copadoApp.showMessage('ERROR', res);
                copadoApp.unlock();
            }
        );
    },
    prepareGrid: function () {
        var me = copadoQAStep;
        var res = me.data.values,
            len = res.length,
            options = '';
        me.selectedType = len ? res[0].type : false;

        for (var i = 0; len > i; i++) {
            var item = res[i];
            options += '<option value="' + item.n + '">' + item.n + '</option>';
        }

        $copado('#qa-values').html(options);
        copadoApp.unlock();
    },
    setPrevData: function (data) {
        if (!data) return;
        data = JSON.parse(data);

        var me = copadoQAStep;

        $copado('#objectsQA').val(data.sco);
        if (data) {
            me.data.settings = data.settings;
            me.data.values = data.prevRes;
            me.prepareGrid();

            var len = data.settings.length,
                $obj = $copado('#qa-values');

            while (len--) {
                $obj.find('option[value="' + data.settings[len].n + '"]').attr('selected', 'selected');
            }
        }
        copadoApp.unlock();
    },
    reset: function () {
        $copado('#qa-values').html('');
        copadoQAStep.data.objSelected = false;
        copadoQAStep.data.completeObjSelected = false;
    },

    getObjToSave: function () {
        var me = copadoQAStep;

        var settings = [];
        $copado('#qa-values option:selected').each(function (a, b) {
            settings.push({
                s: true,
                t: 'QuickAction',
                n: $copado(this).val()
            });
        });

        return {
            settings: settings,
            sco: me.data.completeObjSelected,
            csName: me.data.objSelected,
            prevRes: me.data.values
        };
    }
};

/**************************************************************************************/
//      CUSTOM SETTING STEP
/**************************************************************************************/
var copadoCSStep = {
    data: {
        objSelected: 0,
        completeObjSelected: 0,
        step: false,
        values: []
    },
    init: function (step) {
        console.time('cs build');
        var me = copadoCSStep;
        copadoCSStep.data.step = step;
        //get obj data
        copadoCSStep.getObjects(step, copadoCSStep.getObjectsCB);
        //build select
        //
        //bind button to get
        //
        if (copadoCSStep.started) {
            copadoCSStep.reset();
        } else {
            copadoCSStep.started = true;
            $copado('#getCSValues').on('click', copadoCSStep.getCSValues);
            $copado('#refresh-cache-cs').on('click', copadoCSStep.refreshCache);
        }
        console.timeEnd('cs build');
        if (me.data.objects && me.data.objects.length > 0) {
            copadoCSStep.data.objSelected = me.data.objects[0].N;
            copadoCSStep.data.completeObjSelected = me.data.objects[0].L;
        }
    },

    reset: function () {
        $copado('#cs-values').html('');
        copadoCSStep.data.objSelected = false;
        copadoCSStep.data.completeObjSelected = false;
    },

    /**
     * Create the grid
     * @param  {[type]} res  data to show
     * @param  {[type]} prev prev selected items
     * @return {[type]}      [description]
     */
    createGrid: function (res, prev) {
        copadoApp.lock();

        var me = copadoCSStep;
        //below fields are all either not needed system fields or already in place our fields
        //the values of the following variables must match the one returns from backend as a respond(SF system fields and our fields), and changes will change the grid columns
        //If you change this, you should also change the same lines in CustomSettingComponent.Resource
        var fields2prevent =
            '==SetupOwnerId==, ==s==, ==Name==, ==type==, ==LastModifiedDate==, ==SystemModstamp==, ==IsDeleted==, ==CreatedById==, ==CreatedDate==, ==Id==, ==LastModifiedById==';
        //reset flag
        copadoGrid.hasPreviousSelected = false;
        //merge previous selected
        me.data.metadata = res; //rock.mergeSavedMeta(res, prev);

        //fix undefined selected field
        var len = me.data.metadata.length;
        while (len--) {
            var e = me.data.metadata[len];
            e.s = e.s || false;
        }

        var objColumns;
        if (res.length > 0) {
            objColumns = Object.keys(res[0]);
        }
        //create datasource
        var source2 = {
            localdata: res,
            datafields: [
                {
                    name: 's',
                    type: 'bool'
                },
                {
                    name: 'Name',
                    type: 'string'
                },
                {
                    name: 'type',
                    type: 'string'
                },
                {
                    name: 'SetupOwnerId',
                    type: 'string'
                }
            ],
            datatype: 'array',
            updaterow: function (rowid, rowdata, commit) {
                commit(true);
                rock.datasource.localdata[rowid] = rowdata;
                copadoStep.dirty = true;
            }
        };
        if (objColumns) {
            for (var c = 0; c < objColumns.length; c++) {
                if (fields2prevent.indexOf(objColumns[c]) < 0) {
                    if (objColumns[c].indexOf('Date') > -1) {
                        source2.datafields.push({
                            name: objColumns[c],
                            type: 'date'
                        });
                    } else if ((res[0] && res[0][objColumns[c]] == 'true') || res[0][objColumns[c]] == 'false') {
                        source2.datafields.push({
                            name: objColumns[c],
                            type: 'bool'
                        });
                    } else
                        source2.datafields.push({
                            name: objColumns[c],
                            type: 'string'
                        });
                }
            }
        }

        source2.localdata = prev;

        //adapter wrapper
        dataAdapter2 = new $copado.jqx.dataAdapter(source2);

        //keep jquery pointer for performance query
        $grid2 = $copado('<div>');

        $copado('#jqxgrid-custom-setting').html($grid2);

        //keep generic data source for later save and validate functions
        rock.datasource = source2;
        var gridObject = {
            width: '100%',
            source: dataAdapter2,
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: true,
            selectionmode: 'none',
            enablebrowserselection: true,
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '200'],
            pagesize: 50,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            columns: [
                {
                    text: copadoLabels.selected,
                    columntype: 'checkbox',
                    filtertype: 'bool',
                    datafield: 's',
                    width: 60
                },
                {
                    text: copadoLabels.type,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    datafield: 'type',
                    width: 120,
                    editable: false
                },
                {
                    text: 'Setup Owner Id',
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    width: 250,
                    editable: false,
                    datafield: 'SetupOwnerId'
                },
                {
                    text: copadoLabels.name,
                    filtertype: 'checkedlist',
                    editable: false,
                    datafield: 'Name'
                }
            ],
            ready: function () {
                //show selected if is edition
                copadoGrid.hasPreviousSelected && copadoGrid.addSelectedFilter($grid2);

                copadoApp.unlock();
            }
        };
        //******UCU*****Be careful with column order, if you change order also consider changing getObjToSave function also!!!
        if (objColumns) {
            for (var c = 0; c < objColumns.length; c++) {
                if (fields2prevent.indexOf(objColumns[c]) < 0) {
                    if (objColumns[c].indexOf('Date') > -1) {
                        gridObject.columns.push({
                            text: objColumns[c].replace('__c', '').replace('_', ' '),
                            filtertype: 'textbox',
                            filtercondition: 'contains',
                            editable: false,
                            datafield: objColumns[c]
                        });
                    } else if ((res[0] && res[0][objColumns[c]] == 'true') || res[0][objColumns[c]] == 'false') {
                        gridObject.columns.push({
                            text: objColumns[c].replace('__c', '').replace('_', ' '),
                            columntype: 'checkbox',
                            filtertype: 'bool',
                            editable: false,
                            datafield: objColumns[c],
                            width: 100
                        });
                    } else {
                        gridObject.columns.push({
                            text: objColumns[c].replace('__c', '').replace('_', ' '),
                            filtertype: 'textbox',
                            filtercondition: 'contains',
                            editable: false,
                            datafield: objColumns[c]
                        });
                    }
                }
            }
        }
        $grid2.jqxGrid(gridObject);
        copadoGrid.addSelectAll($grid2);
    },

    toggleAll: function () {
        var $btn = $copado('#cs-toggle-all'),
            prev = $btn.attr('data-all');
        $btn.attr('data-all', !prev).html(prev ? copadoLabels.unselect_all : copadoLabels.select_all);

        var options = $copado('#cs-values').find('option');
        options.attr('selected', !prev ? 'selected' : false);

        return false;
    },

    refreshCache: function () {
        if ($copado('#cs-values option:selected').length && !confirm('You have selected values. If continue will lose the current selection.')) {
            return false;
        }

        copadoApp.lock();
        copadoCSStep.data.objects = false;
        copadoCSStep.reset();
        copadoCSStep.getObjects(copadoCSStep.data.step, copadoCSStep.getObjectsCB, true);
    },

    getObjects: function (step, cb, force) {
        if (copadoCSStep.data.objects) {
            cb();
            copadoApp.unlock();
            return;
        }
        dw.u.getCachedRemote({
            url: rock.config.sobjects_url + '&onlyCustomSettings=true',
            name: 'Custom Settings',
            force: force,
            parentId: copadoStep.orgId,
            success: function (res, date) {
                copadoCSStep.data.objects = res;
                cb && cb();
                copadoApp.unlock();
            },
            error: function (r) {
                console.error('Error: ', r);
            }
        });
    },

    getObjectsCB: function () {
        dw.qb.createObjectSelector('#objectsCJ', copadoCSStep.data.objects, copadoCSStep.onSelectObject);
    },
    onSelectObject: function (name, label) {
        copadoCSStep.data.objSelected = name;
        copadoCSStep.data.completeObjSelected = label;
        copadoApp.enabledBtn('#getCSValues', 'Get Custom Settings values');
    },

    getCSValues: function () {
        if (!copadoCSStep.data.objSelected) {
            copadoApp.showMessage('WARNING', 'Select first a custom object');
            return false;
        }

        copadoCSStep.getRemoteCSValues();
        return false;
    },

    getObjToSave: function () {
        var settings = [];
        var type;

        var allData = dataAdapter2.records;
        allData.forEach(function (element) {
            if (element.s) {
                if (element.type == 'List') {
                    settings.push(element.Name);
                } else {
                    settings.push(element.SetupOwnerId);
                }
            }
        });
        return {
            fromSuffix: $copado('.cs-fromSuffix').val(),
            toSuffix: $copado('.cs-toSuffix').val(),
            settings: settings,
            sco: copadoCSStep.data.completeObjSelected,
            csName: copadoCSStep.data.objSelected,
            prevRes: copadoCSStep.data.values
        };
    },

    setPrevData: function (data) {
        data = JSON.parse(data);
        $copado('.cs-fromSuffix').val(data ? data.fromSuffix : '');
        $copado('.cs-toSuffix').val(data ? data.toSuffix : '');

        $copado('#objectsCJ').val(data.sco);
        if (data) {
            copadoCSStep.data.settings = data.settings;
            //$copado('#objectsCJ').val(data.sco);
            copadoCSStep.data.values = data.prevRes;
            copadoCSStep.prepareGrid();

            var len = data.settings.length,
                $obj = $copado('#cs-values');

            while (len--) {
                $obj.find('option[value="' + data.settings[len] + '"]').attr('selected', 'selected');
            }
        }
        copadoCSStep.createGrid(copadoCSStep.data.values, copadoCSStep.data.values);
        copadoApp.unlock();
    },

    getRemoteCSValues: function () {
        copadoApp.lock();
        dw.u.getRemote(
            rock.config.custom_settings_url.replace('{sobject}', copadoCSStep.data.objSelected),
            function (res) {
                copadoCSStep.data.values = res.sort(function (a, b) {
                    if (a.Name < b.Name) return -1;
                    if (a.Name > b.Name) return 1;
                    return 0;
                });
                copadoCSStep.createGrid(copadoCSStep.data.values, copadoCSStep.data.values);
            },
            false,
            false,
            function (res) {
                res && copadoApp.showMessage('ERROR', res);
                copadoApp.unlock();
            }
        );
    },

    selectedType: false,

    prepareGrid: function () {
        var res = copadoCSStep.data.values,
            len = res.length,
            options = '';
        copadoCSStep.selectedType = len ? res[0].type : false;
        var typeField = copadoCSStep.selectedType == 'Hierarchy' ? 'SetupOwnerId' : 'Name';

        for (var i = 0; len > i; i++) {
            var item = res[i];
            options += '<option value="' + item[typeField] + '">' + item.Name + '</option>';
        }

        copadoApp.unlock();
    }
};

/**************************************************************************************/
//      GIT PROMOTION STEP
/**************************************************************************************/
var copadoGitPromotionStep = {
    ui: {},
    data: {
        commitId: '',
        repository: '',
        branch: '',
        repositoryId: '',
        name: '',
        fullurl: ''
    },
    stepObj: false,
    init: function (stepObj) {
        copadoApp.lock();

        console.info('copadoGitPromotionStep init', stepObj);
        var me = copadoGitPromotionStep,
            ns = copadoApp.ns;
        me.stepObj = stepObj;

        //init ui
        me.ui.$gitRepository = $copado('.js-gitRepository').html('');
        me.ui.$gitBranch = $copado('.js-gitBranch').html('');
        me.ui.$gitName = $copado('.js-gitName').html('');
        me.ui.$gitCommit = $copado('.js-gitCommit').val('');
        me.ui.$gitCommitLookup = $copado('.js-gitCommit-lookup');

        me.ui.$testLevel = $copado('[id=js-TestLevel]');

        me.setPrevData(stepObj[copadoApp.ns + 'dataJson__c']);

        //bind
        me.bindAction();

        if (!me.stepObj.Id) {
            //clean form and grid
            me.data.repository = '';
            me.data.branch = '';
            me.data.commitId = '';
            me.data.repositoryId = '';
            me.data.name = '';
            me.data.fullurl = '';
            me.data.testLevel = '';
            $copado('#jqxgrid-git-metadata').html('');
            me.data.metadata = [];
            return;
        }

        //set data  -- updated second line to be able to show whole url near branch label - UCU 24.05.18
        me.setData2(
            me.stepObj[ns + 'Git_Repository__r'] ? me.stepObj[ns + 'Git_Repository__r'].Name : '',
            me.stepObj[ns + 'Branch__c'],
            me.stepObj[ns + 'Commit_Id__c'],
            me.stepObj[ns + 'Git_Repository__c'],
            me.stepObj[ns + 'Commit_Name__c'],
            me.stepObj[ns + 'Git_Repository__r']
                ? me.stepObj[ns + 'Git_Repository__r'][ns + 'Branch_Base_URL__c']
                    ? me.stepObj[ns + 'Git_Repository__r'][ns + 'Branch_Base_URL__c'] + me.stepObj[ns + 'Branch__c']
                    : me.stepObj[ns + 'Branch__c']
                : ''
        );

        //check or ask for metadata
        me.data.commitId && me.getMetadata(me.createGrid);
    },

    /**
     * Create the grid
     * @param  {[type]} res  data to show
     * @param  {[type]} prev prev selected items
     * @return {[type]}      [description]
     */
    createGrid: function (res, prev) {
        var me = copadoGitPromotionStep;
        //reset flag
        copadoGrid.hasPreviousSelected = false;
        //merge previous selected
        me.data.metadata = rock.mergeSavedMeta(res, prev);

        //fix undefined selected field
        var len = me.data.metadata.length;
        while (len--) {
            var e = me.data.metadata[len];
            e.s = e.s || false;
        }
        //create datasource
        var source2 = {
            localdata: res,
            datafields: [
                {
                    name: 's',
                    type: 'bool'
                },
                {
                    name: 'cmm',
                    type: 'string'
                },
                {
                    name: 'n',
                    type: 'string'
                },
                {
                    name: 't',
                    type: 'string'
                }
            ],
            datatype: 'array'
        };

        //adapter wrapper
        dataAdapter2 = new $copado.jqx.dataAdapter(source2);

        //keep jquery pointer for performance query
        $grid2 = $copado('<div>');

        $copado('#jqxgrid-git-promotion').html($grid2);

        //keep generic data source for later save and validate functions
        rock.datasource = source2;

        /**
         * Helper to colored status cell by status
         * @param  {[type]} row         [description]
         * @param  {[type]} column      [description]
         * @param  {[type]} value       [description]
         * @param  {[type]} defaultHtml [description]
         * @return {[type]}             [description]
         */
        var cellsrenderer = function (row, column, value, defaultHtml) {
            var color = false;
            if (value == 'deleted') {
                color = '#FFC6C6';
            } else if (value == 'updated') {
                color = '#FFFFE3';
            } else if (value == 'created') {
                color = '#CCFFCC';
            }

            if (color) {
                var element = $copado(defaultHtml);
                element.css({
                    'background-color': color,
                    'text-align': 'center'
                });
                return element[0].outerHTML;
            }
            return defaultHtml;
        };
        $grid2.jqxGrid({
            width: '100%',
            source: dataAdapter2,
            showfilterrow: true,
            filterable: true,
            theme: 'base',
            editable: rock.EditGitPromotion == 'true',
            selectionmode: 'none',
            enablebrowserselection: true,
            pageable: true,
            pagesizeoptions: ['10', '20', '50', '100', '200'],
            pagesize: 50,
            sortable: true,
            columnsresize: true,
            localization: localizationobj,
            columns: [
                {
                    text: copadoLabels.selected,
                    columntype: 'checkbox',
                    filtertype: 'bool',
                    datafield: 's',
                    editable: rock.EditGitPromotion == 'true',
                    width: 60
                },
                {
                    text: 'Commit Info.',
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    datafield: 'cmm',
                    width: 120,
                    editable: false,
                    cellsrenderer: cellsrenderer
                },
                {
                    text: copadoLabels.name,
                    filtertype: 'textbox',
                    filtercondition: 'contains',
                    editable: false,
                    datafield: 'n'
                },
                {
                    text: copadoLabels.type,
                    filtertype: 'checkedlist',
                    editable: false,
                    datafield: 't'
                }
            ],
            ready: function () {
                copadoApp.unlock();
            }
        });

        //filtering the grid to see only the components that are part of the user story when deploying.
        copadoGrid.addSelectedFilter($grid2);

        if (me && rock.EditGitPromotion == 'true') {
            $grid2.on('cellvaluechanged', function (event) {
                var local = rock.datasource.localdata;
                var t = $grid2.jqxGrid('getrowdata', event.args.rowindex);
                if (event.args.datafield == 's' && t.s === true) {
                    t.s = true;
                } else if (event.args.datafield == 's' && t.s === false) {
                    t.s = false;
                }
                local[event.args.rowindex] = t;
                $grid2.jqxGrid('refresh');
            });
        }
    },

    /**
     * Get remote metadata from commit
     * Save it in attachment related to repository
     * @param  {Function} cb [description]
     * @return {[type]}      [description]
     */
    getMetadata: function (cb, calledRecursively) {
        copadoApp.lock();

        var me = copadoGitPromotionStep;
        //copadoApp.lock();

        //get from Attachment
        var att = dw.u.getDecodedAttach(me.data.repositoryId, me.data.commitId + '.json');

        if (att) {
            //parse and cb
            var att = att ? JSON.parse(att.Body) : [];
            //get saved data
            if (me.stepObj.Id) {
                var prev = dw.u.getDecodedAttach(me.stepObj.Id, 'MetaData');
                if (prev) {
                    me.data.prevAttId = prev.Id;
                }
            }

            prev = prev ? JSON.parse(prev.Body) : [];

            setTimeout(function () {
                cb && cb(att, prev);
            }, 33);
        } else if (calledRecursively) {
            alert('The commit ' + me.data.commitId + ' was not found');
            copadoApp.unlock();
        } else {
            copadoApp.parentId = me.data.repositoryId;
            copadoApp.startStatusManager();

            statusManager.successFunction = function () {
                me.getMetadata(me.createGrid, true);
            };
            statusManager.initialise();

            //remote
            var uri = rock.config.git_metadata_url
                .replace('{branch}', me.data.branch)
                .replace('{repositoryId}', me.data.repositoryId)
                .replace('{commitId}', me.data.commitId);
            statusManager.parentId = me.data.repositoryId;
            statusManager.startProcess(function () {
                utilsV2.onSuccessCB = function (res) {
                    var obj = $copado.parseJSON(res);
                    if (obj.copadoJobId) {
                        statusManager.copadoJobId = obj.copadoJobId;
                        statusManager.startStatusChecker();
                    }
                };
                utilsV2.getRemote(uri);
            });
        }
    },

    /**
     * bind ui actions
     * @return {[type]} [description]
     */
    bindAction: function () {
        var me = copadoGitPromotionStep;

        if (me._bound) return;
        me._bound = true;

        me.ui.$gitCommitLookup.on('click', me.openLookupPopup);
    },

    /**
     * Sel local data
     * @param {[type]} repository   [description]
     * @param {[type]} branch       [description]
     * @param {[type]} commitId     [description]
     * @param {[type]} repositoryId [description]
     */
    setData: function (repository, branch, commitId, repositoryId, name) {
        var me = copadoGitPromotionStep;

        me.data.repository = repository;
        me.data.branch = branch;
        me.data.commitId = commitId;
        me.data.repositoryId = repositoryId;
        me.data.name = name;
    },
    /*
        created setData2 to be able to store fullurl and to not make it mandatory at the same time UCU 4.6.18
    */
    setData2: function (repository, branch, commitId, repositoryId, name, fullurl) {
        var me = copadoGitPromotionStep;

        me.data.repository = repository;
        me.data.branch = branch;
        me.data.commitId = commitId;
        me.data.repositoryId = repositoryId;
        me.data.name = name;
        me.data.fullurl = fullurl;
    },

    /**
     * Parse the json saved and fill the inputs
     *
     * @param {string} data [description]
     */
    setPrevData: function (data) {
        console.info('DATA: ', data);
        data = typeof data === 'string' ? JSON.parse(data) : data || false;
        $copado('[id=findReplaceArrayPlaceholder]').html('');
        metadataReplace.findReplaceArray = [];
        $copado('[id=js-TestLevel]').val(data ? data.testLevel : 'NoTestRun');
        metadataReplace.findReplaceArray = data && data.replacements ? data.replacements : [];
        if (data && data.replacements) metadataReplace.findReplace.decode();
        if (data) metadataReplace.createChildRows(data.replacements);
    },

    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        return JSON.stringify({
            testLevel: $copado('[id=js-TestLevel]').val(),
            replacements: metadataReplace.findReplaceArray
        });
    },

    /**
     * This is called from the commit lookup
     * @param  {[type]} obj the object result
     * @return {[type]}     [description]
     */
    lookupCB: function (obj) {
        var me = copadoGitPromotionStep;

        //if diff commit
        //
        if (obj.commitId == me.data.commitId) return;

        copadoApp.lock();

        //update obj + ui
        me.setData(obj.repository, obj.branch, obj.commitId, obj.repositoryId, obj.name);

        var ns = copadoApp.ns;

        me.stepObj[ns + 'Branch__c'] = obj.branch;
        me.stepObj[ns + 'Commit_Id__c'] = obj.commitId;
        me.stepObj[ns + 'Git_Repository__c'] = obj.repositoryId;
        me.stepObj[ns + 'Commit_Name__c'] = obj.name;
        me.stepObj[ns + 'Git_Repository__r'] = {
            Name: obj.repository
        };

        //ui
        me.setObjValues();

        //set dirty
        copadoStep.dirty = true;

        //clean grid
        me.data.prevAttId && sforce.connection.deleteIds([me.data.prevAttId]);
        $copado('#jqxgrid-git-metadata').html('');
        me.getMetadata(me.createGrid);
    },

    /**
     * Call Commit custom lookup
     * @return {[type]} [description]
     */
    openLookupPopup: function () {
        var me = copadoGitPromotionStep,
            ns = copadoApp.ns;
        var _namespace = copadoApp.ns != '' ? copadoApp.ns + '__' : '';

        //prepare url parameters
        var url = '/apex/' + _namespace + 'GitCommitLookup?from=Deployment&callback=copadoGitPromotionStep.lookupCB';
        url += '&repository=' + me.data.repository;
        url += '&branch=' + me.data.branch;
        url += '&commitId=' + me.data.commitId;

        var popupParams = 'width=1024,height=530,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no';
        window.open(url, 'lookup', popupParams, true);
    },

    /**
     * Set UI data
     * @param {[type]} obj [description]
     */
    setObjValues: function (obj) {
        var me = copadoGitPromotionStep,
            ns = copadoApp.ns;
        me.ui.$gitRepository.html(me.data.repository);
        //me.ui.$gitBranch.html(me.data.branch);
        //shows direct link to users branch - UCU

        if (me.data.fullurl.length > 0) {
            me.ui.$gitBranch.html('<a href="' + me.data.fullurl + '" target="_blank" title="' + me.data.fullurl + '">' + me.data.branch + '</a>');
        } else me.ui.$gitBranch.html(me.data.branch);
        me.ui.$gitCommit.val(me.data.commitId);
        me.ui.$gitName.html(me.data.name);
    }
};

/**************************************************************************************/
//      SALESFORCE FLOW STEP
/**************************************************************************************/
var copadoSalesforceFlowStep = {
    allowManualCompletion: function (job) {
        var data = job ? JSON.parse(job[copadoApp.ns + 'Step__r'][copadoApp.ns + 'dataJson__c']) : false;
        if (data.type == 'wait') return true;
        return false;
    },

    doStopStatusChecker: function (job) {
        var data = job ? JSON.parse(job[copadoApp.ns + 'Step__r'][copadoApp.ns + 'dataJson__c']) : false;
        var returnValue = data && data.type == 'wait' ? true : false;
        return returnValue;
        return true;
    },
    /**
     * Parse the json saved and fill the inputs
     *
     * @param {string} data [description]
     */
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        //fill or reset if field is empty
        $copado('[id=jsSalesforceFlowName]').val(data ? data.flowApiName : '');
        $copado('[id=jsSalesforceFlowType]').val(data ? data.type : 'wait');
        salesforceFlow.flowParams = data && data.flowParameters ? data.flowParameters : [];
        salesforceFlow.createChildRows(salesforceFlow.flowParams);
    },
    /**
     * recover from DOM inputs the field values
     * and return the json representation containing those values
     * @return {[type]} [description]
     */
    getObjToSave: function () {
        return JSON.stringify({
            flowApiName: $copado('#jsSalesforceFlowName').val(),
            type: $copado('#jsSalesforceFlowType').val(),
            flowParameters: salesforceFlow.flowParams
        });
    },
    /**
     * Verify that the information in the form is complete
     * @return { boolean } true if valid, false if not.
     */
    isValid: function () {
        return $copado('#jsSalesforceFlowName option:selected').length > 0;
    },
    updateJobStatus: function (jobId) {
        try {
            job = new sforce.SObject(copadoApp.ns + 'Deployment_Job__c');
            var $statusPicklist = $copado('#js-jobStatus-' + jobId);
            var $tmpStatusPicklist = $copado('#js-PendingStatus-' + jobId);
            if ($statusPicklist.length) {
                job[copadoApp.ns + 'Status__c'] = $statusPicklist.val();
            }
            if ($tmpStatusPicklist.length) {
                job[copadoApp.ns + 'Early_Completion_Status__c'] = $tmpStatusPicklist.val();
            }

            job.Id = jobId;
            var result = sforce.connection.update([job]);
            copadoApp.getJobs();
            copadoApp.startStatusChecker();
            copadoApp.showMessage('CONFIRM', 'Salesforce Flow updated.');

            ga('send', 'event', 'Step', 'Salesforce Flow', 'Updated - ' + job[copadoApp.ns + 'Status__c']);
        } catch (e) {
            console.error(e);
        }
    },

    commentPopupHTML:
        '<div style="text-align:center"> <b>__LEAVE_A_COMMENT__</b> </div> <div> <textarea id="flow-comment" cols="40" style="margin:5px; height:60px" placeholder="__LEAVE_A_COMMENT_PLASEHOLDER__"></textarea> <br /> <div style="text-align:center" ><button class="copado-lightning" id=flow-comment-ok>__SAVE_AND_CLOSE__</button> </div> </div>',

    openCommentPopup: function (jobId) {
        copadoApp.data.jobIdsToSkipRedraw.push(jobId);
        //reset popup
        $copado('#flow-comment-popup').remove();
        //create container
        $copado('body').append('<div id=flow-comment-popup />');
        $copado('#flow-comment-popup').on('close', function (event) {
            console.info(event);
            copadoApp.data.jobIdsToSkipRedraw.splice(0, 1);
        });
        //create popup content
        $copado('#flow-comment-popup').html(
            copadoSalesforceFlowStep.commentPopupHTML
                .replace('__LEAVE_A_COMMENT__', copadoLabels.LEAVE_A_COMMENT)
                .replace('__SAVE_AND_CLOSE__', copadoLabels.SAVE_AND_CLOSE)
                .replace('__LEAVE_A_COMMENT_PLASEHOLDER__', copadoLabels.LEAVE_A_COMMENT_PLASEHOLDER)
        );

        var $btnOk = $copado('#flow-comment-ok');

        //bind
        $btnOk.on('click', function () {
            copadoSalesforceFlowStep.saveComment(jobId);
        });

        //open
        $copado('#flow-comment-popup')
            .jqxWindow({
                isModal: true,
                width: 320,
                height: 160,
                showCloseButton: false,
                draggable: false
            })
            .css({
                position: 'fixed'
            });
    },
    saveComment: function (jobId) {
        var m = $copado('#flow-comment').val(),
            status = $copado('#js-jobStatus-' + jobId).val();

        var $statusPicklist = $copado('#js-jobStatus-' + jobId);
        var $tmpStatusPicklist = $copado('#js-PendingStatus-' + jobId);
        if ($statusPicklist.length) {
            status = $statusPicklist.val();
        }
        if ($tmpStatusPicklist.length) {
            status = $tmpStatusPicklist.val();
        }

        //validate comment on status failed
        if (!m && status == 'Failed') {
            alert(copadoLabels.MUST_LEAVE_A_COMMENT_ERROR);
            return false;
        }

        $copado('#flow-comment-popup').jqxWindow('close');
        //update job
        copadoSalesforceFlowStep.updateJobStatus(jobId);

        if (m) {
            var obj = [
                {
                    m: 'NEW STATUS: ' + status + ' on ' + JSON.stringify(new Date()),
                    l: 'INFO',
                    t: ''
                },
                {
                    m: 'Comment: ' + m,
                    l: 'INFO',
                    t: ''
                }
            ];
            dw.u.upsertAttach(jobId, jobId + '.json', JSON.stringify(obj));
            ga('send', 'event', 'Step', 'Salesforce Flow', 'Leave a comment');
        }
        return true;
    },
    getStatusHTML: function (status, jobId) {
        var html = '<select id="js-jobStatus-' + jobId + '">';
        html += '<option value="In progress" ' + (status === 'In progress' ? 'selected=selected' : '') + '>In progress</option>';
        html += '<option value="Success" ' + (status === 'Success' ? 'selected=selected' : '') + '>Complete</option>';
        html += '<option value="Failed" ' + (status === 'Failed' ? 'selected=selected' : '') + '>Incomplete</option>';
        html += '</select> ';
        html +=
            '<button class="copado-lightning" onclick="copadoSalesforceFlowStep.openCommentPopup(\'' +
            jobId +
            '\');return false;">' +
            copadoLabels.UPDATE_BUTTON +
            '</button>';
        var flag = status === 'In progress' ? '<span class="jobIcon job-in-progress"> </span>' : '';
        return flag + html;
    }
};

/**************************************************************************************/
//      FUNCTION
/**************************************************************************************/
var functionRecord;
var copadoFunctionStep = {
    data: {
        functionAPIName: ''
    },
    init: function (step) {
        var me = copadoFunctionStep;
        if (me.started) {
            me.reset();
        } else {
            me.started = true;
        }
    },
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        if (data) {
            copadoFunctionStep.getFunctionDetails(data);
        } else {
            var me = copadoFunctionStep;
            me.reset();
        }
    },
    getFunctionDetails: function (data) {
        var functionAPIName = data ? data.functionAPIName : '';
        var query;
        if (functionAPIName) {
            query =
                'SELECT Id, Name, ' +
                copadoApp.ns +
                'API_Name__c, ' +
                copadoApp.ns +
                'Parameters__c FROM ' +
                copadoApp.ns +
                'Function__c WHERE ' +
                copadoApp.ns +
                "API_Name__c = '" +
                functionAPIName +
                "' LIMIT 1";
        } else {
            var functionId = $copado('[id$=auxFunctionId_lkid]').val();
            query =
                'SELECT Id, Name, ' +
                copadoApp.ns +
                'API_Name__c, ' +
                copadoApp.ns +
                'Parameters__c FROM ' +
                copadoApp.ns +
                "Function__c WHERE Id = '" +
                functionId +
                "' LIMIT 1";
        }
        sforce.connection.query(query, {
            onSuccess: function (result) {
                var records = result.getArray('records');
                if (records.length == 1) {
                    functionRecord = records[0];
                    var recordName = functionRecord.Name;
                    var recordId = functionRecord.Id;
                    $copado('[id$=auxFunctionId_lkold]').val(recordName);
                    $copado('[id$=auxFunctionId]').val(recordName);
                    $copado('[id$=auxFunctionId_lkid]').val(recordId);
                    if (data && data.functionParameters) {
                        copadoFunctionStep.addParametersToLayout(data.functionParameters);
                    } else {
                        var functionParameters = functionRecord[copadoApp.ns + 'Parameters__c'];
                        var parsedParameters = JSON.parse(functionParameters);
                        copadoFunctionStep.addParametersToLayout(parsedParameters);
                    }
                    $copado('[id$=openfunction]').show();
                    $copado('[id$=functionParamWrapperLabel]').show();
                }
            },
            onFailure: function (error) {
                console.error('An error has occurred ' + error);
            }
        });
    },
    getObjToSave: function () {
        return JSON.stringify({
            functionAPIName: functionRecord ? functionRecord[copadoApp.ns + 'API_Name__c'] : '',
            functionParameters: copadoFunctionStep.prepareParameterJSON()
        });
    },
    reset: function () {
        copadoFunctionStep.data.functionId = '';
        $copado('[id$=auxFunctionId_lkid]').val('000000000000000');
        $copado('[id$=auxFunctionId_lkold]').val('');
        $copado('[id$=auxFunctionId]').val('');
        $copado('[id$=headerFunction]').text('');
        $copado('#functionParameters').html('');
        $copado('[id$=openfunction]').hide();
        $copado('[id$=functionParamWrapperLabel]').hide();
    },
    isValid: function () {
        return $copado('[id$=auxFunctionId]').val() == '' ? false : true;
    },
    addParametersToLayout: function (functionParameters) {
        $copado('#functionParameters').html('');
        functionParameters.forEach(parameter => {
            var nameField =
                '<input type="text" style="margin: 0.5rem 0.5rem 0.5rem 0rem" placeholder="' +
                copadoLabels.PARAMETER_NAME +
                '" class="js-param" value="' +
                parameter.name +
                '" />';
            var parameterValue = parameter.defaultValue || parameter.value;
            var valueField =
                '<input type="text" style="margin: 0.5rem" placeholder="' +
                copadoLabels.PARAMETER_VALUE +
                '"  class="js-param" value="' +
                parameterValue +
                '" />';
            var wrapper = '<div class="js-param-container" style="clear:both;">' + nameField + valueField + '</div>';
            $copado(wrapper).appendTo('#functionParameters');
        });
    },
    prepareParameterJSON: function () {
        var parameterArray = [];

        for (let i = 0; i < document.querySelectorAll('.js-param-container').length; i++) {
            var currentContainer = document.querySelectorAll('.js-param-container')[i];
            var objects = currentContainer.querySelectorAll('.js-param');
            parameterArray.push({ name: objects[0].value, value: objects[1].value });
        }

        return parameterArray;
    },
    openFunction: function () {
        let functionId = $copado('[id$=auxFunctionId_lkid]').val();
        if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
            return window.open('/lightning/r/' + functionId + '/view', '_blank');
        } else {
            return window.open('/' + functionId, '_blank');
        }
    }
};

/**************************************************************************************/
//      TEST
/**************************************************************************************/
var testRecord;
var copadoTestStep = {
    data: {
        testId: ''
    },
    init: function (step) {
        var me = copadoTestStep;
        if (me.started) {
            me.reset();
        } else {
            me.started = true;
        }
    },
    setPrevData: function (data) {
        data = data ? JSON.parse(data) : false;
        if (data) {
            copadoTestStep.getTestDetails(data);
        } else {
            var me = copadoTestStep;
            me.reset();
        }
    },
    getTestDetails: function (data) {
        var testId = data ? data.testId : $copado('[id$=auxTestId_lkid]').val();
        var query;
        if (testId) {
            query =
                'SELECT Id, Name, ' +
                copadoApp.ns +
                'ExtensionConfiguration__c, ' +
                copadoApp.ns +
                'ExtensionConfiguration__r.Name, ' +
                copadoApp.ns +
                'ExtensionConfiguration__r.' + 
                copadoApp.ns +
                'ExtensionTool__c, ' +
                copadoApp.ns +
                'Type__c FROM ' +
                copadoApp.ns +
                "Test__c WHERE Id = '" +
                testId +
                "' LIMIT 1";
        } 
        sforce.connection.query(query, {
            onSuccess: function (result) {
                var records = result.getArray('records');
                if (records.length == 1) {
                    testRecord = records[0];
                    var recordName = testRecord.Name;
                    var recordId = testRecord.Id;
                    $copado('[id$=auxTestId_lkold]').val(recordName);
                    $copado('[id$=auxTestId]').val(recordName);
                    $copado('[id$=auxTestId_lkid]').val(recordId);
                    copadoTestStep.addTestFieldsToLayout(testRecord);
                    $copado('[id$=opentest]').show();
                }
            },
            onFailure: function (error) {
                console.error('An error has occurred ' + error);
            }
        });
    },
    getObjToSave: function () {
        return JSON.stringify({
            testId: testRecord ? testRecord['Id'] : '',
            testName: testRecord ? testRecord['Name'] : ''
        });
    },
    reset: function () {
        copadoTestStep.data.testId = '';
        $copado('[id$=auxTestId_lkid]').val('000000000000000');
        $copado('[id$=auxTestId_lkold]').val('');
        $copado('[id$=auxTestId]').val('');
        $copado('[id$=headerTest]').text('');
        $copado('[id$=opentest]').hide();
        copadoTestStep.deleteFieldsFromLayout();
    },
    isValid: function () {
        return $copado('[id$=auxTestId]').val() == '' ? false : true;
    },
    addTestFieldsToLayout: function (testRecord) {
        var extensionConfiguration = testRecord[copadoApp.ns + 'ExtensionConfiguration__r'];
        var tool = extensionConfiguration[copadoApp.ns + 'ExtensionTool__c'];
        var type = testRecord[copadoApp.ns + 'Type__c'] != null ? testRecord[copadoApp.ns + 'Type__c'] : ''; 
        var configUrl = copadoTestStep.getExtConfigUrl(testRecord[copadoApp.ns + 'ExtensionConfiguration__c']);
        
        copadoTestStep.deleteFieldsFromLayout();
        var tableElements = $copado('[Id$=js-stepBlock-Test]').find('table');
        var rows = tableElements[0].rows;

        // Add Tool Configuration
        rows[0].insertCell(2).outerHTML = '<th class="labelCol vfLabelColTextWrap" scope="row"></th>';
        rows[0].cells[2].innerHTML = '<label>' + copadoLabels.TOOL_CONFIGURATION + '</label>';
        rows[0].insertCell(3).outerHTML = '<td class="dataCol"></td>';
        rows[0].cells[3].innerHTML = '<a href="' + configUrl + '" target="_blank" title="' + configUrl + '">' + extensionConfiguration['Name'] + '</a>';

        // Add Tool and Type
        tableElements[0].insertRow(1);
        rows[1].innerHTML = ' <th class="labelCol vfLabelColTextWrap" scope="row"><label>' + copadoLabels.TOOL + '</label></th>'
                            + '<td class="dataCol">' + tool + '</td>'
                            + '<th class="labelCol vfLabelColTextWrap" scope="row"><label>' + copadoLabels.type + '</label></th>'
                            + '<td class="dataCol">' + type + '</td>';
            
    },
    deleteFieldsFromLayout: function () {
        var tableElements = $copado('[Id$=js-stepBlock-Test]').find('table');
        var rows = tableElements[0].rows;
        for (var index = rows[0].cells.length - 1; index > 1; index--) {
            rows[0].deleteCell(index);
        }
        if (rows.length > 1) {
            tableElements[0].deleteRow(1);
        }
    },
    getExtConfigUrl: function (extensionConfigurationId) {
        if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
            return '/lightning/r/' + extensionConfigurationId + '/view';
        } else {
            return '/' + extensionConfigurationId;
        }
    },
    openTest: function () {
        let testId = $copado('[id$=auxTestId_lkid]').val();
        if (typeof sforce != 'undefined' && sforce && !!sforce.one) {
            return window.open('/lightning/r/' + testId + '/view', '_blank');
        } else {
            return window.open('/' + testId, '_blank');
        }
    }
};

/**************************************************************************************/
//      QUERY BUILDER
/**************************************************************************************/

//namespace
var dw = dw || {};

dw.qb = dw.qb || {};

dw.qb.type = copadoStep.stepType;

//TODO Replace this
dw.qb.createCacheDeleteButton = function (date) {
    if (!date) {
        $copado('#qb-refresh').hide();
    } else {
        var $btn = $copado('#qb-refresh');
        $btn.html(
            $btn
                .html()
                .replace('__DATE__', date)
                .replace('__METATYPE__', '')
        ).show();
    }
};

dw.qb.removeCached = function () {
    //hide
    copadoApp.lock();

    //reload
    $copado('#queryBuilder').hide();

    //init(true);
    dw.qb.init(true, copadoStep.orgId);

    return false;
};

dw.qb.prepareSource = function (data) {
    //normalize data
    var source = [],
        len = data.length;
    for (var i = 0; i < len; i++) {
        source[i] = data[i].L + ' (' + data[i].N + ')';
    }

    source.sort();
    return source;
};

dw.qb.createObjectSelector = function (selector, data, cb) {
    var $objects = $copado(selector).jqxComboBox({
        source: dw.qb.prepareSource(data),
        autoComplete: true,
        width: '400px',
        height: '25px',
        selectedIndex: 0
    });

    $objects.bind('select', function (event) {
        var args = event.args;
        if (args && !isNaN(args.index)) {
            var item = $objects.jqxComboBox('listBox').visibleItems[args.index];
            cb && cb(item.label.split('(')[1].split(')')[0], item.label);
        }
    });

    $objects.jqxComboBox('focus');
    return $objects;
};

dw.qb.bound = false;

dw.qb.startQueryBuilder = function (data) {
    console.timeEnd('startQueryBuilder, get Data attach');

    try {
        $copado('.query-step-2').hide();
        dw.qb.ui.$objects = dw.qb.createObjectSelector('#objects', data, dw.qb.onSelectObject);
        //start get fields
        dw.qb.ui.getFields = $copado('#getFields');

        dw.qb.where = '';
        dw.qb.ui.fields = $copado(".duelingListBox select[id$=':leftList']");
        dw.qb.ui.fieldsSelected = $copado(".duelingListBox select[id$=':rightList']");
        dw.qb.ui.leftHidden = $copado(".duelingListBox input[id$=':leftHidden']");
        dw.qb.ui.rightHidden = $copado(".duelingListBox input[id$=':rightHidden']");

        if (!dw.qb.bound) {
            dw.qb.ui.fieldsEx = $copado('#fieldsEx').on('change', dw.qb.selectFieldEx);
        }
        dw.qb.ui.attachmentOptions = $copado('#attachmentOptions').on('change', dw.qb.selectAttachmentOption);
        dw.qb.ui.matchOwner = $copado('#matchOwner').on('change', dw.qb.selectOwnerId);
        dw.qb.ui.matchRecordType = $copado('#matchRecordType').on('change', dw.qb.selectRecordType);

        !dw.qb.bound &&
            dw.qb.ui.getFields.on('click', function (e) {
                if (!dw.qb.objectSelected) {
                    return;
                }

                //lock button
                copadoApp.disabledBtn('#getFields', copadoLabels.loading);

                dw.qb.ui.fields.html(copadoLabels.loading);
                //call get
                dw.qb.getFields();

                return false;
            });

        //query label
        dw.qb.ui.query = $copado('.query-label');

        // Overload MultiselectPicklist.moveSelectedOptions to process the selection
        if (!dw.qb.bound) {
            var old_moveSelectedOptions = moveSelectedOptions;
            moveSelectedOptions = function (idFrom, idTo, idHdnFrom, idHdnTo) {
                old_moveSelectedOptions.call(this, idFrom, idTo, idHdnFrom, idHdnTo);
                if (idFrom.lastIndexOf(':leftList') !== -1) {
                    dw.qb.toogleFieldSelection(dw.qb.ui.fields, true); // Add field
                } else {
                    dw.qb.toogleFieldSelection(dw.qb.ui.fieldsSelected, false); // Remove field
                }
            };
        }

        dw.qb.preQuery && dw.qb.rebuild();
        !dw.qb.bound && $copado('#testQuery').on('click', dw.qb.testQuery);

        $copado('#loading').hide();
        $copado('#queryBuilder').fadeIn();

        dw.qb.ui.$objects.jqxComboBox('focus');

        //bind query hand edition sync
        !dw.qb.bound &&
            dw.qb.ui.query.on('keyup change', function () {
                dw.qb.query = dw.qb.ui.query.val();
                var w = dw.qb.query.split(/ where /i);
                dw.qb.where = w.length > 1 ? w[1] : '';
            });
        dw.qb.bound = true;
    } catch (e) {
        console.log('Error on QB init', e);
    }

    copadoApp.unlock();
};

dw.qb.objectSelected = false;
dw.qb.ui = {};
dw.qb.selectedFields = [];
dw.qb.queryTemplate = 'Select fields from object clause';
dw.qb.query = false;

dw.qb.rebuild = function () {
    try {
        var preJson = dw.qb.preQuery;
        if (preJson.rb) {
            dw.qb.preData = preJson;
            //preselect objects
            var item = dw.qb.ui.$objects.jqxComboBox('getItemByValue', preJson.rb.sco);
            if (item) {
                dw.qb.ui.$objects.jqxComboBox('selectItem', item);

                //TODO:get fields (cache?)
                dw.qb.ui.getFields.click();

                //getFileds callback
                dw.qb.rebuilding = 1;
            }

            dw.qb.where = dw.qb.preData.q.split(/ where /i)[1] || '';
        }
    } catch (e) {
        console.log('Error: ', e, dw.qb.preQuery, preJson);
    }
};

dw.qb.addFieldSelection = function () {
    dw.qb.toogleFieldSelection(this, true);
};
dw.qb.removeFieldSelection = function () {
    dw.qb.toogleFieldSelection(this, false);
};

dw.qb.toogleFieldSelection = function (list, sel) {
    var $el = dw.qb.ui.fieldsSelected.find('option'),
        el = $el.eq(0);
    $el.attr('selected', false);

    dw.qb.selectedFields = [];
    for (var i = 0; i < $el.length; i++) {
        dw.qb.selectedFields.push($copado($el[i]).val());
    }
    dw.qb.buildQuery();
};

dw.qb.onSelectObject = function (objName, objLabel) {
    dw.qb.selectedCompleteObject = objLabel;
    dw.qb.objectSelected = objName;
    dw.qb.ui.objectLabel = dw.qb.ui.objectLabel || $copado('#selected-obj');
    dw.qb.ui.objectLabel.html(dw.qb.objectSelected);
    dw.qb.ui.query.html('');
    dw.qb.ui.fields.html('');
    copadoApp.enabledBtn('#getFields', 'Get fields');
};

dw.qb.selectFieldEx = function () {
    var field = dw.qb.ui.fieldsEx.val();
    //unselect prev external selected
    var prev = dw.qb.externalId;
    dw.qb.externalId = field;
    dw.qb.iao = dw.qb.ui.attachmentOptions.val();
    //select on fields ( clear selection first )
    $copado('option:selected', dw.qb.ui.fields).prop('selected', false);
    var t = $copado('option[value="' + dw.qb.externalId + '"]', dw.qb.ui.fields).prop('selected', 'selected');
    moveSelectedOptions(
        dw.qb.ui.fields.attr('id'),
        dw.qb.ui.fieldsSelected.attr('id'),
        dw.qb.ui.rightHidden.attr('id'),
        dw.qb.ui.leftHidden.attr('id')
    );
    // prevent the selection ability on the user-chosen externalId field.
    $copado('option', dw.qb.ui.fieldsSelected).removeAttr('disabled');
    $copado('option[value="' + dw.qb.externalId + '"]', dw.qb.ui.fieldsSelected).prop('disabled', 'disabled');
    $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
    var ownerIdFieldVal = dw.qb.ui.matchOwner.prop('checked');
    dw.qb.selectOwnerId(ownerIdFieldVal);
    var recordTypeFieldVal = dw.qb.ui.matchRecordType.prop('checked');
    dw.qb.selectRecordType(recordTypeFieldVal);
};

dw.qb.selectAttachmentOption = function () {
    console.log('Attachment option selected: ', dw.qb.ui.attachmentOptions);
};

dw.qb.selectOwnerId = function (onlyOnchange) {
    if (onlyOnchange) {
        var ownerIdFieldVal = dw.qb.ui.matchOwner.prop('checked');
        $copado('option:selected', dw.qb.ui.fields).prop('selected', false);
        $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
        if (ownerIdFieldVal) {
            $copado('option[value="OwnerId"]', dw.qb.ui.fields).prop('selected', 'selected');
            moveSelectedOptions(
                dw.qb.ui.fields.attr('id'),
                dw.qb.ui.fieldsSelected.attr('id'),
                dw.qb.ui.rightHidden.attr('id'),
                dw.qb.ui.leftHidden.attr('id')
            );
            $copado('option[value="OwnerId"]', dw.qb.ui.fieldsSelected).prop('disabled', 'disabled');
            $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
        } else {
            $copado('option[value="OwnerId"]', dw.qb.ui.fieldsSelected).prop('selected', 'selected');
            $copado('option[value="OwnerId"]', dw.qb.ui.fieldsSelected).removeAttr('disabled');
            moveSelectedOptions(
                dw.qb.ui.fieldsSelected.attr('id'),
                dw.qb.ui.fields.attr('id'),
                dw.qb.ui.leftHidden.attr('id'),
                dw.qb.ui.rightHidden.attr('id')
            );
            $copado('option:selected', dw.qb.ui.fields).prop('selected', false);
        }
    }
};

dw.qb.selectRecordType = function (onlyOnchange) {
    if (onlyOnchange) {
        var recordTypeFieldVal = dw.qb.ui.matchRecordType.prop('checked');
        $copado('option:selected', dw.qb.ui.fields).prop('selected', false);
        $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
        if (recordTypeFieldVal) {
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fields).prop('selected', 'selected');
            moveSelectedOptions(
                dw.qb.ui.fields.attr('id'),
                dw.qb.ui.fieldsSelected.attr('id'),
                dw.qb.ui.rightHidden.attr('id'),
                dw.qb.ui.leftHidden.attr('id')
            );
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fieldsSelected).prop('disabled', 'disabled');
            $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
        } else {
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fieldsSelected).prop('selected', 'selected');
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fieldsSelected).removeAttr('disabled');
            moveSelectedOptions(
                dw.qb.ui.fieldsSelected.attr('id'),
                dw.qb.ui.fields.attr('id'),
                dw.qb.ui.leftHidden.attr('id'),
                dw.qb.ui.rightHidden.attr('id')
            );
            $copado('option:selected', dw.qb.ui.fields).prop('selected', false);
        }
    }
};

dw.qb.selectRecordId = function () {
    $copado('option:selected', dw.qb.ui.fields).prop('selected', false);
    $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
    $copado('option[value="Id"]', dw.qb.ui.fields).prop('selected', 'selected');
    moveSelectedOptions(
        dw.qb.ui.fields.attr('id'),
        dw.qb.ui.fieldsSelected.attr('id'),
        dw.qb.ui.rightHidden.attr('id'),
        dw.qb.ui.leftHidden.attr('id')
    );
    $copado('option[value="Id"]', dw.qb.ui.fieldsSelected).prop('disabled', 'disabled');
    $copado('option:selected', dw.qb.ui.fieldsSelected).prop('selected', false);
};

dw.qb.buildQuery = function () {
    var query = dw.qb.queryTemplate
        .replace('fields', dw.qb.selectedFields.join(','))
        .replace('object', dw.qb.objectSelected)
        .replace('clause', dw.qb.where ? ' where ' + dw.qb.where : '');

    dw.qb.ui.query.val(query);
    dw.qb.query = query;
    dw.qb.queryTested = false;
};

dw.qb.getFields = function () {
    dw.qb.selectedFields = [];
    dw.qb.ui.leftHidden.val('');
    dw.qb.ui.rightHidden.val('');

    dw.qb.externalId = false;
    $copado('.query-step-2').hide();

    copadoApp.disabledBtn('#getFields', 'Loading...');

    var cb = function (data) {
        try {
            var len = data.length,
                html = '',
                exhtml = '',
                mOwner = '',
                mRecordtype = '',
                exCounter = 0;

            data = data.sort(function (a, b) {
                a = a.label.toLowerCase();
                b = b.label.toLowerCase();
                return a < b ? -1 : a > b ? 1 : 0;
            });

            for (var i = 0; i < len; i++) {
                var val = data[i].name,
                    option =
                        '<option value="' +
                        val +
                        '" ' +
                        (data[i].externalId ? 'ext="1"' : '') +
                        ' title="' +
                        val +
                        ' ' +
                        data[i].type +
                        '">' +
                        data[i].label +
                        ' (' +
                        val +
                        ')</option>';

                html += option;

                if (data[i].externalId) {
                    exhtml += option;
                    exCounter++;
                } else if (data[i].name == 'OwnerId') {
                    mOwner = data[i].name;
                } else if (data[i].name == 'RecordTypeId') {
                    mRecordtype = data[i].name;
                }
            }
            //unlock button
            copadoApp.enabledBtn('#getFields', 'Get fields');

            if (!exCounter) {
                copadoApp.showMessage('ERROR', copadoLabels.EXTERNAL_ID_REQUIRED);
                return;
            }

            dw.qb.ui.fields.html(html);
            dw.qb.ui.fieldsEx.html(exhtml);

            $copado('.query-step-2').fadeIn();
            if (!mOwner) {
                $copado('.matchOwnerPanel').css('display', 'none');
            }
            if (!mRecordtype) {
                $copado('.matchRecordTypePanel').css('display', 'none');
            }

            //preselect first external
            !dw.qb.rebuilding && dw.qb.selectFieldEx();
            !dw.qb.rebuilding && dw.qb.selectRecordId();

            //if rebuilding
            if (dw.qb.rebuilding) {
                dw.qb.rebuilding = 0;
                var fields = dw.qb.preData.q
                    .replace(/ from /i, ' FROM ')
                    .replace(/select /i, ' SELECT ')
                    .split(' FROM ')[0]
                    .split('SELECT ')[1]
                    .split(',');

                // clear any possible selection, and "select" the fields arlready named in the query
                $copado('option', dw.qb.ui.fields).removeAttr('selected');
                $copado(fields).each(function (el, val) {
                    var t = $copado('option[value="' + val.trim() + '"]', dw.qb.ui.fields).prop('selected', 'selected');
                });
                moveSelectedOptions(
                    dw.qb.ui.fields.attr('id'),
                    dw.qb.ui.fieldsSelected.attr('id'),
                    dw.qb.ui.rightHidden.attr('id'),
                    dw.qb.ui.leftHidden.attr('id')
                );

                //select external Id
                dw.qb.ui.fieldsEx.val(dw.qb.preData.f);

                dw.qb.ui.attachmentOptions.val(dw.qb.preData.iao ? dw.qb.preData.iao : 'none');
                dw.qb.ui.matchOwner.prop('checked', dw.qb.preData ? dw.qb.preData.containsOwnerId : false);
                dw.qb.ui.matchRecordType.prop('checked', dw.qb.preData ? dw.qb.preData.containsRecordTypeId : false);
                dw.qb.selectFieldEx();
                //dw.qb.ui.fieldsEx.change();

                //paste query
                setTimeout(function () {
                    dw.qb.ui.query.val(dw.qb.preData.q);

                    // clean dirty flag
                    copadoStep.dirty = false;
                }, 321);
            }
        } catch (e) {
            console.warn('Error on QB Rebuild', e);
        }
    };

    //remote call
    dw.u.getRemote(rock.config.describe_url.replace('{sobject}', dw.qb.objectSelected), function (res) {
        cb(res);
    });
};

dw.qb.getObjectToRebuild = function () {
    var me = dw.qb;
    return {
        sco: me.selectedCompleteObject,
        fs: me.allfields,
        efs: me.allexfields,
        w: dw.qb.where
    };
};

dw.qb.init = function (force, orgId) {
    //reset
    //TODO: move this to function
    $copado('#selected-obj, #fields-unselected, #fields-selected, #query-label,#fieldsEx')
        .empty()
        .val('');
    $copado(".duelingListBox select[id$=':leftList']").empty();
    $copado(".duelingListBox select[id$=':rightList']").empty();

    dw.qb.ui.fields = $copado(".duelingListBox select[id$=':leftList']");
    dw.qb.ui.fieldsSelected = $copado(".duelingListBox select[id$=':rightList']");
    dw.qb.ui.leftHidden = $copado(".duelingListBox input[id$=':leftHidden']");
    dw.qb.ui.rightHidden = $copado(".duelingListBox input[id$=':rightHidden']");

    // hide the useless up-down buttons
    $copado('.duelingListBox td.buttonCell:last-of-type').hide();
    $copado('#query-step-2').hide();

    console.time('get Data attach');
    //start component
    dw.u.getCachedRemote({
        url: rock.config.sobjects_url,
        name: 'Data',
        force: force,
        parentId: orgId,
        success: function (res, date) {
            dw.qb.createCacheDeleteButton(date);

            dw.qb.startQueryBuilder(res);
        },
        error: function (r) {
            console.warn('dw.u.getCachedRemote Error: ', r);
        }
    });
};

dw.qb.testQuery = function (e) {
    e.preventDefault();
    if (!dw.qb.query) {
        return false;
    }

    if (dw.qb.type === 'Bulk Data') {
        if (dw.qb.query.match(/\(.*[select].*\)|COUNT\(|SUM\(/i)) {
            copadoApp.showMessage('ERROR', copadoLabels.BULK_SOQL_ERROR);
            return false;
        }
    }

    var queryFields = dw.qb.query.match(/select (.*) from/i);
    queryFields = queryFields && queryFields.length > 1 ? queryFields[1] : false;
    //check query malformed
    if (!queryFields) {
        copadoApp.showMessage('ERROR', copadoLabels.SOQL_MALFORMED_ERROR);
        return false;
    }
    var hasExternal = false;
    //check query has at least one external ID

    $copado('#fieldsEx option').each(function () {
        if (queryFields.indexOf(this.value) !== -1) {
            hasExternal = true;
            return false;
        }
    });

    if (!hasExternal) {
        copadoApp.showMessage('ERROR', copadoLabels.SOQL_HASNOT_EXTERNALID_ERROR);
        return false;
    }
    var idCount = queryFields.match(/\b(id)\b/gim);
    var attachmentOptionsValue = dw.qb.ui.attachmentOptions.val();
    var matchOwnerFieldVal = dw.qb.ui.matchOwner.prop('checked');
    var recordTypeFieldVal = dw.qb.ui.matchRecordType.prop('checked');

    if (!idCount && (matchOwnerFieldVal || recordTypeFieldVal || (attachmentOptionsValue && attachmentOptionsValue != 'none'))) {
        copadoApp.showMessage('ERROR', copadoLabels.SOQL_HASNOT_ID_ERROR);
        return false;
    }

    //check query has ownerId
    if (matchOwnerFieldVal && queryFields.indexOf('OwnerId') === -1) {
        copadoApp.showMessage('ERROR', copadoLabels.MATCH_OWNER_WARNING);
        return false;
    }

    //check query has ownerId
    if (recordTypeFieldVal && queryFields.indexOf('RecordTypeId') === -1) {
        copadoApp.showMessage('ERROR', copadoLabels.MATCH_RECORD_TYPE_WARNING);
        return false;
    }

    $copado('#testQuery')
        .attr('disabled', 'disabled')
        .html(copadoLabels.TESTING);

    copadoApp.lock();
    dw.u.getRemote(
        rock.config.testquery_url,
        function (r) {
            copadoApp.unlock();
            if (r && r.done) {
                dw.qb.queryTested = true;
                copadoApp.showMessage('CONFIRM', copadoLabels.QUERY_TEST_SUCCESSFUL);
            } else {
                dw.qb.queryTested = false;
                copadoApp.showMessage('ERROR', r.error);
            }
            $copado('#testQuery')
                .removeAttr('disabled')
                .html(copadoLabels.TEST_QUERY);
        },
        dw.qb.query,
        false,
        function (r) {
            //TODO: unify this code and response error
            copadoApp.unlock();
            dw.qb.queryTested = false;
            copadoApp.showMessage('ERROR', r.error || r);

            $copado('#testQuery')
                .removeAttr('disabled')
                .html(copadoLabels.TEST_QUERY);
        }
    );
    return false;
};

dw.qb.getDataJson = function () {
    var obj = {
        o: dw.qb.objectSelected,
        q: dw.qb.query,
        f: dw.qb.externalId,
        rb: dw.qb.getObjectToRebuild(),
        iao: dw.qb.ui.attachmentOptions.val() ? dw.qb.ui.attachmentOptions.val() : 'none',
        containsOwnerId: dw.qb.ui.matchOwner.prop('checked'),
        containsRecordTypeId: dw.qb.ui.matchRecordType.prop('checked')
    };
    return JSON.stringify(obj);
};

/***************/
//Overiding ScreenLocker to handle from copadoApp instead statusManager
function lockScreen() { }

function unlockScreen() { }
/**************/
