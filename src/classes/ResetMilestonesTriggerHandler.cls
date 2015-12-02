/**====================================================================
 * Appirio, Inc
 * Name: ResetMilestonesTriggerHandler
 * Description: T-436036 - Trigger Handler for ResetMilestonesTrigger
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
public with sharing class ResetMilestonesTriggerHandler {
	
	// Method executes on after update
	public static void afterUpdate(List<Reset_Milestones__c> newMilestones, 
																		Map<Id, Reset_Milestones__c> oldMap){
		updateParents(newMilestones, oldMap);
	}
	
	// Method executes on after delete
	public static void afterDelete(List<Reset_Milestones__c> oldMilestones){
		updateParents(oldMilestones, null);
	}
	
	// Updates parents of Reset milestones
	private static void updateParents(List<Reset_Milestones__c> newMilestones, 
																				Map<Id, Reset_Milestones__c> oldMap){
		Map<Id, Space_Plan_Reset__c> resetsToUpdate = new Map<Id, Space_Plan_Reset__c>();
		
		
		for(Reset_Milestones__c ms : newMilestones){
			if(oldMap != null){
				if(ms.reset__c != null 
				&& (oldMap.get(ms.id).Total_Complete_Tasks__c != ms.Total_Complete_Tasks__c)
				|| (oldMap.get(ms.id).Total_Open_Tasks__c != ms.Total_Open_Tasks__c)
				|| (oldMap.get(ms.id).Total_Late_Task_Count__c != ms.Total_Late_Task_Count__c)
				|| (oldMap.get(ms.id).Total_Blocked_Task_Count__c != ms.Total_Blocked_Task_Count__c)){
			  	resetsToUpdate.put(ms.reset__c, new Space_Plan_Reset__c(id = ms.reset__c));                           			
				}
			}else if (ms.reset__c != null){
				resetsToUpdate.put(ms.reset__c, new Space_Plan_Reset__c(id = ms.reset__c));
			}
		}
		if(resetsToUpdate.size() > 0){
			update resetsToUpdate.values();
		}
	}

}