/**====================================================================
 * Appirio, Inc
 * Name: ResetTaskTriggerHandler
 * Description: T-436036 - Handler class for Trigger on ResetTaskTrigger
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
public with sharing class ResetTaskTriggerHandler {
	
	// Method executes on beforeUpdate
	public static void beforeUpdate(List<Reset_Tasks__c> recs, Map<Id, Reset_Tasks__c> oldMap){
		updateDaysLate(recs, oldMap);
	}
	
	// Method executes on beforeInsert
	public static void beforeInsert(List<Reset_Tasks__c> recs){
		updateDaysLate(recs, null);
	}
	
	// Method updates days_late__c field 
	private static void updateDaysLate(List<Reset_Tasks__c> recs, Map<Id, Reset_Tasks__c> oldMap){
		for(Reset_Tasks__c rec : recs){
			if (rec.due_Date__c != null && (oldMap == null || oldMap.get(rec.id).due_Date__c != rec.due_Date__c)){				
				if(rec.Complete__c == false && system.today() > rec.due_Date__c) {				
      		rec.Days_Late__c = rec.due_Date__c.daysBetween(system.today());
      	} else {
        	rec.Days_Late__c = 0; 
      	}
			}
		}
	}
}