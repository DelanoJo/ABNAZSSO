trigger PriceListTrigger on M_Price_List__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate))
    {
        List<M_Price_List__c> newPriceLists = trigger.new;
        Set<Id> allNewPriceListIds = new Set<Id>();
        Set<Id> allAccountIds = new Set<Id>();

         for (M_Price_List__c pl: newPriceLists){
                allNewPriceListIds.add(pl.Id);
                allAccountIds.add(pl.M_Account__c);
         }

        M_OPLI_Settings__c OPLISettings = OPLIRecord.getActiveOPLISetting();

        List<M_Price_List__c> existingActiveStandardPriceLists = 
            [Select M_Account__c From M_Price_List__c where M_IsActive__c = true and M_Price_List_Type__c = 'Standard' and Id not In: allNewPriceListIds];
            
        List<M_Price_List__c> existingActiveNotStandardPriceLists = 
            [Select M_Account__c From M_Price_List__c where M_IsActive__c = true and M_Price_List_Type__c <> 'Standard' and M_Account__c in: allAccountIds and Id not In: allNewPriceListIds];

		//PLRL-010
        if (OPLISettings.M_Only_ONE_Price_List_Valid__c) {
            for (M_Price_List__c newPriceList:newPriceLists) {

                if (newPriceList.M_IsActive__c ) {
                    if (newPriceList.M_Price_List_Type__c == 'Standard' && (existingActiveStandardPriceLists != null && existingActiveStandardPriceLists.size() > 0))
                        newPriceList.addError('Only one active price list permitted');
                    else if (newPriceList.M_Price_List_Type__c <> 'Standard'){
                     	for (M_Price_List__c EPL:existingActiveNotStandardPriceLists)
                     	  if (newPriceList.M_Account__c == EPL.M_Account__c)
                            	newPriceList.addError('Only one active price list per account is permitted');
                    }
                }
            }
        }
    }
}