@isTest
private class TestPromotionAccountTrigger 
{

	static testMethod void posGameplanRecCreationTest()
	{	
		List<buzz_retail__Promotion_Account__c> promotionAccounts = new List<buzz_retail__Promotion_Account__c>();	
		createTestData(promotionAccounts);
		
		
		Test.startTest();
		
		
		insert promotionAccounts;
		
		Test.stopTest();	
		
		
		List<lboc_Gameplan__c> gameplanRecords = [Select Id from lboc_Gameplan__c where lboc_Type__c = 'Detail Record'];
		system.assertEquals(300, gameplanRecords.size());
		/*
		List<lboc_Gameplan__c> soldInMarkets = [select Id from buzz_retail__TG__c where Name like '%Sold-In%'];
		System.AssertEquals(1, soldInMarkets.size());
		List<buzz_retail__Promotion__c> soldInMarketPromotions = [select Id from buzz_retail__Promotion__c where lboc_Sold_in_Market__c = :soldInMarkets[0].Id];
		System.AssertEquals(1, soldInMarketPromotions.size());
		List<buzz_retail__TGAC__c> soldInMarketTargetAccounts = [select Id from buzz_retail__TGAC__c where buzz_retail__TG__c = :soldInMarkets[0].Id];		
		System.AssertEquals(300, soldInMarketTargetAccounts.size());	*/		
								
	}
	
	// Test method to check whether Sold in Market got created successfully.
	static testMethod void posSoldInMarketCreateTest()
	{	
		List<buzz_retail__Promotion_Account__c> promotionAccounts = new List<buzz_retail__Promotion_Account__c>();	
		createTestData(promotionAccounts);
		
		
		Test.startTest();
		
		insert promotionAccounts;
		
		//buzz_retail__Promotion_Account__c promotionAccountsToUpdate = [select Id, lboc_Promotion_Sell_in_Status__c from buzz_retail__Promotion_Account__c limit 1];
		//promotionAccountsToUpdate.lboc_Promotion_Sell_in_Status__c = 'Sold-In';
		//update promotionAccountsToUpdate;
		
		promotionAccounts.get(0).lboc_Promotion_Sell_in_Status__c= 'Sold-In';
		update promotionAccounts.get(0);
		
		promotionAccounts.get(1).lboc_Promotion_Sell_in_Status__c= 'Sold-In';
		update promotionAccounts.get(1);
		
		Test.stopTest();	
		
		
		List<buzz_retail__TG__c> soldInMarkets = [select Id from buzz_retail__TG__c where Name like '%Sold-In%'];
		System.AssertEquals(1, soldInMarkets.size());	
								
	}
	
	private static void createTestData(List<buzz_retail__Promotion_Account__c> promotionAccounts)
	{
		List<Labatt_Custom_Setting__c> customSettings = new List<Labatt_Custom_Setting__c>();
		customSettings.add(new Labatt_Custom_Setting__c(Name='Planning', Type__c='PromotionAccountTriggerStatus'));
		customSettings.add(new Labatt_Custom_Setting__c(Name='Sold-In', Type__c='PromotionAccountTriggerStatus'));
		insert customSettings;
		
		List<Account> accounts = new List<Account>();
		// Create around 300 Accts.
		for(Integer accCount=0 ; accCount < 300 ; accCount++)
		{
			Account testAccount1 = new Account();
			testAccount1.Name = 'Test Acct ' + accCount;
			testAccount1.lboc_Labatt_Outlet_Id__c = 'L000' + accCount;
			testAccount1.buzz_retail__Account_ID__c = 'L000' + accCount;
			accounts.add(testAccount1);	
		}
		insert accounts;

		
		/*insert testAccount1;
		Account testAccount2 = new Account(Name='Test Account 2');
		insert testAccount2;*/
		
		buzz_retail__TG__c market = new buzz_retail__TG__c(Name='Test Market 1');
		insert market;
		
		// Add all 300 accounts into this market.
		List<buzz_retail__TGAC__c> targetAccounts = new List<buzz_retail__TGAC__c>();
		for(Integer marCount=0 ; marCount < 300 ; marCount++)
		{
			buzz_retail__TGAC__c tarAcct = new buzz_retail__TGAC__c();
			tarAcct.buzz_retail__Account__c = accounts.get(marCount).Id;
			tarAcct.buzz_retail__TG__c = market.Id;
			targetAccounts.add(tarAcct);	
		}
		insert targetAccounts;
		
		/*targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount1.Id,
																	   buzz_retail__TG__c = market.Id));
		targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount2.Id,
																	   buzz_retail__TG__c = market.Id));		
		insert targetAccounts;*/
		
		
																	   															   		
		buzz_retail__Promotion__c promotion = new buzz_retail__Promotion__c(Name='Test Promotion 1',buzz_retail__Status__c = 'Approved',
																		buzz_retail__In_Store_Start_Date__c = Date.today().addDays(1),
																		buzz_retail__In_Store_End_Date__c = Date.today().addDays(7));
		insert promotion;
		
		buzz_retail__Promotion__c promotionToUpdate = [select Id, buzz_retail__Market_Target__c from buzz_retail__Promotion__c limit 1];
		promotionToUpdate.buzz_retail__Market_Target__c = market.Id;
		update promotionToUpdate;
		
		
		// Add all 300 accounts into the Promotion Accounts.
		for(Integer promoAccCount=0 ; promoAccCount < 300 ; promoAccCount++)
		{
			buzz_retail__Promotion_Account__c promoAcct = new buzz_retail__Promotion_Account__c();
			promoAcct.buzz_retail__Account__c = accounts.get(promoAccCount).Id;
			promoAcct.buzz_retail__Promotion__c = promotion.Id;
			promotionAccounts.add(promoAcct);	
		}
		/*insert targetAccounts;
		
		promotionAccounts.add(new buzz_retail__Promotion_Account__c(buzz_retail__Account__c = testAccount1.Id, buzz_retail__Promotion__c = promotion.Id));
		promotionAccounts.add(new buzz_retail__Promotion_Account__c(buzz_retail__Account__c = testAccount2.Id, buzz_retail__Promotion__c = promotion.Id));
		insert promotionAccounts;*/
		
	}

}