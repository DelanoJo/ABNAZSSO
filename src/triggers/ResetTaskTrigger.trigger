/**====================================================================
 * Appirio, Inc
 * Name: ResetTaskTrigger
 * Description: T-436036 - Trigger on Reset_Tasks__c
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
trigger ResetTaskTrigger on Reset_Tasks__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	if(Trigger.isBefore){
		if(Trigger.isUpdate){
			ResetTaskTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
		} else if (Trigger.isInsert){
			ResetTaskTriggerHandler.beforeInsert(Trigger.new);
		}
	}
}