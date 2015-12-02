@isTest
private class ManageTransactionItemTest {

    static testMethod void miscTest() {

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
            M_Inventory_Location__c=invLoca.id, M_Status__c='draft'
        );
        insert newInvCapture;

        ApexPages.StandardController con = new ApexPages.StandardController(newInvCapture);
        ManageTransactionItemCon ext = new ManageTransactionItemCon(con);

        String ns = ext.nameSpace;
        Boolean isAdjustment = ext.IsAdjustment;
        Boolean isInBound = ext.IsInBound;
        Boolean isStandard = ext.IsStandard;
        PageReference p = ext.Close();        

    }

    static testMethod void loadTransItemsTest() {

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
            M_Inventory_Location__c=invLoca.id, M_Status__c='draft'
        );
        insert newInvCapture;

        List<M_Transaction_Item__c> items = ManageTransactionItemCon.loadTransItems(newInvCapture.Id, 'InboundTransfer');
    }


    static testMethod void CheckAutoCreatedTest() {

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
            M_Inventory_Location__c=invLoca.id, M_Status__c='draft'
        );
        insert newInvCapture;

		ApexPages.StandardController con = new ApexPages.StandardController(newInvCapture);

	    ManageTransactionItemCon ext = new ManageTransactionItemCon(con);

        List<M_Transaction_Item__c> items = ManageTransactionItemCon.loadTransItems(newInvCapture.Id, 'Adjustment');      
	
	    String ns = ext.nameSpace;
	    Boolean isAdjustment = ext.IsAdjustment;
	    Boolean isInBound = ext.IsInBound;
	    Boolean isStandard = ext.IsStandard;
	    PageReference p = ext.Close();  
       

    }

}