/**====================================================================
 * Appirio, Inc
 * Name: ScheduleBatchChildCount
 * Description: Scheduler Class for BatchChildCount
 * Created Date: 1 October 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
global class ScheduleBatchChildCount implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchChildCount b = new BatchChildCount();
		database.executebatch(b);
	}
}