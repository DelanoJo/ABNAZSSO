/*
 * Modified by Minh-Dien Le @10-Sep-2013
 * - Added test elements
 * - testPriceListForAccount
 * - testPriceListForOutlet
 * - testPriceListForOrder
 */

@isTest
private class PriceListRecordTest {

	public static Account distAcct, testCustomer, testOutlet;
	public static M_Inventory_Location__c invLocation;
	public static M_Price_List__c customerPriceList;
	public static M_OPLI_Settings__c OpliSetting;
	
	
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
	        			new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=244, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+30, M_Returning_From_c__c=Date.Today()-2, 
	        					M_Return_Price__c=120, M_Product_Format__c=prodFormatCase.id, M_Price_List__c=customerPriceList.id, M_Item__c=p.id, M_Allow_Inventory__c=true,Automated_Order_Item__c=true, M_Active_for_Order__c=true,M_Active_for_Returns__c=true)};
				
				insert itemPrices;
			}
		}     
	}

	static testMethod void testPriceListForAccount(){
		//prepare data with price list and 5 products
		prepareTestElements(true,5);
		
		Test.startTest();
		
		M_Price_List__c priceListFetched = PriceListRecord.getPriceListForAccount(testOutlet.id);
		system.assertEquals(priceListFetched.id, customerPriceList.id);		
		Test.stopTest();
	
	}

	static testMethod void testPriceListForOutlet(){
		//prepare data with price list and 5 products
		prepareTestElements(true,5);
		
		Test.startTest();
		M_Price_List__c priceListFetched = PriceListRecord.getPriceListForOutlet(testOutlet.id);
		
		//currentle this method is not implemented yet
		//but we still need to test with null output
		system.assertEquals(priceListFetched, null);		
		Test.stopTest();
	}
	

	static testMethod void testPriceListForOrder(){
		//prepare data with price list and 5 products
		prepareTestElements(true,5);
		
		//Create some order
    	M_Order_sigcap_Header__c testOrder = new M_Order_sigcap_Header__c(
				RecordTypeId = TestUtils.getRecordTypeId('M_Order_sigcap_Header__c', 'DSD from SSR Van'),
    	 		M_Status__c = 'Draft',
    	 		M_AccountName__c = testOutlet.Id,
    	 		M_Order_Transaction_Type__c = 'Order',
    	 		M_Inventory_TransactionType__c = 'None');
    	insert testOrder;	
    	
    	
    	Test.startTest();
    	M_Price_List__c priceListFetched = PriceListRecord.getPriceListForOrder(testOrder.id);
		system.assertEquals(priceListFetched.id, customerPriceList.id);		
		Test.stopTest();		
		
	}

}