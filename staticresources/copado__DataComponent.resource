//namespace
var dw = dw || {};

dw.qb = dw.qb || {};

dw.qb.type = "Data";
console.log("step type ==>", dw.qb.type);
dw.qb.preQuery = "";

dw.qb.createCacheDeleteButton = function(date) {
    if (!date) {
        $copado("[id*=removeCacheContainer]").hide();
    } else {
        var $btn = $copado("[id$=removeCache]");
        console.log($btn);
        console.log($btn.html());
        if ($btn && $btn.html())
            $btn.html(
                $btn
                    .html()
                    .replace("__DATE__", date)
                    .replace("__METATYPE__", "")
            ).show();
    }
};

dw.qb.removeCached = function() {
    //hide

    //reload
    $copado("#loading").show();
    $copado("#queryBuilder").hide();

    init(true);

    return false;
};

dw.qb.startQueryBuilder = function(data, parsed) {
    try {
        //normalize data
        var source = [],
            len = data.length;
        for (var i = 0; i < len; i++) {
            source[i] = data[i].L + " (" + data[i].N + ")";
        }

        source.sort();

        if ($copado("#objects").length > 0) {
            // Create a jqxDropDownList
            var $objects = $copado("#objects").jqxComboBox({
                source: source,
                autoComplete: true,
                width: "400px",
                height: "25px",
                selectedIndex: 0
            });

            $objects.bind("select", function(event) {
                var args = event.args;
                if (args && !isNaN(args.index)) {
                    var item = $objects.jqxComboBox("listBox").visibleItems[args.index];
                    dw.qb.objectSelected = item.label.split("(")[1].split(")")[0];
                    dw.qb.selectedCompleteObject = item.label;
                    dw.qb.onSelectObject();
                }
            });
        }
        //its defined at first, not after refresh metadata since parsed inherited from the page but component
        if(parsed) {
            $copado("#attachmentOptions").val(parsed.iao);
        }
        //start get fields
        dw.qb.ui.getFields = $copado("#getFields");
        dw.qb.ui.testQuery = $copado("#testQuery");

        dw.qb.ui.fields = $copado("#fields-unselected");
        dw.qb.ui.fieldsSelected = $copado("#fields-selected");

        dw.qb.ui.fieldsEx = $copado("#fieldsEx").on("change", dw.qb.selectFieldEx);
        dw.qb.ui.attachmentOptions = $copado("#attachmentOptions").on("change", dw.qb.iao);
        dw.qb.ui.matchOwner = $copado("#matchOwner").on("change", dw.qb.selectOwnerId);
        dw.qb.ui.matchRecordType = $copado("#matchRecordType").on("change", dw.qb.selectRecordType);
        dw.qb.ui.leftHidden = $copado("#fields-unselected");
        dw.qb.ui.rightHidden = $copado("#fields-selected");

        if (parsed) {
            dw.qb.ui.matchOwner.prop("checked", parsed && parsed.containsOwnerId ? parsed.containsOwnerId : false);
            dw.qb.ui.matchRecordType.prop("checked", parsed && parsed.containsRecordTypeId ? parsed.containsRecordTypeId : false);
        }

        dw.qb.ui.getFields.on("click", function(e) {
            if (!dw.qb.objectSelected) {
                return;
            }

            //lock button
            dw.qb.ui.getFields.attr("disabled", "disabled");

            dw.qb.ui.fields.html(labels.config.loading_label);
            //call get
            dw.qb.getFields();

            return false;
        });

        //query label
        dw.qb.ui.query = $copado(".query-label");

        dw.qb.ui.$objects = $objects;

        //fields build

        dw.qb.ui.fieldsSelected.on("change", dw.qb.removeFieldSelection);
        dw.qb.ui.fields.on("change", dw.qb.addFieldSelection);

        $copado("#testQuery").on("click", dw.qb.testQuery);
        $copado("#loading").hide();
        $copado("#queryBuilder").fadeIn();

        if ($copado("#objects").length > 0) {
            dw.qb.preQuery && dw.qb.rebuild();
            $objects.jqxComboBox("focus");
        }

        //bind query hand edition sync
        dw.qb.ui.query.on("keyup change", function() {
            dw.qb.query = dw.qb.ui.query.val();
            var w = dw.qb.query.split(/ where /i);
            dw.qb.where = w.length > 1 ? " where " + w[1] : "";
        });
    } catch (e) {
        console.log("Error on QB init", e);
    }
};

dw.qb.objectSelected = false;
dw.qb.ui = {};
dw.qb.selectedFields = [];
dw.qb.queryTemplate = "Select fields from object clause";
dw.qb.query = false;

dw.qb.rebuild = function() {
    try {
        var preJson = dw.qb.preQuery;
        if (preJson.rb) {
            dw.qb.preData = preJson;
            //preselect objects
            var item = dw.qb.ui.$objects.jqxComboBox("getItemByValue", preJson.rb.sco);
            if (item) {
                dw.qb.ui.$objects.jqxComboBox("selectItem", item);

                //get fields (cache?)
                dw.qb.ui.getFields.click();

                //getFileds callback
                dw.qb.rebuilding = 1;
            }

            dw.qb.where = dw.qb.preData.q.split(/ where /i)[1] || "";
        }
    } catch (e) {
        console.log("Error: ", e, dw.qb.preQuery, preJson);
    }
};

dw.qb.addFieldSelection = function() {
    dw.qb.toogleFieldSelection(this, true);
};
dw.qb.removeFieldSelection = function() {
    dw.qb.toogleFieldSelection(this, false);
};

dw.qb.toogleFieldSelection = function(list, sel) {
    var $el = $copado(list).find("option:selected"),
        el = $el.eq(0),
        field = $el.val();

    if (!field) {
        return;
    }

    $el.attr("selected", false);

    if (!sel) {
        //remove
        //only remove if not is the only one external
        if ($el.is("[ext]") && dw.qb.ui.fieldsSelected.find("option[ext]").length < 2) {
            alert(labels.config.req_ext_id_label);
            return;
        }
        var index = dw.qb.selectedFields.indexOf(field);
        dw.qb.selectedFields.splice(index, 1);
        dw.qb.ui.fields.append(el);
    } else {
        dw.qb.selectedFields.push(field);
        dw.qb.ui.fieldsSelected.append(el);
    }
    dw.qb.buildQuery();
};

dw.qb.onSelectObject = function() {
    dw.qb.ui.objectLabel = dw.qb.ui.objectLabel || $copado("#selected-obj");
    dw.qb.ui.objectLabel.html(dw.qb.objectSelected);
    dw.qb.ui.query.html("");
    dw.qb.ui.fields.html("");
    dw.qb.ui.getFields.removeAttr("disabled");
};

dw.qb.selectFieldEx = function() {
    var field = dw.qb.ui.fieldsEx.val();
    console.log("change ex", field);

    //unselect prev external selected
    var prev = dw.qb.externalId;
    dw.qb.externalId = field;

    //select on fields
    //$copado('option[value="'+dw.qb.externalId+'"]',dw.qb.ui.fields).click();
    $copado('option[value="' + dw.qb.externalId + '"]', dw.qb.ui.fields).attr("selected", "selected");
    dw.qb.ui.fields.change();

    dw.qb.selectRecordType(true);
    dw.qb.selectOwnerId(true);
    if (prev) {
        //$copado('option[value="'+prev+'"]',dw.qb.ui.fieldsSelected).click();
        $copado('option[value="' + prev + '"]', dw.qb.ui.fieldsSelected).attr("selected", "selected");
        dw.qb.ui.fieldsSelected.change();
    }
};

dw.qb.buildQuery = function() {
    var query = dw.qb.queryTemplate
        .replace("fields", dw.qb.selectedFields.join(","))
        .replace("object", dw.qb.objectSelected)
        .replace("clause", dw.qb.where ? " where " + dw.qb.where : "");

    dw.qb.ui.query.val(query);

    dw.qb.query = query;
    dw.qb.queryTested = false;
};

dw.qb.getFields = function() {
    $copado("select#fields-selected option").each(function() {
        $copado(this).remove();
    });
    dw.qb.selectedFields = [];
    dw.qb.externalId = false;
    $copado(".query-step-2").hide();
    dw.qb.ui.fieldsSelected.splice(1, dw.qb.ui.fieldsSelected.length);
    dw.qb.ui.getFields.attr("disabled", "disabled").html(labels.config.loading_label);

    var cb = function(data) {
        try {
            var len = data.length,
                html = "",
                exhtml = "",
                exCounter = 0,
                mOwner = "",
                mRecordtype = "";

            data = data.sort(function(a, b) {
                if (a.label.toLowerCase() < b.label.toLowerCase()) return -1;
                if (a.label.toLowerCase() > b.label.toLowerCase()) return 1;

                return 0;
            });

            for (var i = 0; i < len; i++) {
                var val = data[i].name,
                    option =
                        '<option value="' +
                        val +
                        '" ' +
                        (data[i].externalId ? 'ext="1"' : "") +
                        ' title="' +
                        val +
                        " " +
                        data[i].type +
                        '">' +
                        data[i].label +
                        " (" +
                        val +
                        ")</option>";
                html += option;

                if (data[i].externalId) {
                    exhtml += option;
                    exCounter++;
                } else if (data[i].name == "OwnerId") {
                    mOwner = data[i].name;
                } else if (data[i].name == "RecordTypeId") {
                    mRecordtype = data[i].name;
                }
            }
            //unlock button
            dw.qb.ui.getFields.removeAttr("disabled").html("Get fields");

            if (!exCounter) {
                alert(labels.config.req_ext_id_label);
                return;
            }

            dw.qb.ui.fields.html(html);
            dw.qb.ui.fieldsEx.html(exhtml);
            dw.qb.ui.testQuery.removeAttr("disabled");
            dw.qb.ui.testQuery.addClass("slds-button_success");

            $copado(".query-step-2").fadeIn();

            $copado(".matchOwnerPanel").css("display", !mOwner ? " none" : "");

            $copado(".matchRecordTypePanel").css("display", !mRecordtype ? " none" : "");

            //preselect first external
            !dw.qb.rebuilding && dw.qb.selectFieldEx();

            //if rebuilding
            if (dw.qb.rebuilding) {
                dw.qb.rebuilding = 0;
                var fields = dw.qb.preData.q
                    .replace(/ from /i, " FROM ")
                    .replace(/select /i, " SELECT ")
                    .split(" FROM ")[0]
                    .split("SELECT ")[1]
                    .split(",");

                $copado(fields).each(function(el, val) {
                    dw.qb.ui.fields.val(val);
                    dw.qb.ui.fields.change();
                });

                //select external Id
                dw.qb.ui.fieldsEx.val(dw.qb.preData.f);
                dw.qb.selectFieldEx();
                //dw.qb.ui.fieldsEx.change();

                //paste query
                setTimeout(function() {
                    dw.qb.ui.query.val(dw.qb.preData.q);
                }, 321);
            }
        } catch (e) {
            console.log("Error on QB Rebuild", e);
        }
    };

    //remote call
    dw.u.getRemote(datasetup.config.describe_url.replace("{sobject}", dw.qb.objectSelected), function(res) {
        cb(res);
    });
};

dw.qb.getObjectToRebuild = function() {
    var me = dw.qb;
    return {
        sco: me.selectedCompleteObject,
        fs: me.allfields,
        efs: me.allexfields,
        w: dw.qb.where
    };
};

dw.qb.selectOwnerId = function(onlyOnchange) {
    if (onlyOnchange) {
        var ownerIdFieldVal = dw.qb.ui.matchOwner.prop("checked");
        $copado("option:selected", dw.qb.ui.fields).prop("selected", false);
        $copado("option:selected", dw.qb.ui.fieldsSelected).prop("selected", false);
        if (ownerIdFieldVal) {
            $copado('option[value="OwnerId"]', dw.qb.ui.fields).prop("selected", "selected");
            moveSelectedOptions(
                dw.qb.ui.fields.attr("id"),
                dw.qb.ui.fieldsSelected.attr("id"),
                dw.qb.ui.rightHidden.attr("id"),
                dw.qb.ui.leftHidden.attr("id")
            );
            $copado('option[value="OwnerId"]', dw.qb.ui.fieldsSelected).prop("disabled", "disabled");
            $copado("option:selected", dw.qb.ui.fieldsSelected).prop("selected", false);
        } else {
            $copado('option[value="OwnerId"]', dw.qb.ui.fieldsSelected).prop("selected", "selected");
            $copado('option[value="OwnerId"]', dw.qb.ui.fieldsSelected).removeAttr("disabled");
            moveSelectedOptions(
                dw.qb.ui.fieldsSelected.attr("id"),
                dw.qb.ui.fields.attr("id"),
                dw.qb.ui.leftHidden.attr("id"),
                dw.qb.ui.rightHidden.attr("id")
            );
            $copado("option:selected", dw.qb.ui.fields).prop("selected", false);
        }
    }
};

dw.qb.selectRecordType = function(onlyOnchange) {
    if (onlyOnchange) {
        var recordTypeFieldVal = dw.qb.ui.matchRecordType.prop("checked");
        $copado("option:selected", dw.qb.ui.fields).prop("selected", false);
        $copado("option:selected", dw.qb.ui.fieldsSelected).prop("selected", false);
        if (recordTypeFieldVal) {
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fields).prop("selected", "selected");
            moveSelectedOptions(
                dw.qb.ui.fields.attr("id"),
                dw.qb.ui.fieldsSelected.attr("id"),
                dw.qb.ui.rightHidden.attr("id"),
                dw.qb.ui.leftHidden.attr("id")
            );
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fieldsSelected).prop("disabled", "disabled");
            $copado("option:selected", dw.qb.ui.fieldsSelected).prop("selected", false);
        } else {
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fieldsSelected).prop("selected", "selected");
            $copado('option[value="RecordTypeId"]', dw.qb.ui.fieldsSelected).removeAttr("disabled");
            moveSelectedOptions(
                dw.qb.ui.fieldsSelected.attr("id"),
                dw.qb.ui.fields.attr("id"),
                dw.qb.ui.leftHidden.attr("id"),
                dw.qb.ui.rightHidden.attr("id")
            );
            $copado("option:selected", dw.qb.ui.fields).prop("selected", false);
        }
    }
};

dw.qb.testQuery = function(e) {
    e.preventDefault();

    if (!dw.qb.query) {
        return false;
    }

    if (datasetup.type === "Bulk Data") {
        if (dw.qb.query.match(/\(.*[select].*\)|COUNT\(|SUM\(/i)) {
            alert(labels.config.bulk_soql_error);
            return false;
        }
    }

    var queryFields = dw.qb.query.match(/select (.*) from/i);
    queryFields = queryFields && queryFields.length > 1 ? queryFields[1] : false;
    //check query malformed
    if (!queryFields) {
        alert();
        return false;
    }
    var hasExternal = false;
    //check query has at least one external ID
    $copado("#fieldsEx option").each(function() {
        if (queryFields.indexOf(this.value) !== -1) {
            hasExternal = true;
            return false;
        }
    });

    var idCount = queryFields.match(/\b(id)\b/gim);
    var attachmentOptionsValue = dw.qb.ui.attachmentOptions.val();
    var matchOwnerFieldVal = dw.qb.ui.matchOwner.prop("checked");
    var recordTypeFieldVal = dw.qb.ui.matchRecordType.prop("checked");

    if (!idCount && (matchOwnerFieldVal || recordTypeFieldVal || (attachmentOptionsValue && attachmentOptionsValue != "none"))) {
        showMessage("ERROR", labels.config.SOQL_HASNOT_ID_ERROR);
        return false;
    }

    //check query has recordTypeId
    if (matchOwnerFieldVal && !(matchOwnerFieldVal && queryFields.indexOf("OwnerId") !== -1)) {
        showMessage("ERROR", labels.config.MATCH_OWNER_WARNING);
        return false;
    }

    //check query has ownerId
    if (recordTypeFieldVal && !(recordTypeFieldVal && queryFields.indexOf("RecordTypeId") !== -1)) {
        showMessage("ERROR", labels.config.MATCH_RECORD_TYPE_WARNING);
        return false;
    }

    if (!hasExternal) {
        showMessage("ERROR", labels.config.soql_hasnotext_error);
        return false;
    }

    $copado("#testQuery")
        .attr("disabled", "disabled")
        .html(labels.config.testing);

    lockScreen();
    dw.u.getRemote(
        datasetup.config.testquery_url,
        function(r) {
            if (r && r.done) {
                dw.qb.queryTested = true;
                showMessage("CONFIRM", labels.config.successful_testing);
            } else {
                dw.qb.queryTested = false;
                showMessage("ERROR", r.error);
            }
            unlockScreen();
            $copado("#testQuery")
                .removeAttr("disabled")
                .html(labels.config.test_query);
        },
        dw.qb.query,
        false,
        function(r) {
            //TODO: unify this code and response error

            dw.qb.queryTested = false;
            showMessage("ERROR", r.error || r);
            unlockScreen();
            $copado("#testQuery")
                .removeAttr("disabled")
                .html(labels.config.test_query);
        }
    );

    return false;
};

function init(force, parsed) {
    //start component
    dw.u.getCachedRemote({
        url: datasetup.config.sobjects_url,
        name: "Data",
        force: force,
        parentId: datasetup.org__c,
        success: function(res, date) {
            dw.qb.createCacheDeleteButton(date);
            console.warn("rest", res);
            dw.qb.startQueryBuilder(res, parsed);
        },
        error: function(r) {
            console.log("Error init: ", r);
        }
    });
}

moveSelectedOptions = function(idFrom, idTo, idHdnFrom, idHdnTo) {
    if (idFrom.lastIndexOf("unselected") !== -1) {
        dw.qb.toogleFieldSelection(dw.qb.ui.fields, true); // Add field
    } else {
        dw.qb.toogleFieldSelection(dw.qb.ui.fieldsSelected, false); // Remove field
    }
};
