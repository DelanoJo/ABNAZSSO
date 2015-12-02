/**====================================================================
 * Appirio, Inc
 * Name: ResetMilestone_Charts_Gantt_Helper
 * Description: Controller for ResetMilestone_Charts_GanttMilestones.page(T-433601)
 * Created Date: 18 Sep 2015
 * Created By: Parul Gupta (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public with sharing class ResetMilestone_Charts_Gantt_Helper {

	public String myId {get;set;}
	public Boolean allowView {get;set;}
	
	ApexPages.StandardController stdCont;
	
	public ResetMilestone_Charts_Gantt_Helper(ApexPages.StandardController stc){
		myId = stc.getId();
		allowView = Apexpages.currentPage().getParameters().get('p') == null;
	}
}