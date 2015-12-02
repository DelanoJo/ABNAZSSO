public class InventoryTransactionRecord
{
     
    public static boolean preventUpateTrigger = true; //to prevent the recursion of update trigger 
    
    public static  List<M_Inventory__c> FindEmptyInventoryRecord(List<M_Transaction_Item__c> infantItems) {
    	
      	System.Debug('MMMMMM : InventoryTransactionRecord.FindEmptyInventoryRecord infantItems.size: ' + infantItems.size());
    	
		//Modified by Minh-Dien Le
		//Check empty inventories without children
  		List <M_Inventory__c> emptyInventories = new List<M_Inventory__c>([Select m.id, m.Name From M_Inventory__c m where M_StockQtyinTransit__c=0 and M_StockQtyAtHand__c=0 and Id NOT IN  (SELECT M_Inventory__c FROM M_Transaction_Item__c where id in:infantItems)]);
  		
  		System.Debug('MMMMMM : InventoryTransactionRecord.FindEmptyInventoryRecord END');
  		return emptyInventories;
  		     	
  		
 
  		/*
  		Old code
  		This method return all inventories with and without children
  		
    	set<ID> possibleinventories = new set<ID>();
    	for (M_Transaction_Item__c ti:[select id,M_Inventory__c from M_Transaction_Item__c where id in:infantItems]) {
    		possibleinventories.add(ti.M_Inventory__c);
    	}
    	
    	List<M_Inventory__c> zeroInventories = new List<M_Inventory__c>([select id from M_Inventory__c where Id in:PossibleInventories and M_StockQtyAtHand__c=0 and M_StockQtyinTransit__c=0]);
    	return zeroInventories;
    	*/
    }
    
    
    
    public static void ProcessInventoryBreak(List<Id> InventoriesToBreak) {
    	
    	System.Debug('MMMMMM : InventoryTransactionRecord.ProcessInventoryBreak InventoriesToBreak.size: ' + InventoriesToBreak.size());
    	TriggerControl.FreezeInventoryTrigger=true;
    	
    	System.Debug('FRED : TEST BREAK TRIGGER Process InvBreak 1');
    	M_OPLI_Settings__c opli=OPLIRecord.getActiveOPLISetting();    	
    	    
    	//M_Merck_Product_Code__c,
    	Map<Id,M_Inventory__c> inventories = new Map<Id,M_Inventory__c>([SELECT Id, Name,M_Inventory_Location__c,M_Distributor__c,
        			M_BreakCase__c,M_BatchExpiration__c,M_IsMobile__c,M_LastCaseBorken__c,
        			M_Owner__c,M_Product__c,M_Product_Format__c,M_ProductBatch__c,M_UPC_Code__c,M_Product_Format__r.buzz_retail__Conversion_Eaches__c
                    FROM M_Inventory__c
                    WHERE id in:InventoriesToBreak and M_Product_Format__r.buzz_retail__FormatCode__c='Case']);
 
    	if (inventories.size()>0){
    		
    		Map<Id,Id> MapProductEaches = new Map<Id,Id>();
    		List<M_Inventory_Transaction__c> newTransactions = new list<M_Inventory_Transaction__c>();
    	
    		set<Id> possibleProducts = new set<Id>();
        	set<Id> possibleLocations= new set<Id>();
    		for (M_Inventory__c caseInv:inventories.values()) {
        		possibleProducts.add(caseInv.M_Product__c); 
        		possibleLocations.add(caseInv.M_Inventory_Location__c);      		
        	}
    		
    		//1. Build Map of corresponding "Eaches" by products
    		for (buzz_retail__ProductFormat__c pf:[select Id,buzz_retail__Product__c from buzz_retail__ProductFormat__c where buzz_retail__Product__c in :PossibleProducts and buzz_retail__FormatCode__c='Each'])
    			MapProductEaches.put(pf.buzz_retail__Product__c,pf.id);	
    	
    	    		
    		//2. Build Missing "EACH" inventories
    		Map<string,Id> MapEachInventory = new Map<string,Id>();
        	        	      
        	for (M_Inventory__c eachinv:[select Id,M_Product__c,M_Inventory_Location__c,M_Distributor__c,M_Product_Format__c from M_Inventory__c
        	                     where M_Product__c in:possibleProducts and M_Inventory_Location__c in:possibleLocations
        	                     and M_Product_Format__r.buzz_retail__FormatCode__c ='Each' ]) {
        		MapEachInventory.put(String.ValueOf(eachinv.M_Distributor__c)+String.ValueOf(eachinv.M_Inventory_Location__c)+String.ValueOf(eachinv.M_Product__c),eachinv.id);
        	}
	        
	        //Loop in case inventories and check what is missing
	        List<M_Inventory__c> inventoriestoAdd = new List<M_Inventory__c>();
	        for (M_Inventory__c caseInv:inventories.values()) {
	        	string key=String.ValueOf(caseInv.M_Distributor__c)+String.ValueOf(caseInv.M_Inventory_Location__c)+String.ValueOf(caseInv.M_Product__c);
	        	if (!MapEachInventory.containsKey(key)) {
					M_Inventory__c newInvent = new M_Inventory__c();
			        newInvent.M_Inventory_Location__c=caseInv.M_Inventory_Location__c;
			        newInvent.M_Distributor__c=caseInv.M_Distributor__c;
			        newInvent.M_Product__c=caseInv.M_Product__c;
			        newInvent.M_Product_Format__c=MapProductEaches.get(caseInv.M_Product__c);
					InventoriestoAdd.add(newInvent);    
	        	}      		
        	}
	         
	        //Insert and add to map for further usage.
	        if (InventoriestoAdd.size()>0) {
	            insert InventoriestoAdd;
	            for (M_Inventory__c i: InventoriesToAdd) {
	                MapEachInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c),i.id);   
	            }           
	        }   
	 		    		    	
	    	for (M_Inventory__c inventory:inventories.Values()) {
	    		
	    			//3. Transaction Header
	    			M_Inventory_Transaction__c newTrans=new M_Inventory_Transaction__c();
	    			newTrans.RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Break_Case);
	    			newTrans.M_Distributor__c=inventory.M_Distributor__c;
	    			newTrans.M_Transaction_Date__c=System.Today();
	    			newTrans.M_Inventory_Location__c=inventory.M_Inventory_Location__c;
	    			newTrans.M_From__c=inventory.M_Distributor__c;
	    			newTrans.M_To__c=inventory.M_Distributor__c;
	    			newTrans.M_Status__c='Processing';
	    			newTrans.M_Transaction_Origin_ID__c=inventory.id;
	    			newTransactions.add(newTrans);
	    			
	    			//4. Upadte Inventory's Last Date Broken	    			
	    			inventory.M_LastCaseBorken__c=System.Today();
	    			inventory.M_BreakCase__c=false; //to avoid retriggering this when it's coming from the mobile
	    				    	
	    	}
	    		    	
    		insert newTransactions;
    		
    		
    		    		    		 
    		List<M_Transaction_Item__c> newTransItems = new List<M_Transaction_Item__c>();
    		
    		for (M_Inventory_Transaction__c trans:newTransactions) {
    			
    			M_Inventory__c originalInv=inventories.get(trans.M_Transaction_Origin_ID__c);
    			    			    	
    			//5. Debit Transation
    			M_Transaction_Item__c debitTrans = new M_Transaction_Item__c();
    			debitTrans.M_Inventory_Transaction__c=trans.Id;
    			debitTrans.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Break_Case);
    			debitTrans.M_Inventory__c=trans.M_Transaction_Origin_ID__c;
    			debitTrans.M_Product__c=originalInv.M_Product__c;
    			debitTrans.M_Product_Format__c=originalInv.M_Product_Format__c; //Should always be a case
    			debitTrans.M_Original_Qty__c=1; //1 case
    			debitTrans.M_IsMobile__c=trans.M_IsMobile__c;
    			debitTrans.M_Debit_Transaction__c=true;
    			debitTrans.M_Credit_Transaction__c=false;
    			newTransItems.add(debitTrans);
    			    			    		
    			//6. Credit Transaction //should point to a "Each" inventory
    			M_Transaction_Item__c creditTrans = new M_Transaction_Item__c();
    			creditTrans.M_Inventory_Transaction__c=trans.Id;
    			creditTrans.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Break_Case);
    			creditTrans.M_Inventory__c=MapEachInventory.get(String.ValueOf(originalInv.M_Distributor__c)+String.ValueOf(originalInv.M_Inventory_Location__c)+String.ValueOf(originalInv.M_Product__c));
    			creditTrans.M_Product__c=originalInv.M_Product__c;    			
    			creditTrans.M_Product_Format__c=MapProductEaches.get(originalInv.M_Product__c);
    			creditTrans.M_Original_Qty__c=originalInv.M_Product_Format__r.buzz_retail__Conversion_Eaches__c;
    			creditTrans.M_IsMobile__c=trans.M_IsMobile__c;
    			creditTrans.M_Debit_Transaction__c=false;
    			creditTrans.M_Credit_Transaction__c=true;
    			newTransItems.add(creditTrans); 
    			
    			trans.M_Status__c=opli.Inventory_Transaction_Completion_Status__c;   			
    		}
    		
    		insert newTransItems;
    		update newTransactions; //to reflect final status
    		    	
    		//Update inventories with Last Date Broken
    		update inventories.Values();
    		    		    	
    	}   
    	
    	System.Debug('MMMMMM : InventoryTransactionRecord.ProcessInventoryBreak END');
    	 	
    }
     
     public static void ProcessOutboundTransfers(List<M_Inventory_Transaction__c> outboundTransfers) {
        
        System.Debug('MMMMMM : InventoryTransactionRecord.ProcessOutboundTransfers outboundTransfers.size: ' + outboundTransfers.size());
        
        TriggerControl.FreezeInventoryTrigger=true;
        
        Map<Id,List<M_Transaction_Item__c>> OutboundMapTransItems=TransactionItemRecord.BuildMapTransactionitems(outboundTransfers);
        
        List<M_Inventory_Transaction__c> inboundTransfers_toinsert = new List<M_Inventory_Transaction__c>();

		Map<Id,Id> MapInboundOutbound = new Map<Id,Id>();

		//1. Create headers                        
        for (M_Inventory_Transaction__c out:outboundTransfers) {                      
            M_Inventory_Transaction__c inb = new M_Inventory_Transaction__c();
            inb.RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Inbound_Transfer);
            inb.M_Distributor__c=out.M_To__c;
           	inb.M_Transaction_Origin_ID__c=out.id;
            inb.M_Transaction_Date__c=System.Today();
            inb.M_Inventory_Location__c=out.M_Destination_Inventory_Location__c; 
            inb.M_From__c=out.M_From__c;
            inb.M_To__c=out.M_To__c;
            inb.M_Status__c='processing';                       
            inboundTransfers_toinsert.add(inb);     
        }
        
        insert inboundTransfers_toinsert;
        
        //2-Build and Insert Inventories for possible distributors and location
  		Set<string> PossibleDistributorLocationKey = new Set<string>();
  		Set<Id> PossibleDistributors = new set<Id>();
  		
  		for (M_Inventory_Transaction__c it:inboundTransfers_toinsert){  			  	  			
  			PossibleDistributorLocationKey.add(it.M_Distributor__c+''+it.M_Inventory_Location__c);
			PossibleDistributors.add(it.M_Distributor__c);		   			  			   			  			
  		}
        
        Map<string,Id> MapInventory = new Map<string,Id>();
        
        for (M_Inventory__c i: [Select Id,M_Inventory_Location__c,M_Distributor__c,M_Product__c,M_Product_Format__c 
              from M_Inventory__c where M_Distributor__c in:PossibleDistributors ]) {
            MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);           
        }
        
        List<M_Inventory__c> InventoriestoAdd = new List<M_Inventory__c>();     
        
        for (M_Inventory_Transaction__c t: inboundTransfers_toinsert) {  
        	if (OutboundMapTransItems.containsKey(t.M_Transaction_Origin_ID__c)) {
				for (M_Transaction_Item__c outTi:OutboundMapTransItems.get(t.M_Transaction_Origin_ID__c)) {
					string key=String.ValueOf(t.M_Distributor__c) + String.ValueOf(t.M_Inventory_Location__c) + String.ValueOf(outTi.M_Product__c) + String.ValueOf(outTi.M_Product_Format__c);
        			if (!MapInventory.containsKey(key)) {
	                    M_Inventory__c newInvent = new M_Inventory__c();
	                    newInvent.M_Inventory_Location__c=t.M_Inventory_Location__c;
	                    newInvent.M_Distributor__c=t.M_Distributor__c;
	                    newInvent.M_Product__c=outTi.M_Product__c;
	                    newInvent.M_Product_Format__c=outTi.M_Product_Format__c;
                		InventoriestoAdd.add(newInvent);    
                	}  	
				}        	
			}   			  	                       		        		        	        
        }
        
        //Insert and add to map for further usage.
        if (InventoriestoAdd.size()>0) {
            insert InventoriestoAdd;
            for (M_Inventory__c i: InventoriesToAdd) {
                MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);   
            }           
        }
        
        
        List<M_Transaction_Item__c> InboundItem_toinsert = new list<M_Transaction_Item__c>();
        
		for (M_Inventory_Transaction__c inbtrans:inboundTransfers_toinsert) {
			if (OutboundMapTransItems.containsKey(inbtrans.M_Transaction_Origin_ID__c)) {
				for (M_Transaction_Item__c outTi:OutboundMapTransItems.get(inbtrans.M_Transaction_Origin_ID__c)) {
					
					string key=String.ValueOf(inbtrans.M_Distributor__c) + String.ValueOf(inbtrans.M_Inventory_Location__c) + String.ValueOf(outTi.M_Product__c) + String.ValueOf(outTi.M_Product_Format__c);
					
					M_Transaction_Item__c newinTi = new M_Transaction_Item__c();
					newinTi.M_Inventory_Transaction__c=inbtrans.id;
					newinTi.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Inbound_Transfer);
					newinTi.M_Inventory__c=MapInventory.Containskey(key)?MapInventory.get(key):null;
					newinTi.M_Product__c=outTi.M_Product__c;
					newinTi.M_Product_Format__c=outTi.M_Product_Format__c;
					newinTi.M_Qty_Transferred__c=outTi.M_Original_Qty__c;
					newinTi.M_Qty_in_Transit__c=outTi.M_Original_Qty__c;
					newinTi.M_IsMobile__c=outTi.M_IsMobile__c;
					newinTi.M_Credit_Transaction__c=true;
					newinTi.M_Debit_Transaction__c=false;

					InboundItem_toinsert.add(newinTi);
				}
			}
			inbtrans.M_Status__c='Pending';  
		}
        
        if (InboundItem_toinsert.size()>0)
        	insert InboundItem_toinsert;
        
        update inboundTransfers_toinsert;
        
        System.Debug('MMMMMM : InventoryTransactionRecord.ProcessOutboundTransfers END');
        
    }
     
     public static void CreateTransactionItemForInventoryCapture(List<M_Inventory_Transaction__c> ManualTransactions) {
   	
   	  	System.Debug('MMMMMM : InventoryTransactionRecord.CreateTransactionItemForInventoryCapture ManualTransactions.size: ' + ManualTransactions.size());
   	
   		TriggerControl.FreezeInventoryTrigger=true;
   	
   		//1-Build Map of Capture Product Formats 
   		List<buzz_retail__ProductFormat__c> CapturedProductFormat = TransactionItemRecord.BuildListProductAndProductFormatForInventoryCapture();	
   		
   		//2-Build and Insert Invetories for possible distributors and location
  		Set<string> PossibleDistributorLocationKey = new Set<string>();
  		Set<Id> PossibleDistributors = new set<Id>();
  		
  		for (M_Inventory_Transaction__c it:ManualTransactions){  			  	  			
  			PossibleDistributorLocationKey.add(it.M_Distributor__c+''+it.M_Inventory_Location__c);
			PossibleDistributors.add(it.M_Distributor__c);		   			  			   			  			
  		}
        
        Map<string,Id> MapInventory = new Map<string,Id>();
        
        for (M_Inventory__c i: [Select Id,M_Inventory_Location__c,M_Distributor__c,M_Product__c,M_Product_Format__c 
              from M_Inventory__c where M_Distributor__c in:PossibleDistributors ]) {
            MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);           
        }
        
        List<M_Inventory__c> InventoriestoAdd = new List<M_Inventory__c>();     
        
        for (M_Inventory_Transaction__c t: ManualTransactions) {        	        
        	for (buzz_retail__ProductFormat__c pf:CapturedProductFormat) {
        		string key=String.ValueOf(t.M_Distributor__c) + String.ValueOf(t.M_Inventory_Location__c) + String.ValueOf(pf.buzz_retail__Product__c) + String.ValueOf(pf.id);
        		if (!MapInventory.containsKey(key)) {
                    M_Inventory__c newInvent = new M_Inventory__c();
                    newInvent.M_Inventory_Location__c=t.M_Inventory_Location__c;
                    newInvent.M_Distributor__c=t.M_Distributor__c;
                    newInvent.M_Product__c=pf.buzz_retail__Product__c;
                    newInvent.M_Product_Format__c=pf.id;
                	InventoriestoAdd.add(newInvent);    
                }  
        	}        		        		        	          
        }
        
        //Insert and add to map for further usage.
        if (InventoriestoAdd.size()>0) {
            insert InventoriestoAdd;
            for (M_Inventory__c i: InventoriesToAdd) {
                MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);   
            }           
        }
   		   	
   		//3-Loop and build transaction items
   		List<M_Transaction_Item__c> TransactionitemsToInsert = new List<M_Transaction_Item__c>();
   		
   		for (M_Inventory_Transaction__c it:ManualTransactions) {
   			   		
   			//Inventory capture
   			for (buzz_retail__ProductFormat__c pf:CapturedProductFormat) {
   				string key=String.ValueOf(it.M_Distributor__c) + String.ValueOf(it.M_Inventory_Location__c) + String.ValueOf(pf.buzz_retail__Product__c) + String.ValueOf(pf.id);        		
   				M_Transaction_Item__c newItem=new M_Transaction_Item__c();
   				newItem.M_Inventory_Transaction__c=it.id;
   				newItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Inventory_Capture);   					
   				newItem.M_Inventory__c=MapInventory.Containskey(key)?MapInventory.get(key):null;
   				newItem.M_Product__c=pf.buzz_retail__Product__c;
   				newItem.M_Product_Format__c=pf.id;   					
   				newItem.M_IsMobile__c=it.M_IsMobile__c;   					
   				TransactionitemsToInsert.add(newItem);   					
   			}      			   	
   		}
   	
   		if (TransactionitemsToInsert.size()>0)	
   			insert TransactionitemsToInsert;
   			
   		System.Debug('MMMMMM : InventoryTransactionRecord.CreateTransactionItemForInventoryCapture END ');
 
    }
    
    public static void CreateTransactionItemForManual(List<M_Inventory_Transaction__c> ManualTransactions) {
   	   	
   	   	System.Debug('MMMMMM : InventoryTransactionRecord.CreateTransactionItemForManual ManualTransactions.size: ' + ManualTransactions.size());
   	   	TriggerControl.FreezeInventoryTrigger=true;
   	   	
   		//1-Build Map of Inventory for NON inventory capture transactions
   		set<string> DistributorLocationKey = new set<string>();
   		set<id> PossibleDistributors = new set<id>();
   		for (M_Inventory_Transaction__c mt:ManualTransactions) {    			
			DistributorLocationKey.add(mt.M_Distributor__c+''+mt.M_Inventory_Location__c);
			PossibleDistributors.add(mt.M_Distributor__c);	   				   			   			
   		}
   		
   		Map<string,List<M_Inventory__c>> MapInventories=TransactionItemRecord.BuildMapInventoryForManualTransactions(DistributorLocationKey,PossibleDistributors);
   	   	   	
   		//3-Loop and build transaction items
   		List<M_Transaction_Item__c> TransactionitemsToInsert = new List<M_Transaction_Item__c>();
   		
   		for (M_Inventory_Transaction__c it:ManualTransactions) {
   			string key=it.M_Distributor__c+''+it.M_Inventory_Location__c;	
   			if (MapInventories.containsKey(key)) {
   				
  				for (M_Inventory__c inv: MapInventories.get(key)) {	
   				
   					M_Transaction_Item__c newItem=new M_Transaction_Item__c();
   					newItem.M_Inventory_Transaction__c=it.id;
	   					
   					if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Adjustment))
   						newItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Adjustment);
   					else if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Outbound_Transfer))
   						newItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Outbound_Transfer);
   					else if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Sample_Drop))
   						newItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Sample_Drop);
   						   		
   					newItem.M_Inventory__c=inv.id;
   					newItem.M_Product__c=inv.M_Product__c;
   					newItem.M_Product_Format__c=inv.M_Product_Format__c;   					
   					newItem.M_IsMobile__c=it.M_IsMobile__c;	   				   			
   					TransactionitemsToInsert.add(newItem);
   				}
   			}   		   			   			   	
   		}
   		
   		if (TransactionitemsToInsert.size()>0)	
   			insert TransactionitemsToInsert;
   			
   		System.Debug('MMMMMM : InventoryTransactionRecord.CreateTransactionItemForManual END');
   			
    }
              
    public static void ProcessSubmittedOrdersAndReturns(List<M_Order_sigcap_Header__c> ExistingOrders) {
         
        System.Debug('MMMMMM : InventoryTransactionRecord.ProcessSubmittedOrdersAndReturns ExistingOrders.size: ' + ExistingOrders.size());
        TriggerControl.FreezeInventoryTrigger=true; 
         
        //Function (possibly gonna go in OrderRecord) to define which order will need to be update vs created
        //This is done by checking if a transaction already exist. If it does, we only update the date. Else we create the whole thing
        
        //Rebuild list to get all required fields and process only valid orders.
        List<M_Order_sigcap_Header__c> OrderAndReturns = new List<M_Order_sigcap_Header__c>(
        [select Id, M_Inventory_TransactionType__c ,M_Distributor__c,M_Order_Date__c,M_AccountName__c,OwnerId
            from M_Order_sigcap_Header__c 
            where Id in :ExistingOrders and M_Inventory_Submitted__c=true and (M_Inventory_TransactionType__c='Order' OR M_Inventory_TransactionType__c='Return')]);
         
        //Set of Orders not needing a transaction       
        Map<Id,M_Inventory_Transaction__c> MapOrderIdWithTransaction = new Map<Id,M_Inventory_Transaction__c>();
        for (M_Inventory_Transaction__c it: [select Id,M_Transaction_Date__c,M_Order__c from M_Inventory_Transaction__c Where M_Order__c in:OrderAndReturns])
            MapOrderIdWithTransaction.put(it.M_Order__c,it);
        
         
        //Parse OrderandReturns and define what is to update and what is to create
        List<M_Order_sigcap_Header__c> OrdersWithoutTransactions = new List<M_Order_sigcap_Header__c>();
        List<M_Inventory_Transaction__c> TransactionsToUpdate = new List<M_Inventory_Transaction__c>();
                
        for (M_Order_sigcap_Header__c o: OrderAndReturns) {
            if (MapOrderIdWithTransaction.containsKey(o.id)) {
                    M_Inventory_Transaction__c it = MapOrderIdWithTransaction.get(o.id);
                    if (it.M_Transaction_Date__c!=o.M_Order_Date__c){
         
                        it.M_Transaction_Date__c=o.M_Order_Date__c;
                        TransactionsToUpdate.add(it);
                    }
            }
            else
                OrdersWithoutTransactions.add(o);
        }   
        
        if (TransactionsToUpdate.size()>0)
            update TransactionsToUpdate;
        
        if (OrdersWithoutTransactions.size()>0)
            InventoryTransactionRecord.CreateInventoryTransactionForOrders(OrdersWithoutTransactions);
            
        System.Debug('MMMMMM : InventoryTransactionRecord.ProcessSubmittedOrdersAndReturns END');
 
            
            
    }
    
  	  	  
    public static void CreateInventoryTransactionForOrders(List<M_Order_sigcap_Header__c> OrderAndReturns) {
        
        System.Debug('MMMMMM : InventoryTransactionRecord.CreateInventoryTransactionForOrders OrderAndReturns.size: ' + OrderAndReturns.size());
        
        TriggerControl.FreezeInventoryTrigger=true;
            
        M_OPLI_Settings__c opli = OPLIRecord.getActiveOPLISetting();
            
        //Map of Inventory Location for possible Warehouse, order details etc
        Map<Id,Id> MapDistributorLocation=OrderRecord.BuildDistributorLocationMap(OrderAndReturns);                                         
        Map<Id,List<M_Order_Detail__c>> MapOrderDetails= OrderRecord.BuildOrderDetailMap(OrderAndReturns);
                                                                                                
        //Loop through Orders and build Transaction table
        List<M_Inventory_Transaction__c> TransactionToInsert = new List<M_Inventory_Transaction__c>();
        
        for (M_Order_sigcap_Header__c o:OrderAndReturns) {
            
            //Transaction Header
            M_Inventory_Transaction__c newTrans = new M_Inventory_Transaction__c();
            
            if (o.M_Inventory_TransactionType__c=='Order')
                newTrans.RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Order);
            else if (o.M_Inventory_TransactionType__c=='Return')
                newTrans.RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Returns);
                
            newTrans.M_Distributor__c=o.M_Distributor__c;
            if (MapDistributorLocation.containsKey(o.M_Distributor__c))
                newTrans.M_Inventory_Location__c=MapDistributorLocation.get(o.M_Distributor__c);
            
            newTrans.M_Transaction_Date__c=o.M_Order_Date__c;
            newTrans.M_From__c=o.M_Distributor__c;
            newTrans.M_To__c=o.M_AccountName__c;
            newTrans.M_Status__c='processing';
            newTrans.M_Order__c=o.id;       
            TransactionToInsert.add(newTrans);
        }
        
        insert TransactionToInsert;
        
        //Build Map of Inventories for possible Distributor and Distributor Location (based on MapDistributorLocation)
        Map<string,Id> MapInventory = new Map<string,Id>();
        for (M_Inventory__c i: [Select Id,M_Inventory_Location__c,M_Distributor__c,M_Product__c,M_Product_Format__c 
              from M_Inventory__c where M_Distributor__c in:MapDistributorLocation.KeySet() and M_Inventory_Location__c in:MapDistributorLocation.Values() ]) {
            MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);           
        }
        
        List<M_Inventory__c> InventoriestoAdd = new List<M_Inventory__c>();     
        for (M_Inventory_Transaction__c t: TransactionToInsert) {

            if (MapOrderDetails.containsKey(t.M_Order__c)) {
                
                for (M_Order_Detail__c od:MapOrderDetails.get(t.M_Order__c)) {
                    //Check if inventori exists for this                    
                    if (!MapInventory.containsKey(String.ValueOf(t.M_Distributor__c)  + String.ValueOf(t.M_Inventory_Location__c) + String.ValueOf(od.M_Product_Name__c) + String.ValueOf(od.M_Product_Format__c))) {
                        M_Inventory__c newInvent = new M_Inventory__c();
                        newInvent.M_Inventory_Location__c=MapDistributorLocation.get(t.M_Distributor__c);
                        newInvent.M_Distributor__c=t.M_Distributor__c;
                        newInvent.M_Product__c=od.M_Product_Name__c;
                        newInvent.M_Product_Format__c=od.M_Product_Format__c;
                        InventoriestoAdd.add(newInvent);    
                    }                                           
                }
            }
        }
        
        //Insert and add to map for further usage.
        if (InventoriestoAdd.size()>0) {
            insert InventoriestoAdd;
            for (M_Inventory__c i: InventoriesToAdd) {
                MapInventory.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c)+String.ValueOf(i.M_Product_Format__c),i.id);   
            }           
        }
                
        //Process Transaction Items. They need to be done AFTER the Header Insertion so we can have an id               
        List<M_Transaction_Item__c> TransactionItemsToInsert = new List<M_Transaction_Item__c>();
                    
        for (M_Inventory_Transaction__c t: TransactionToInsert) {

            if (MapOrderDetails.containsKey(t.M_Order__c)) {
                
                for (M_Order_Detail__c od:MapOrderDetails.get(t.M_Order__c)) {
                    
                    M_Transaction_Item__c TransItem = new M_Transaction_Item__c();
                    TransItem.M_Inventory_Transaction__c=t.Id;
                
                    //Rec Type
                    if (t.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Order)) {
                        TransItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Order);
                        TransItem.M_Credit_Transaction__c=false;                        
                        TransItem.M_Debit_Transaction__c=true;
                    }                                           
                    else if (t.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Returns)){
                        TransItem.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Returns);
                        TransItem.M_Credit_Transaction__c=true;
                        TransItem.M_Debit_Transaction__c=false;    
                    }                  
                                                        
                    TransItem.M_Inventory__c=MapInventory.get(String.ValueOf(t.M_Distributor__c)+String.ValueOf(t.M_Inventory_Location__c)+String.ValueOf(od.M_Product_Name__c)+String.ValueOf(od.M_Product_Format__c));
                    
                    TransItem.M_Product__c=od.M_Product_Name__c;
                    TransItem.M_Product_Format__c=od.M_Product_Format__c;                   
                    TransItem.M_Original_Qty__c=od.M_Qty_Ordered__c;
      
                    TransItem.M_OrderDetailReference__c=od.id;
                    TransactionItemsToInsert.add(TransItem);                                                                                            
                }   
            } 
            t.M_Status__c=opli.Inventory_Transaction_Completion_Status__c;  
        }
        
        insert TransactionItemsToInsert;
        update TransactionToInsert; //to reflect status change
        //Note: a TransactionItemTrigger will update the Order DEtails with links to them
        
        System.Debug('MMMMMM : InventoryTransactionRecord.CreateInventoryTransactionForOrders END');
 
        
    }
        
}