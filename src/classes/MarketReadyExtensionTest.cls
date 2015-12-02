/**====================================================================
 * Appirio, Inc
 * Name: MarketReadyExtensionTest
 * Description: Test Class for MarketReadyExtension
 * Created Date: 24 August 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class MarketReadyExtensionTest {
  private static Milestone1_Project__c project;
  private static US_Product__c product;
  static testMethod void testMarketReadyExtension() {
    createTestData();
    Test.startTest();
      MarketReadyExtension controller = new MarketReadyExtension();
      ApexPages.StandardController stdController = new ApexPages.StandardController(project);
      controller = new MarketReadyExtension(stdController);
      try {
        controller.step2();
      }
      catch(Exception ex) {
        system.assert(ex.getMessage().contains('Please Select a Template'));
      }
      controller.cancel();
      controller.step1();
      system.assertEquals(1, controller.getItems().size());
      controller.selection = project.Id;
      controller.step2();
      controller.product = product.Id;
      controller.newProject.Region__c = 'Region 1';
      controller.newProject.Deadline__c = System.today();
      try {
        controller.step3();
      }
      catch(Exception ex) {
        system.assert(ex.getMessage().contains('Please Select a Product, Region and STR Date'));
      }
      controller.productName = controller.product +' - '+ controller.newProject.Region__c +' - '+ String.valueOf(controller.newProject.Deadline__c);
      controller.newProject.Name = controller.product +' - '+ controller.newProject.Region__c +' - '+ String.valueOf(controller.newProject.Deadline__c);
      controller.step3();
      controller.newProject.Deadline__c = System.today().addDays(10);
      controller.updateDates();
      PageReference ref = controller.saveRecords();
      String projectId = ref.getUrl().substring(1);
      system.debug(projectId);
      List<Milestone1_Project__c> newProgramList = new List<Milestone1_Project__c>([SELECT Id, Name, Deadline__c, Region__c
                                                                                    FROM Milestone1_Project__c 
                                                                                    WHERE Id = :projectId]);
      system.assertEquals(1, newProgramList.size());
      system.assertEquals(controller.newProject.Deadline__c, newProgramList[0].Deadline__c);
      system.assertEquals(controller.newProject.Region__c, newProgramList[0].Region__c);
    Test.stopTest();
  }
  
  private static void createTestData(){
      project = Milestone1_Test_Utility.sampleProjectActive('Test Project');
      map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
      map<String, Schema.RecordTypeInfo> rtMap = gd.get('Milestone1_Project__c').getDescribe().getRecordTypeInfosByName();
      project.RecordTypeId = rtMap.get('Master Template').getRecordTypeId();
      project.Kickoff__c = date.newInstance(1989, 4, 21);
      insert project;
      
      product = new US_Product__c(Name = 'Test Product', CurrencyIsoCode = 'CAD');
      insert product;
      Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);  
      insert milestone;
      
      List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();  
      Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
      task1.Task_Expected_Duration__c = 10;
      task1.Task_Lead_Time__c = 5;
      tasks.add(task1);
      
      task1 = Milestone1_Test_Utility.sampleTask(milestone);
      task1.Task_Expected_Duration__c = 10;
      task1.Task_Lead_Time__c = 5;
      tasks.add(task1);
      
      task1 = Milestone1_Test_Utility.sampleTask(milestone);
      task1.Task_Expected_Duration__c = 10;
      task1.Task_Lead_Time__c = 5;
      tasks.add(task1);
      
      insert tasks;
      
    }
}