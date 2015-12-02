/**====================================================================
 * Appirio, Inc
 * Name: ResetMilestonesTrigger
 * Description: T-436036 - Trigger on Reset_Milestones__c
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
trigger ResetMilestonesTrigger on Reset_Milestones__c (after update, after delete) {
	if(Trigger.isAfter){
		if(Trigger.isUpdate){
			ResetMilestonesTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
		} else if(Trigger.isDelete){
			ResetMilestonesTriggerHandler.afterDelete(Trigger.old);
		}
	}
}