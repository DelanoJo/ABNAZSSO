@isTest
private class TestDisplayCascadeBatch 
{
		
    static testMethod void testDisplayCascadeForSingleMarketMultipleAccounts() 
    {   
        Test.StartTest();
        
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
        
        lboc_Master_Display__c masterDisplay = new lboc_Master_Display__c(Name = 'Test Display 1',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterDisplay;
        
        
        lboc_Master_Display_Market__c masterDisplayMarket = new lboc_Master_Display_Market__c(lboc_Market__c = market.Id,
                                                                                           lboc_Master_Display__c = masterDisplay.Id);
        insert masterDisplayMarket;
        
       
                
        DisplayCascadeBatch objectCascadeBatch = new DisplayCascadeBatch();
        Id batchprocessid = Database.executeBatch(objectCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        List<buzz_retail__Display__c> createdDisplays = [select Id from buzz_retail__Display__c];
        System.AssertEquals(2, createdDisplays.size());        
    }
    
    static testMethod void testDisplayCascadeForMultipleMarketAndSingleAccount() 
    {
 
        Test.startTest();
        Account testAccount1 = new Account(Name='Test Account 1');
        insert testAccount1;
        
        Account testAccount2 = new Account(Name='Test Account 2');
        insert testAccount2;        
        
        buzz_retail__TG__c market1 = new buzz_retail__TG__c(Name='Test Market 1');
        insert market1;
        
        buzz_retail__TG__c market2 = new buzz_retail__TG__c(Name='Test Market 1');
        insert market2;
                
        List<buzz_retail__TGAC__c> targetAccounts = new List<buzz_retail__TGAC__c>();
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount1.Id,
                                                                       buzz_retail__TG__c = market1.Id));
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount1.Id,
                                                                       buzz_retail__TG__c = market2.Id));   
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount2.Id,
                                                                       buzz_retail__TG__c = market1.Id));
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount2.Id,
                                                                       buzz_retail__TG__c = market2.Id));                                                                       
        insert targetAccounts;        
                                                                                                                                                
        buzz_retail__Promotion__c promotion = new buzz_retail__Promotion__c(Name='Test Promotion 1',buzz_retail__Status__c = 'Approved',
                                                                        buzz_retail__In_Store_Start_Date__c = Date.today().addDays(1),
                                                                        buzz_retail__In_Store_End_Date__c = Date.today().addDays(7));
        insert promotion;
        
        lboc_Master_Display__c masterDisplay = new lboc_Master_Display__c(Name = 'Test Display 1',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterDisplay;
                
        lboc_Master_Display_Market__c masterDisplayMarket1 = new lboc_Master_Display_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Display__c = masterDisplay.Id);
        lboc_Master_Display_Market__c masterDisplayMarket2 = new lboc_Master_Display_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Display__c = masterDisplay.Id);
                                                                                                                                                                                                                
        insert masterDisplayMarket1;
        insert masterDisplayMarket2;
        
        
               
        DisplayCascadeBatch objectCascadeBatch = new DisplayCascadeBatch();
        Id batchprocessid = Database.executeBatch(objectCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        
        List<buzz_retail__Display__c> createdDisplays = [select Id from buzz_retail__Display__c];
        System.AssertEquals(2, createdDisplays.size());        
    }    
    
    static testMethod void testDisplayCascadeForMultipleMarketAndMultiplesAccounts() 
    {
        
        Test.startTest();
        Account testAccount1 = new Account(Name='Test Account 1');
        insert testAccount1;
        
        Account testAccount2 = new Account(Name='Test Account 2');
        insert testAccount2;        
        
        buzz_retail__TG__c market1 = new buzz_retail__TG__c(Name='Test Market 1');
        insert market1;
        
        buzz_retail__TG__c market2 = new buzz_retail__TG__c(Name='Test Market 2');
        insert market2;
                
        List<buzz_retail__TGAC__c> targetAccounts = new List<buzz_retail__TGAC__c>();
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount1.Id,
                                                                       buzz_retail__TG__c = market1.Id));
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount1.Id,
                                                                       buzz_retail__TG__c = market2.Id));   
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount2.Id,
                                                                       buzz_retail__TG__c = market1.Id));
        targetAccounts.add(new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount2.Id,
                                                                       buzz_retail__TG__c = market2.Id));                                                                       
        insert targetAccounts;        
                                                                                                                                                
        buzz_retail__Promotion__c promotion = new buzz_retail__Promotion__c(Name='Test Promotion 1',buzz_retail__Status__c = 'Approved',
                                                                        buzz_retail__In_Store_Start_Date__c = Date.today().addDays(1),
                                                                        buzz_retail__In_Store_End_Date__c = Date.today().addDays(7));
        insert promotion;
        
        lboc_Master_Display__c masterDisplay1 = new lboc_Master_Display__c(Name = 'Test Display 1',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterDisplay1;
        
        lboc_Master_Display__c masterDisplay2 = new lboc_Master_Display__c(Name = 'Test Display 2', 
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterDisplay2;        
                
        lboc_Master_Display_Market__c masterDisplayMarket1 = new lboc_Master_Display_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Display__c = masterDisplay1.Id);
        lboc_Master_Display_Market__c masterDisplayMarket2 = new lboc_Master_Display_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Display__c = masterDisplay1.Id);
                                                                                                        
        lboc_Master_Display_Market__c masterDisplayMarket3 = new lboc_Master_Display_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Display__c = masterDisplay2.Id);
        lboc_Master_Display_Market__c masterDisplayMarket4 = new lboc_Master_Display_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Display__c = masterDisplay2.Id);                                                                                                        
                                                                                                                                                                                                                
        insert masterDisplayMarket1;
        insert masterDisplayMarket2;
        insert masterDisplayMarket3;
        insert masterDisplayMarket4;
        
       
               
        DisplayCascadeBatch objectCascadeBatch = new DisplayCascadeBatch();
        Id batchprocessid = Database.executeBatch(objectCascadeBatch);
        
        Account testAccount3 = new Account(Name='Test Account 3');
        insert testAccount3;  
        
        buzz_retail__TGAC__c targetAccount = new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount3.Id,
                                                                       buzz_retail__TG__c = market2.Id);                                                                        
        insert targetAccount;        

        batchprocessid = Database.executeBatch(objectCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        
        List<buzz_retail__Display__c> createdDisplays = [select Id from buzz_retail__Display__c];
        System.AssertEquals(6, createdDisplays.size());   
          
    }    	

}