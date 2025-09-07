public with sharing class UnsplashService implements Queueable, Database.AllowsCallouts {

    private static final String BASE_URL = 'https://api.unsplash.com/photos/random';
    private static final String ACCESS_KEY = 'mrOJiHdno_Y9grtfE3Wuk2nwUhlTfzHDyDw5LNNTvwk';

    private final List<Id> itemIds;

    public UnsplashService(List<Id> itemIds) {
        this.itemIds = itemIds;
    }

    public static void enqueueImageLookup(List<Item__c> items) {
        List<Id> ids = new List<Id>();
        for (Item__c i : items) {
            if (String.isBlank(i.Image__c) && !String.isBlank(i.Name)) {
                ids.add(i.Id);
            }
        }
        if (!ids.isEmpty()) {
            System.enqueueJob(new UnsplashService(ids));
        }
    }

    public void execute(QueueableContext qc) {
        List<Item__c> toUpdate = new List<Item__c>();

        for (Item__c i : [
            SELECT Id, Name, Image__c
            FROM Item__c
            WHERE Id IN :itemIds
        ]) {
            if (!String.isBlank(i.Image__c) || String.isBlank(i.Name)) continue;

            String url = fetchImage(i.Name);
            if (!String.isBlank(url)) {
                toUpdate.add(new Item__c(Id = i.Id, Image__c = url));
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    @TestVisible
    private static String fetchImage(String query) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '?query=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Authorization', 'Client-ID ' + ACCESS_KEY);

        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (data.containsKey('urls')) {
                Map<String, Object> urls = (Map<String, Object>) data.get('urls');
                return (String) urls.get('regular');
            }
        }
        return null;
    }
}
