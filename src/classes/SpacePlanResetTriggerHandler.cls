/**====================================================================
 * Appirio, Inc
 * Name: SpacePlanResetTriggerHandler
 * Description: T-436036 - Handler class for SpacePlanResetTrigger
 * Created Date: 24 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 =====================================================================*/
public with sharing class SpacePlanResetTriggerHandler {
	 
    // Method executes on beforeUpdate
    public static void beforeUpdate( List<Space_Plan_Reset__c> recs ){
        
        Map<Id, Space_Plan_Reset__c> projectsById = new Map<Id, Space_Plan_Reset__c>();       
        for( Space_Plan_Reset__c rec : recs ){
            projectsById.put(rec.Id, rec);
            rec.Number_of_Incomplete_Milestones__c = 0;
            rec.Next_Reset_Milestone_Due_Date__c = null;
            rec.Total_Complete_Task_Count__c = 0;
            rec.Total_Open_Task_Count__c = 0;
            rec.Total_Blocked_Task_Count__c = 0;
            rec.Total_Late_Task_Count__c = 0;
            
        }
        
        List<Reset_Milestones__c> milestones = [SELECT Id,
                                                           Name,
                                                           Reset__c,
                                                           Complete__c,
                                                           Deadline__c,                                                          
                                                           Total_Complete_Tasks__c,
                                                           Total_Open_Tasks__c,
                                                           Total_Late_Task_Count__c,
                                                           Total_Blocked_Task_Count__c
                                                    FROM Reset_Milestones__c
                                                    WHERE Reset__c IN :projectsById.keySet()
                                                   ];
        System.debug('*** milestones queried for projects: ' + milestones.size());
        
        for(Reset_Milestones__c ms : milestones){
            Space_Plan_Reset__c proj = projectsById.get(ms.Reset__c);
            if(ms.Complete__c == false){
                proj.Number_of_Incomplete_Milestones__c++;
                
                if(ms.Deadline__c != null){
                    if(proj.Next_Reset_Milestone_Due_Date__c == null || ms.Deadline__c < proj.Next_Reset_Milestone_Due_Date__c){
                        proj.Next_Reset_Milestone_Due_Date__c = ms.Deadline__c;
                    } 
                    
                }
            }
            
            proj.Total_Complete_Task_Count__c += ms.Total_Complete_Tasks__c;
            proj.Total_Open_Task_Count__c += ms.Total_Open_Tasks__c;
            proj.Total_Blocked_Task_Count__c += ms.Total_Blocked_Task_Count__c;
            proj.Total_Late_Task_Count__c += ms.Total_Late_Task_Count__c;
            
            System.debug('*** New values: ' + proj);
        }
        
    }

	 // Method executes on before delete
	 public static void beforeDelete(List<Space_Plan_Reset__c> recs){}	
}