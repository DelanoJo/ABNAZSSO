/**====================================================================
 * Appirio, Inc
 * Name: MandateProductTrigger
 * Description: Trigger for Mandate Product Object (T-432400)
 * Created Date: 9 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
 trigger MandateProductTrigger on Mandate_Product__c (after delete, after insert, before delete) {
   
  /*--------------------------------------------------------------------------
    Method to handle all After Delete funtionalities
  --------------------------------------------------------------------------*/
  if(Trigger.isAfter && Trigger.isDelete) {
    MandateProductTriggerHandler.onAfterDelete(Trigger.old);
  }
  /*--------------------------------------------------------------------------
    Method to handle all After Insert funtionalities
  --------------------------------------------------------------------------*/
  if(Trigger.isAfter && Trigger.isInsert) {
    MandateProductTriggerHandler.onAfterInsert(Trigger.new);
  }
  /*--------------------------------------------------------------------------
    Method to handle all Before Delete funtionalities
  --------------------------------------------------------------------------*/
  if(Trigger.isBefore&& Trigger.isDelete) {
    MandateProductTriggerHandler.onBeforeDelete(Trigger.oldMap);
  }
}