trigger ItemTrigger on Item__c (after insert) {
    UnsplashService.enqueueImageLookup(Trigger.new);
}
