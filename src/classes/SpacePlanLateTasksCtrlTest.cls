/**=====================================================================
 * Appirio, Inc
 * Name: SpacePlanLateTasksCtrlTest
 * Description: T-433601
 * Created Date: 19 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class SpacePlanLateTasksCtrlTest {

    static testMethod void testSpacePlanLateTasks() {
    	Space_Plan_Reset__c spacePlan = Milestone1_Test_Utility.sampleSpacePlan('Basic Sample For Test' + DateTime.now().getTime());
      ApexPages.StandardController stc = new ApexPages.StandardController(spacePlan);
      SpacePlanLateTasksCtrl cont = new SpacePlanLateTasksCtrl(stc);
    }
}