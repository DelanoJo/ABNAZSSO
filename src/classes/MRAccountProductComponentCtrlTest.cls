/**====================================================================
* Appirio, Inc
* Name: MRAccountProductComponentCtrlTest
* Description: Test class for MRAccountProductComponentController
* Created Date: 2 November 2015
* Created By: Matt Salpietro (Appirio)
* 
* Date Modified                Modified By                  Description of the update
* 
=====================================================================*/
@isTest
private class MRAccountProductComponentCtrlTest {
	private static Milestone1_Project__c program;
	private static Account decisionPoint;
	private static Account wholesaler;
	private static List<Milestone1_Task__c> tasks;

    static testMethod void testRetailerAuth() {
		// Create test data
		createTestData();

		// Create controller object
        MRAccountProductComponentController controller = new MRAccountProductComponentController();
        controller.recordId = program.Id;
		//controller.initialAccountId = decisionPoint.Id;
        controller.fieldsCSV = 'Auth_Type__c,Est_Store_Pct__c,Est_Vol_Per_Outlet__c';
        controller.accountField = 'Retailer';
        controller.childObject = 'MR_Retailer_Product_Authorization__c';

        system.assertNotEquals(null,controller.recordId);

        // Assert for records
        controller.getRecords();
        system.assertEquals(1,controller.retAuthList.size());
        system.assertEquals(2,controller.accountOptions.size());
       
        controller.retAuthList[0].put('Auth_Type__c','Mandate');
        controller.save();

        List<MR_Retailer_Product_Authorization__c> retAuthList = [SELECT Id, Auth_Type__c, Retailer__c
													        	  FROM MR_Retailer_Product_Authorization__c
													        	  WHERE MR_Product__r.Program__c = :program.Id];
		system.assertEquals(1,retAuthList.size());
        system.assertEquals(decisionPoint.Id,retAuthList[0].Retailer__c);

        controller.recordId = tasks[1].Id;
        controller.initialAccountId = decisionPoint.Id;
        controller.getRecords();
        system.assertEquals(1,controller.accountOptions.size());

        controller.saveAndClose();
	}

    static testMethod void testWslrProdCommit() {
        // Create test data
        createTestData();

        // Create controller object
        MRAccountProductComponentController controller = new MRAccountProductComponentController();
        controller.recordId = program.Id;
        controller.fieldsCSV = 'Pre_Sell_Commitment__c,Pricing_Alignment__c,Recommended_Volume_Cases__c,Forecast_Updated__c';
        controller.accountField = 'Wholesaler';
        controller.childObject = 'MR_Wholesaler_Product_Commitment__c';

        system.assertNotEquals(null,controller.recordId);

        // Assert for records
        controller.getRecords();
        system.assertEquals(1,controller.retAuthList.size());
        system.assertEquals(1,controller.accountOptions.size());
       
        controller.retAuthList[0].put('Pre_Sell_Commitment__c','100');
        controller.save();

        List<MR_Wholesaler_Product_Commitment__c> retAuthList = [SELECT Id, Wholesaler__c
                                                                  FROM MR_Wholesaler_Product_Commitment__c
                                                                  WHERE MR_Product__r.Program__c = :program.Id];
        system.assertEquals(1,retAuthList.size());
        system.assertEquals(wholesaler.Id,retAuthList[0].Wholesaler__c);

        controller.recordId = tasks[0].Id;
        controller.initialAccountId = wholesaler.Id;
        controller.getRecords();
        system.assertEquals(1,controller.accountOptions.size());

        controller.saveAndClose();
    }
    
    // Create test data
    private static void createTestData(){
    	// Create wholesaler account
        wholesaler = TestUtils.createTestAccount('Wholesaler Account', 'Wholesaler', null);
        wholesaler.Type = 'Wholesaler';
        insert wholesaler;

    	// Create parent account
    	decisionPoint = TestUtils.createTestAccount('Test Decision Point', 'Decision Point', null);
    	decisionPoint.Type = 'Decision Point';
        decisionPoint.Wholesaler__c = wholesaler.Id;
    	insert decisionPoint;

    	Account decisionPoint2 = TestUtils.createTestAccount('Test Decision Point 2', 'Decision Point', null);
    	decisionPoint2.Type = 'Decision Point';
    	insert decisionPoint2;
    	
    	// Create wholesaler account
        wholesaler = TestUtils.createTestAccount('Wholesaler Account', 'Wholesaler', null);
        wholesaler.Type = 'Wholesaler';
        insert wholesaler;
      
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
      
        tasks = new List<Milestone1_Task__c>();	
    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Clone_by_Wholesaler__c = true;
    	task1.Wholesaler__c = wholesaler.Id;
    	tasks.add(task1);
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Clone_by_Retailer__c = true;
    	task2.Retailer__c = decisionPoint.Id;
    	tasks.add(task2);

    	Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(milestone);
    	task3.Clone_by_Retailer__c = true;
    	task3.Retailer__c = decisionPoint2.Id;
    	tasks.add(task3);
    	
    	insert tasks;
    }
}