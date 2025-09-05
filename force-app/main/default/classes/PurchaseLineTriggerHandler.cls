public with sharing class PurchaseLineTriggerHandler {
    public static void handle(Boolean isInsert, Boolean isUpdate, Boolean isDelete,
                              List<PurchaseLine__c> newList, List<PurchaseLine__c> oldList) {
        Set<Id> purchaseIds = new Set<Id>();
        if (isInsert || isUpdate) for (PurchaseLine__c pl : newList) purchaseIds.add(pl.PurchaseId__c);
        if (isDelete) for (PurchaseLine__c pl : oldList) purchaseIds.add(pl.PurchaseId__c);
        if (!purchaseIds.isEmpty()) updateTotals(purchaseIds);
    }

    private static void updateTotals(Set<Id> purchaseIds){
        List<Purchase__c> ups = new List<Purchase__c>();
        for (Purchase__c p : [
            SELECT Id, TotalItems__c, GrandTotal__c,
                   (SELECT Amount__c, UnitCost__c FROM PurchaseLines__r)
            FROM Purchase__c WHERE Id IN :purchaseIds
        ]) {
            Decimal totalItems = 0; Decimal grandTotal = 0;
            for (PurchaseLine__c pl : p.PurchaseLines__r) {
                Decimal a = pl.Amount__c == null ? 0 : pl.Amount__c;
                Decimal u = pl.UnitCost__c == null ? 0 : pl.UnitCost__c;
                totalItems += a;
                grandTotal += a * u;
            }
            p.TotalItems__c = (Integer)totalItems;
            p.GrandTotal__c = grandTotal;
            ups.add(p);
        }
        if (!ups.isEmpty()) update ups;
    }
}
