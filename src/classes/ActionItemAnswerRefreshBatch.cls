/**
  Updates the Last Value field on a given Action Item Answer record based
  on the response provided to the same action item in the previous call
  visit for the same account.
  
*/
global class ActionItemAnswerRefreshBatch implements Database.Batchable<sObject>
{
	
	// Query to get all the "Calls" and their associated "Accounts" & "Action Item Answer" for tomorrow or next day.
    global final String query = 'Select Name,buzz_retail__Call__r.Name,buzz_retail__Answer__c,lboc_Last_Value__c, buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c from buzz_retail__ActionItem_Answer__c where buzz_retail__Call__r.buzz_retail__Date__c = TOMORROW';
	
	// Start method to get all the next day Calls and related information to it.
	global Database.QueryLocator start(Database.BatchableContext actionItemAnsBatchCtx)
	{
      	return Database.getQueryLocator(query);
    }
    
    
    // Execute method to process the results reeived from Start method.
    global void execute(Database.BatchableContext actionItemAnsBatchCtx, List<buzz_retail__ActionItem_Answer__c> actItemAnsResultSet)
    {
    	// Call the method in the service class to populate the Last value.
 		ActionItemAnswerRefreshBatchService.populateAnswerFromLastCall(actItemAnsResultSet);
             
    }
    
    // Finish method to close all the activities once the Action item answers are updated.
    global void finish(Database.BatchableContext BC)
    {
		system.debug('Action Item Answer Refresh to populate Last value Batch completed');
    }
    
}