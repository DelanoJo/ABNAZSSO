@isTest
private class PriceListTriggerTest {

    static testMethod void PriceListTestActivePriceList() {
    	
    	final ID customerRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Customer);
    	final ID DistributionCenterWithInvRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);
    	
    	Account TestCustomerAccount = new Account(
				Name = 'Test Customer Account',
	            buzz_retail__Customer_Subtype__c = 'National Chain',	             
	            Phone = '5145145145',
	            RecordTypeId = customerRecTypeId,
	            BillingCity = 'Montreal', 
	            BillingCountry = 'Canada', 
	            BillingPostalCode = 'H1H 1H1', 
	            BillingState = 'Quebec', 
	            BillingStreet = 'Cote Vertu');
    
    	insert TestCustomerAccount;
    	
    	Account TestDefaultAccount = new Account(
				Name = 'Test Default Account',
	            buzz_retail__Distributor_Type__c = 'DCS',
	            buzz_retail__IsActive__c = true, 
	            M_Is_Inventory_Return__c = true,
	            M_DefaultOrderLocation__c = true,
	            M_DefaultReturnLocation__c = true,
	            Phone = '5145145145',	            
	            RecordTypeId = DistributionCenterWithInvRecTypeId,
	            BillingCity = 'Montreal', 
	            BillingCountry = 'Canada', 
	            BillingPostalCode = 'H1H 1H1', 
	            BillingState = 'Quebec', 
	            BillingStreet = 'Cote Vertu');
    
    	insert TestDefaultAccount;
    	
    	
    	
    	M_OPLI_Settings__c TestOPLISettings = new M_OPLI_Settings__c(
    			Name = 'Test Settings',
    			M_IsActive__c = true,
    			M_Only_ONE_Price_List_Valid__c = true,
    			M_Default_DSC_Return_Account__c = TestDefaultAccount.Id,
    			M_Default_DSC_Order_Account__c = TestDefaultAccount.Id,
    			M_Def_Inv_Return_Loc__c = TestDefaultAccount.Id
    			
    	); 
    	
    	insert TestOPLISettings;
    	
    	
    	try
    	{
	    	   M_Price_List__c TestPriceList1 = new M_Price_List__c (
	    			Name = 'Default Price List',
	    			M_Price_List_Type__c = 'Standard',
	    			M_IsActive__c = true
	    	);
	    	
	    	insert TestPriceList1;
	    	
	    	M_Price_List__c TestPriceList2 = new M_Price_List__c (
	    			Name = 'Test Price List 2',
	    			M_Price_List_Type__c = 'Standard',
	    			M_IsActive__c = true 
	    	);
	    	
	    	insert TestPriceList2;
	    	
	    	system.assert(false,'Only one active price list permitted');
	    	
    	}catch (System.DmlException e){
    		system.debug('Test1:' + e.getDmlMessage(0));
    	}
    	
    	try
    	{
    		
    	   M_Price_List__c TestPriceList3 = new M_Price_List__c (
    			Name = 'Default Price List',
    			M_Price_List_Type__c = 'Customer',
    			M_IsActive__c = true,
    			M_Account__c = TestCustomerAccount.Id
    		);
    	
    		insert TestPriceList3;
    	
    		M_Price_List__c TestPriceList4 = new M_Price_List__c (
    			Name = 'Test Price List 2',
    			M_Price_List_Type__c = 'Customer',
    			M_IsActive__c = true,
    			M_Account__c = TestCustomerAccount.Id 
    		);
    	
    		insert TestPriceList4;
    		
	    	system.assert(false,'Only one active price list per account is permitted');
    	}
    	catch(System.DmlException e)
    	{
    		system.debug('Test2:' + e.getDmlMessage(0));    		
    	}
    }
}