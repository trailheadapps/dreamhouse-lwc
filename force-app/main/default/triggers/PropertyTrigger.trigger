trigger PropertyTrigger on Property__c (
    before insert,
    before update,
    after insert,
    after update
) {
    PropertyTriggerHandler handler = new PropertyTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
