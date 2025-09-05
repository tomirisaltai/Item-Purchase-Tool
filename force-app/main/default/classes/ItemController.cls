public with sharing class ItemController {

    @AuraEnabled(cacheable=true)
    public static List<Item__c> listItems(String family, String type, String search, Integer limitSize, Integer offsetVal) {
        String soql = 'SELECT Id, Name, Price__c, Family__c, Type__c, Image__c FROM Item__c WHERE Id != null';
        if (!String.isBlank(family)) soql += ' AND Family__c = :family';
        if (!String.isBlank(type))   soql += ' AND Type__c = :type';
        if (!String.isBlank(search)) {
            String likeTerm = '%' + search + '%';
            soql += ' AND (Name LIKE :likeTerm OR Description__c LIKE :likeTerm)';
        }
        soql += ' ORDER BY Name';
        if (limitSize != null) soql += ' LIMIT :limitSize';
        if (offsetVal != null) soql += ' OFFSET :offsetVal';
        return Database.query(soql);
    }

    @AuraEnabled(cacheable=true)
    public static Integer countItems(String family, String type, String search) {
        String soql = 'SELECT COUNT() FROM Item__c WHERE Id != null';
        if (!String.isBlank(family)) soql += ' AND Family__c = :family';
        if (!String.isBlank(type))   soql += ' AND Type__c = :type';
        if (!String.isBlank(search)) {
            String likeTerm = '%' + search + '%';
            soql += ' AND (Name LIKE :likeTerm OR Description__c LIKE :likeTerm)';
        }
        return (Integer)Database.countQuery(soql);
    }
}
