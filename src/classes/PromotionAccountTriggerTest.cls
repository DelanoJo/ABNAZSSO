@isTest
public class PromotionAccountTriggerTest {
	
	static testMethod void testPromotionAccountTriggerTest()
	{		
		createTestData();
		
		Test.startTest();
		List<buzz_retail__Promotion_Account__c> promotionAccountsToUpdate = [select Id, lboc_Promotion_Sell_in_Status__c from buzz_retail__Promotion_Account__c];
		for(buzz_retail__Promotion_Account__c promotionAccountToUpdate:promotionAccountsToUpdate)
		{
			promotionAccountToUpdate.lboc_Promotion_Sell_in_Status__c = 'Accepted';
		}
		update promotionAccountsToUpdate;
		
		Test.stopTest();	
		
		List<buzz_retail__TG__c> soldInMarkets = [select Id from buzz_retail__TG__c where Name like '%Sold-In%'];
		System.AssertEquals(1, soldInMarkets.size());
		List<buzz_retail__Promotion__c> soldInMarketPromotions = [select Id from buzz_retail__Promotion__c where lboc_Sold_in_Market__c = :soldInMarkets[0].Id];
		System.AssertEquals(1, soldInMarketPromotions.size());
		List<buzz_retail__TGAC__c> soldInMarketTargetAccounts = [select Id from buzz_retail__TGAC__c where buzz_retail__TG__c = :soldInMarkets[0].Id];		
		System.AssertEquals(2, soldInMarketTargetAccounts.size());			
								
	}
	
	private static void createTestData()
	{
		List<Labatt_Custom_Setting__c> customSettings = new List<Labatt_Custom_Setting__c>();
		customSettings.add(new Labatt_Custom_Setting__c(Name='Accepted', Type__c='PromotionAccountTriggerStatus'));
		customSettings.add(new Labatt_Custom_Setting__c(Name='Executed', Type__c='PromotionAccountTriggerStatus'));
		insert customSettings;
		
		List<Account> accounts = new List<Account>();
		Account testAccount1 = new Account(Name='Test Account 1');
		insert testAccount1;
		Account testAccount2 = new Account(Name='Test Account 2');
		insert testAccount2;
		
		buzz_retail__TG__c market = new buzz_retail__TG__c(Name='Test Market 1');
		insert market;
		
		List<buzz_retail__TGAC__c> targetAccounts = new List<buzz_retail__TGAC__c>();
		targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount1.Id,
																	   buzz_retail__TG__c = market.Id));
		targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount2.Id,
																	   buzz_retail__TG__c = market.Id));		
		insert targetAccounts;
																	   															   		
		buzz_retail__Promotion__c promotion = new buzz_retail__Promotion__c(Name='Test Promotion 1',buzz_retail__Status__c = 'Approved',
																		buzz_retail__In_Store_Start_Date__c = Date.today().addDays(1),
																		buzz_retail__In_Store_End_Date__c = Date.today().addDays(7));
		insert promotion;
		
		buzz_retail__Promotion__c promotionToUpdate = [select Id, buzz_retail__Market_Target__c from buzz_retail__Promotion__c limit 1];
		promotionToUpdate.buzz_retail__Market_Target__c = market.Id;
		update promotionToUpdate;

		List<buzz_retail__Promotion_Account__c> promotionAccounts = new List<buzz_retail__Promotion_Account__c>();
		promotionAccounts.add(new buzz_retail__Promotion_Account__c(buzz_retail__Account__c = testAccount1.Id, buzz_retail__Promotion__c = promotion.Id));
		promotionAccounts.add(new buzz_retail__Promotion_Account__c(buzz_retail__Account__c = testAccount2.Id, buzz_retail__Promotion__c = promotion.Id));
		insert promotionAccounts;
		
	}
}