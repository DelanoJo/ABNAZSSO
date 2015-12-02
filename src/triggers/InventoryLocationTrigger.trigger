trigger InventoryLocationTrigger on M_Inventory_Location__c (before insert, before update) {

    if (trigger.isBefore && (trigger.IsInsert || trigger.isUpdate)) {
    	
    	//*******************************************************************
    	//  Disabled and Removed the Default_Reception_Location__c
    	//  CHANGED ON: 04/14/2014
    	//*******************************************************************
    	
        //Build map of existing Locations per account that are in OTHERS Inventory Locations
        set<Id> OthersDisbursementAccounts = new set<Id>();

        for (M_Inventory_Location__c il:[select M_Distributor__c,Default_Disbursement_Location__c from M_Inventory_Location__c where Id not in :trigger.new]) {
             
            if  (il.Default_Disbursement_Location__c==true)
                OthersDisbursementAccounts.add(il.M_Distributor__c);            
        }
    
        
        for (M_Inventory_Location__c il:trigger.new) {
            if (il.Default_Disbursement_Location__c==true) {
                //Make sure there are no other in the map for the same account
                if (OthersDisbursementAccounts.contains(il.M_Distributor__c)) 
                    il.addError(System.Label.InvLocOneDisburment);
            }

        }
        
        
    }

}