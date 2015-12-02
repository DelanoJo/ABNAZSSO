trigger PromotionAccountTrigger on buzz_retail__Promotion_Account__c (after insert,after update) 
{
	if(Trigger.isAfter)
	{
		Map<Id, buzz_retail__Promotion_Account__c> updatedPromotionAccounts = new Map<Id,buzz_retail__Promotion_Account__c>();
		Map<Id, buzz_retail__Promotion_Account__c> modifiedPromotionAcctMap = new Map<Id, buzz_retail__Promotion_Account__c>();
		Map<Id, buzz_retail__Promotion_Account__c> newGameplanPromotionAccts = new Map<Id, buzz_retail__Promotion_Account__c>();
		Map<Id, buzz_retail__Promotion_Account__c> gamePlanSummaryPromotionAcctMap = new Map<Id, buzz_retail__Promotion_Account__c>();
																										  	
		//loop through list of updated promotion accounts and determin if status has changed to Accepted
		//if it is accepted check to see if "sold in market" exists for the promotions account's promotion
		//create new sold in market if one doesn't exist for promotion
		
		
		Set<String> promotionAccountTriggerStatuses = PromotionAccountTriggerHandler.getPromotionAccountTriggerStatuses();
																  																  	
		for(buzz_retail__Promotion_Account__c promotionAccount:trigger.new)
		{
			if(Trigger.isUpdate)
			{
				buzz_retail__Promotion_Account__c oldPromotionAccount = Trigger.oldMap.get(promotionAccount.Id);
				if(promotionAccountTriggerStatuses.contains(promotionAccount.lboc_Promotion_Sell_in_Status__c) && !promotionAccountTriggerStatuses.contains(oldPromotionAccount.lboc_Promotion_Sell_in_Status__c))	
				{
					updatedPromotionAccounts.put(promotionAccount.Id, promotionAccount);
				}
				
				if(promotionAccount.lboc_Promotion_Sell_in_Status__c != oldPromotionAccount.lboc_Promotion_Sell_in_Status__c)
				{
					modifiedPromotionAcctMap.put(promotionAccount.Id,promotionAccount);
					gamePlanSummaryPromotionAcctMap.put(promotionAccount.Id,promotionAccount);
				}
				
			}
			else if (Trigger.isInsert)
			{
				if(promotionAccountTriggerStatuses.contains(promotionAccount.lboc_Promotion_Sell_in_Status__c))
				{
					updatedPromotionAccounts.put(promotionAccount.Id, promotionAccount);
					
				}	
				newGameplanPromotionAccts.put(promotionAccount.Id, promotionAccount);
				gamePlanSummaryPromotionAcctMap.put(promotionAccount.Id,promotionAccount);
			}	
		}
		
		
		
		if(updatedPromotionAccounts.size() > 0)
		{
			Map<Id,buzz_retail__Promotion__c> promotionMap =  new Map<Id, buzz_retail__Promotion__c>([select Id, Name, lboc_Sold_in_Market__c 
																								  from buzz_retail__Promotion__c where Id in
																								  	(select buzz_retail__Promotion__c 
																								  	from buzz_retail__Promotion_Account__c 
																								  	where Id in :updatedPromotionAccounts.keyset())] );			
		
			PromotionAccountTriggerHandler.handleSoldInMarketCreationForPromotionAccounts(updatedPromotionAccounts, promotionMap);
			PromotionAccountTriggerHandler.handlePromotionSoldInKitCreationForPromotionAccounts(updatedPromotionAccounts, promotionMap);
			
		}
		
		// Logic to create new Gameplan records.
		if(newGameplanPromotionAccts.size() > 0)
		{
			system.debug('Size of new Records being added ::' + newGameplanPromotionAccts.size());
			PromotionAccountTriggerHandler.createNewGameplanDetailRecords(newGameplanPromotionAccts);
		}
		
		
		//Update the Gameplan Record for any new changes to the Promotion account records.
		//If Promotion account sold in status has been changed.
		if(modifiedPromotionAcctMap != null && modifiedPromotionAcctMap.size() > 0)
		{
			system.debug('Inside Batch Execution Method');
			PromotionAccountTriggerHandler.updateGameplanDetailRecords(modifiedPromotionAcctMap);
		}
		
		if(gamePlanSummaryPromotionAcctMap.size() > 0)
		{
			delete [Select Id from lboc_Gameplan__c where lboc_type__c = 'Summary Record'];
			GameplanCascadeBatchService.createGameplanSummaryRecords();
		}
		
	}		
}