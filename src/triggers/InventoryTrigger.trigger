trigger InventoryTrigger on M_Inventory__c (after insert, after update, before insert,before update) {

// ****************** MM 2013-10-10 AUTO BREAK CASE CODE  MOVED TO TRNSACTION ITEM TRIGGER

/*
System.Debug('MMMMMM : InventoryTrigger trigger.new.size: ' + trigger.new.size());
if(trigger.isDelete)
	System.Debug('MMMMMM : InventoryTrigger isDelete');
	
if (trigger.isAfter) {
	//Item#703 - Setting Break Case checkbox to true if Each Inventory is negative 
	System.Debug('MMMMMM : InventoryTrigger isAfter');
			
	List <M_Inventory__c> ListInventoriesToBreak = new List <M_Inventory__c>();
	system.debug('*****************************LN  In Trigger Inventory Trigger Break Case');  
	for (M_Inventory__c i:trigger.new) 
		if (i.M_FormatCode__c =='Each')
			ListInventoriesToBreak.add(i);
	
	if(ListInventoriesToBreak.size()>0){
		InventoryRecord.ProcessAllInventoriesToBreak(ListInventoriesToBreak); 
	}
}

System.Debug('MMMMMM : InventoryTrigger END');
*/


// **************** MM  MM 2013-10-10 OLD MANUAL BREAK CASE CODE 

/*private static boolean stillNegativeInv = true;
	
	
	System.DEbug('LN Break CAse Test:FreezeTrigger=' + TriggerControl.FreezeInventoryTrigger);
	
	if (!TriggerControl.FreezeInventoryTrigger)
	{ 
		if (trigger.isAfter) 
		{//Item#703 - Setting Break Case checkbox to true if Each Inventory is negative 
			
			List <M_Inventory__c> ListInventoriesToBreak = new List <M_Inventory__c>();
			System.Debug('*****************************LN  In Trigger Inventory Trigger Break Case');  
			for (M_Inventory__c i:trigger.new) 
				if (i.M_FormatCode__c =='Each')
					ListInventoriesToBreak.add(i);
						  
			InventoryRecord.ProcessAllInventoriesToBreak(ListInventoriesToBreak); 
		}
	}
	//END --Item 703 End
	
   
   /* Old Break case functionaltly removed 
    if (!TriggerControl.FreezeInventoryTrigger)
     {   
		if (trigger.isAfter) 
		{	
			System.DEbug('FRED Break CAse Test 2');		
			List<Id> InventoriesToBreakIds = new list<Id>();
			for (M_Inventory__c i:trigger.new)
			{
				System.DEbug('FRED Break CAse Test 3 ' + i.M_BreakCase__c + ' ' + i.name);
				if (i.M_BreakCase__c==true)
				 {
					System.DEbug('FRED Break CAse Test 4');
					InventoriesToBreakIds.add(i.id);
				 }
			}					
			if (InventoriesToBreakIds.size()>0) {
				System.DEbug('FRED Break CAse Test 5');
				InventoryTransactionRecord.ProcessInventoryBreak(InventoriesToBreakIds);
			}		
		}
	}*/
}