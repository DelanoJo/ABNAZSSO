global class AutomatedBreakCaseBatch implements Schedulable,Database.Batchable<sObject>{ 

    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
    	system.debug('*******************************LN Batch start');
    	//limit limit 50000';
        string query='Select Id,Name,M_StockQtyAtHand__c,M_FormatCode__c from M_Inventory__c  where M_StockQtyAtHand__c <0 and M_FormatCode__c=\'Each\' limit 50000';
        system.debug('*******************************LN Query :'+ query);
        return Database.getQueryLocator(query);
    }
     
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {   
        system.debug('*******************************LN AutomatedBreakCaseBatch Scope:'+scope);
       // TriggerControl.FreezeInventoryTriggerBreakCase =True;
        //InventoryRecord.CalledFromAutomateBreakCaseBatch = true;
        InventoryRecord.ProcessAllInventoriesToBreak((List <M_Inventory__c>)scope); 
        
    }
    
    global void execute(SchedulableContext ctx) {       
        Database.executeBatch(new AutomatedBreakCaseBatch()); 
    }
    
    global void finish(Database.BatchableContext BC)
    {  // TriggerControl.FreezeInventoryTriggerBreakCase =False;
        system.debug('*******************************LN Batch FINISH');
    }


}