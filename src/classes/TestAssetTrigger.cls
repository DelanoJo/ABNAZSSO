@isTest
private class TestAssetTrigger {

    @isTest static void Test1() {
        
        List<Account> acctList = new List<Account>(); 
        Account acc1 = new Account();
        acc1.Name = 'BeerStore Mississauga';
        acc1.lboc_Labatt_Outlet_Id__c = '23456';
        acc1.buzz_retail__Account_ID__c = '23456';
        acctList.add(acc1);
        
        insert acctList;

        List<buzz_retail__Asset__c> assets = new List<buzz_retail__Asset__c>();
        buzz_retail__Asset__c asset1 = new buzz_retail__Asset__c();
        asset1.Name = 'Asset 1';
        asset1.buzz_retail__Account__c = acc1.Id;
        assets.add(asset1);
        
        insert assets;

    }
    
}