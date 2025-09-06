public with sharing class ItemService {
    public class Result {
        @AuraEnabled public List<Item__c> items;
        @AuraEnabled public Integer total;
    }

    @AuraEnabled(cacheable=true)
    public static Result searchItems(String family, String type, String q, Integer limitSize, Integer offsetSize){
        String soql = 'SELECT Id, Name, Family__c, Type__c, Price__c, Image__c FROM Item__c WHERE Id != null';
        if(String.isNotBlank(family)) soql += ' AND Family__c = :family';
        if(String.isNotBlank(type))   soql += ' AND Type__c   = :type';
        if (String.isNotBlank(q)) {
        soql += ' AND (Name LIKE :(\'%' + q + '%\') OR Description__c LIKE :(\'%' + q + '%\'))';
    }

        String countSoql = soql.replace('SELECT Id, Name, Family__c, Type__c, Price__c, Image__c','SELECT COUNT()');

        soql += ' ORDER BY Name LIMIT :limitSize OFFSET :offsetSize';
        Result r = new Result();
        r.items = Database.query(soql);
        r.total = (Integer)Database.countQuery(countSoql);
        return r;
    }
}