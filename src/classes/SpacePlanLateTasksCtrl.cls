/**=====================================================================
 * Appirio, Inc
 * Name: SpacePlanLateTasksCtrl
 * Description: T-433601
 * Created Date: 18 Sep 2015
 * Created By: Poonam Varyani (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public with sharing class SpacePlanLateTasksCtrl {
    Space_Plan_Reset__c spacePlan;
    
    public SpacePlanLateTasksCtrl(ApexPages.StandardController controller){
        spacePlan = (Space_Plan_Reset__c)controller.getRecord();
    }
}