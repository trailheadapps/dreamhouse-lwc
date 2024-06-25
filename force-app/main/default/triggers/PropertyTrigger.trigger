trigger PropertyTrigger on Property__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    PropertyTriggerHandler.handleTrigger(
        Trigger.new,
        Trigger.newMap,
        Trigger.oldMap,
        Trigger.operationType
    );

}
