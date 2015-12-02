/**====================================================================
 * Appirio, Inc
 * Name: SpacePlanResetTrigger
 * Description: T-436036 - Trigger on Space_Plan_Reset__c
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
trigger SpacePlanResetTrigger on Space_Plan_Reset__c (before update, before delete, before insert) {
		if(Trigger.isBefore){
			if( Trigger.isUpdate ){
	        SpacePlanResetTriggerHandler.beforeUpdate(trigger.new);
	    } 
	    else if( Trigger.isDelete ) {
	        SpacePlanResetTriggerHandler.beforeDelete(trigger.old);
	    }
		}   
}