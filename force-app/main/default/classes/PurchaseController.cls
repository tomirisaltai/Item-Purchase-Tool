public with sharing class PurchaseController {

    @AuraEnabled
    public static Id createPurchase(Id accountId, List<Id> itemIds) {
        if (accountId == null) {
            throw new AuraHandledException('Missing Account Id.');
        }
        if (itemIds == null || itemIds.isEmpty()) {
            throw new AuraHandledException('Cart is empty.');
        }
        Map<Id, Integer> qtyByItem = new Map<Id, Integer>();
        for (Id iid : itemIds) {
            qtyByItem.put(iid, (qtyByItem.containsKey(iid) ? qtyByItem.get(iid) + 1 : 1));
        }
        Map<Id, Item__c> itemById = new Map<Id, Item__c>([
            SELECT Id, Price__c
            FROM Item__c
            WHERE Id IN :qtyByItem.keySet()
        ]);
        if (itemById.isEmpty()) {
            throw new AuraHandledException('Selected items were not found.');
        }

        Purchase__c purchase = new Purchase__c(
            ClientId__c = accountId
        );
        insert purchase;

        //Amount__c = QUANTITY, UnitCost__c = ITEM PRICE
        List<PurchaseLine__c> lines = new List<PurchaseLine__c>();
        for (Id itemId : qtyByItem.keySet()) {
            Integer qty = qtyByItem.get(itemId);
            Item__c it  = itemById.get(itemId);
            Decimal unit = (it != null && it.Price__c != null) ? it.Price__c : 0;

            lines.add(new PurchaseLine__c(
                PurchaseId__c = purchase.Id,
                ItemId__c     = itemId,
                UnitCost__c   = unit,
                Amount__c     = qty
            ));
        }
        if (!lines.isEmpty()) insert lines;

        return purchase.Id;
    }
}
