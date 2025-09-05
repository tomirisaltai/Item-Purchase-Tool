trigger PurchaseLineTrigger on PurchaseLine__c (
    after insert, after update, after delete, after undelete
) {
    PurchaseLineTriggerHandler.handle(Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.new, Trigger.old);
}