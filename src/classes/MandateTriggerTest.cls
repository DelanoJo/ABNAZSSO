/**====================================================================
 * Appirio, Inc
 * Name: MandateTriggerTest
 * Description: Test Class for Handler class for MandateTrigger
 * Created Date: 24 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class MandateTriggerTest {

  private static Mandate__c mandate;
	static testMethod void testUpdateMandatePeriod() {
	  createTestData(); 
	  Test.startTest();
	   mandate.Period__c = 'Bi Annual';
	   try {
	     insert mandate;
	   }
	   catch(Exception ex) {
	     System.assert(ex.getMessage().contains('update Period while inserting Mandate'));
	   }
	   mandate.Period__c = null;
	   insert mandate;
	   System.assertEquals('Annual', [SELECT Period__c FROM Mandate__c WHERE Id = :mandate.Id limit 1].Period__c);
	   
	   mandate.Period__c = 'Bi Annual';
     update mandate;
     System.assertEquals('Annual', [SELECT Period__c FROM Mandate__c WHERE Id = :mandate.Id limit 1].Period__c);
	  Test.stopTest();
	}
	
	private static void createTestData() {
	  Account parentAccount = TestUtils.createTestAccount('Customer Corporate', 'Customer', null);
    parentAccount.Type = 'Customer Parent';
    parentAccount.Mandate__c = 'Annual';
    insert parentAccount;
    
    mandate = new Mandate__c(Name = 'Test Mandate', Account__c = parentAccount.Id, Cloned__c = true);
	}
}