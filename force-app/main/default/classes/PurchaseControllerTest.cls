@IsTest
private class PurchaseControllerTest {

    @IsTest
    static void testCreatePurchaseFlow() {
        // Account (used as Client)
        Account acc = TestDataFactory.makeAccount();

        // Items to purchase
        Item__c i1 = TestDataFactory.makeItem('Item-1', 'Phones',  'Standard', 120, 'desc1');
        Item__c i2 = TestDataFactory.makeItem('Item-2', 'Laptops', 'Pro',      800, 'desc2');

        Test.startTest();
        Id purchaseId = PurchaseController.createPurchase(acc.Id, new List<Id>{ i1.Id, i2.Id });
        Test.stopTest();

        System.assertNotEquals(null, purchaseId, 'Should return Purchase__c Id');

        // Verify header
        Purchase__c p = [
            SELECT Id, ClientId__c, TotalItems__c, GrandTotal__c
            FROM Purchase__c
            WHERE Id = :purchaseId
        ];
        System.assertEquals(acc.Id, p.ClientId__c, 'Linked to Account via ClientId__c');
        System.assert(p.TotalItems__c > 0, 'Totals should be populated');
        System.assert(p.GrandTotal__c > 0, 'Grand total must be positive');
        Integer lineCount = [
            SELECT COUNT() FROM PurchaseLine__c WHERE PurchaseId__c = :p.Id
        ];
        System.assertEquals(2, lineCount, 'Two PurchaseLine__c rows should be created');
    }
}
