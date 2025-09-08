@IsTest
private class ItemControllerTest {

    @IsTest
    static void testSearchNameAndDescriptionAndPagination() {
        // seed 6 items
        List<Item__c> items = TestDataFactory.seedItemsForSearch();

        Test.startTest();
        // Search by NAME
        Integer totalByName = ItemController.countItems(null, null, 'ZenBook');
        List<Item__c> rowsByName = ItemController.listItems(null, null, 'ZenBook', 50, 0);

        // Search by DESCRIPTION
        Integer totalByDesc = ItemController.countItems(null, null, 'titanium');
        List<Item__c> rowsByDesc = ItemController.listItems(null, null, 'titanium', 50, 0);

        // Filter by Family + Type
        Integer totalPhonesPro = ItemController.countItems('Phones', 'Pro', null);
        List<Item__c> rowsPhonesPro = ItemController.listItems('Phones', 'Pro', null, 50, 0);

        // Pagination sanity
        List<Item__c> page1 = ItemController.listItems(null, null, null, 2, 0);
        List<Item__c> page2 = ItemController.listItems(null, null, null, 2, 2);
        Test.stopTest();

        System.assertEquals(1, totalByName, 'Name search should find ZenBook 14');
        System.assertEquals(1, rowsByName.size());
        System.assertEquals('ZenBook 14', rowsByName[0].Name);

        System.assertEquals(1, totalByDesc, 'Description search should match "titanium" (NovaPhone Pro)');
        System.assertEquals('NovaPhone Pro', rowsByDesc[0].Name);
        System.assertNotEquals(null, rowsByDesc[0].Description__c, 'SELECT must include Description__c');

        System.assertEquals(1, totalPhonesPro, 'Phones + Pro should return NovaPhone Pro only');
        System.assertEquals('NovaPhone Pro', rowsPhonesPro[0].Name);

        System.assertEquals(2, page1.size(), 'limit 2 page1');
        System.assertEquals(2, page2.size(), 'limit 2 page2');
        System.assertNotEquals(page1[0].Id, page2[0].Id, 'pages should differ');
    }
}
