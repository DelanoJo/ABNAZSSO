trigger InventoryTransactionTrigger on M_Inventory_Transaction__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
   	
    if (trigger.isBefore && (trigger.isInsert||trigger.isUpdate)) {

		//System.Debug('MMMMMM : InventoryTransactionTrigger isBefore');
        //M_OPLI_Settings__c opli=OPLIRecord.getActiveOPLISetting();
                
        //ITRL-009: COmpletion of calculated fields for Manual Transactions     
            for (M_Inventory_Transaction__c it:trigger.new) {
                    
            if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Inventory_Capture)) {
             //  it.M_From__c=opli.M_Def_Inv_Return_Loc__c;
                it.M_To__c=it.M_Distributor__c;             
            }
            else if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Adjustment)){
                it.M_From__c=it.M_Distributor__c;
                it.M_To__c=it.M_Distributor__c;
            }
            else if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Outbound_Transfer)){
                it.M_From__c=it.M_Distributor__c;
                //it.M_To__c= manual                
            }
            else if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Sample_Drop)){
                it.M_From__c=it.M_Distributor__c;
                //it.M_To__c= manual
            } 
            
            //ITRL-0132 Inventory Transaction is Read Only on Complete Flag
            system.debug('trigger.isbefore');
            if(it.M_Completed__c&&trigger.oldmap.get(it.id).M_Completed__c&&trigger.IsUpdate){
                M_Inventory_Transaction__c oldTI = (trigger.oldmap == null) ? null: trigger.oldmap.get(it.id);
                if(oldTI != null && oldTI.M_Status__c != it.M_Status__c && it.M_Status__c != null){
                    system.debug(oldTI.M_Status__c +'oldTI.M_Status__c before check'+it.M_Status__c);
                    String saveStatus = it.M_Status__c;
                    Util.copyFields(oldTI, it, false);
                    it.M_Status__c = saveStatus;
                    //transactionItemsModified.add(it);
                }
                else{
                    it.addError(system.label.ReadonlyInventoryTransaction);
                }
            }
        }
    }
   
   //AFTER =============================================================================================
   
    //ITRL-010: Delete zero qty transastion Items
    
    //Check Complete flag on transaction items, based on the "Completed" checkbox on the transaction. This cannot
    //Be done with a formula field because we need that field in a ROll Up field on inventory, and Roll-up don't 
    //support filtering on formula field.s
    if(trigger.IsAfter && (trigger.isUpdate||trigger.isInsert)) {
        
        //System.Debug('MMMMMM : InventoryTransactionTrigger IsAfter 1');
        
        set<Id> CompletedTransactions=new set<Id>();  
        Map<id,M_Inventory_Transaction__c> oldMapIT = (Map<id,M_Inventory_Transaction__c>)trigger.oldmap;
            
        for (M_Inventory_Transaction__c it:trigger.new)
            if (it.M_Completed__c==true){
                CompletedTransactions.add(it.id);
            }
            
        //ITRL-0132 Inventory Transaction is Read Only on Complete Flag
        /*if(CompletedTransactions.size()>0 && oldMapIT.size()>0){
            InventoryTransactionRecord.setRecordReadOnly(CompletedTransactions,oldMapIT);
        }*/
                
        List<M_Transaction_Item__c> zeroQtyItems = new List<M_Transaction_Item__c>();
        List<M_Transaction_Item__c> updateTransItems = new List<M_Transaction_Item__c>();          

        for (M_Transaction_Item__c ti:[select Id,M_Original_Qty__c,M_Inventory_Transaction__c, M_Inventory__c from M_Transaction_Item__c where M_Inventory_Transaction__c in :trigger.new]) {           
                    
            if (CompletedTransactions.contains(ti.M_Inventory_Transaction__c)) {    
                    
                ti.M_Completed__c=true;             
                if (ti.M_Original_Qty__c==0 || ti.M_Original_Qty__c==null)  
                    zeroQtyItems.add(ti);
                else
                    updateTransItems.add(ti);                           
            }
            else {
                ti.M_Completed__c=false;
                updateTransItems.add(ti);
            }
        }           
        //system.debug('\n\n================================ CHECK TRANSACTION LIST ======================================\n\n');
        //system.debug('Size of Transaction to be updated : '+updateTransItems.size()+'\n\n');
        //system.debug('Size of Transaction be be deleted : '+zeroQtyItems.size());
        //system.debug('\n\n==============================================================================================');         
        update updateTransItems;
        
        List<ID> possibleInventoriesToDelete = new List<ID>();
        for(M_Transaction_Item__c ti : zeroQtyItems)
        	possibleInventoriesToDelete.add(ti.M_Inventory__c);
                        
        //Modified by Minh-Dien@20-Aug-2013
        //Double check
        if (zeroQtyItems.size() > 0) {
        	delete zeroQtyItems;
        }
        
        //Return only inventories with empty inventory transaction item
        List<M_Inventory__c> zeroqtyInv= new List<M_Inventory__c>([Select m.id, m.Name From M_Inventory__c m where M_StockQtyinTransit__c=0 and M_StockQtyAtHand__c=0 and M_Total_Items__c = 0 and Id IN : possibleInventoriesToDelete]);
        
       	if (zeroqtyInv.size()> 0 ){
       		delete zeroqtyInv;
       	}
    }
    
    //ITRL-011 Automatically create Transaction Items for Inserted Inventory Capture/Outbound/Adjustement/Sample Drop        
    if (trigger.isAfter &&trigger.isInsert) {     
         
         //System.Debug('MMMMMM : InventoryTransactionTrigger IsAfter 2');
          
         List<M_Inventory_Transaction__c> InveCapTransactions = new List<M_Inventory_Transaction__c>();    
         List<M_Inventory_Transaction__c> ManuelTransactions = new List<M_Inventory_Transaction__c>();    
       
         for (M_Inventory_Transaction__c it:trigger.new) {
             if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Inventory_Capture))
                InveCapTransactions.add(it);
             else if (              
                it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Adjustment)||
                it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Outbound_Transfer)||
                it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Sample_Drop)
             ) 
                ManuelTransactions.add(it);
         }
         if (InveCapTransactions.size()>0)                     
            InventoryTransactionRecord.CreateTransactionItemForInventoryCapture(InveCapTransactions);
         if (ManuelTransactions.size()>0)                     
            InventoryTransactionRecord.CreateTransactionItemForManual(ManuelTransactions);
         
    }
    
    //ITRL-017 Create Inbound transfers from Outbound transfers. This is done by checking the value of the completed flag
    if (trigger.isAfter&&trigger.isUpdate) {
    	
        //System.Debug('MMMMMM : InventoryTransactionTrigger IsAfter 3');
        List<M_Inventory_Transaction__c> Outboundtransfers = new List<M_Inventory_Transaction__c>();    
        for (M_Inventory_Transaction__c it:trigger.new) {
             if (it.RecordTypeId==RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Outbound_Transfer)) {
             
               //This prevent doing this task everytime the record would be modified.
               if (it.M_Completed__c==true && trigger.oldMap.get(it.id).M_Completed__c==false)        
                    Outboundtransfers.add(it);              
             }      
        }
        
        if (Outboundtransfers.size()>0)
            InventoryTransactionRecord.ProcessOutBoundTransfers(Outboundtransfers);
        
    }
    
     //--IF (Status=’Cancel’) THEN Delete all Inventory Transaction Items

     if(trigger.IsAfter && trigger.isUpdate){
        set<Id> CancelledInvTransactionsIds=new set<Id>();  
        
        //check flag
        //Boolean isCancelled = false;        
        for (M_Inventory_Transaction__c it:trigger.new){
            if (it.M_Status__c=='Cancelled'){
                CancelledInvTransactionsIds.add(it.id);
                //isCancelled = true;
            }
        }
   
        List<M_Transaction_Item__c> TransItemTODelete = new List<M_Transaction_Item__c>([select id,M_Inventory_Transaction__c, M_Inventory__c from M_Transaction_Item__c where M_Inventory_Transaction__c in: CancelledInvTransactionsIds]);
        
        List<ID> possibleInventoriesToDelete = new List<ID>();
        for(M_Transaction_Item__c ti : TransItemTODelete)
        	possibleInventoriesToDelete.add(ti.M_Inventory__c);
        	       
        if (TransItemTODelete.size()>0)
            delete(TransItemTODelete);
      	
        //Return only inventories with empty inventory transaction item
        List<M_Inventory__c> zeroqtyInv= new List<M_Inventory__c>([Select m.id, m.Name From M_Inventory__c m where M_StockQtyinTransit__c=0 and M_StockQtyAtHand__c=0 and M_Total_Items__c = 0 and Id IN :possibleInventoriesToDelete]);
 
       	if (zeroqtyInv.size()>0){
       		delete zeroqtyInv;
       	}      
   
   } 
    
   
	//System.Debug('MMMMMM : InventoryTransactionTrigger END');
}