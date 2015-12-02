/**====================================================================
 * Appirio, Inc
 * Name: CloneMandateTest
 * Description: Test Class for CloneMandate
 * Created Date: 31 August 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class CloneMandateTest {
  private static Account parentAccount;
  private static Account childAccount;
  private static Account dpAccount;
  private static Mandate__c mandate1;
  private static Mandate__c mandate2;
  private static Mandate__c mandate3;
  private static US_Product__c product;
  static testMethod void testCheckWSLRForecast() {
    createTestData();
    Test.startTest();
      CloneMandate.cloneMandateToChildren(mandate1.Id, mandate1.Account__c, dpAccount.Type);
      system.assertEquals(2, [SELECT Id FROM Mandate__c WHERE Name = 'Test Mandate 1'].size());
      
      CloneMandate.cloneMandateToChildren(mandate2.Id, mandate2.Account__c, childAccount.Type);
      system.assertEquals(2, [SELECT Id FROM Mandate__c WHERE Name = 'Test Mandate 2'].size());
      
      CloneMandate.cloneMandateToChildren(mandate3.Id, mandate3.Account__c, parentAccount.Type);
    Test.stopTest();
    List<Mandate__c> mandate3Created = new List<Mandate__c>([SELECT Id, (SELECT Id, Product__c FROM Mandate_Products__r) FROM Mandate__c WHERE Name = 'Test Mandate 3']);
    system.assertEquals(1, mandate3Created[0].Mandate_Products__r.size());
    system.assertEquals(1, mandate3Created[1].Mandate_Products__r.size());
    system.assertEquals(product.Id, mandate3Created[0].Mandate_Products__r[0].Product__c);
    system.assertEquals(product.Id, mandate3Created[1].Mandate_Products__r[0].Product__c);
  }
  
  private static void createTestData() {
    parentAccount = TestUtils.createTestAccount('Customer Corporate', 'Chain', null);
    parentAccount.Type = 'Chain';
    parentAccount.Mandate__c = 'Quarterly';
    insert parentAccount;
    
    childAccount = TestUtils.createTestAccount('Customer Banner', 'Banner', parentAccount.Id);
    childAccount.Type = 'Banner';
    childAccount.Mandate__c = 'Quarterly';
    insert childAccount;
    
    dpAccount = TestUtils.createTestAccount('Customer DP', 'Decision Point', childAccount.Id);
    dpAccount.Type = 'Decision Point';
    dpAccount.Mandate__c = 'Quarterly';
    insert dpAccount;
    
    Account pocAccount = TestUtils.createTestAccount('Customer POC', 'POC', dpAccount.Id);
    pocAccount.Type = 'POC';
    pocAccount.Mandate__c = 'Quarterly';
    insert pocAccount;
    
    mandate1 = new Mandate__c(Name = 'Test Mandate 1', Account__c = dpAccount.Id);
    insert mandate1;
    
    mandate2 = new Mandate__c(Name = 'Test Mandate 2', Account__c = childAccount.Id);
    insert mandate2;
    
    mandate3 = new Mandate__c(Name = 'Test Mandate 3', Account__c = parentAccount.Id);
    insert mandate3;
    product = new US_Product__c(Name = 'Test Product', ACTV_FLG_US__c = true);
	  insert product;  
	  Mandate_Product__c mprod = new Mandate_Product__c(Product__c = product.Id, Mandate__c = mandate3.Id);
	  insert mprod;
  }
}