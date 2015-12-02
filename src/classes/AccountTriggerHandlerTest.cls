// 
// (c) 2012 Appirio, Inc.
//
// Test class of AccountTriggerHandler
//
// 16 Sep 2015     Parul Gupta       Original
//
@isTest
private class AccountTriggerHandlerTest {

		private static Account parentAcc;
		
		// Method tests trigger onAfterInsert
    static testMethod void testOnAfterInsert() {
    	  createTestData();
        Test.startTest();
        parentAcc.Captaincy_Survey_Last_Updated_By__c = 'Test user';
        insert parentAcc;
        Test.stopTest();
    }
    
    // Method tests trigger onAfterUpdate
    static testMethod void testOnAfterUpdate() {
    		createTestData();        
        parentAcc.Captaincy_Survey_Last_Updated_By__c = 'Test user';
        insert parentAcc;
        
        Test.startTest();
        parentAcc.Captaincy_Survey_Last_Updated_By__c = 'Test user 1';
        update parentAcc;
        Test.stopTest();
    }
    
    private static void createTestData(){
    	
    	// Create parent account
    	parentAcc = TestUtils.createTestAccount('Test Parent Account', 'Decision Point', null);
    	parentAcc.Type = 'Decision Point';
    	
    	Captaincy_Survey_Fields__c cFields = new Captaincy_Survey_Fields__c();
    	cFields.Field_API_Name__c = 'Captaincy_Survey_Last_Updated_By__c';
    	cFields.Name = 'Captaincy Survey: Last Updated By';
    	insert cFields;
    }
}