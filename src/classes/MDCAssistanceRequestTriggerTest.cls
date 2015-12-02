/**====================================================================
 * Appirio, Inc
 * Name: MDCAssistanceRequestTrigger
 * Description: Trigger for MDC_Assistance_Request__c 
 * Created Date: 16 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 *
 =====================================================================*/
@isTest
private class MDCAssistanceRequestTriggerTest {
  private static MDC_Assistance_Request__c request1;
  private static MDC_Assistance_Request__c request2;
  private static Space_Plan_Reset__c plan;
	static testMethod void testTrigger() {
	  createTestData();  
	  Test.startTest();
	   insert request1;
	   System.assertEquals('New', [SELECT MDC_Request_Status__c FROM Space_Plan_Reset__c WHERE Id = :plan.Id limit 1].MDC_Request_Status__c);
	   request1.Num_Planograms__c = 5;
		 request1.Num_Stores__c = 5;
		 request1.Avg_Num_Doors__c = 5;
		 request1.Merchandising_End_Date__c = System.today().addDays(5);
		 request1.Merchandising_Start_Date__c = System.today();
		 request1.Reset_Type__c = 'Other';
		 request1.Reset_Date_US__c = System.today().addDays(10);
	   request1.Status__c = 'Approved';
	   update request1;
	   //System.assertEquals('Approved', [SELECT MDC_Request_Status__c FROM Space_Plan_Reset__c WHERE Id = :plan.Id limit 1].MDC_Request_Status__c);
	  Test.stopTest();
	}
	
	private static void createTestData() {
	  plan = new Space_Plan_Reset__c();
	  plan.Name = 'Test Plan';
	  insert plan;
	  request1 = new MDC_Assistance_Request__c();
	  request1.Space_Plan_Reset__c = plan.Id;
	  request1.Status__c = 'New';
	  
	  request2 = new MDC_Assistance_Request__c();
    request2.Space_Plan_Reset__c = plan.Id;
    request2.Status__c = 'Approved';
    insert request2;
	  
	}
}