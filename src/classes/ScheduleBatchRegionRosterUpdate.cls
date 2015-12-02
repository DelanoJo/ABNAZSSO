/**====================================================================
 * Appirio, Inc
 * Name: ScheduleBatchRegionRosterUpdate
 * Description: Scheduler Class for BatchRegionRosterUpdate
 * Created Date: 1 October 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
global class ScheduleBatchRegionRosterUpdate implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchRegionRosterUpdate b = new BatchRegionRosterUpdate();
		database.executebatch(b);
	}
}