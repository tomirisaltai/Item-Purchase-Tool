public with sharing class ItemController {

    @AuraEnabled
    public static List<Item__c> listItems(String family, String type, String search,
                                          Integer limitSize, Integer offsetVal) {
        String whereClause = 'WHERE Id != null';
        if (!String.isBlank(family)) whereClause += ' AND Family__c = \'' + String.escapeSingleQuotes(family) + '\'';
        if (!String.isBlank(type))   whereClause += ' AND Type__c   = \'' + String.escapeSingleQuotes(type)   + '\'';
        if (!String.isBlank(search)) {
            String likeTerm = '%' + String.escapeSingleQuotes(search) + '%';
            whereClause += ' AND (Name LIKE \'' + likeTerm + '\' OR Description__c LIKE \'' + likeTerm + '\')';
        }

        String soql =
            'SELECT Id, Name, Family__c, Type__c, Price__c, Image__c, Description__c ' +
            'FROM Item__c ' + whereClause + ' ORDER BY Name';

        if (limitSize != null && limitSize > 0)  soql += ' LIMIT ' + limitSize;
        if (offsetVal  != null && offsetVal  >= 0) soql += ' OFFSET ' + offsetVal;

        System.debug('listItems params search=' + search);
        System.debug('listItems SOQL=' + soql);
        return Database.query(soql);
    }

    @AuraEnabled
    public static Integer countItems(String family, String type, String search) {
        String whereClause = 'WHERE Id != null';
        if (!String.isBlank(family)) whereClause += ' AND Family__c = \'' + String.escapeSingleQuotes(family) + '\'';
        if (!String.isBlank(type))   whereClause += ' AND Type__c   = \'' + String.escapeSingleQuotes(type)   + '\'';
        if (!String.isBlank(search)) {
            String likeTerm = '%' + String.escapeSingleQuotes(search) + '%';
            whereClause += ' AND (Name LIKE \'' + likeTerm + '\' OR Description__c LIKE \'' + likeTerm + '\')';
        }

        String soql = 'SELECT COUNT() FROM Item__c ' + whereClause;
        System.debug('countItems params search=' + search);
        System.debug('countItems SOQL=' + soql);
        return (Integer)Database.countQuery(soql);
    }
}
