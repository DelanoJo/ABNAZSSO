/**=====================================================================
 * Appirio, Inc
 * Name: SpacePlanResetExtensionTest
 * Description: Test Class for Controller for Space Plan Reset steps
 * Created Date: 22 Sept 2015 T-433463
 * Created By: Nimisha Prashant (Appirio)
 * 
 =====================================================================*/
@isTest
private class SpacePlanResetExtensionTest {
    private static Space_Plan_Reset__c spacePlan;
    private static Reset_Milestones__c milestone;
    private static Account testAcc;
    static testMethod void testSpacePlanWizard() {
        createTestData();
        Test.startTest();
          Test.setCurrentPage(Page.SpacePlanResetStep1);
          ApexPages.currentPage().getParameters().put('Id', spacePlan.Id);
		      SpacePlanResetExtension controller = new SpacePlanResetExtension();
		      ApexPages.StandardController stdController = new ApexPages.StandardController(spacePlan);
		      controller = new SpacePlanResetExtension(stdController);
		      controller.selection = '';
		      try {
		        controller.step2();
		      }
		      catch(Exception ex) {
		        system.assert(ex.getMessage().contains('Please Select a Template'));
		      }
          controller.step1();
          system.assertEquals(1, controller.getItems().size());
          controller.selection = spacePlan.Id;
          controller.step2();
          try {
            controller.step3();
          }
          catch(Exception ex) {
            system.assert(ex.getMessage().contains('Please Select a Space Plan Template'));
          }
          try {
            controller.step4();
          }
          catch(Exception ex) {
            system.assert(ex.getMessage().contains('Please Select a Space Plan Template'));
          }          
          controller.newSpacePlan.Name = 'new Plan - 2015';
          controller.newSpacePlan.Reset_Start_Date_US__c = System.today().addDays(5);
          controller.newSpacePlan.Merchandising_Start_Date__c = System.today();
          try {
            controller.step3();
          }
          catch(Exception ex) {
            system.assert(ex.getMessage().contains('Please choose a valid date'));
          }
          controller.newSpacePlan.Merchandising_Start_Date__c = System.today().addDays(10);
          controller.step3();
          system.assertEquals(1, controller.records.size());
          controller.selectAll();
	        for(SpacePlanResetExtension.SelectableAccount acc : controller.records){
	          acc.selected = true;
	          acc.selectItem();
	        }
	        system.assertEquals(1, controller.records.size());
	        system.assertEquals(1, controller.selectedAccountsValues.size());
	        system.assert(controller.itemsSelected);
	        system.assertEquals(1, controller.pageNumber);
	        system.assertEquals(4, controller.getAccountRecordTypes().size());
	        controller.newSpacePlan.Reset_Date_US__c = System.today().addDays(15);
          controller.step4();
          controller.updateDates();
          controller.saveRecords();
		    Test.stopTest();  
    }
    private static void createTestData() {
      testAcc = TestUtils.createTestAccount('Test Account', 'Decision Point', null);
      testAcc.Type = 'Decision Point';
      insert testAcc;
      spacePlan = Milestone1_Test_Utility.sampleSpacePlan('Basic Sample For Test' + DateTime.now().getTime());
      spacePlan.RecordTypeId = TestUtils.getRecordTypeId('Space_Plan_Reset__c', 'Master Template');
      insert spacePlan;
      milestone = Milestone1_Test_Utility.sampleResetMilestone(spacePlan);
      insert milestone;
      Reset_Tasks__c task = new Reset_Tasks__c();
      task.Name = 'Test Task1';
      task.Milestone__c = milestone.Id;
      task.Complete__c = true;
      task.Task_Lead_Time__c = 5;
      insert task;
      task = new Reset_Tasks__c();
      task.Name = 'Test Task2';
      task.Milestone__c = milestone.Id;
      task.Start_Date__c = System.today().addDays(-10);
      task.Due_Date__c = System.today().addDays(-5);
      insert task;
      task = new Reset_Tasks__c();
      task.Name = 'Test Task3';
      task.Milestone__c = milestone.Id;
      task.Start_Date__c = System.today().addDays(5);
      task.Due_Date__c = System.today().addDays(10);
      task.Task_Expected_Duration__c = 5;
      insert task;
    }
}