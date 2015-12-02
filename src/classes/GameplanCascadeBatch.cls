/**
  Batch Job to create the Gameplan Report for all active promotions running in the 
  Salesforce Org for a given year.
  This report will be created for every sales rep and will be displayed on the IPAD.
  
*/
global class GameplanCascadeBatch implements Database.Batchable<sObject>
{
	
	// Query field to get all the Promotion Accounts in the system.
    global String promoAccountQuery; 
    
    // Start method to get all the next day Calls and related information to it.
	global Database.QueryLocator start(Database.BatchableContext gameplanBatchCtx)
	{
		 String promoStatus = 'Approved';
		 //Delete all Gameplan records before creating new ones.
		 for(List<lboc_Gameplan__c> deleteGameplanList : [Select Id from lboc_Gameplan__c])
		 {
		 	delete deleteGameplanList;
		 }	
		 // Query to fetch all the Promotion Accounts and related fields that needs to be populated on the Gameplan object.	
		 this.promoAccountQuery = 'SELECT Id,Name,lboc_Promotion_Sell_in_Status__c,buzz_retail__In_Store_Start_Date__c ';
         this.promoAccountQuery += ' , buzz_retail__Promotion__c,buzz_retail__In_Store_End_Date__c';
         this.promoAccountQuery += ' , buzz_retail__Account__r.OwnerId,buzz_retail__Account__c,buzz_retail__Account__r.lboc_Sales_Territory__c';
         this.promoAccountQuery += ' , buzz_retail__Account__r.lboc_Region__c,buzz_retail__Account__r.lboc_District__c';
         this.promoAccountQuery += ' , buzz_retail__Account__r.lboc_Area__c';
         this.promoAccountQuery += ' , (Select lboc_No_Kits_Sold_in__c from Promotion_Sold_in_Kits__r)';
         this.promoAccountQuery += ' from buzz_retail__Promotion_Account__c where buzz_retail__Promotion__r.buzz_retail__Status__c =:promoStatus';
               
		 return Database.getQueryLocator(promoAccountQuery);
    }
    
    // Execute method to process the results reeived from Start method.
    global void execute(Database.BatchableContext gameplanBatchCtx, List<buzz_retail__Promotion_Account__c> promoAcctResultSet)
    {
    	//Loop through all the Promotion Account result set.
    	system.debug('Size of Promo Account Result Set :: ' + promoAcctResultSet.size());
    	
    	if(promoAcctResultSet != null && promoAcctResultSet.size() > 0)
    	{
    		
    		GameplanCascadeBatchService.createGameplanDetailRecords(promoAcctResultSet);
    	}
    	
    	
    }
    
    // Finish method to create the Summary records based on the Individual gameplan records created in Execute method.
    global void finish(Database.BatchableContext gameplanBatchCtx)
    {
		GameplanCascadeBatchService.createGameplanSummaryRecords();
		system.debug('Gameplan Batch completed');
    }
    
}