/**====================================================================
 * Appirio, Inc
 * Name: MandateProductTriggerTest
 * Description: Test class for MandateProductTriggerHandler
 * Created Date: 9 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class MandateProductTriggerTest {

    static Mandate_Product__c mandateProduct1;

	static testMethod void testInsert() {
        createTestData();
        Test.startTest();
            insert mandateProduct1;
        Test.stopTest();
        List<Mandate_Product__c> mandateProducts = new List<Mandate_Product__c>([SELECT Id FROM Mandate_Product__c]);
        system.assertEquals(2, mandateProducts.size());
	}

    static testMethod void testDelete() {
        createTestData();
        insert mandateProduct1;
        Test.startTest();
            MandateProductTriggerHandler.firstRun = true;
            delete mandateProduct1;
        Test.stopTest();
        List<Mandate_Product__c> mandateProducts = new List<Mandate_Product__c>([SELECT Id FROM Mandate_Product__c]);
        system.assertEquals(0, mandateProducts.size());
    }
	
	private static void createTestData() {
        Account parentAccount = TestUtils.createTestAccount('Customer Corporate', 'Customer', null);
        parentAccount.Type = 'Customer Parent';
        parentAccount.Mandate__c = 'Quarterly';
        insert parentAccount;

        Account childAccount = TestUtils.createTestAccount('Customer POC', 'POC', parentAccount.Id);
        childAccount.Type = 'POC';
        childAccount.Mandate__c = 'Quarterly';
        insert childAccount;

        Mandate__c mandate1 = new Mandate__c(Name = 'Test Mandate 1', Account__c = parentAccount.Id, Cloned__c = true);
        insert mandate1;

        Mandate__c mandate2 = new Mandate__c(Name = 'Test Mandate 2', Account__c = childAccount.Id, Parent_Mandate__c = mandate1.Id, Cloned__c = true);
        insert mandate2;

        US_Product__c product = new US_Product__c(Name = 'Test Product', ACTV_FLG_US__c = true);
        insert product;

        mandateProduct1 = new Mandate_Product__c(Product__c = product.Id, Mandate__c = mandate1.Id);
        //insert mandateProduct1;

        //Mandate_Product__c mandateProduct2 = new Mandate_Product__c(Product__c = product.Id, Mandate__c = mandate2.Id, Cloned__c = true);
        //insert mandateProduct2;
	}
}