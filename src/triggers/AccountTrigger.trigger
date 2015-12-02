/*
** Created by Liliane 22/06/2015 - Sprint 6
** To update the owner Field of  the Assets for this Account to the same Account Onwer
** Modified by Parul Gupta 16/09/2015 - T-433599
*/
trigger AccountTrigger on Account (after insert, after update) {
    
    if(trigger.isAfter){
    if(trigger.isInsert){
      AccountTriggerHandler.afterInsert(trigger.new);
    }else if(trigger.isUpdate){
      AccountTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);     
    }
  }
    
}