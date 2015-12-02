@isTest
private class AttachmentCascadeBatchTest {

    static testMethod void testAttachmentCascadeForSingleMarketMultipleAccounts() {
           
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
        
        lboc_Master_Attachment__c masterAttachment = new lboc_Master_Attachment__c(Name = 'Test Attachment 1', 
                                                                                lboc_Master_Attachment_Number__c = '111111',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterAttachment;
        
		Attachment attachment1 = new Attachment(Body=blob.valueOf('Test Attachment 1'), 
												Name = 'Attachment_' + DateTime.Now(), 
												parentId= masterAttachment.Id);
		insert attachment1;        

		Attachment attachment2 = new Attachment(Body=blob.valueOf('Test Attachment 2'), 
												Name = 'Attachment_' + DateTime.Now(), 
												parentId= masterAttachment.Id);
		insert attachment2;        
        
        lboc_Master_Attachment_Market__c masterAttachmentMarket = new lboc_Master_Attachment_Market__c(lboc_Market__c = market.Id,
                                                                                                    lboc_Master_Attachment__c = masterAttachment.Id);
        insert masterAttachmentMarket;
        
        masterAttachment.lboc_Status__c = 'Approved';
        update masterAttachment;
                
        AttachmentCascadeBatch attachmentCascadeBatch = new AttachmentCascadeBatch();
        Id batchprocessid = Database.executeBatch(attachmentCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        List<Attachment> createdAttachments = [select Id from Attachment];
        //2 orignal and 4(2 for each of the test accounts)
        System.AssertEquals(6, createdAttachments.size());        
    }
    
    static testMethod void testAttachmentCascadeForMultipleMarketAndSingleAccount() {
 
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
        
        lboc_Master_Attachment__c masterAttachment = new lboc_Master_Attachment__c(Name = 'Test Attachment 1', 
                                                                                lboc_Master_Attachment_Number__c = '111111',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterAttachment;
        
		Attachment attachment1 = new Attachment(Body=blob.valueOf('Test Attachment 1'), 
												Name = 'Attachment_' + DateTime.Now(), 
												parentId= masterAttachment.Id);
		insert attachment1;        
                
        lboc_Master_Attachment_Market__c masterAttachmentMarket1 = new lboc_Master_Attachment_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Attachment__c = masterAttachment.Id);
        lboc_Master_Attachment_Market__c masterAttachmentMarket2 = new lboc_Master_Attachment_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Attachment__c = masterAttachment.Id);
                                                                                                                                                                                                                
        insert masterAttachmentMarket1;
        insert masterAttachmentMarket2;
        
        masterAttachment.lboc_Status__c = 'Approved';
        update masterAttachment;
               
        AttachmentCascadeBatch objectCascadeBatch = new AttachmentCascadeBatch();
        Id batchprocessid = Database.executeBatch(objectCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        
        List<Attachment> createdAttachments = [select Id from Attachment];
        // 2 New Outlet Attachments and the existing Attachment
        System.AssertEquals(3, createdAttachments.size());        
    }    
    
    static testMethod void testAttachmentCascadeForMultipleMarketAndMultiplesAccounts() {
        
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
        
        lboc_Master_Attachment__c masterAttachment1 = new lboc_Master_Attachment__c(Name = 'Test Attachment 1', 
                                                                                lboc_Master_Attachment_Number__c = '111111',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterAttachment1;
        
		Attachment attachment1 = new Attachment(Body=blob.valueOf('Test Attachment 1'), 
												Name = 'Attachment_' + DateTime.Now(), 
												parentId= masterAttachment1.Id);
		insert attachment1;        
        
        lboc_Master_Attachment__c masterAttachment2 = new lboc_Master_Attachment__c(Name = 'Test Attachment 2', 
                                                                                lboc_Master_Attachment_Number__c = '22222',
                                                                                lboc_Start_Date__c = Date.today().addDays(-1),
                                                                                lboc_End_Date__c = Date.today().addDays(+1));
        insert masterAttachment2;      
        
		Attachment attachment2 = new Attachment(Body=blob.valueOf('Test Attachment 2'), 
												Name = 'Attachment_' + DateTime.Now(), 
												parentId= masterAttachment2.Id);
		insert attachment2;          
                
        lboc_Master_Attachment_Market__c masterAttachmentMarket1 = new lboc_Master_Attachment_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Attachment__c = masterAttachment1.Id);
        lboc_Master_Attachment_Market__c masterAttachmentMarket2 = new lboc_Master_Attachment_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Attachment__c = masterAttachment1.Id);
                                                                                                        
        lboc_Master_Attachment_Market__c masterAttachmentMarket3 = new lboc_Master_Attachment_Market__c(lboc_Market__c = market1.Id,
                                                                                                        lboc_Master_Attachment__c = masterAttachment2.Id);
        lboc_Master_Attachment_Market__c masterAttachmentMarket4 = new lboc_Master_Attachment_Market__c(lboc_Market__c = market2.Id,
                                                                                                        lboc_Master_Attachment__c = masterAttachment2.Id);                                                                                                        
                                                                                                                                                                                                                
        insert masterAttachmentMarket1;
        insert masterAttachmentMarket2;
        insert masterAttachmentMarket3;
        insert masterAttachmentMarket4;
        
        masterAttachment1.lboc_Status__c = 'Approved';
        update masterAttachment1;
        
        masterAttachment2.lboc_Status__c = 'Approved';
        update masterAttachment2;
               
        AttachmentCascadeBatch attachmentCascadeBatch = new AttachmentCascadeBatch();
        Id batchprocessid = Database.executeBatch(attachmentCascadeBatch);
        
        Account testAccount3 = new Account(Name='Test Account 3');
        insert testAccount3;  
        
        buzz_retail__TGAC__c targetAccount = new buzz_retail__TGAC__c(buzz_retail__Account__c = testAccount3.Id,
                                                                     buzz_retail__TG__c = market2.Id);                                                                        
        insert targetAccount;        

        batchprocessid = Database.executeBatch(attachmentCascadeBatch);
        batchprocessid = Database.executeBatch(attachmentCascadeBatch);
        Test.stopTest();
        
        AsyncApexJob async = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems from AsyncApexJob where Id = :batchprocessid];
        
        List<Attachment> createdAttachments = [select Id from Attachment where ParentId = :testAccount1.Id];
        System.AssertEquals(2, createdAttachments.size());   
          
    }    	
}