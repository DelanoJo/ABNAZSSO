/**=====================================================================
 * Appirio, Inc
 * Name: CloneResetTask
 * Description: class for Clone by Wholesaler button on reset task
 * Created Date: 17 Sept 2015 T-433493
 * Created By: Siddharth Varshneya (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/

global class CloneResetTask{
     
     /*---------------------------------------------------------------------------
     Reset Task to Clone that task to every Wholesaler that is related to the Accounts 
     in associated Space Plan Reset Retailer​ records for that Space Plan Reset 
     --------------------------------------------------------------------------*/
     webservice static void cloneResetTask(String objId){
        Reset_Tasks__c obj = null;
        for(Reset_Tasks__c tmp : [SELECT Name,RecordTypeId,Assigned_To__c,Blocked__c,Blocked_Reason__c,Class__c,Description__c,Due_Date__c,
                             Task_Expected_Duration__c,Task_Lead_Time__c,Milestone__c,Predecessor_Task__c,
                             Task_Stage__c,Start_Date__c,Wholesaler__c FROM Reset_Tasks__c WHERE ID = : objId]){
                        obj = tmp;   
        }
                             
        Reset_Milestones__c objRM = null;
        for(Reset_Milestones__c tmp : [SELECT Reset__c,Id from Reset_Milestones__c WHERE id=: obj.Milestone__c]){
                        objRM = tmp;   
        }
        
        list<Space_Plan_Reset_Retailer__c> lstSPRR = [SELECT Space_Plan_Reset__c,Account__c FROM Space_Plan_Reset_Retailer__c 
                                                    WHERE Space_Plan_Reset__c = :objRM.Reset__c];
        
        set<Id> accIds = new set<Id>();
        for(Space_Plan_Reset_Retailer__c objSPRR : lstSPRR){
            accIds.add(objSPRR.Account__c);
        }
        
        set<Id> wrIds = new set<Id>();
        for(Account tmp : [SELECT Wholesaler__c FROM Account WHERE Id IN : accIds]){
            wrIds.add(tmp.Wholesaler__c);
        }
        
        list<Reset_Tasks__c> insertList = new list<Reset_Tasks__c>();
        for(Id objWID : wrIds){
            Reset_Tasks__c rt = new Reset_Tasks__c();
            rt.Name = obj.Name;
            rt.recordTypeId = obj.RecordTypeId;
            rt.Assigned_To__c = obj.Assigned_To__c;
            rt.Blocked__c = obj.Blocked__c;
            rt.Blocked_Reason__c = obj.Blocked_Reason__c;
            rt.Class__c = obj.Class__c;
            rt.Description__c = obj.Description__c;
            rt.Due_Date__c = obj.Due_Date__c;
            rt.Task_Expected_Duration__c = obj.Task_Expected_Duration__c;
            rt.Task_Lead_Time__c = obj.Task_Lead_Time__c;
            rt.Milestone__c = obj.Milestone__c;
            rt.Predecessor_Task__c = obj.Predecessor_Task__c;
            rt.Task_Stage__c = obj.Task_Stage__c;
            rt.Start_Date__c = obj.Start_Date__c;
            rt.Wholesaler__c = objWID;
            insertList.add(rt);
        }
        
        if(insertList.size() > 0){
            insert insertList;
        }
        
     }

}