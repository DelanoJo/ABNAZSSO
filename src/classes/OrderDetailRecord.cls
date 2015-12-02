public class OrderDetailRecord {
	
		public static void CreateTransactionItemForInsert(List<M_Order_Detail__c> orderdetails) {
		
		//TriggerControl.FreezeInventoryTrigger=true;
		
		//This Create Tranasction Items for Manually entered Order Detaisl
		
		//1. Build Map of transactions existing corresponding to the Parent Orders
		set<Id> PossibleOrders = new set<Id>();
		for (M_Order_Detail__c od:orderdetails)
			PossibleOrders.add(od.M_Order__c);
			
		Map<Id,M_Inventory_Transaction__c> MapTransactions = new Map<Id,M_Inventory_Transaction__c>();
		for (M_Inventory_Transaction__c trans:[select Id,M_Distributor__c,M_Inventory_Location__c,RecordTypeId,M_Order__c from M_Inventory_Transaction__c where M_Order__c in:PossibleOrders and M_Completed__c=false])
			MapTransactions.put(trans.M_Order__c,trans);	
		
		//2. Build Map of existing inventories for all possoble locations
		set<Id> PossibleLocations = new set<Id>();
		for (M_Inventory_Transaction__c it:MapTransactions.Values())
			PossibleLocations.add(it.M_Inventory_Location__c);
			
		Map<string,Id> MapInventory = new Map<string,Id>();
        for (M_Inventory__c i: [Select Id,M_Inventory_Location__c,M_Distributor__c,M_Product__c,M_Product_Format__c 
              from M_Inventory__c where M_Inventory_Location__c in:PossibleLocations]) 
            MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);           
        
		
		//3. Check if all the inventories exists
		List<M_Inventory__c> InventoriestoAdd = new List<M_Inventory__c>();   
		
		for (M_Order_Detail__c od:orderdetails) {
			if (MapTransactions.containsKey(od.M_Order__c)) {
				M_Inventory_Transaction__c trans=MapTransactions.get(od.M_Order__c);
				//Check if inventori exists for this                    
                if (!MapInventory.containsKey(String.ValueOf(trans.M_Distributor__c)  + String.ValueOf(trans.M_Inventory_Location__c) + String.ValueOf(od.M_Product_Name__c) + String.ValueOf(od.M_Product_Format__c))) {
                    M_Inventory__c newInvent = new M_Inventory__c();
                    newInvent.M_Inventory_Location__c=trans.M_Inventory_Location__c;
                    newInvent.M_Distributor__c=trans.M_Distributor__c;
                    newInvent.M_Product__c=od.M_Product_Name__c;
                    newInvent.M_Product_Format__c=od.M_Product_Format__c;
                    InventoriestoAdd.add(newInvent);    
                }  	
			}
		}
				       
        //Insert and add to map for further usage.
        if (InventoriestoAdd.size()>0) {
        	TriggerControl.FreezeInventoryTrigger=true;
            insert InventoriestoAdd;
            TriggerControl.FreezeInventoryTrigger=false;
            for (M_Inventory__c i: InventoriesToAdd) {
                MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);   
            }           
        }
        
        List<M_Transaction_Item__c> TransItemToInsert = new List<M_Transaction_Item__c>();
		
		//3. Final Process Loop
		for (M_Order_Detail__c od:orderdetails) {
			if (MapTransactions.containsKey(od.M_Order__c)) {
				M_Inventory_Transaction__c trans=MapTransactions.get(od.M_Order__c);
				
				M_Transaction_Item__c newTransItem = new M_Transaction_Item__c();
				
				newTransItem.M_Inventory_Transaction__c=trans.Id;
                
                //Rec Type
                if (trans.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Order)) {
                    newTransItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Order);
                    newTransItem.M_Credit_Transaction__c=false;                        
                    newTransItem.M_Debit_Transaction__c=true;
                }                                           
                else if (trans.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Returns)){
                    newTransItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Returns);
                    newTransItem.M_Credit_Transaction__c=true;
                    newTransItem.M_Debit_Transaction__c=false;    
                }                  
                                                    
                newTransItem.M_Inventory__c=MapInventory.get(String.ValueOf(trans.M_Distributor__c)+String.ValueOf(trans.M_Inventory_Location__c)+String.ValueOf(od.M_Product_Name__c)+String.ValueOf(od.M_Product_Format__c));
                
                newTransItem.M_Product__c=od.M_Product_Name__c;
                newTransItem.M_Product_Format__c=od.M_Product_Format__c;                   
                newTransItem.M_Original_Qty__c=od.M_Qty_Ordered__c;
  
                newTransItem.M_OrderDetailReference__c=od.id;
                TransItemToInsert.add(newTransItem);    
				
			}	
		}
		
		if (TransItemToInsert.size()>0)
			insert TransItemToInsert;
			
	}
	
}