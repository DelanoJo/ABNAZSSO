global with sharing class OrderDetailCon {
	

    private ApexPages.StandardController con;
   
    public  M_Order_sigcap_Header__c MOrder;

    public OrderDetailCon(ApexPages.StandardController controller) {
        con = controller;
        
        //MOrder= [Select Id,M_Order_Transaction_Type__c from M_Order_sigcap_Header__c where id =:con.getId()];
        List<M_Order_sigcap_Header__c> MOrders = [Select Id,M_Order_Transaction_Type__c from M_Order_sigcap_Header__c where id =:con.getId()];
        if(MOrders.isEmpty())
		{
		   //display error message;
		}
		else
		{
		   MOrder=MOrders[0];
		// do rest work;
		}
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
    
    public boolean IsOrder{
    	get {
	    		if (MOrder.M_Order_Transaction_Type__c=='Order')
	    			return true;
	    		else
	    			return false; 
    		}
    	private set;
    } 
    public boolean IsReturn{
    	get {
	    		if (MOrder.M_Order_Transaction_Type__c=='Return')
	    			return true;
	    		else
	    			return false; 
    		}
    	private set;
    } 
    
    
    @RemoteAction
    global static List<M_Order_Detail__c> loadOrderDetails(Id orderId) {
    	//M_Merck_Product_Code__c,
	        return [SELECT M_Product_Name__c,M_Product_Format__c,M_UPC_Code__c,
	                       M_Stock_Qty__c,M_Qty_Ordered__c,M_Reason_for_Return__c     
                	FROM M_Order_Detail__c
                	WHERE M_Order__c =: orderId];
    	
/*        return [SELECT Qty_Eaches__c, Name, M_isMobile__c, M_UPC_Code__c, M_Transaction_Type__c, 
	                    M_Transaction_Item__c, M_Stock_Qty__c, M_Status__c, M_Sold_To__c, 
	                    M_Reason_for_Return__c, M_Qty_Ordered__c, M_Product_Name__c, M_Product_Format__c, 
	                    M_Original_Call_Detail_ID__c, M_Order__c, M_Merck_Product_Code__c, 
	                    M_Line_Item_Discount__c, M_Item_Price__c, M_Item_Price_ID__c, 
	                    M_Item_Net_Amount__c, M_Item_Discount__c, M_Item_Amount__c, 
	                    M_Inventory__c, M_ERP_TRX_Reference__c, M_Draft_Order_Detail__c, 
	                    LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById
                    FROM M_Order_Detail__c
                    WHERE M_Order__c =: orderId];
   */ 
    }
    
        	
}