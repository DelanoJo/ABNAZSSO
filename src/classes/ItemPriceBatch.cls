global class ItemPriceBatch implements Schedulable,Database.Batchable<sObject>{ 


    global Database.QueryLocator start(Database.BatchableContext BC)
    {   system.debug('leela start');
        string query='select Name, CreatedDate, M_Item__c, M_IntNameValue__c,M_PriceListProductProductFormat__c, M_ProductProductFormat__c, M_Product_Format__c, M_Active_for_Order__c, M_Selling_From__c, M_Selling_Until__c, M_Active_for_Returns__c, M_Returning_From_c__c, M_Returning_Until__c from M_Item_Price__c ';
        return Database.getQueryLocator(query);
    }
     
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {   
        system.debug('ItemPrice batch'+scope); 
        ItemPriceRecord.calledFromBatch = true;
        ItemPriceRecord.setUnsetFlags((List <M_Item_Price__c>)scope);
        //detecting duplicates based on product,Product Format,and Name having the highest autonumber
        ItemPriceRecord.removeDuplicatesInBatch((List <M_Item_Price__c>)scope);
    }
    
    global void execute(SchedulableContext ctx) {       
        Database.executeBatch(new ItemPriceBatch()); 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        ItemPriceRecord.sendEmailJobFinish(BC, 'ItemPriceBatch');
    }
}