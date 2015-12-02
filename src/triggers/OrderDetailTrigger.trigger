trigger OrderDetailTrigger on M_Order_Detail__c (after delete, after insert, after update, 
before delete, before insert, before update) {
	
	if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
		
		for( M_Order_Detail__c od : trigger.new){
			
			//It is used to calculate the Total CUT (Cases & Eaches) in order object.
			system.debug('testing insert'+od.M_Convert_To_Eaches__c);
        	od.Qty_Cases_Eaches__c = od.M_Convert_To_Eaches__c;
        	
        	//OrderDetail create concatination to prevent duplicates
    		//Added by Iulian Chiriac @ 13/JAN/2014
        	if(od.M_Transaction_Type__c == 'Order'){
                od.UniquenessCheck__c = od.M_Order__c + '_' +
                                        od.M_Product_Name__c + '_' +
                                        od.M_Product_Format__c;
            } else if(od.M_Transaction_Type__c == 'Return'){
                od.UniquenessCheck__c = od.M_Order__c + '_' +
                                        od.M_Product_Name__c + '_' +
                                        od.M_Product_Format__c + '_' +
                                        od.M_Reason_for_Return__c;
                //od.UniquenessCheck__c = 'a1';
            }
        	
		}
	}
	
	if(trigger.isBefore && trigger.isUpdate){
		
		for( M_Order_Detail__c od : trigger.new){
			
			//ORI-012 Status (Validation)
			if(od.M_Order__r.M_Read_Only__c){
				
				M_Order_Detail__c oldOD = (trigger.oldmap == null) ? null: trigger.oldmap.get(od.id);
				
				if(oldOD != null && oldOD.M_Status__c != od.M_Status__c && od.M_Status__c != null){
					String saveStatus = od.M_Status__c;
                    Util.copyFields(oldOD, od, false);
                    od.M_Status__c = saveStatus;
				}
				else{
					od.addError(system.label.ReadonlyOrderAndOrderDetail);
				}
			}
		}
	}

    //Upon modification of an order detail qty, modify the correspondant Transaction Item qty.
    if (trigger.iSAfter && trigger.isUpdate) {
        
        Map<Id, M_Order_Detail__c> allOldOrderDetails= trigger.oldMap;
		
        List<M_Transaction_Item__c> TransItemToUpdate = new list<M_Transaction_Item__c>();
        for(M_Order_Detail__c od: trigger.new) {
        	        	
            if (allOldOrderDetails.containsKey(od.id) && (allOldOrderDetails.get(od.id).M_Qty_Ordered__c!=od.M_Qty_Ordered__c)&&od.M_Transaction_Item__c!=null) 
                TransItemToUpdate.add(new M_Transaction_Item__c(Id=od.M_Transaction_Item__c,M_Original_Qty__c=od.M_Qty_Ordered__c));                                
        }
        
        if (TransItemToUpdate.size()>0)
            update TransItemToUpdate;           
    }   
    
    //Insert new Trans Item
    if (trigger.isAfter&&trigger.isInsert) {
    	//Note that the following creates only Transaction Items if a transaction related to the order exists.
    	List<M_Order_Detail__c> detailsdetailsdetails = new List<M_Order_Detail__c>();
    	
    	//LN
    	set<Id> OrderIdstoupdate = new set<Id>();
    	//LN
    	for (M_Order_Detail__c od:trigger.new){
    		//if (od.M_IsMobile__c!=true)
    		detailsdetailsdetails.add(od);
    		
    		// lN Item 684
    		 if (od.M_detailIsCloned__c == true )
    		    OrderIdstoupdate.add(od.M_Order__c);
    		   // MapOrdersToUpdate.get(od.M_Order__c).M_detailIsCloned__c= true;
    	}		
    	OrderDetailRecord.CreateTransactionItemForInsert(detailsdetailsdetails);
    	
    	
    	//LN
    	 List<M_Order_sigcap_Header__c> ListOrdersToUpdate = new List<M_Order_sigcap_Header__c>([select Id,M_detailIsCloned__c from M_Order_sigcap_Header__c
    	   																					where Id in :OrderIdstoupdate]); 
                                                           
    	for (M_Order_sigcap_Header__c ords:ListOrdersToUpdate)
    		ords.M_detailIsCloned__c= true;
    	    	   	
    	if (ListOrdersToUpdate.size()>0 )
    	   update ListOrdersToUpdate;
    }
    
    /*if (trigger.isAfter && !OrderDetailRecord.preventUpateTrigger &&(trigger.isInsert || trigger.isUpdate) ) {
    	
    	//It is used to calculate the Total CUT (Cases & Eaches) in order object.
	    Set <Id> odIds =  new Set<Id>();
	    for(M_Order_Detail__c od: trigger.new) {
	    	odIds.add(od.Id);
	    }
	    if(odIds.size()>0){
	    	system.debug('odIds'+odIds);
	    	OrderDetailRecord.updateOrderDetailFields(odIds);
	    }
    
    }*/
}