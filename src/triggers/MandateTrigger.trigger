/**====================================================================
 * Appirio, Inc
 * Name: MandateTrigger
 * Description: Trigger for Mandate Object (T-436247)
 * Created Date: 24 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
trigger MandateTrigger on Mandate__c (before insert, before update) {
  
  /*--------------------------------------------------------------------------
    Method to handle all Before Insert funtionalities
  --------------------------------------------------------------------------*/
  if(Trigger.isBefore && Trigger.isInsert) {
    MandateTriggerHandler.onBeforeInsert(Trigger.new); 
  }
  /*--------------------------------------------------------------------------
    Method to handle all Before Update funtionalities
  --------------------------------------------------------------------------*/
  if(Trigger.isBefore && Trigger.isUpdate) {
    MandateTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.new);
  }
}