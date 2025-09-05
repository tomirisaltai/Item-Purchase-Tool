public with sharing class PurchaseController {

    @AuraEnabled
    public static Id checkout(Id accountId, List<PurchaseLine__c> lines) {
        if (accountId == null || lines == null || lines.isEmpty()) {
            throw new AuraHandledException('Account and at least one line are required.');
        }

        // Create parent Purchase
        Purchase__c pur = new Purchase__c(ClientId__c = accountId, Name = 'Purchase');
        insert pur;

        // Attach and insert lines (trigger will roll up totals)
        for (PurchaseLine__c l : lines) l.PurchaseId__c = pur.Id;
        insert lines;

        return pur.Id;
    }
}
