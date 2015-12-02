@isTest
private class InventoryRecord_TEST {
	
	 public static User CreateUserForProfile(Id pProfileId){
		return new User(alias ='standt', 
			email='buzztest@retailbuzz.com', 
			emailencodingkey='UTF-8', 
			lastname='Testing', 
			languagelocalekey='en_US', 
			localesidkey='en_US', 
			profileid = pProfileId, 
			timezonesidkey='America/Los_Angeles',
			M_Order_Inventory_Account__c = 0021, 
			username='buzztest@retailbuzz.com');
    }
 
    static testMethod void myUnitTest() 
    {
    	/*
    	Map<String,ID> profiles = new Map<String,ID>();
		List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
		
		User admin = CreateUserForProfile(profiles.get('System Administrator'));
		insert admin;
		
         Account disAccount = new Account(
            Name = 'Test Distributor',
            buzz_retail__Distributor_Type__c = 'SSR',
            buzz_retail__Account_ID__c = '121212',
            buzz_retail__IsActive__c = true, 
            M_Is_Inventory_Location__c = true,
            M_Is_Inventory_Return__c = true,
            RecordTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),
            M_Route_Number__c = 9999);
        insert disAccount;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id,M_Automate_Inventory_Break_Case__c = true);
        insert opli;
        
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

		
		
		Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
    	Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
		
		Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        
        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        //M_Merck_Product_Code__c='11111',
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        //M_Merck_Product_Code__c='11222',
        prodList.add(p2);
        insert prodList;

        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name='EA',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Each',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name='CS',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
		
       //Create PriceList
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true, M_Active_for_Order__c=true,M_Active_for_Returns__c=true);
		ipInsertList.add(ip1);
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=244, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true, M_Active_for_Order__c=true,M_Active_for_Returns__c=true);
		ipInsertList.add(ip2);
		
		insert ipInsertList;
		
		//validate price list
		List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
		system.debug('ipInsertedList:- '+ipInsertedList);		
		
		
		//Create Inventory
		M_Inventory__c newInv1 = new M_Inventory__c(
			M_Distributor__c=disAccount.id,
			M_Inventory_Location__c=invLoca.id,
			M_Product__c=p1.id,
			M_Product_Format__c=prodForm1.id				
		);
		
		insert newInv1;
		
		M_Inventory__c newInv2 = new M_Inventory__c(
			M_Distributor__c=disAccount.id,
			M_Inventory_Location__c=invLoca.id,
			M_Product__c=p1.id,
			M_Product_Format__c=prodForm2.id				
		);
		

		insert newInv2;
		
		
		//Create Inventory Transaction
		M_Inventory_Transaction__c  newInvTrans2 = new M_Inventory_Transaction__c (
			RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType, RecType.Name.Adjustment),
			M_Inventory_Location__c=invLoca.id,
			M_Distributor__c=disAccount.id,
			M_Status__c='Draft',
			M_Reason_for_Transaction__c='Wrong Count'
			
		);
		

		insert newInvTrans2;
		
		
		M_Transaction_Item__c  newTransItem2 = new M_Transaction_Item__c (
		M_Inventory__c =newInv2.Id,
		M_Inventory_Transaction__c =newInvTrans2.Id,
		M_Product__c =p1.Id,
		M_Product_Format__c =prodFormatList[0].id,
		M_Adjustment_Type__c='Add to Inventory',
		M_Original_Qty__c = 2
		);
		
		
		//system.debug('\n\n======================================================\n\n');
		//system.debug(newTransItem2);
		//system.debug('\n\n======================================================\n\n');
		
		//insert newTransItem2;
		//newInvTrans2.M_Status__c='Final';
		//update newInvTrans2;
		
		
		buzz_retail__Call__c call = new buzz_retail__Call__c(
    		Name = 'Test Call',
    		buzz_retail__Account__c = outlet.Id,
    		buzz_retail__Date__c = system.now()
    	);
    	system.runas(admin){
    	  insert call;
    	}
		
		//Create Order 
    	M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.DSD_from_SSR_Van),
    	 M_Status__c = 'Draft',
    	 M_Distributor__c =disAccount.Id,
    	 M_AccountName__c= Outlet.Id,
    	 M_Contact__c = 'test',
    	 M_Call__c = call.Id   
    	);
   
     Test.startTest();
	       system.runas(admin){
	    	insert TestOrder;
  		   }	    	 
    	 M_Order_Detail__c TestOrderDetail = new M_Order_Detail__c(
    	 M_Order__c =TestOrder.id,
    	 M_Qty_Ordered__c = 20,
    	 M_Product_Name__c = p1.Id,
    	 M_Product_Format__c = prodForm1.Id
         );
         
         system.runas(admin){
         
         insert TestOrderDetail;
         } 
         
        TestOrder.M_Status__c = 'Final';
    	update TestOrder; 
    
     
        // Schedule the job and test the AutomatedBreakCaseBatch
        AutomatedBreakCaseBatch BCTRX = new AutomatedBreakCaseBatch();
		String schedule = '0 33 13 * * ?';
		 //system.schedule('AutomatedBreakCaseBatch', schedule, BCTRX);
 		Test.stopTest();
 		
        */
 		
 }
           


}