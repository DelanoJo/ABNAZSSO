@isTest
private class TestObjectiveCascadeBatch 
{
	
    static testMethod void testObjectiveCascadeBatch() 
    {

		createTestData();         
		
        Test.StartTest();
        
                
        ObjectiveCascadeBatch objectCascadeBatch = new ObjectiveCascadeBatch();
        Id batchprocessid = Database.executeBatch(objectCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        List<lboc_Objective__c> createdObjectives = [select Id from lboc_Objective__c];
        System.AssertEquals(4, createdObjectives.size());        

        List<lboc_Objective__c> createdObjectivesForAccount = [select Id from lboc_Objective__c where lboc_Objective__c.lboc_Outlet__c in (select Id from Account where Name = 'Test Account 1')];
        System.AssertEquals(2, createdObjectivesForAccount.size());        
              
    }
     
    public static void createTestData()
    {
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
        
        lboc_Master_Objective__c masterObjective1 = new lboc_Master_Objective__c(lboc_Description__c = 'Test Objective 1',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
                                                                                
        insert masterObjective1;
        
        lboc_Master_Objective__c masterObjective2 = new lboc_Master_Objective__c(lboc_Description__c = 'Test Objective 2',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterObjective2;        
                
        lboc_Master_Objective_Market__c masterObjectiveMarket1 = new lboc_Master_Objective_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Objective__c = masterObjective1.Id);
        lboc_Master_Objective_Market__c masterObjectiveMarket2 = new lboc_Master_Objective_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Objective__c = masterObjective1.Id);
                                                                                                        
        lboc_Master_Objective_Market__c masterObjectiveMarket3 = new lboc_Master_Objective_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Objective__c = masterObjective2.Id);
        lboc_Master_Objective_Market__c masterObjectiveMarket4 = new lboc_Master_Objective_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Objective__c = masterObjective2.Id);                                                                                                        
                                                                                                                                                                                                                
        insert masterObjectiveMarket1;
        insert masterObjectiveMarket2;
        insert masterObjectiveMarket3;
        insert masterObjectiveMarket4;
        
        masterObjective1.lboc_Status__c = 'Approved';
        update masterObjective1;
        
        masterObjective2.lboc_Status__c = 'Approved';
        update masterObjective2;
                                   
    }
	
}