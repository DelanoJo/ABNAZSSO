/**=====================================================================
 * Appirio, Inc
 * Name: SpaceResetMilestoneProgressExtTest
 * Description: [T-433601]
 * Created Date: 21 September
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class SpaceResetMilestoneProgressExtTest {

    static testMethod void testExtension() {
      Space_Plan_Reset__c spacePlan = Milestone1_Test_Utility.sampleSpacePlan('Basic Sample For Test' + DateTime.now().getTime());
      insert spacePlan;
      Reset_Milestones__c milestone = Milestone1_Test_Utility.sampleResetMilestone(spacePlan);
      insert milestone;
      
      ApexPages.StandardController stc = new ApexPages.StandardController(spacePlan);
      SpaceResetMilestoneProgressExt cont = new SpaceResetMilestoneProgressExt(stc);
      
      system.assertEquals(1, cont.steps.size());
    }
}