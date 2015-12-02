global with sharing class sortOrderDetailsCon {
    
    public String orderIdStr { get; set; }
    
    public sortOrderDetailsCon() {}
    
    public List<M_Order_Detail__c> sortedOrderDetails {
    	get{
    		sortedOrderDetails = [	SELECT 
	    								Id, lboc_SAP_Material_Name__c, 
	    								M_Qty_Ordered__c,
	    								M_Item_Price__c,
	    								M_Item_Net_Amount__c,
	    								M_Convert_To_Eaches__c,
	    								M_Product_Name__r.lboc_Sequence_Number__c,
	    								M_Product_Name__r.buzz_retail__UPC_Code__c,
	    								M_UPC_Code__c
									FROM M_Order_Detail__c    							
    								WHERE M_Order__c =: orderIdStr
    								ORDER BY M_Product_Name__r.lboc_Sequence_Number__c ASC NULLS LAST
    							];
	         return sortedOrderDetails;
    	}
    	
    	set;
    }
    
}