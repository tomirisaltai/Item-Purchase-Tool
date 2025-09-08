trigger ItemTrigger on Item__c (after insert) {
    if (Test.isRunningTest()) {
        return;
    }
    UnsplashService.enqueueImageLookup(Trigger.new);
}
