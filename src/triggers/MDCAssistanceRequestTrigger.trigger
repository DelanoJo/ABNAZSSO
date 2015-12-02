/**====================================================================
 * Appirio, Inc
 * Name: MDCAssistanceRequestTrigger
 * Description: Trigger for MDC_Assistance_Request__c 
 * Created Date: 16 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 *
 =====================================================================*/
trigger MDCAssistanceRequestTrigger on MDC_Assistance_Request__c (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            MDCAssistanceRequestTriggerHandler.onAfterInsert(trigger.new);
        }
        
        if(Trigger.isUpdate) {
            MDCAssistanceRequestTriggerHandler.afterUpdate(trigger.oldMap, trigger.new);
        }
    }
}