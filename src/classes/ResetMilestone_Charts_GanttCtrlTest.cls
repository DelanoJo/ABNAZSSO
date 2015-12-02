/**====================================================================
 * Appirio, Inc
 * Name: ResetMilestone_Charts_GanttCtrlTest
 * Description: Test Class for ResetMilestone_Charts_GanttController.cls(T-433601)
 * Created Date: 21 Sep 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 *
 =====================================================================*/
@isTest
private class ResetMilestone_Charts_GanttCtrlTest {
    private static Space_Plan_Reset__c spacePlan;
    private static Reset_Milestones__c milestone;
    static testMethod void testController() {
        createTestData();
        
        ResetMilestone_Charts_GanttController cont = new ResetMilestone_Charts_GanttController();
        cont.mytarget = String.valueOf(spacePlan.Id);
        String projgrantjson = cont.getProjectGanttJson();
        
        cont.mytarget = String.valueOf(milestone.Id);
        projgrantjson = cont.getProjectGanttJson();
    }
    private static void createTestData() {
      spacePlan = Milestone1_Test_Utility.sampleSpacePlan('Basic Sample For Test' + DateTime.now().getTime());
	    insert spacePlan;
	    milestone = Milestone1_Test_Utility.sampleResetMilestone(spacePlan);
	    insert milestone;
	    Reset_Tasks__c task = new Reset_Tasks__c();
	    task.Name = 'Test Task1';
	    task.Milestone__c = milestone.Id;
	    task.Complete__c = true;
	    insert task;
	    task = new Reset_Tasks__c();
	    task.Name = 'Test Task2';
	    task.Milestone__c = milestone.Id;
	    task.Start_Date__c = System.today().addDays(-10);
	    task.Due_Date__c = System.today().addDays(-5);
	    insert task;
	    task = new Reset_Tasks__c();
	    task.Name = 'Test Task3';
	    task.Milestone__c = milestone.Id;
	    task.Start_Date__c = System.today().addDays(5);
	    task.Due_Date__c = System.today().addDays(10);
	    insert task;
    }
}