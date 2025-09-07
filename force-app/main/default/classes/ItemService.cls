public with sharing class ItemService {
    public class Result {
        @AuraEnabled public List<Item__c> items;
        @AuraEnabled public Integer total;
    }

    @AuraEnabled(cacheable=true)
    public static Result searchItems(String family, String type, String q, Integer limitSize, Integer offsetSize) {
        String whereClause = buildWhere(family, type, q);

        String listSoql =
            'SELECT Id, Name, Family__c, Type__c, Price__c, Image__c ' +
            'FROM Item__c ' + whereClause + ' ORDER BY Name';

        if (limitSize != null && limitSize > 0)  listSoql += ' LIMIT ' + limitSize;
        if (offsetSize != null && offsetSize >= 0) listSoql += ' OFFSET ' + offsetSize;

        String countSoql = 'SELECT COUNT() FROM Item__c ' + whereClause;

        Result r = new Result();
        r.items = Database.query(listSoql);
        r.total = (Integer)Database.countQuery(countSoql);
        return r;
    }

    private static String buildWhere(String family, String type, String q) {
        List<String> parts = new List<String>();
        parts.add('WHERE Id != null');

        if (!String.isBlank(family)) {
            parts.add('AND Family__c = \'' + String.escapeSingleQuotes(family) + '\'');
        }
        if (!String.isBlank(type)) {
            parts.add('AND Type__c = \'' + String.escapeSingleQuotes(type) + '\'');
        }
        if (!String.isBlank(q)) {
            String likeTerm = '%' + String.escapeSingleQuotes(q) + '%';
            parts.add('AND (Name LIKE \'' + likeTerm + '\' OR Description__c LIKE \'' + likeTerm + '\')');
        }
        return String.join(parts, ' ');
    }
}
