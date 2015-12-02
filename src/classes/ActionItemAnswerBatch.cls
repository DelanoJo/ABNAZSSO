/**
  Schedule Batch Class for calling "ActionItem Answer Refresh batch" 
*/
global class ActionItemAnswerBatch implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		ActionItemAnswerRefreshBatch actItemBatch = new ActionItemAnswerRefreshBatch();
		Database.executeBatch(actItemBatch);
		
	}
}