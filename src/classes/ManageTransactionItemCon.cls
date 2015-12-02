global with sharing class ManageTransactionItemCon {
     private ApexPages.StandardController con;   
     public  M_Inventory_Transaction__c MTrans;

    final Id InvCapRecTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Inventory_Capture);
    final Id AdjRecTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Adjustment);
    final Id OutboundRecTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Outbound_Transfer);
    final Id DropRecTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Sample_Drop);
    final Id InboundRecTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Inbound_Transfer);

    public ManageTransactionItemCon(ApexPages.StandardController controller) {
        con = controller;
system.debug('con.getId(): ' + con.getId());
system.debug('qry result: ' + [Select Id,RecordTypeId,M_Transaction_Date__c from M_Inventory_Transaction__c where id =:con.getId()]);
        MTrans= [Select Id,RecordTypeId,M_Transaction_Date__c from M_Inventory_Transaction__c where id =:con.getId()];
    }
    public String nameSpace {
        get {
            if(nameSpace == null) {
                nameSpace = Util.getBuzzNamespace();
            }
            return nameSpace;
        }
        private set;
    }

    public boolean IsAdjustment{
        get {
            if (MTrans.RecordTypeId==AdjRecTypeId)
                return true;
            else
                return false; 
        }
        private set;
    }

    public boolean IsInBound{
        get {
	        if (MTrans.RecordTypeId==InboundRecTypeId)
	            return true;
	        else
	            return false; 
        }
        private set;
    }

    public boolean IsStandard{
        get {
                if (MTrans.RecordTypeId==InvCapRecTypeId ||
                    MTrans.RecordTypeId==OutboundRecTypeId ||
                    MTrans.RecordTypeId== DropRecTypeId)
                    return true;
                else
                    return false; 
            }
        private set;
    }
    
	
    public PageReference Close(){
        return new PageReference('/' + MTrans.id);
    }

    @RemoteAction
    global static List<M_Transaction_Item__c> loadTransItems(Id transId, String transactionType) {
		// add required fields to the map
		Map<String, String> fieldsMap = new Map<String, String>();
		fieldsMap.put('M_Actual_Qty__c', null);
		fieldsMap.put('M_Adjustment_Type__c', null);
		fieldsMap.put('M_Completed__c', null);
		fieldsMap.put('M_Credit_Transaction__c', null);
		fieldsMap.put('M_Debit_Transaction__c', null);
		fieldsMap.put('M_Discrepancy__c', null);
		fieldsMap.put('M_From__c', null);
		fieldsMap.put('M_Inventory__c', null);
		fieldsMap.put('M_Inventory_Capture__c', null);
		fieldsMap.put('M_Inventory_Count__c', null);
		fieldsMap.put('M_IsMobile__c', null);
		fieldsMap.put('M_Net_Qty__c', null);
		fieldsMap.put('M_Order_Detail_Reference__c', null);
		fieldsMap.put('M_Product__c', null);
		fieldsMap.put('M_Product_Format__c', null);
		fieldsMap.put('M_Original_Qty__c', null);
		fieldsMap.put('M_Qty_in_Transit__c', null);
		fieldsMap.put('M_Qty_Transferred__c', null);
		fieldsMap.put('M_Reason_for_Discrepancy__c', null);
		fieldsMap.put('M_Record_Type__c', null);
		fieldsMap.put('M_Qty_at_hand__c', null);
		fieldsMap.put('M_OrderDetailReference__c', null);
		fieldsMap.put('M_To__c', null);
		fieldsMap.put('M_Transaction_Date__c', null);

		// add fields from fieldset to make it a complete list of fields to query
		String fsName = '';
		if (transactionType == 'InboundTransfer') {
			fsName = 'InboundTransferSet';
		} else if (transactionType == 'Adjustment') {
			fsName = 'AdjustmentSet';
		} else if (transactionType == 'Standard') {
			fsName = 'StandardSet';
		}
		
		for (FieldSetMember fs : Schema.SObjectType.M_Transaction_Item__c.fieldSets.getMap().get(fsName).getFields()) {
			fieldsMap.put(fs.getFieldPath(), null);
		}
    	
    	String sQuery = 'SELECT '
    					+ Util.buildDelimitedString(fieldsMap.keySet(), ',')
    					+ ' FROM M_Transaction_Item__c'
                    	+ ' WHERE M_Inventory_Transaction__c = ' + '\'' + transId + '\'';

            /*
            return [SELECT M_Actual_Qty__c,M_Adjustment_Type__c,M_Completed__c,M_Credit_Transaction__c,
                           M_Debit_Transaction__c,M_Discrepancy__c,M_From__c,M_Inventory__c,M_Inventory_Capture__c,
                            M_Inventory_Count__c,M_IsMobile__c,M_Net_Qty__c,M_Order_Detail_Reference__c,M_Product__c,
                            M_Product_Format__c,M_Original_Qty__c,M_Qty_in_Transit__c,M_Qty_Transferred__c,M_Reason_for_Discrepancy__c,
                            M_Record_Type__c,M_Qty_at_hand__c,M_OrderDetailReference__c,M_To__c,M_Transaction_Date__c     
                    FROM M_Transaction_Item__c
                    WHERE M_Inventory_Transaction__c =: transId];
        	*/
        	
        return Database.query(sQuery);

    }
    
}