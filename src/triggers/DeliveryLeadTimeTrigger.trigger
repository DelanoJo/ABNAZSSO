trigger DeliveryLeadTimeTrigger on Delivery_Lead_Time__c (before insert, before update) {
    
    //Check uniqueness
    
    set<string> SetDLT = new set<string>();
        For (Delivery_Lead_Time__c DLT: [Select Id,State__c, Delivery_Lead_Days__c 
                                         From Delivery_Lead_Time__c   where Id not in:Trigger.new ]){
                                                        
            SetDLT.add(DLT.State__c);
      }
            
        for (Delivery_Lead_Time__c b:Trigger.new)
            if (SetDLT.Contains(b.State__c))
                b.addError(Label.LeadTimeUniqueness);
                
                
  

}