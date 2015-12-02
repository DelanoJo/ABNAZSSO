public with sharing class PriceListRecord {
	
	
	
    public static M_Price_List__c getPriceListForOutlet(Id accountId) {
        // NOT IMPLEMENTED FOR SUNCARE
        return null;
    }
	
	
	
    public static M_Price_List__c getPriceListForAccount(Id accountId) {
        M_Price_List__c result = null;
        Id searchId = accountId;
        do{
            List<M_Price_List__c> priceLists = [SELECT Id FROM M_Price_List__c WHERE M_IsActive__c = true AND M_Account__c =: searchId];
            system.assert(priceLists.size() <= 1, 'Too many price lists found');

            if (priceLists.size() == 1) {
                result = getPriceList(priceLists[0].Id);
            }
            else {
                Account acc = [SELECT Id,ParentId FROM Account WHERE Id=: searchId];
                searchId = acc.ParentId;
            }
        }
        while(searchId != null && result == null);
        return result;
    }
    
    private static M_Price_List__c getPriceList(Id priceListId) {
    	M_Price_List__c priceList = null;
    	for(M_Price_List__c pl : [SELECT Id FROM M_Price_List__c WHERE Id =: priceListId AND M_IsActive__c = true]){
    		priceList = pl;
    	}
        return priceList == null ? null : priceList;
    }

    public static M_Price_List__c getPriceListForOrder(Id orderId) {
        M_Price_List__c priceList;
        M_Order_sigcap_Header__c o = [SELECT Id, M_AccountName__c FROM M_Order_sigcap_Header__c WHERE Id =: orderId];
        M_OPLI_Settings__c opli = OPLIRecord.getActiveOPLISetting();


        // Step 0
        if (!opli.M_Only_ONE_Price_List_Valid__c) {
            return null;
        }        

        // Step 1
        if (opli.M_Use_Outlet_Pricing__c) {
            priceList = getPriceListForOutlet(o.M_AccountName__c);
            if (priceList != null)
                return priceList;
        }

        // Step 2
        if (opli.M_Use_Customer_Pricing__c) {
            priceList = getPriceListForAccount(o.M_AccountName__c);
            System.debug('PriceListRecord priceList'+priceList+ 'Account name '+o.M_AccountName__c);
            if (priceList != null)
                return priceList;
        }

        // Step 3 Distrib
        if (opli.M_Use_Distributor_Pricing__c) {
            // NOT IMPLEMENTED FOR SUNCARE
        }

        // Step 4 Standard
        // find M_PriceList where standard = true and active
        // M_IsActive__c  M_Price_List_Type__c=standard
        if (opli.M_Price_List__c != null) {
        	System.debug('SD priceList'+ opli.M_Price_List__c);
            priceList = getPriceList(opli.M_Price_List__c);
            if (priceList != null)
                return priceList;
        }

        return null;
    }

}