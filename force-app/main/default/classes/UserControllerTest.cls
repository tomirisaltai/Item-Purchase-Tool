@IsTest
private class UserControllerTest {

    @IsTest
    static void testIsCurrentUserManager() {

        User u = [SELECT Id, IsManager__c FROM User WHERE Id = :UserInfo.getUserId()];
        u.IsManager__c = true;
        update u;

        Test.startTest();
        Boolean isMgr = UserController.isCurrentUserManager();
        Test.stopTest();

        System.assertEquals(true, isMgr, 'Should return true when IsManager__c is set');
    }
}
