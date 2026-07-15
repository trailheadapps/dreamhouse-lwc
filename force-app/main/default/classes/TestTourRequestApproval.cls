@isTest
private class TestTourRequestApproval {
    // --- Fixtures -----------------------------------------------------------

    private static Broker__c makeBroker(Id realtorUserId) {
        Broker__c broker = new Broker__c(
            Name = 'Test Broker',
            Email__c = 'broker@example.com',
            Phone__c = '1234567890',
            Mobile_Phone__c = '1234567890',
            Title__c = 'Broker',
            Realtor_User__c = realtorUserId
        );
        insert broker;
        return broker;
    }

    private static Property__c makeProperty(Id brokerId) {
        Property__c property = new Property__c(
            Name = 'Test Property',
            Broker__c = brokerId
        );
        insert property;
        return property;
    }

    private static Tour_Request__c makeRequest(Id propertyId, Id customerId) {
        return new Tour_Request__c(
            Property__c = propertyId,
            Customer__c = customerId,
            Requested_Date_Time__c = System.now().addDays(3)
        );
    }

    private static Boolean approvalProcessIsActive() {
        return ![
                SELECT Id
                FROM ProcessDefinition
                WHERE TableEnumOrId = 'Tour_Request__c' AND State = 'Active'
            ]
            .isEmpty();
    }

    // --- Validation rules (deterministic; active regardless of approval) ----

    @isTest
    static void customerRequiredBlocksInsertWithoutCustomer() {
        Id me = UserInfo.getUserId();
        Property__c property = makeProperty(makeBroker(me).Id);

        Tour_Request__c request = makeRequest(property.Id, null);
        DmlException caught;
        Test.startTest();
        try {
            insert request;
        } catch (DmlException e) {
            caught = e;
        }
        Test.stopTest();

        Assert.isNotNull(
            caught,
            'A tour request without a Customer should be blocked by Customer_Required.'
        );
    }

    @isTest
    static void submitRequiresRealtorBlocksPendingWithoutRealtor() {
        Id me = UserInfo.getUserId();
        // Broker has no realtor -> before-save flow leaves Realtor_User__c blank.
        Property__c property = makeProperty(makeBroker(null).Id);
        Tour_Request__c request = makeRequest(property.Id, me);
        insert request;

        request.Status__c = 'Pending Approval';
        DmlException caught;
        Test.startTest();
        try {
            update request;
        } catch (DmlException e) {
            caught = e;
        }
        Test.stopTest();

        Assert.isNotNull(
            caught,
            'Moving a request to Pending Approval without a realtor should be blocked by Submit_Requires_Realtor.'
        );
    }

    // --- Approval lifecycle -------------------------------------------------
    // Approval.process() requires an ACTIVE approval process. T-02 deploys the
    // process INACTIVE (activation is T-03). This test therefore asserts the
    // full submit -> Pending Approval -> approve -> Approved lifecycle when the
    // process is active, and otherwise asserts the deployed-inactive
    // precondition. It needs no code change once T-03 activates the process.

    @isTest
    static void submitAndApproveDrivesStatusToApproved() {
        Id me = UserInfo.getUserId();
        Property__c property = makeProperty(makeBroker(me).Id);
        Tour_Request__c request = makeRequest(property.Id, me);
        insert request; // before-save flow stamps Realtor_User__c = me

        request = [
            SELECT Id, Status__c, Realtor_User__c
            FROM Tour_Request__c
            WHERE Id = :request.Id
        ];
        Assert.areEqual(
            me,
            request.Realtor_User__c,
            'Before-save flow should have stamped the realtor.'
        );

        if (!approvalProcessIsActive()) {
            // T-02 deployed state: process is inactive, so no lifecycle to run.
            Assert.areEqual(
                'Draft',
                request.Status__c,
                'With the approval process inactive the request stays in Draft.'
            );
            return;
        }

        Test.startTest();
        Approval.ProcessSubmitRequest submit = new Approval.ProcessSubmitRequest();
        submit.setObjectId(request.Id);
        Approval.ProcessResult submitResult = Approval.process(submit);

        Tour_Request__c afterSubmit = [
            SELECT Status__c
            FROM Tour_Request__c
            WHERE Id = :request.Id
        ];
        Assert.areEqual(
            'Pending Approval',
            afterSubmit.Status__c,
            'Submitting for approval should set Status = Pending Approval.'
        );

        Approval.ProcessWorkitemRequest approve = new Approval.ProcessWorkitemRequest();
        approve.setAction('Approve');
        approve.setWorkitemId(submitResult.getNewWorkitemIds()[0]);
        Approval.process(approve);
        Test.stopTest();

        Tour_Request__c afterApprove = [
            SELECT Status__c
            FROM Tour_Request__c
            WHERE Id = :request.Id
        ];
        Assert.areEqual(
            'Approved',
            afterApprove.Status__c,
            'Approving should set Status = Approved.'
        );
    }

    @isTest
    static void rejectDrivesStatusToRejected() {
        if (!approvalProcessIsActive()) {
            return; // exercised live in T-03 once the process is active
        }
        Id me = UserInfo.getUserId();
        Property__c property = makeProperty(makeBroker(me).Id);
        Tour_Request__c request = makeRequest(property.Id, me);
        insert request;

        Test.startTest();
        Approval.ProcessSubmitRequest submit = new Approval.ProcessSubmitRequest();
        submit.setObjectId(request.Id);
        Approval.ProcessResult submitResult = Approval.process(submit);

        Approval.ProcessWorkitemRequest reject = new Approval.ProcessWorkitemRequest();
        reject.setAction('Reject');
        reject.setWorkitemId(submitResult.getNewWorkitemIds()[0]);
        Approval.process(reject);
        Test.stopTest();

        Tour_Request__c afterReject = [
            SELECT Status__c
            FROM Tour_Request__c
            WHERE Id = :request.Id
        ];
        Assert.areEqual(
            'Rejected',
            afterReject.Status__c,
            'Rejecting should set Status = Rejected.'
        );
    }

    @isTest
    static void submitBulkRequestsDrivesAllToPending() {
        Id me = UserInfo.getUserId();
        Property__c property = makeProperty(makeBroker(me).Id);
        List<Tour_Request__c> requests = new List<Tour_Request__c>();
        for (Integer i = 0; i < 5; i++) {
            requests.add(makeRequest(property.Id, me));
        }
        insert requests;

        if (!approvalProcessIsActive()) {
            for (Tour_Request__c tr : [
                SELECT Status__c
                FROM Tour_Request__c
                WHERE Id IN :requests
            ]) {
                Assert.areEqual(
                    'Draft',
                    tr.Status__c,
                    'With the process inactive bulk requests stay in Draft.'
                );
            }
            return;
        }

        Test.startTest();
        List<Approval.ProcessSubmitRequest> submits = new List<Approval.ProcessSubmitRequest>();
        for (Tour_Request__c tr : requests) {
            Approval.ProcessSubmitRequest submit = new Approval.ProcessSubmitRequest();
            submit.setObjectId(tr.Id);
            submits.add(submit);
        }
        Approval.process(submits);
        Test.stopTest();

        for (Tour_Request__c tr : [
            SELECT Status__c
            FROM Tour_Request__c
            WHERE Id IN :requests
        ]) {
            Assert.areEqual(
                'Pending Approval',
                tr.Status__c,
                'Every bulk-submitted request should be Pending Approval.'
            );
        }
    }
}
