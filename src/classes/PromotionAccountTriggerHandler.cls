public without sharing class PromotionAccountTriggerHandler 
{	
	private static String SOLD_IN_MARKET_SUFFIX = ' - Sold-In Market';
	
	public static void handleSoldInMarketCreationForPromotionAccounts(Map<Id, buzz_retail__Promotion_Account__c> updatedPromotionAccounts, Map<Id,buzz_retail__Promotion__c> promotionMap)
	{
		Map<buzz_retail__Promotion__c, buzz_retail__TG__c>	promotionToSoldInMarketMap = new Map<buzz_retail__Promotion__c, buzz_retail__TG__c>();	
		List<Id> existingSoldInMarkets = new List<Id>();
		//loop through list of updated promotion accounts and determine if status has changed to Accepted
		//if it is accepted check to see if "sold in market" exists for the promotions account's promotion
		//create new sold in market if one doesn't exist for promotion																				  	
		for(buzz_retail__Promotion_Account__c promotionAccount:updatedPromotionAccounts.values())
		{
			buzz_retail__Promotion__c promotion = promotionMap.get(promotionAccount.buzz_retail__Promotion__c);
			if(promotion.lboc_Sold_in_Market__c == null )
			{	
				buzz_retail__TG__c market = new buzz_retail__TG__c(Name=promotion.Name + SOLD_IN_MARKET_SUFFIX, buzz_retail__Batch_Refresh__c = false);
				promotionToSoldInMarketMap.put(promotion, market);						
			}
			else
			{
				existingSoldInMarkets.add(promotion.lboc_Sold_in_Market__c);	
			}			
		}
				
		//for promotions that don't have sold in markets, create new sold in markets and update promotion with sold in market
		if(promotionToSoldInMarketMap.size() > 0)
		{			
			List<buzz_retail__TG__c> marketList = new List<buzz_retail__TG__c>();		
			List<buzz_retail__Promotion__c> promotionList = new List<buzz_retail__Promotion__c>();				
			marketList.addAll(promotionToSoldInMarketMap.values());
			insert marketList;
			
			for(buzz_retail__Promotion__c promo:promotionToSoldInMarketMap.keyset())
			{
				promo.lboc_Sold_in_Market__c = promotionToSoldInMarketMap.get(promo).Id;
				promotionList.add(promo);
			}
			
			update promotionList;
		}

		//reload promotion map to get updated sold-in market
		promotionMap = new Map<Id,buzz_retail__Promotion__c>([select Id, Name, lboc_Sold_in_Market__c 
						  from buzz_retail__Promotion__c where Id in
							(select buzz_retail__Promotion__c 
							 from buzz_retail__Promotion_Account__c 
							 where Id in :updatedPromotionAccounts.keyset())]);	
		
		//get existing sold in market accounts so we don't try and insert duplicates  this is for when an account gets updated																								
		List<buzz_retail__TGAC__c> existingSoldInMarketAccounts = [select Id, buzz_retail__Account__c, buzz_retail__TG__c from buzz_retail__TGAC__c where buzz_retail__TG__c in :existingSoldInMarkets];
		Map<Id, Set<Id>> existingSoldInMarketsAccountsMap = new Map<Id, Set<Id>>();
		for(buzz_retail__TGAC__c existingSoldInMarketAccount:existingSoldInMarketAccounts)
		{
			if(existingSoldInMarketsAccountsMap.get(existingSoldInMarketAccount.buzz_retail__TG__c) == null)
				existingSoldInMarketsAccountsMap.put(existingSoldInMarketAccount.buzz_retail__TG__c, new Set<Id>());
			existingSoldInMarketsAccountsMap.get(existingSoldInMarketAccount.buzz_retail__TG__c).add(existingSoldInMarketAccount.buzz_retail__Account__c);
		}																																												
		
		//for the accepted promotion accounts create new targeted accounts for sold in market if they don't already exist
		List<buzz_retail__TGAC__c> targetAccountList = new List<buzz_retail__TGAC__c>();							 	
		for(buzz_retail__Promotion_Account__c updatedPromotionAccount: updatedPromotionAccounts.values())
		{			
			buzz_retail__Promotion__c promotion = promotionMap.get(updatedPromotionAccount.buzz_retail__Promotion__c);
			if(existingSoldInMarketsAccountsMap.get(promotion.lboc_Sold_in_Market__c) == null || (!existingSoldInMarketsAccountsMap.get(promotion.lboc_Sold_in_Market__c).contains(updatedPromotionAccount.buzz_retail__Account__c)))
			{
				buzz_retail__TGAC__c targetAccount = new buzz_retail__TGAC__c(buzz_retail__Account__c = updatedPromotionAccount.buzz_retail__Account__c, 
																		  buzz_retail__TG__c = promotion.lboc_Sold_in_Market__c);
				targetAccountList.add(targetAccount);			
			}
		}
		
		if(targetAccountList.size() > 0)
			insert targetAccountList;					
	}
	
	public static void handlePromotionSoldInKitCreationForPromotionAccounts(Map<Id, buzz_retail__Promotion_Account__c> updatedPromotionAccounts, 
		Map<Id,buzz_retail__Promotion__c> promotionMap)
	{
		Map<Id, Account> accountRegionMap = new Map<Id,Account>([select Id, lboc_Sales_Territory__c from Account where Id in (select buzz_retail__Account__c from buzz_retail__Promotion_Account__c
																													where id in :updatedPromotionAccounts.keyset())]);
		List<lboc_Kit__c> kits = [select Id, lboc_Promotion__c, lboc_Sales_Territory__c from lboc_Kit__c where lboc_Promotion__c in :promotionMap.keyset() and lboc_Sales_Territory__c != null];
		Map<Id, Map<String, List<lboc_Kit__c>>> promotionKitRegionMap = new Map<Id, Map<String, List<lboc_Kit__c>>>();
		
		System.debug(LoggingLevel.Debug, 'Test Kit Size ' + kits.size());
		for(lboc_Kit__c kit:kits)
		{
			if(promotionKitRegionMap.get(kit.lboc_Promotion__c) == null)
				promotionKitRegionMap.put(kit.lboc_Promotion__c, new Map<String, List<lboc_Kit__c>>());
				
			if(promotionKitRegionMap.get(kit.lboc_Promotion__c).get(kit.lboc_Sales_Territory__c) == null)
				promotionKitRegionMap.get(kit.lboc_Promotion__c).put(kit.lboc_Sales_Territory__c, new List<lboc_Kit__c>());
			
			promotionKitRegionMap.get(kit.lboc_Promotion__c).get(kit.lboc_Sales_Territory__c).add(kit);			
		}
		System.debug(LoggingLevel.Debug, 'Brent Test Promotion Kit Region Map Size ' + promotionKitRegionMap.size());
		
		Map<Id, buzz_retail__Promotion_Account__c> existingPromotionAccountsWithSoldInKits = new Map<Id, buzz_retail__Promotion_Account__c>([select Id from buzz_retail__Promotion_Account__c where Id in
																							(select lboc_Promotion_Account__c from lboc_Promotion_Sold_in_Kit__c 
																							where lboc_Promotion_Account__c in :updatedPromotionAccounts.keyset())]);
		System.debug(LoggingLevel.Debug, 'Brent Test Existins Promotion Sold In Kits Size ' + existingPromotionAccountsWithSoldInKits.size());

																				
		List<lboc_Promotion_Sold_in_Kit__c> promotionSoldInKits = new List<lboc_Promotion_Sold_in_Kit__c>();
		lboc_Promotion_Sold_in_Kit__c promotionSoldInKit;
		for(buzz_retail__Promotion_Account__c updatedPromotionAccount:updatedPromotionAccounts.values())
		{
			String accountRegion = accountRegionMap.get(updatedPromotionAccount.buzz_retail__Account__c).lboc_Sales_Territory__c;
			System.debug(LoggingLevel.Debug, 'Brent Test Promotion Account Account Region ' + accountRegion);
			
			if(existingPromotionAccountsWithSoldInKits.get(updatedPromotionAccount.Id) == null && !promotionKitRegionMap.isEmpty() &&
					promotionKitRegionMap.get(updatedPromotionAccount.buzz_retail__Promotion__c).get(accountRegion) != null)
			{
				for(lboc_Kit__c kit:promotionKitRegionMap.get(updatedPromotionAccount.buzz_retail__Promotion__c).get(accountRegion))
				{
					promotionSoldInKit = new lboc_Promotion_Sold_in_Kit__c(lboc_Promotion_Account__c = updatedPromotionAccount.Id,
																		lboc_Kit__c = kit.Id,
																		lboc_Account__c = updatedPromotionAccount.buzz_retail__Account__c);
					promotionSoldInKits.add(promotionSoldInKit);
				}
			}			
		}
		if(promotionSoldInKits.size() > 0)
			insert promotionSoldInKits;
	}
	
	public static Set<String> getPromotionAccountTriggerStatuses()
	{
		List<Labatt_Custom_Setting__c> customSettingStatuses = [select Name from Labatt_Custom_Setting__c where Type__c = 'PromotionAccountTriggerStatus'];
		Set<String> promotionAccountTriggerStatuses = new Set<String>();
		for(Labatt_Custom_Setting__c customSetting:customSettingStatuses)	
			promotionAccountTriggerStatuses.add(customSetting.Name);
		return promotionAccountTriggerStatuses;
	}
	
	
	
	// Method to add new Promotion Account records added 
	public static void createNewGameplanDetailRecords(Map<Id, buzz_retail__Promotion_Account__c> updatedPromotionAccounts)
	{
		 // Query to fetch all the Promotion Accounts and related fields that needs to be populated on the Gameplan object.	
		 List<buzz_retail__Promotion_Account__c> promoAcctResultSet = [SELECT Id,Name,lboc_Promotion_Sell_in_Status__c,buzz_retail__In_Store_Start_Date__c, 
         		buzz_retail__Promotion__c,buzz_retail__In_Store_End_Date__c,
         		buzz_retail__Account__r.OwnerId,buzz_retail__Account__c,buzz_retail__Account__r.lboc_Sales_Territory__c,
         		buzz_retail__Account__r.lboc_Region__c,buzz_retail__Account__r.lboc_District__c,
         		buzz_retail__Account__r.lboc_Area__c,
         		(Select lboc_No_Kits_Sold_in__c from Promotion_Sold_in_Kits__r)
         		from buzz_retail__Promotion_Account__c where Id =: updatedPromotionAccounts.keySet()];
         
         GameplanCascadeBatchService.createGameplanDetailRecords(promoAcctResultSet);	
         	
	}
	
	
	// Method to update the existing gameplan records.
	public static void updateGameplanDetailRecords(Map<Id, buzz_retail__Promotion_Account__c> updatedPromotionAccounts)
	{
	
		//Fetch all the records from the gameplan for a given Promotion Account ID.
		List<lboc_Gameplan__c> gameplanRecList = [Select Id,lboc_In_Store_Start_Date__c,lboc_Promotion_Account__c,
			lboc_In_Store_End_Date__c,lboc_Accepted__c,
			lboc_Executed__c,lboc_Denied__c,lboc_Planned__c,lboc_Allocation_Utilized__c from lboc_Gameplan__c 
			where lboc_type__c = 'Detail Record' and lboc_Promotion_Account__c =:updatedPromotionAccounts.keySet()];
		
		Map<Id,buzz_retail__Promotion_Account__c> promoSoldKitsMap = new Map<Id,buzz_retail__Promotion_Account__c>([Select Id, (Select lboc_No_Kits_Sold_in__c from Promotion_Sold_in_Kits__r) 
						from buzz_retail__Promotion_Account__c where Id =: updatedPromotionAccounts.keySet()]);
		
		// loop through the records and update them based on the updated promotion sell in status.
		for(lboc_Gameplan__c gamePlanRec : gameplanRecList)
		{
			//Check the new promotion sell-in status for the Promtoion Account record and update the Gameplan records.
			// Promotion Sell in status logic.
			buzz_retail__Promotion_Account__c promoAcctRec = updatedPromotionAccounts.get(gamePlanRec.lboc_Promotion_Account__c);
			
			buzz_retail__Promotion_Account__c promoSoldInKitRec = promoSoldKitsMap.get(gamePlanRec.lboc_Promotion_Account__c);
    		if(promoAcctRec.lboc_Promotion_Sell_in_Status__c == 'Sold-In')
    		{
    			gamePlanRec.lboc_Accepted__c = 1;
    			gamePlanRec.lboc_Executed__c = 0;
    			gamePlanRec.lboc_Denied__c = 0;
    			gamePlanRec.lboc_Planned__c = 0;	
    		}
    		else if(promoAcctRec.lboc_Promotion_Sell_in_Status__c == 'Not Planned')
    		{
    			gamePlanRec.lboc_Executed__c = 1;
    			gamePlanRec.lboc_Denied__c = 0;
    			gamePlanRec.lboc_Planned__c = 0;
    			gamePlanRec.lboc_Accepted__c = 0;
    		}
    		else if(promoAcctRec.lboc_Promotion_Sell_in_Status__c == 'Denied')
    		{
    			gamePlanRec.lboc_Denied__c = 1;
    			gamePlanRec.lboc_Planned__c = 0;
    			gamePlanRec.lboc_Accepted__c = 0;
    			gamePlanRec.lboc_Executed__c = 0;
    		}
    		else if(promoAcctRec.lboc_Promotion_Sell_in_Status__c == 'Planning')
    		{
    			gamePlanRec.lboc_Planned__c = 1;
    			gamePlanRec.lboc_Accepted__c = 0;
    			gamePlanRec.lboc_Executed__c = 0;
    			gamePlanRec.lboc_Denied__c = 0;
    		}
    		
    		Decimal soldInKits = 0;
    		for(lboc_Promotion_Sold_in_Kit__c promoSoldKit : promoSoldInKitRec.Promotion_Sold_in_Kits__r)
    		{
        		system.debug('Promotion Sold In Kit ::' + promoSoldKit.lboc_No_Kits_Sold_in__c);
        		soldInKits += promoSoldKit.lboc_No_Kits_Sold_in__c;
    		}
    		gamePlanRec.lboc_Allocation_Utilized__c = soldInKits;
    		gamePlanRec.lboc_In_Store_Start_Date__c = promoAcctRec.buzz_retail__In_Store_Start_Date__c;
    		gamePlanRec.lboc_In_Store_End_Date__c = promoAcctRec.buzz_retail__In_Store_End_Date__c;
		}
		update gameplanRecList;	
		
		// Delete the Summary records and create them again with the new updates.
		//delete [Select Id from lboc_Gameplan__c where lboc_type__c = 'Summary Record'];
		//GameplanCascadeBatchService.createGameplanSummaryRecords();
			
	}
	
	// Method to update the existing gameplan records.
	/*public static void updateGameplanSummaryRecords(Map<Id, buzz_retail__Promotion_Account__c> updatedPromotionAccounts)
	{
		
	}*/
	
}