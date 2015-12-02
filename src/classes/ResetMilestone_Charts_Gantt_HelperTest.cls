/**====================================================================
 * Appirio, Inc
 * Name: ResetMilestone_Charts_Gantt_HelperTest
 * Description: Test Class for ResetMilestone_Charts_Gantt_Helper.cls(T-433601)
 * Created Date: 21 Sep 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 *
 =====================================================================*/
@isTest
private class ResetMilestone_Charts_Gantt_HelperTest {

    static testMethod void testController() {
        Space_Plan_Reset__c spacePlan = Milestone1_Test_Utility.sampleSpacePlan('Basic Sample For Test' + DateTime.now().getTime());
	      ApexPages.StandardController stc = new ApexPages.StandardController(spacePlan);
	      ResetMilestone_Charts_Gantt_Helper cont = new ResetMilestone_Charts_Gantt_Helper(stc);
    }
}