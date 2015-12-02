/**====================================================================
 * Appirio, Inc
 * Name: CloneResetTaskTest 
 * Description: Test class for CloneResetTask
 * Created Date: 18 september 2015
 * Created By: Siddharth Varshneya (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class CloneResetTaskTest{
    private static Milestone1_Project__c project;
    
    static testMethod void testCloneResetTask() {
       // Create test data
       createTestData();
       list<Reset_Tasks__c> lst = [SELECT Name,RecordTypeId,Assigned_To__c,Blocked__c,Blocked_Reason__c,Class__c,Description__c,Due_Date__c,
                             Task_Expected_Duration__c,Task_Lead_Time__c,Milestone__c,Predecessor_Task__c,
                             Task_Stage__c,Start_Date__c,Wholesaler__c FROM Reset_Tasks__c];
       system.debug('==lst=='+lst );
       CloneResetTask.cloneResetTask(String.valueOf(lst.get(0).Id));
    }
      
   // Create test data
    private static void createTestData(){

      // Create wholesaler account
      Account wholesaler = TestUtils.createTestAccount('Wholesaler Account', 'Wholesaler', null);
      wholesaler.Type = 'Wholesaler';
      insert wholesaler;

      // Create parent account
      Account parentAcc = TestUtils.createTestAccount('Test Parent Account', 'Decision Point', null);
      parentAcc.Type = 'Decision Point';
      insert parentAcc;
      
      // Create child accounts
      List<Account> accList = new List<Account>();
      for(Integer index = 0; index < 5; index++){
        parentAcc = TestUtils.createTestAccount('Test Child Account ' + index, 'POC', parentAcc.id);
        parentAcc.Type = 'POC';
        parentAcc.Wholesaler__c = wholesaler.Id;
        accList.add(parentAcc);
      }
      insert accList;
      
      // Create Product
      US_Product__c product = new US_Product__c(Name = 'Test Product', ACTV_FLG_US__c = true);
      insert product;
      
      // Create Test Program, Milestone and tasks
      project = Milestone1_Test_Utility.sampleProjectActive('Test Project');
      insert project;
      
      // Create Market Product
      Market_Ready_Product__c progProduct = new Market_Ready_Product__c(Program__c = project.id, product__c = product.id);
      insert progProduct;
      
      Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);  
      insert milestone;
      
      List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();  
      Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
      task1.Clone_by_Wholesaler__c = true;
      tasks.add(task1);
      
      Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
      task2.Clone_by_Retailer__c = true;
      task2.task_owner_role__c = 'Integration User';
      tasks.add(task2);
      
      Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(milestone);
      task3.Clone_by_WSLR_PDCN__c = true;
      task3.product__c = product.id;
      task3.task_owner_role__c = 'CPPM';
      tasks.add(task3);
      
      insert tasks;
      
      Space_Plan_Reset__c objSPR =new Space_Plan_Reset__c();
      objSPR.name = 'rn1';
      insert objSPR;
      
      Space_Plan_Reset_Retailer__c objSPRR = new Space_Plan_Reset_Retailer__c();
      objSPRR.Account__c = accList[0].id;
      objSPRR.Space_Plan_Reset__c = objSPR.Id;
      insert objSPRR;
      
      Reset_Milestones__c objrm = new Reset_Milestones__c();
      objrm.Reset__c = objSPR.Id;
      insert objrm;

      Reset_Tasks__c objRt = new Reset_Tasks__c();
      objRt.Wholesaler__c = wholesaler.Id;
      objRt.Class__c = 'Wholesaler';
      objRt.Milestone__c = objrm.Id;
      insert objRt;
    }
}