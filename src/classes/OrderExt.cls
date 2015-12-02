public class OrderExt 
{    
    private ApexPages.StandardController con;   
     
    M_Order_sigcap_Header__c OrderRec;
    
    public OrderExt(ApexPages.StandardController c) 
    { 
        con = c; 
        OrderRec = [Select Id,M_Record_Type__c                 
        		    From M_Order_sigcap_Header__c WHERE Id=:con.getRecord().Id];    	

    }
    
    //LN  -- Item 684
	 public PageReference OrderCloneRedirect()
	    {    M_Order_sigcap_Header__c   newOrder = OrderRec.clone(false,true,false,false);
	    	 newOrder.M_Status__c = 'Draft';
	         newOrder.M_Order__c = OrderRec.id;
	    	
	    	 insert newOrder; 
	       
	     return new PageReference ('/' +newOrder.Id +'/e?retURL=/'+newOrder.Id);
	    
	    }
	    
	    
}