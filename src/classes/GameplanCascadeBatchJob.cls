/**
  Schedule Batch Class for calling "ActionItem Answer Refresh batch" 
*/
global class GameplanCascadeBatchJob implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		GameplanDeleteBatch gameplanDelBatch = new GameplanDeleteBatch();	
		Database.executeBatch(gameplanDelBatch);
	}
}