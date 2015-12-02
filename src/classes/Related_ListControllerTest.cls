/**====================================================================
 * Appirio, Inc
 * Name: Related_ListControllerTest
 * Description: Test class for Related_ListController
 * Created Date: 24 August 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class Related_ListControllerTest {

	private static Milestone1_Project__c program;
		
    static testMethod void testRelatedListController() {
    	createTestData();

    	Related_ListController controller = new Related_ListController();

    	// Set controller paremeters
    	controller.objectName='Milestone1_Task__c'; 
        controller.fieldsCSV='Name,Project_Milestone__r.Name,Due_Date__c,Blocked__c,Blocked_Reason_Picklist__c,Project_Milestone__r.Project__r.Name'; 
        controller.pageSize=1;
        controller.searchFieldValue=program.Id;
        controller.searchFieldName='Project_Milestone__r.Project__c';
        controller.orderByFieldName='Due_Date__c';
        controller.sortDirection='asc';
        controller.filter='Complete__c = false';
        controller.title='Late Tasks';
        controller.returnUrl='/'+program.Id;
        controller.moreLink='/'+program.Id;
        controller.showAsStandardRelatedList=false;
        
        system.assertEquals(1,controller.getRecords().size());
        system.assertEquals(3,controller.ssc.getResultSize());

        // Next Page
        controller.sortByField = 'Due_Date__c';
        controller.fieldsCSV=null;
        controller.fieldsList=new List<String>{'Name','Project_Milestone__r.Name','Due_Date__c','Blocked__c','Blocked_Reason_Picklist__c','Project_Milestone__r.Project__r.Name'}; 
        controller.pageNumber = 2;
        system.assertEquals(1,controller.getRecords().size());

        // Delete record
        controller.deleteRecordId = controller.getRecords()[0].Id;
        controller.deleteRecord();
        system.assertEquals(2,controller.ssc.getResultSize());

        controller.showMore();
        controller.getShowNewButton();
        controller.sortByFieldAction();
    }

    static testMethod void testRelatedListControllerFail() {
    	createTestData();

    	PageReference pg = Page.MRProgramLateTasks;
        Test.setCurrentPage(pg);

    	Related_ListController controller = new Related_ListController();

    	// Set controller paremeters
    	controller.objectName='Milestone1_Task__c'; 
        controller.pageSize=1;
        controller.searchFieldValue=program.Id;
        controller.searchFieldName='Project_Milestone__r.Project__c';
        controller.orderByFieldName='Due_Date__c';
        controller.filter='Complete__c = false';
        controller.title='Late Tasks';
        controller.returnUrl='/'+program.Id;
        controller.showAsStandardRelatedList=false;
        controller.sortDirection = 'fail';
        
        controller.getRecords();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
		System.assertEquals(2, pageMessages.size());
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