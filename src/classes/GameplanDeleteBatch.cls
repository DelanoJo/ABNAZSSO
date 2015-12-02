/**
  Batch job to delete the Gameplans records before we insert the new records. 
*/
global class GameplanDeleteBatch implements Database.Batchable<sObject>
{
	// Start method to get all the next day Calls and related information to it.
	global Database.QueryLocator start(Database.BatchableContext gameplanDelBatchCtx)
	{
		String gamePlanDelQuery = 'SELECT Id from lboc_Gameplan__c';
		return Database.getQueryLocator(gamePlanDelQuery);
	}

	
	// Execute method to delete the records returned by the Start method
    global void execute(Database.BatchableContext gameplanDelBatchCtx, List<lboc_Gameplan__c> gamePlanResultSet)
    {
    	//Loop through all the Promotion Account result set.
    	system.debug('Size of Game Plan Result Set :: ' + gamePlanResultSet.size());
    	
    	delete gamePlanResultSet;
    		
    }
    
    // Finish method to call the Gameplan Cascade batch if successfull delete complete.
    global void finish(Database.BatchableContext gameplanDelBatchCtx)
    {
    	 AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      					TotalJobItems, CreatedBy.Email
      					FROM AsyncApexJob WHERE Id =:gameplanDelBatchCtx.getJobId()];
      					
      	if(a.Status == 'Completed')	
      	{			
			GameplanCascadeBatch gameplanBatch = new GameplanCascadeBatch();
			Database.executeBatch(gameplanBatch);
      	}	
    }
}