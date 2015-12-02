/*
 * Trigger to handle the Objective Trigger - Add to call logic
 */

trigger ObjectiveTrigger on lboc_Objective__c (before insert, before update)
{
    List<lboc_Objective__c> objList = Trigger.new;
    ObjectiveTriggerHandler.updateCallFieldOnObjectiveRec(objList);
}

/* RM
trigger ObjectiveTrigger on lboc_Objective__c (after insert, after update) 
{
    
     if (!ObjectiveTriggerHandler.hasAlreadyRunTrigger()) 
     {  
        
        List<lboc_Objective__c> objList = Trigger.new;
        ObjectiveTriggerHandler.updateCallFieldOnObjectiveRec(objList);
     }  
    
}
*/