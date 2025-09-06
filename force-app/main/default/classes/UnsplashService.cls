public with sharing class UnsplashService {
    private static final String BASE_URL = 'https://api.unsplash.com/photos/random';
    private static final String ACCESS_KEY = 'mrOJiHdno_Y9grtfE3Wuk2nwUhlTfzHDyDw5LNNTvwk';

    @AuraEnabled(cacheable=true)
    public static String fetchRandomImage(String query) {
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