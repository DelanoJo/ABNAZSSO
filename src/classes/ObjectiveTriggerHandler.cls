/*
 * Objective Trigger Handler class will be used to write the business logic
 * to handle the "this call" logic for objectives.
 */
public with sharing class ObjectiveTriggerHandler 
{
    /* RM
    private static boolean alreadyRunTrigger = false;

    public static boolean hasAlreadyRunTrigger() 
    {
        return alreadyRunTrigger;
    }

    // By setting the variable to true, it maintains this 
    // new value throughout the duration of the request 
    // (or testMethod) 
     
    public static void setAlreadyRunTrigger() 
    {
        alreadyRunTrigger = true;
    }
    */
    
    // Method to update the Call field on Objective record.
    public static void updateCallFieldOnObjectiveRec(List<lboc_Objective__c> objList)
    {
        
        // List to store filtered Objective list which has status as != Not Completed & No Call associated.
        List<lboc_Objective__c> finalObjectiveList = new List<lboc_Objective__c>();
        
        Set<Id> objOutletIds = new Set<Id>();
        Set<Id> callOutletIds = new Set<Id>();
        
        Map<Id,buzz_retail__Call__c> callOutletMap = new Map<Id,buzz_retail__Call__c>();
        
        //Get only the records out of the Objective List which has status as Completed and no Call associated to it.
        for(lboc_Objective__c objRec : objList)
        {   
            // RM
            // [Select Id,Name,lboc_Outlet__c,lboc_Call__c from lboc_Objective__c where lboc_status__c != 'Not Completed' and lboc_this_call__c = true and lboc_Call__c = null]
            
            if (objRec.lboc_status__c != 'Not Completed' && objRec.lboc_this_call__c && objRec.lboc_Call__c == null) {
                objOutletIds.add(objRec.lboc_Outlet__c);
                finalObjectiveList.add(objRec);
            }
        }
    
        if(objOutletIds != null && objOutletIds.size() > 0)
        {
            for(buzz_retail__Call__c callRec : [Select Id,buzz_retail__Account__c from buzz_retail__Call__c where buzz_retail__Account__c IN: objOutletIds Order by buzz_retail__Date__c DESC NULLS LAST])
            {
                if(!callOutletIds.contains(callRec.buzz_retail__Account__c))
                {
                    callOutletIds.add(callRec.buzz_retail__Account__c);
                    callOutletMap.put(callRec.buzz_retail__Account__c,callRec);
                }   
            }
            
            if(callOutletMap != null && callOutletMap.size() > 0)
            {
                for(lboc_Objective__c objRecord : finalObjectiveList)
                {
                    if(callOutletMap.containsKey(objRecord.lboc_Outlet__c))
                    {
                        objRecord.lboc_Call__c = callOutletMap.get(objRecord.lboc_Outlet__c).Id;
                    }
                }
            }
            // RM
            //setAlreadyRunTrigger();
            //update finalObjectiveList;
            
        }
            
    }
}