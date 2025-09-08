@IsTest
private class UnsplashServiceTest {

    private class UnsplashMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"urls":{"small":"https://img.small/x","regular":"https://img.reg/y"}}');
            return res;
        }
    }

    @IsTest
    static void testEnqueueDirect() {
        Item__c i = new Item__c(Name='NovaPhone Pro', Family__c='Phones', Type__c='Pro', Price__c=999);
        insert i;

        Test.setMock(HttpCalloutMock.class, new UnsplashMock());
        Test.startTest();
        UnsplashService.enqueueImageLookup(new List<Item__c>{ i });
        Test.stopTest();

        Item__c fetched = [SELECT Image__c FROM Item__c WHERE Id=:i.Id];
        System.assertNotEquals(null, fetched.Image__c, 'Image__c should be populated');
        System.assert(
            fetched.Image__c.startsWith('https://img.'),
            'Image__c did not start with expected prefix, was: ' + fetched.Image__c
        );
    }
}
