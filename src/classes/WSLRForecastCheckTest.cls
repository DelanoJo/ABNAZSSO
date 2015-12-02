/**====================================================================
 * Appirio, Inc
 * Name: WSLRForecastCheckTest
 * Description: Test Class for WSLRForecastCheck
 * Created Date: 26 August 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class WSLRForecastCheckTest {
  private static Milestone1_Milestone__c milestone;
  private static Milestone1_Task__c task;
	static testMethod void testCheckWSLRForecast() {
	  createTestData();
	  Test.startTest();
	   WSLRForecastCheck.checkWSLRForecast(milestone.Id);
	   system.assert([SELECT WSLR_Inventory_Aligned__c 
	                  FROM Milestone1_Task__c 
	                  WHERE Project_Milestone__c = :milestone.Id].get(0).WSLR_Inventory_Aligned__c);
	  Test.stopTest();
	}
	
	static testMethod void testCheckWSLRInventory() {
	  createTestData();
    Test.startTest();
      WSLRForecastCheck.checkWSLRInventory(task.Id, task.Wholesaler__c, task.Product__c);
      system.assert([SELECT WSLR_Inventory_Aligned__c 
                    FROM Milestone1_Task__c 
                    WHERE Id = :task.Id].get(0).WSLR_Inventory_Aligned__c);
    Test.stopTest();
	}
	private static void createTestData() {
	  // Create wholesaler account
	  Account wholesaler = TestUtils.createTestAccount('Wholesaler Account', 'Wholesaler', null);
	  insert wholesaler;
    // Create Product
	  US_Product__c product = new US_Product__c(Name = 'Test Product', ACTV_FLG_US__c = true);
	  insert product;  
	  // Create Test Program, Milestone and tasks
	  Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectActive('Test Project');
	  insert project;
	  
	  milestone = Milestone1_Test_Utility.sampleMilestone(project);  
    insert milestone;
    
	  task = Milestone1_Test_Utility.sampleTask(milestone);
	  task.Clone_by_WSLR_PDCN__c = true;
	  task.Wholesaler__c = wholesaler.Id;
	  task.Product__c = product.Id;
	  insert task;
	  
	  Forecast__c forecast = new Forecast__c(Name='Test Forecast', Wholesaler__c = wholesaler.Id, Product__c = product.Id);
	  insert forecast;
	}
}