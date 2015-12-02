/**====================================================================
 * Appirio, Inc
 * Name: ResetTaskTriggerHandlerTest
 * Description: T-436036 - Test class for ResetTaskTriggerHandler
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
@isTest
private class ResetTaskTriggerHandlerTest {

		private static List<Reset_Tasks__c> tasks;
		
		// Test method
    static testMethod void testBeforeInsert() {
        tasks = new List<Reset_Tasks__c>();
        createTestData();
        Test.startTest();
        	insert tasks;
        	tasks = [Select id, Milestone__c, Milestone__r.Total_Late_Task_Count__c from Reset_Tasks__c where name = 'Test Task3'];
        	system.assert(tasks[0].Milestone__r.Total_Late_Task_Count__c > 0);
        Test.stopTest();
    }
    
    // Create test data
     private static void createTestData() {
      Account testAcc = TestUtils.createTestAccount('Test Account', 'Decision Point', null);
      testAcc.Type = 'Decision Point';
      insert testAcc;
      Space_Plan_Reset__c spacePlan = Milestone1_Test_Utility.sampleSpacePlan('Basic Sample For Test' + DateTime.now().getTime());
      spacePlan.RecordTypeId = TestUtils.getRecordTypeId('Space_Plan_Reset__c', 'Master Template');
      insert spacePlan;
      Reset_Milestones__c milestone = Milestone1_Test_Utility.sampleResetMilestone(spacePlan);
      insert milestone;
      Reset_Tasks__c task = new Reset_Tasks__c();
      task.Name = 'Test Task1';
      task.Milestone__c = milestone.Id;
      task.Complete__c = true;
      task.Task_Lead_Time__c = 5;
      tasks.add(task);
      task = new Reset_Tasks__c();
      task.Name = 'Test Task2';
      task.Milestone__c = milestone.Id;
      task.Start_Date__c = System.today().addDays(-10);
      task.Due_Date__c = System.today().addDays(-5);
      tasks.add(task);
      task = new Reset_Tasks__c();
      task.Name = 'Test Task3';
      task.Milestone__c = milestone.Id;
      task.Start_Date__c = System.today().addDays(-10);
      task.Due_Date__c = System.today().addDays(5);
      task.Task_Expected_Duration__c = 5;
      task.Complete__c = false;
      tasks.add(task);
    }
}