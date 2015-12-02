@isTest
private class BreakCaseTest {

	static testMethod void testInventoryTrigger() {
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
				
		M_Inventory__c newInv = new M_Inventory__c(
			M_Distributor__c=disAccount.id,
			M_Inventory_Location__c=invLoca.id,
			M_Product__c=NewProduct1.id,
			M_Product_Format__c=FormatCase.id,
			M_BreakCase__c=true			
		);
		insert newInv;		
	}

    static testMethod void GetInvLocationListTest() {

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
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
        insert opli;
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;


        ApexPages.StandardController con = new ApexPages.StandardController(disAccount);
        BreakCasePageCon ext = new BreakCasePageCon(con);
        List<SelectOption> options = ext.GetInvLocationList();
        
        system.assertEquals(1,options.size());
    }

    static testMethod void BreakSelectedItemsTest() {
        
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
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
        insert opli;
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        ApexPages.StandardController con = new ApexPages.StandardController(disAccount);
        BreakCasePageCon ext = new BreakCasePageCon(con);

        ext.selectedInventoriesString = invLoca.Id;
        ext.BreakSelectedItems();
    }
    static testMethod void BreakSelectedItemsNoneSelectedTest() {

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
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
        insert opli;
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        ApexPages.StandardController con = new ApexPages.StandardController(disAccount);
        BreakCasePageCon ext = new BreakCasePageCon(con);

        ext.selectedInventoriesString = '';
        ext.BreakSelectedItems();
    }

    static testMethod void loadInventoriesTest() {

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
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
        insert opli;
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        List<M_Inventory__c> inventories = BreakCasePageCon.loadInventories(invLoca.Id);
    }

    static testMethod void MiscTest() {

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
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=disAccount.Id);
        insert opli;
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;


        ApexPages.StandardController con = new ApexPages.StandardController(disAccount);
        BreakCasePageCon ext = new BreakCasePageCon(con);

        String ns = ext.nameSpace;
        PageReference p1 = ext.doNothing(); 
        PageReference p2 = ext.Close(); 
    }

}