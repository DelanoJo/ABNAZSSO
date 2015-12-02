/**====================================================================
 * Appirio, Inc
 * Name: MarketSelectionControllerTest
 * Description: Test class for MarketSelectionController
 * Created Date: 24 August 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class MarketSelectionControllerTest {

	private static Milestone1_Project__c program;
		
    static testMethod void testMarketSelectionController() {
		// Create test data
		createTestData();
    		
		// Create controller objects
        ApexPages.StandardController stdController = new ApexPages.StandardController(program);
        MarketSelectionController controller = new MarketSelectionController(stdController);
        
        controller.parentName = 'Test Parent Account';
        controller.loadData();
        // Assert for records
        system.assert(controller.records.size() > 0);
        system.assert(controller.searchCon.selectedPageNumber > 0);
        system.assert(controller.searchCon.totalRecords > 0);
        system.assert(controller.searchCon.pageSize > 0);
       
       	// Set Selected records
        List<MarketSelectionController.SelectableAccount> setterRecords = new List<MarketSelectionController.SelectableAccount>();
        for(MarketSelectionController.SelectableAccount acc : controller.records){
        	acc.selected = true;
        	acc.selectItem();
        	setterRecords.add(acc);
        }
        setterRecords[0].removeSelected();
        setterRecords[0].selected = true;
        setterRecords[0].selectItem();
        controller.records = setterRecords;
        
        // Assert for selected accounts
        system.assert(controller.itemsSelected == true);
        system.assert(controller.selectedAccounts.size() > 0);
        
        // Navigate for coverage
        controller.searchCon.first();
        controller.searchCon.last();
        controller.searchCon.next();
        controller.searchCon.previous();
        controller.sortRecordset();
        
        // Navigate to second step
        controller.goSecondStep();
        
        system.assert(controller.selectedWSLRs.size() > 0);
                
        // Save records
        controller.saveData();
        
      	// Initiate controller object with Project already having Participants       
        stdController = new ApexPages.StandardController(program);
        controller = new MarketSelectionController(stdController);
        MarketSelectionController.searchFilters('test', 'Name');
        controller.cancel();
    }
    
    // Tests controller without program Id
    static testMethod void testMarketSelectionControllerWithInvalidInput() {
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Milestone1_Project__c());
	    MarketSelectionController controller = new MarketSelectionController(stdController);
	    system.assert(ApexPages.getMessages().size() > 0);
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
    	program = Milestone1_Test_Utility.sampleProjectActive('Test Project');
    	insert program;
    	
    	// Create Market Product
    	Market_Ready_Product__c progProduct = new Market_Ready_Product__c(Program__c = program.id, Product__c = product.id);
    	insert progProduct;
    	
    	Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(program);  
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
    }
}