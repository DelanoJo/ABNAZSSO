trigger TransactionItemTrigger on M_Transaction_Item__c (before insert, before update,after insert, after update) {
	
	if (trigger.isBefore && (trigger.IsInsert||trigger.IsUpdate)) {
		
		for (M_Transaction_Item__c ti:trigger.new) {
					
			//Debit/Credit transaction/Discrepancy field
			if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Order)) {
				ti.M_Debit_Transaction__c=true;
				ti.M_Credit_Transaction__c=false;
			}
			else if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Returns)) {
				ti.M_Debit_Transaction__c=false;
				ti.M_Credit_Transaction__c=true;
			}
			else if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Inventory_Capture)) {
				ti.M_Discrepancy__c=ti.M_Actual_Qty__c!=null&&ti.M_Actual_Qty__c!=0?ti.M_Original_Qty__c-ti.M_Actual_Qty__c:0;           	
				ti.M_Debit_Transaction__c=false;
				ti.M_Credit_Transaction__c=true;
			}
			else if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Sample_Drop)) {
				ti.M_Discrepancy__c=ti.M_Actual_Qty__c!=null&&ti.M_Actual_Qty__c!=0?ti.M_Original_Qty__c-ti.M_Actual_Qty__c:0;           	
				ti.M_Debit_Transaction__c=true;
				ti.M_Credit_Transaction__c=false;
			}
			else if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Outbound_Transfer)) {
				ti.M_Discrepancy__c=ti.M_Actual_Qty__c!=null&&ti.M_Actual_Qty__c!=0?ti.M_Original_Qty__c-ti.M_Actual_Qty__c:0;
				ti.M_Debit_Transaction__c=true;
				ti.M_Credit_Transaction__c=false;
			}
			else if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Inbound_Transfer)) {
				ti.M_Discrepancy__c=ti.M_Actual_Qty__c!=null&&ti.M_Actual_Qty__c!=0?ti.M_Qty_Transferred__c-ti.M_Actual_Qty__c:0;           	
				ti.M_Debit_Transaction__c=false;
				ti.M_Credit_Transaction__c=true;
			}
			else if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Adjustment)) {
				ti.M_Discrepancy__c=ti.M_Actual_Qty__c!=null&&ti.M_Actual_Qty__c!=0?ti.M_Original_Qty__c-ti.M_Actual_Qty__c:0;
           	
				if (ti.M_Adjustment_Type__c=='Add to Inventory') {
					ti.M_Debit_Transaction__c=false;
					ti.M_Credit_Transaction__c=true;
				}
				else {
					ti.M_Debit_Transaction__c=true;
					ti.M_Credit_Transaction__c=false;				
				}
			}
		
			//Net Qty
			if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Inbound_Transfer)){
				
				ti.M_Original_Qty__c=ti.M_Actual_Qty__c!=null?ti.M_Actual_Qty__c:ti.M_Qty_Transferred__c;
				ti.M_Discrepancy__c=ti.M_Actual_Qty__c!=null&&ti.M_Actual_Qty__c!=0?ti.M_Qty_Transferred__c-ti.M_Actual_Qty__c:0;
           		ti.M_Net_Qty__c=ti.M_Original_Qty__c;
				if (ti.M_Completed__c) 										
					ti.M_Qty_in_Transit__c=0;					
			}
			else
			{
				ti.M_Net_Qty__c=ti.M_Actual_Qty__c!=null?ti.M_Actual_Qty__c:ti.M_Original_Qty__c;							
			}
			
			if (ti.M_Debit_Transaction__c==true&&ti.M_Net_Qty__c!=null)
                	ti.M_Net_Qty__c=-ti.M_Net_Qty__c; 
          
			//Checkbox to manage the roll up to inventory
			if (ti.RecordTypeId==RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Order))        
          		ti.M_CountInInventory__c=true; //For orders, we always count the inventory
          	else {
          		if (ti.M_Completed__c==true)
          			ti.M_CountInInventory__c=true; //For the rest, only if completed.
          	}
          		
          
            //ITRL-0132 Inventory Transaction & Transaction Item is Read Only on Complete Flag
             if(ti.M_Completed__c&&trigger.oldmap.get(ti.id).M_Completed__c&&trigger.IsUpdate){
			//if(ti.M_Completed__c){
				ti.addError(system.label.ReadonlyInventoryTransactionAndTransactionItems);
			}
					
			
		}
		
	}
	 
    //Upon creation of Transaction Item, link the correscodent order detail back to it
    if (trigger.isAfter && trigger.IsInsert) {
    		//This fetches the Order Detail record (written in the Source Reference) to put in a link to the 
	        //transaction item
	    
	        Map<Id,Id> MapOrderDetailTransactionId = new Map<Id,Id> ();     
	        for (M_Transaction_Item__c ti:trigger.new){
	        	MapOrderDetailTransactionId.put((Id)ti.M_OrderDetailReference__c,ti.id);
	        }
	            
	        List<M_Order_Detail__c> OrdDetToUpdate= new List<M_Order_Detail__c>();
	        for (M_Order_Detail__c od: [select M_Transaction_Item__c,Id from M_Order_Detail__c where Id in:MapOrderDetailTransactionId.keyset()]) {
	            if (MapOrderDetailTransactionId.containsKey(od.id)) {
	                od.M_Transaction_Item__c=MapOrderDetailTransactionId.get(od.id);
	                
	                OrdDetToUpdate.add(od);
	            }
	        }
	        update OrdDetToUpdate;
    }
    
    System.debug('MMMMMM TransactionItemTrigger BEFORE BREAK CASE LOGIC');
    
    if (trigger.isAfter && (trigger.isUpdate || trigger.isInsert)) {
	
		System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC');
		List<ID> InventoryIds = new List<ID>();
		for(M_Transaction_Item__c ti : trigger.new){
			
			System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: ti.Id: ' + ti.Id);
			System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: ti.Name: ' + ti.Name);
			System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: ti.M_CountInInventory__c: ' + ti.M_CountInInventory__c);
			System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: ti.M_Net_Qty__c: ' + ti.M_Net_Qty__c);
			System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: trigger.isUpdate: ' + trigger.isUpdate);
			System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: trigger.isInsert: ' + trigger.isInsert);
			
			if(trigger.isUpdate){
				System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC: trigger.oldMap.get(ti.Id).M_CountInInventory__c: ' + trigger.oldMap.get(ti.Id).M_CountInInventory__c);

				if((ti.M_Net_Qty__c < 0 && (ti.M_CountInInventory__c <> trigger.oldMap.get(ti.Id).M_CountInInventory__c)) && ti.M_CountInInventory__c == true){
					System.debug('MMMMMM Added Inventory 1: ' + ti.Name);
					InventoryIds.add(ti.M_Inventory__c);
				}
			}
			else if (trigger.isInsert){
				if(ti.M_Net_Qty__c < 0 && ti.M_CountInInventory__c == true){
					System.debug('MMMMMM Added Inventory 2: ' + ti.Name);
					InventoryIds.add(ti.M_Inventory__c);
				}
			}
		}
		
		if(InventoryIds.Size() > 0 ){
		
			//M_Merck_Product_Code__c,
			List<M_Inventory__c> tiInventories = [SELECT Id,Name, Division, M_BatchExpiration__c, M_BreakCase__c, 
											M_Distributor__c,M_FormatCode__c, M_Inventory_Location__c, M_LastCaseBorken__c,  
											M_IsMobile__c, M_Owner__c, M_Parent_Brand__c, M_Product__c, M_ProductProductFormat__c, M_Product_Format__c,
                                            M_Product_Format__r.Name, M_ProductBatch__c, M_StockQtyAtHand__c, M_StockQtyinTransit__c,
                                            M_Total_Items__c, M_UPC_Code__c
                                            FROM M_Inventory__c WHERE ID IN : InventoryIds  ]; 
			
			List <M_Inventory__c> ListInventoriesToBreak = new List<M_Inventory__c>();
			
			for (M_Inventory__c i:tiInventories) 
				if (i.M_FormatCode__c == 'Each')
					ListInventoriesToBreak.add(i);	
			
			if(ListInventoriesToBreak.Size() > 0 )
				InventoryRecord.ProcessAllInventoriesToBreak(ListInventoriesToBreak); 
		}
		System.debug('MMMMMM TransactionItemTrigger BREAK CASE LOGIC ENDED');
    }
        
}