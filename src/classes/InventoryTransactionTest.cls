@isTest
private class InventoryTransactionTest {

	static testMethod void OrderTransactionTest() {
	     
	     test.startTest();
		 Account outletAccount = new Account(
			Name = 'Test Account 1',
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',	            
            RecordTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet),
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            M_Route_Number__c = 8888);
    
    	insert outletAccount;
		Account disAccount = new Account(
			Name = 'Test Distributor',
	        buzz_retail__Distributor_Type__c = 'SSR',
	        buzz_retail__Account_ID__c = '121212',
	        buzz_retail__IsActive__c = true, 
	        M_Is_Inventory_Location__c = true,
	         M_Is_Inventory_Return__c = true,
	        Phone = '5145145145',	            
	        RecordTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),
	        BillingCity = 'Montreal', 
	        BillingCountry = 'Canada', 
	        BillingPostalCode = 'H1H 1H1', 
	        BillingState = 'Quebec', 
	        BillingStreet = 'Cote Vertu',
	        ShippingStreet = 'Street2',
	        ShippingCity = 'City2',
	        ShippingState = 'State2',  
	        ShippingPostalCode = 'PostalCode2',
	        ShippingCountry = 'Country2',
	        M_Route_Number__c = 9999);  
	
		insert disAccount;
		M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
         insert opli;
		M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
			Name='Test Location',
			M_Distributor__c=disAccount.Id,
			Default_Disbursement_Location__c=true
		);
		insert invLoca;
		
		buzz_retail__Product__c NewProduct1 = new buzz_retail__Product__c(
			Name='TestProduct1',
			RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item),
			buzz_retail__IsActive__c=true,
			M_AllowInventory__c=true,
			buzz_retail__AllowAuditDetailing__c=true,
			buzz_retail__Allow_Ordering__c=true,
			M_Allow_Returns__c=true,
			buzz_retail__Price_per_Case__c=20,
			buzz_retail__ProductID__c='111',
			buzz_retail__SRP__c=2,
			buzz_retail__UPC_Code__c='111'
		);
		insert NewProduct1;		
		
		buzz_retail__Product__c NewProduct2 = new buzz_retail__Product__c(
			Name='TestProduct2',
			RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item),
			buzz_retail__IsActive__c=true,
			M_AllowInventory__c=true,
			buzz_retail__AllowAuditDetailing__c=true,
			buzz_retail__Allow_Ordering__c=true,
			M_Allow_Returns__c=true,
			buzz_retail__Price_per_Case__c=20,
			buzz_retail__ProductID__c='222',
			buzz_retail__SRP__c=2,
			buzz_retail__UPC_Code__c='222'
		);
		insert NewProduct2;	
		
		buzz_retail__ProductFormat__c FormatCase = new buzz_retail__ProductFormat__c(
			Name='Case',
			M_Active__c=true,
			buzz_retail__Conversion_Eaches__c=10,
			buzz_retail__Conversion_Cases__c=10,
			buzz_retail__FormatCode__c='Case',
			M_Inventory__c=true,M_Order__c=true,M_Sales__c=true,		
			buzz_retail__Product__c=NewProduct1.id		
		);
		insert FormatCase;
		
		buzz_retail__ProductFormat__c FormatCase2 = new buzz_retail__ProductFormat__c(
			Name='Case',
			M_Active__c=true,
			buzz_retail__Conversion_Eaches__c=10,
			buzz_retail__Conversion_Cases__c=10,
			buzz_retail__FormatCode__c='Case',
			M_Inventory__c=true,M_Order__c=true,M_Sales__c=true,		
			buzz_retail__Product__c=NewProduct2.id		
		);
		insert FormatCase2;
		
		M_Inventory__c newInv = new M_Inventory__c(
			M_Distributor__c=disAccount.id,
			M_Inventory_Location__c=invLoca.id,
			M_Product__c=NewProduct1.id,
			M_Product_Format__c=FormatCase.id			
		);
		insert newInv;
		
		//ORI-029
    	M_Order_sigcap_Header__c TestOrder1 = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery),
    	 M_Status__c = 'Draft',
    	 M_AccountName__c = outletAccount.Id,
    	 M_Order_Transaction_Type__c = 'Order',
    	 M_Distributor__c=disAccount.id,	 
    	 M_Inventory_TransactionType__c = 'Order'   
    	);
		insert TestOrder1;
		
		test.stopTest();
		
		M_Order_Detail__c orddet = new M_Order_Detail__c(
			M_Order__c=TestOrder1.id,
			M_Product_Name__c=NewProduct1.id,
			M_Product_Format__c=FormatCase.id,
			M_Qty_Ordered__c=1
		);
		insert orddet;
		
		TestOrder1.M_Inventory_Submitted__c=true;
		update TestOrder1;
		
		orddet.M_Qty_Ordered__c=10;
		update orddet;
		
		//Insert Order Detail to test the OrderDetail/insert trigger when a transaction exists.
		M_Order_Detail__c orddet2 = new M_Order_Detail__c(
			M_Order__c=TestOrder1.id,
			M_Product_Name__c=NewProduct2.id,
			M_Product_Format__c=FormatCase2.id,
			M_Qty_Ordered__c=1
		);
		insert orddet2;
		
	}
	 
    static testMethod void InventoryCaptureOutboundBreakCaseTest() {
                          
		  Account disAccount = new Account(
			Name = 'Test Distributor',
	        buzz_retail__Distributor_Type__c = 'SSR',
	        buzz_retail__Account_ID__c = '121212',
	        buzz_retail__IsActive__c = true, 
	        M_Is_Inventory_Location__c = true,
	        M_Is_Inventory_Return__c = true,
	        Phone = '5145145145',	            
	        RecordTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),
	        BillingCity = 'Montreal', 
	        BillingCountry = 'Canada', 
	        BillingPostalCode = 'H1H 1H1', 
	        BillingState = 'Quebec', 
	        BillingStreet = 'Cote Vertu',
	        ShippingStreet = 'Street2',
	        ShippingCity = 'City2',
	        ShippingState = 'State2',  
	        ShippingPostalCode = 'PostalCode2',
	        ShippingCountry = 'Country2',
	        M_Route_Number__c = 9999);  
	
		insert disAccount;
		  M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
         insert opli;
         
		M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
			Name='Test Location',
			M_Distributor__c=disAccount.Id,
			Default_Disbursement_Location__c=true
		);
		insert invLoca;
		
		buzz_retail__Product__c NewProduct1 = new buzz_retail__Product__c(
			Name='TestProduct1',
			RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item),
			buzz_retail__IsActive__c=true,
			M_AllowInventory__c=true,
			buzz_retail__AllowAuditDetailing__c=true,
			buzz_retail__Allow_Ordering__c=true,
			M_Allow_Returns__c=true,
			buzz_retail__Price_per_Case__c=20,
			buzz_retail__ProductID__c='111',
			buzz_retail__SRP__c=2,
			buzz_retail__UPC_Code__c='111'
		);
		insert NewProduct1;
		
		buzz_retail__ProductFormat__c FormatEach = new buzz_retail__ProductFormat__c(
			Name='Each',
			M_Active__c=true,
			buzz_retail__Conversion_Eaches__c=10,
			buzz_retail__Conversion_Cases__c=10,
			buzz_retail__FormatCode__c='Each',
			M_Inventory__c=true,M_Order__c=true,M_Sales__c=true,
			buzz_retail__Product__c=NewProduct1.id		
		);
		insert FormatEach;
		
		buzz_retail__ProductFormat__c FormatCase = new buzz_retail__ProductFormat__c(
			Name='Case',
			M_Active__c=true,
			buzz_retail__Conversion_Eaches__c=10,
			buzz_retail__Conversion_Cases__c=10,
			buzz_retail__FormatCode__c='Case',
			M_Inventory__c=true,M_Order__c=true,M_Sales__c=true,		
			buzz_retail__Product__c=NewProduct1.id		
		);
		insert FormatCase;
		
		//Insert Inventory Capture Transaction
		M_Inventory_Transaction__c newInvCapture = new M_Inventory_Transaction__c(
			RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType, RecType.Name.Inventory_Capture),
			M_Distributor__c=disAccount.id,
			M_Inventory_Location__c=invLoca.id,	M_Status__c='draft'
		);
		insert newInvCapture;
		
		//Fetch the created Transation Items in the trigger, and put the quantity of one to 1
		for (M_Transaction_Item__c ti:[select M_Original_Qty__c from M_Transaction_Item__c where M_Inventory_Transaction__c=:newInvCapture.id]) {
			ti.M_Original_Qty__c=1;
			update ti;
			break;
		}
		
		
		//Change the status of the invCapture to final
		newInvCapture.M_Completed__c=true;
		update newInvCapture;
		
		//Insert Inventory Capture Transaction
		M_Inventory_Transaction__c newOutbound = new M_Inventory_Transaction__c(
			RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType, RecType.Name.Outbound_Transfer),
			M_Distributor__c=disAccount.id,			
			M_Inventory_Location__c=invLoca.id,	M_Status__c='draft',
			M_Destination_Inventory_Location__c=invLoca.id,
			M_To__c=disAccount.id			
		);
		insert newOutbound;
		
		//Fetch the created Transation Items in the trigger, and put the quantity of one to 1
		for (M_Transaction_Item__c ti:[select M_Original_Qty__c from M_Transaction_Item__c where M_Inventory_Transaction__c=:newOutbound.id]) {
			ti.M_Original_Qty__c=1;
			update ti;
			break;
		}
		
		newOutbound.M_Completed__c=true;
		update newOutbound;
	
		M_Inventory__c newInv = new M_Inventory__c(
			M_Distributor__c=disAccount.id,
			M_Inventory_Location__c=invLoca.id,
			M_Product__c=NewProduct1.id,
			M_Product_Format__c=FormatCase.id			
		);
		insert newInv;
		
		M_Transaction_Item__c newTransItem = new M_Transaction_Item__c(
			M_Inventory_Transaction__c=newOutbound.id,
			M_Inventory__c=newInv.id,
			M_Product__c=NewProduct1.id,
			M_Product_Format__c=FormatCase.id,
			M_Original_Qty__c=10
			);
		insert newTransItem;
		
		List<Id> InvtoBreakList = new List<Id>();
		InvToBreakList.add(newInv.id);
		
		InventoryTransactionrecord.ProcessInventoryBreak(InvToBreakList);
		
	
    }
    
}