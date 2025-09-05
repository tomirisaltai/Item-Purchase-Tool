public with sharing class HelloWorld {
    @AuraEnabled(cacheable=true)
    public static String sayHello(String name) {
        return 'Hello, ' + name + '!';
    }
}
