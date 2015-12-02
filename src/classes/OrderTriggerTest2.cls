/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OrderTriggerTest2 {
	
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
	

  	static testmethod void OrderTest_FinalStatus1()
  	{
    	Map<String,ID> profiles = new Map<String,ID>();
		List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
		
		Test.startTest();
		
		User admin = CreateUserForProfile(profiles.get('System Administrator'));
		insert admin;
	    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c = true );
        insert distributor;

		M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
			Name='Test Location',
			M_Distributor__c=distributor.Id,
			Default_Disbursement_Location__c=true
		);
		insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final', 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
    	Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p2.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip1);
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip2);
		insert ipInsertList;
		
		//List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
		//system.debug('ipInsertedList:- '+ipInsertedList);
		
    	buzz_retail__Call__c call = new buzz_retail__Call__c(
    		Name = 'Test Call',
    		buzz_retail__Account__c = outlet.Id,
    		buzz_retail__Date__c = system.now()
    	);
    	insert call;
        
    	M_Order_sigcap_Header__c DSDOrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);
    	
    	M_Order_sigcap_Header__c COFSOrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Order_from_SSR),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);
    	
    	 M_Order_sigcap_Header__c CRTROrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_RDS),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);
    	
    	M_Order_sigcap_Header__c CRTSOrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_SSR_Van),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);

    	    	
    	system.runas(admin){
    		
    		insert DSDOrder;
    		//insert COFSOrder;
    		//insert CRTROrder;
    		//insert CRTSOrder;
    		    	    
    		DSDOrder.M_Status__c = 'Final';
    		update DSDOrder;
    		
    	}
		    	
    	M_Order_sigcap_Header__c finalOrder1 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:DSDOrder.id];
    	system.assertEquals(finalOrder1.M_FinalOrder__c,true);
    	
    	//M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:COFSOrder.id];
    	//system.assertEquals(finalOrder2.M_FinalOrder__c,true);
    	
    	//M_Order_sigcap_Header__c finalOrder3 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:CRTROrder.id];
    	//system.assertEquals(finalOrder3.M_FinalOrder__c,true);
    	
    	//M_Order_sigcap_Header__c finalOrder4 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:CRTSOrder.id];
    	//system.assertEquals(finalOrder4.M_FinalOrder__c,true);
  		
    	Test.stoptest();
  		
  	}	

	/*
  	static testmethod void OrderTest_FinalStatus2()
  	{
    	Map<String,ID> profiles = new Map<String,ID>();
		List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
		
		Test.startTest();
		
		User admin = CreateUserForProfile(profiles.get('System Administrator'));
		insert admin;
	    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c = true );
        insert distributor;

		M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
			Name='Test Location',
			M_Distributor__c=distributor.Id,
			Default_Disbursement_Location__c=true
		);
		insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final',M_DefaultSSROrderSet__c = true, 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
    	Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p2.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip1);
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip2);
		insert ipInsertList;
				
    	buzz_retail__Call__c call = new buzz_retail__Call__c(
    		Name = 'Test Call',
    		buzz_retail__Account__c = outlet.Id,
    		buzz_retail__Date__c = system.now()
    	);
    	insert call;
        
    	
    	M_Order_sigcap_Header__c COFSOrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Order_from_SSR),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);
    	
    	    	
    	system.runas(admin){
    		
    		insert COFSOrder;
    		//insert CRTROrder;
    		//insert CRTSOrder;
    		    	    
    		COFSOrder.M_Status__c = 'Final';
    		update COFSOrder;
    		
    	}
		    	
    	
    	M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:COFSOrder.id];
    	system.assertEquals(finalOrder2.M_FinalOrder__c,true);
    	
  		
    	Test.stoptest();
  		
  	}
  	*/
  	  	
  	static testmethod void OrderTest_FinalStatus3()
  	{
    	Map<String,ID> profiles = new Map<String,ID>();
		List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
		
		Test.startTest();
		
		User admin = CreateUserForProfile(profiles.get('System Administrator'));
		insert admin;
	    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultReturnLocation__c = true );
        insert distributor;

		M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
			Name='Test Location',
			M_Distributor__c=distributor.Id,
			Default_Disbursement_Location__c=true
		);
		insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final',M_DefaultSSROrderSet__c = true, 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Return_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
    	Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p2.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip1);
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip2);
		insert ipInsertList;
				
    	buzz_retail__Call__c call = new buzz_retail__Call__c(
    		Name = 'Test Call',
    		buzz_retail__Account__c = outlet.Id,
    		buzz_retail__Date__c = system.now()
    	);
    	insert call;
        
    	
    	 M_Order_sigcap_Header__c CRTROrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_RDS),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);
    	
    	    	
    	system.runas(admin){
    		
    		insert CRTROrder;
    		    	    
    		CRTROrder.M_Status__c = 'Final';
    		update CRTROrder;
    	}
		    	
    	
    	M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:CRTROrder.id];
    	system.assertEquals(finalOrder2.M_FinalOrder__c,true);
    	
  		
    	Test.stoptest();
  		
  	}
  	
  	/*
  	static testmethod void OrderTest_FinalStatus4()
  	{
    	Map<String,ID> profiles = new Map<String,ID>();
		List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
		for(Profile p : ps){
			profiles.put(p.name, p.id);
		}
		
		Test.startTest();
		
		User admin = CreateUserForProfile(profiles.get('System Administrator'));
		insert admin;
	    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultReturnLocation__c = true );
        insert distributor;

		M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
			Name='Test Location',
			M_Distributor__c=distributor.Id,
			Default_Disbursement_Location__c=true
		);
		insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final',M_DefaultSSROrderSet__c = true, 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Return_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
    	Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p2.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip1);
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
		ipInsertList.add(ip2);
		insert ipInsertList;
				
    	buzz_retail__Call__c call = new buzz_retail__Call__c(
    		Name = 'Test Call',
    		buzz_retail__Account__c = outlet.Id,
    		buzz_retail__Date__c = system.now()
    	);
    	insert call;
        
    	
    	M_Order_sigcap_Header__c CRTSOrder = new M_Order_sigcap_Header__c(
    	 RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_SSR_Van),
    	 M_Status__c = 'Draft',
    	 M_Call__c = call.Id   
    	);
    	
    	    	
    	system.runas(admin){
    		
    		insert CRTSOrder;
    		    	    
    		CRTSOrder.M_Status__c = 'Final';
    		update CRTSOrder;
    	}
		    	
    	
    	M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:CRTSOrder.id];
    	system.assertEquals(finalOrder2.M_FinalOrder__c,true);
    	
  		
    	Test.stoptest();
  		
  	}
  	*/
}