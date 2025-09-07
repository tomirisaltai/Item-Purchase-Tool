public with sharing class UserController {
    @AuraEnabled(cacheable=true)
    public static Boolean isCurrentUserManager() {
        User u = [
            SELECT IsManager__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return u.IsManager__c == true;
    }
}
