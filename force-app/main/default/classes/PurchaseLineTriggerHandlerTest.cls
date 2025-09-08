@IsTest
private class PurchaseLineTriggerHandlerTest {

    @IsTest
    static void testTotalsInsertUpdateDelete() {
        Item__c a = TestDataFactory.makeItem('A', 'Headphones', 'Standard', 100, 'aa');
        Item__c b = TestDataFactory.makeItem('B', 'Phones',     'Pro',      50,  'bb');

        Purchase__c p = new Purchase__c(Name='PO-1');
        insert p;

        PurchaseLine__c l1 = new PurchaseLine__c(
            PurchaseId__c = p.Id,
            ItemId__c      = a.Id,
            Amount__c      = 2,
            UnitCost__c    = 100
        );
        PurchaseLine__c l2 = new PurchaseLine__c(
            PurchaseId__c = p.Id,
            ItemId__c      = b.Id,
            Amount__c      = 1,
            UnitCost__c    = 50
        );
        insert new List<PurchaseLine__c>{ l1, l2 };

        p = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id=:p.Id];
        System.assertEquals(3, p.TotalItems__c, 'after insert: quantity sum should be 3');
        System.assertEquals(250, p.GrandTotal__c, 'after insert: total amount mismatch');

        // UPDATE
        l2.Amount__c = 3;
        update l2;
        p = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id=:p.Id];
        System.assertEquals(5, p.TotalItems__c, 'after update: quantity sum should be 5');
        System.assertEquals(350, p.GrandTotal__c, 'after update: total amount mismatch');
        delete l1;
        p = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id=:p.Id];
        System.assertEquals(3, p.TotalItems__c, 'after delete: quantity sum should be 3');
        System.assertEquals(150, p.GrandTotal__c, 'after delete: total amount mismatch');
    }
}
