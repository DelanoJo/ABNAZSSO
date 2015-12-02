/**====================================================================
 * Appirio, Inc
 * Name: ProgramMarketListControllerTest
 * Description: Test class for ProgramMarketListController
 * Created Date: 24 August 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class ProgramMarketListControllerTest {

	private static Milestone1_Project__c program;
		
    static testMethod void testProgramMarketListController() {
		// Create test data
		createTestData();
    		
		// Create controller objects
        ApexPages.StandardController stdController = new ApexPages.StandardController(program);
        ProgramMarketListController controller = new ProgramMarketListController(stdController);
        
        // Set Page
        controller.newConPage = 1;
        controller.curCon = 1;
        controller.setPage();
        controller.curCon = 2;
        controller.setPage();

        // Assert for records
        system.assert(controller.marketDPs.size() > 0);
		system.assert(controller.marketWSLRs.size() > 0);
    }
    
    // Create test data
    private static void createTestData(){
    	
    	// Create parent account
    	Account parentAcc = TestUtils.createTestAccount('Test Parent Account', 'Decision Point', null);
    	parentAcc.Type = 'Decision Point';
    	insert parentAcc;
    	
    	// Create wholesaler account
        Account wholesaler = TestUtils.createTestAccount('Wholesaler Account', 'Wholesaler', null);
        wholesaler.Type = 'Wholesaler';
        insert wholesaler;
    	
    	// Create Test Program, Milestone and tasks
    	program = Milestone1_Test_Utility.sampleProjectActive('Test Project');
    	insert program;
    	
    	Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(program);  
        insert milestone;
      
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();	
    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Wholesaler__c = wholesaler.Id;
    	task1.Class__c = 'Wholesaler Alignment';
    	task1.Task_Stage__c = 'In Progress';
    	tasks.add(task1);
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Wholesaler__c = wholesaler.Id;
    	task2.Class__c = 'Wholesaler Alignment';
    	task2.Blocked__c = true;
    	task2.Blocked_Reason_Picklist__c = 'Test';
    	tasks.add(task2);

    	Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(milestone);
    	task3.Class__c = 'Retailer Alignment';
    	task3.Retailer__c = parentAcc.Id;
    	tasks.add(task3);
    	
    	insert tasks;
    }
}