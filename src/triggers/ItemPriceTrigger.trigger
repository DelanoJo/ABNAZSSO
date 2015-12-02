trigger ItemPriceTrigger on M_Item_Price__c (before insert, before update, after insert, after update) {
     
    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate) && !ItemPriceRecord.preventUpateTrigger && !(OPLIRecord.getActiveOPLISetting().M_Item_Price_unique_product__c)){// added!ItemPriceRecord.preventUpateTrigger so that trigger is disabled on test
        
        for(M_Item_Price__c a : trigger.new){
            if(System.today() >= a.M_Selling_From__c && System.today() <= a.M_Selling_Until__c){
                a.M_Active_for_Order__c = true;
                system.debug('setting active order');
            }
            
            if(System.today() >= a.M_Returning_From_c__c && System.today() <= a.M_Returning_Until__c){
                a.M_Active_for_Returns__c = true;
                system.debug('setting active return');
            }
        }
    }

    if(trigger.isAfter && !ItemPriceRecord.preventUpateTrigger){
        system.debug('trigger.isAfter'+ItemPriceRecord.preventUpateTrigger);
        List<Id> ProductIds = new List<Id>();
        for (M_Item_Price__c i: trigger.new)
            ProductIds.add(i.M_Item__c);
        if (ProductIds.size()>0)    
            ItemPriceRecord.removeDuplicates(ProductIds);
    }
    
}