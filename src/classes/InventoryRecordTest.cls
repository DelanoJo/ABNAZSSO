/**
 * Created by Minh-Dien Le @05-Sep-2013
 *
 * Inventory Record Test Class includes
 * - Test elements: accounts, products, product formats...
 * - testBreakCase
 * - prepareTestElements
 *  
 * Modified by
 * - Put your name, date and reasons to modify
 */
 
 
@isTest
private class InventoryRecordTest {
	
	private static Account distAcct, testCustomer, testOutlet;
	private static M_Inventory_Location__c invLocation;
	private static M_Price_List__c customerPriceList;
	private static M_OPLI_Settings__c OpliSetting;
	
	
	static void prepareTestElements(boolean withPriceList, integer sizeProductList)
	{
		//Create distributor account
		distAcct = TestUtils.createTestAccount('Test Distributor', 'Distribution Center with Inventory', null);
		insert distAcct;
		
		//OPLI setting object with distributor account
		OpliSetting = new M_OPLI_Settings__c(Name='Test OPLI', 
											M_IsActive__c=true,
											M_Only_ONE_Price_List_Valid__c=true,
											M_Use_Outlet_Pricing__c=false,
											M_Use_Customer_Pricing__c=true,
											M_Use_Distributor_Pricing__c=false, 
											M_Price_List__c=null,
											M_Def_Inv_Return_Loc__c=distAcct.Id,
											M_Automate_Inventory_Break_Case__c=true);
        insert OpliSetting;
        
        //create inventory location with distributor account
        invLocation=new M_Inventory_Location__c(Name='Test Inventory Location', M_Distributor__c=distAcct.Id,Default_Disbursement_Location__c=true);
        insert invLocation;
        
        //Customer level 3
        testCustomer = TestUtils.createTestAccount('Test Customer', 'Customer',null);
		insert  testCustomer;       

		//Outlet for test customer
		testOutlet = TestUtils.createTestAccount('Test Outlet', 'Outlet', testCustomer.Id);
		insert testOutlet;
        
        if(withPriceList && customerPriceList==null){
			//Price list for test customer
			customerPriceList = new M_Price_List__c(Name='Customer Price List',M_Account__c= testCustomer.Id, M_IsActive__c = true, M_Price_List_Type__c = 'Customer');
			insert customerPriceList;
        }
		
		//Create product list with product format for test customer
		for(Integer num=0 ; num < sizeProductList; num++){
			
			//M_Merck_Product_Code__c='00000000000000000'+String.ValueOf(num),
  			buzz_retail__Product__c p = new buzz_retail__Product__c(Name ='Product number '+String.ValueOf(num),
  																M_AllowInventory__c = true, 
  																M_Allow_Returns__c=true,
  																buzz_retail__IsActive__c=true,
  																buzz_retail__Allow_Ordering__c=true,
  																buzz_retail__UPC_Code__c='00000000000000000'+String.ValueOf(num), 
  																RecordTypeId=TestUtils.getRecordTypeId('buzz_retail__Product__c', 'Item'));
  			//create a product
  			insert p;
  			
  			//then create product format each
  			buzz_retail__ProductFormat__c prodFormatEach = new buzz_retail__ProductFormat__c(Name='EA',
																buzz_retail__Product__c=p.Id,
																buzz_retail__FormatCode__c='Each',
																buzz_retail__Conversion_Cases__c= 1/12,
																buzz_retail__Conversion_Eaches__c= 1,
																M_Inventory__c = true,
																M_Active__c = true);
			insert prodFormatEach;
			
  			//create product format case					
  			buzz_retail__ProductFormat__c prodFormatCase =	new buzz_retail__ProductFormat__c(Name='CS',
																buzz_retail__Product__c=p.Id,
																buzz_retail__FormatCode__c='Case',
																buzz_retail__Conversion_Cases__c=1,
																buzz_retail__Conversion_Eaches__c=12,
																M_Inventory__c = true,
																M_Active__c = true);
  																
  			insert prodFormatCase;
			
			if (withPriceList && customerPriceList==null){
				//then create product item price for each and case if possible
				List<M_Item_Price__c> itemPrices = new M_Item_Price__c[]{
						new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+30, M_Returning_From_c__c=Date.Today()-2, 
	        					M_Return_Price__c=10, M_Product_Format__c=prodFormatEach.id, M_Price_List__c=customerPriceList.id, M_Item__c=p.id, M_Allow_Inventory__c=true,Automated_Order_Item__c=true, M_Active_for_Order__c=true,M_Active_for_Returns__c=true),
	        			new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=144, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+30, M_Returning_From_c__c=Date.Today()-2, 
	        					M_Return_Price__c=120, M_Product_Format__c=prodFormatCase.id, M_Price_List__c=customerPriceList.id, M_Item__c=p.id, M_Allow_Inventory__c=true,Automated_Order_Item__c=true, M_Active_for_Order__c=true,M_Active_for_Returns__c=true)};
				
				insert itemPrices;
			}
		}     
	}
	
	
	
	/*******************************************************************************************
	Objective: to validate if the break case occured when the inventory of 'each' are negative
	Workflow : 
	- Create inventory capture with some products 
	- Then re-adjust the product format 'each' to negative
	- Validate inventory number, record type, size
	********************************************************************************************/
	static testMethod void testBreakCase(){
        
        //prepare 5 products without price list
        prepareTestElements(false,5);
        		
		Test.startTest();
    	
    	//Create a new inventory capture transaction
    	//for a new inventory
    	M_Inventory_Transaction__c  invTrans = new M_Inventory_Transaction__c(RecordTypeId=TestUtils.getRecordTypeId('M_Inventory_Transaction__c','Inventory Capture'),
 																				M_Inventory_Location__c=invLocation.id,
																				M_Distributor__c=distAcct.id,
																				M_Status__c='Draft');
		

		insert invTrans;
		
		//validation if the transaction is creating the inventory list or not
		Integer numOfInv = [select count() from M_Inventory__c];
		
		//Since we have 5 products with 2 product format each
		//we expect 10 records
		system.assertEquals(numOfInv,10);
		
		//check number of transaction item
		//we expect 10 records also
		Integer numOfInvItem = [select count() from M_Transaction_Item__c where M_Inventory_Transaction__c =:invTrans.id];
		system.assertEquals(numOfInvItem,10);
		
		
		//Add some products				
		List<M_Transaction_Item__c> invTransItemsToUpdate = new List<M_Transaction_Item__c>();
		for (M_Transaction_Item__c invItem:[select id from M_Transaction_Item__c where M_Inventory_Transaction__c =:invTrans.id]){
			invItem.M_Original_Qty__c = 1;
			invTransItemsToUpdate.add(invItem);
		}

		update invTransItemsToUpdate;
		
		//Let's finalized it
		invTrans.M_Status__c = 'Final';
		update invTrans;
		
		//Let's do some simple math of all stock in hand to test
		//Since we have 5 products and 2 product format each then we should have total 10
		AggregateResult sumOfAllStock = [select sum(M_StockQtyAtHand__c) allStock from M_Inventory__c];
		system.assertEquals(Integer.ValueOf(sumOfAllStock.get('allStock')),10);
		
		
		//After all, then we create an adjustment inventory transaction with wrong count	
		M_Inventory_Transaction__c  invTransWithAdjustment = new M_Inventory_Transaction__c(RecordTypeId=TestUtils.getRecordTypeId('M_Inventory_Transaction__c','Adjustment'),
 																				M_Reason_for_Transaction__c='Wrong Count',
 																				M_Inventory_Location__c=invLocation.id,
																				M_Distributor__c=distAcct.id,
																				M_Status__c='Draft');
		
		
		insert invTransWithAdjustment;
		
		//remove 2 from inventory of product format 'each' to have negative number
		List<M_Transaction_Item__c> invTransToBeAdjust = new List<M_Transaction_Item__c>();
		for (M_Transaction_Item__c invItem:[select id from M_Transaction_Item__c where M_Inventory_Transaction__c =:invTransWithAdjustment.id and M_Inventory__c=:[select id from M_Inventory__c where M_FormatCode__c='each']]){
			invItem.M_Original_Qty__c = 2;
			invTransToBeAdjust.add(invItem);
		}
		//update the item
		update invTransToBeAdjust;
		
		//Let's finalized it
		invTransWithAdjustment.M_Status__c = 'Final';
		update invTransWithAdjustment;
		
		//validate the number of break case
		//we know we have changed 5 product inventory, so we expect 5 break cases
		Integer numOfBreakCase = [select count() from M_Inventory_Transaction__c where  M_Record_Type__c='break case'];
		system.assertEquals(numOfBreakCase, 5);
		
		//Test the batch process
		AutomatedBreakCaseBatch testJob = new AutomatedBreakCaseBatch();
		id batchprocessid = Database.executeBatch(testJob);

		
		Test.stopTest();
		
	     
	}//end of testBreakCase()
	
}