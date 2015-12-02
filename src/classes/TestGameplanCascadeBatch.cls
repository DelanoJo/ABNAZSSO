/**
 * This class contains unit tests for validating the behavior of Gameplan Cascade batch
 * 
 */
@isTest
private class TestGameplanCascadeBatch 
{
    static testMethod void positiveGameplanCreationTest() 
    {
    	createTestData();
    	
    	Test.startTest();
    	
    	GameplanDeleteBatch gameplanDelBatch = new GameplanDeleteBatch();
		Database.executeBatch(gameplanDelBatch);
    	
    	Test.stopTest();
        
    }
    
    /* Create test data for testing the Gameplan Cascade Batch functionality.
     * Account, Promotions, Markets,Kits 
     * Promotion Accounts , Promotion Sold in kits using Batch & Trigger will be created.
     */
    public static void createTestData()
    {
    	/* Create Accounts
    	 * 1. BeerStore Mississauga (23456)
    	 * 2. BeerStore Toronto (45678)
    	 */
    	List<Account> acctList = new List<Account>(); 
    	Account acc1 = new Account();
    	acc1.Name = 'BeerStore Mississauga';
    	acc1.lboc_Labatt_Outlet_Id__c = '23456';
    	acc1.buzz_retail__Account_ID__c = '23456';
    	acc1.lboc_Sales_Territory__c = 'Territory 1';
    	acc1.lboc_Area__c = 'Area 1';
    	acc1.lboc_District__c = 'District 1';
    	acc1.lboc_Region__c = 'Region 1';
    	acctList.add(acc1);
    	
    	Account acc2 = new Account();
    	acc2.Name = 'BeerStore Toronto';
    	acc2.lboc_Labatt_Outlet_Id__c = '45678';
    	acc2.buzz_retail__Account_ID__c = '45678';
    	acc2.lboc_Sales_Territory__c = 'Territory 2';
    	acc2.lboc_Area__c = 'Area 2';
    	acc2.lboc_District__c = 'District 2';
    	acc2.lboc_Region__c = 'Region 2';
    	acctList.add(acc2);
    	
    	insert acctList;
    	
    	// Create Market
    	buzz_retail__TG__c marketRec = new buzz_retail__TG__c();
    	marketRec.Name = 'Test Market';
    	insert marketRec;
    	
    	// Create Market Targeted accounts
    	buzz_retail__TGAC__c targetedAcctRec1 = new buzz_retail__TGAC__c();
    	targetedAcctRec1.buzz_retail__Account__c = acc1.Id;
    	targetedAcctRec1.buzz_retail__TG__c = marketRec.Id;
    	insert targetedAcctRec1;
    	
    	// Create Market Targeted accounts
    	buzz_retail__TGAC__c targetedAcctRec2 = new buzz_retail__TGAC__c();
    	targetedAcctRec2.buzz_retail__Account__c = acc2.Id;
    	targetedAcctRec2.buzz_retail__TG__c = marketRec.Id;
    	insert targetedAcctRec2;
    	
    	
    	
    	// Create Promotion
    	buzz_retail__Promotion__c promoRecord = new buzz_retail__Promotion__c();
    	promoRecord.Name = 'Test Promotion';
    	promoRecord.buzz_retail__Status__c = 'Approved';
    	promoRecord.buzz_retail__Approved__c = true;
    	promoRecord.buzz_retail__Sell_in_Start_Date__c = Date.today() - 10;
    	promoRecord.buzz_retail__Sell_in_End_Date__c = Date.today() + 10;
    	promoRecord.buzz_retail__Market_Target__c = marketRec.Id;
    	promoRecord.buzz_retail__DoRefresh__c = true;
    	insert promoRecord;
    	
    	// Create Kit objects.
    	List<lboc_Kit__c> kitList = new List<lboc_Kit__c>();
    	lboc_Kit__c kit1 = new lboc_Kit__c();
    	kit1.lboc_Kit_Name__c = 'Kit 1';
    	kit1.lboc_Sales_Territory__c = 'Territory 1';
    	kit1.lboc_Area__c = 'Area 1';
    	kit1.lboc_District__c = 'District 1';
    	kit1.lboc_Region__c = 'Region 1';
    	kit1.lboc_Promotion__c = promoRecord.Id;
    	kitList.add(kit1);
    	
    	lboc_Kit__c kit2 = new lboc_Kit__c();
    	kit2.lboc_Kit_Name__c = 'Kit 2';
    	kit2.lboc_Sales_Territory__c = 'Territory 2';
    	kit2.lboc_Area__c = 'Area 2';
    	kit2.lboc_District__c = 'District 2';
    	kit2.lboc_Region__c = 'Region 2';
    	kit2.lboc_Promotion__c = promoRecord.Id;
    	kitList.add(kit2);
    	
    	insert kitList;
    	
    	// Create Promotion Account Records.
    	List<buzz_retail__Promotion_Account__c> promoAcctList = new List<buzz_retail__Promotion_Account__c>(); 
    	buzz_retail__Promotion_Account__c promoAcct1 = new buzz_retail__Promotion_Account__c();
    	promoAcct1.lboc_Promotion_Sell_in_Status__c = 'Accepted';
    	promoAcct1.buzz_retail__Account__c = acc1.id;
    	promoAcct1.buzz_retail__Promotion__c = promoRecord.id;
    	promoAcctList.add(promoAcct1);
    	
    	buzz_retail__Promotion_Account__c promoAcct2 = new buzz_retail__Promotion_Account__c();
    	promoAcct2.lboc_Promotion_Sell_in_Status__c = 'Accepted';
    	promoAcct2.buzz_retail__Account__c = acc2.id;
    	promoAcct2.buzz_retail__Promotion__c = promoRecord.id;
    	promoAcctList.add(promoAcct2);
    	
    	insert promoAcctList;

    	
    }
    
}