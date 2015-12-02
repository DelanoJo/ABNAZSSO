/**
 *
 * Author: Raghav Medahal
 */
@isTest
private class EndCallBatchTest {
    
    static testmethod void endCallWithNoMustDoActionItems() {
        // set org call settings
        buzz_retail__OrgCallSettings__c orgCallSettings = CreateOrgCallSettings();
        upsert orgCallSettings;
        
        // create cip
        buzz_retail__CallInitializationParameters__c cip = CreateCallInitParamters();
        insert cip;
        
        // create account
        Account accountOutlet1 = SetupAccount();
        insert accountOutlet1 ;
        
        // create market
        buzz_retail__TG__c mtObj =  CreateMarketTargetTypeAccount();
        insert mtObj;
        
        // create targeted account
        buzz_retail__TGAC__c tgAcObj = CreateTargetedAccount(mtObj, accountOutlet1);
        insert tgAcObj;
        
        // create ai
        buzz_retail__ActionItem__c aiObj = CreateNewActionItem();
        aiObj.buzz_retail__Start_Date__c = Date.Today() -2;
        aiObj.buzz_retail__End_Date__c = Date.Today() + 30;
        insert aiObj;
        
        // create aiTarget or else ai can't be approved
        buzz_retail__ActionItemTarget__c aiTargetObj = CreateActionItemTarget(aiObj, mtObj);
        aiTargetObj.buzz_retail__StartDate__c = Date.Today() - 2;
        aiTargetObj.buzz_retail__EndDate__c = Date.Today() + 30;
        insert aiTargetObj;
        
        // create aiAccount        
        buzz_retail__ActionItemAccount__c aiA = new buzz_retail__ActionItemAccount__c(buzz_retail__ActionItem__c=aiObj.id, 
                                                                    buzz_retail__Account__c=accountOutlet1.id,
                                                                    buzz_retail__StartDate__c = aiTargetObj.buzz_retail__StartDate__c, 
                                                                    buzz_retail__EndDate__c = aiTargetObj.buzz_retail__EndDate__c);
        insert aiA;
        
        // approve ai
        aiObj.buzz_retail__IsApproved__c = true;
        update aiObj;
        
        // create call
        DateTime startDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)); // prev day, so batch will pick it up
        DateTime endDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(9, 0, 0, 0)); // prev day, so batch will pick it up
        buzz_retail__Call__c call = new buzz_retail__Call__c(buzz_retail__Account__c = accountOutlet1.Id, buzz_retail__Date__c = startDate, buzz_retail__End__c = endDate, buzz_retail__Initialize__c = true, buzz_retail__StartCall__c = true, buzz_retail__IsMobile__c = true);
        insert call;
        
        String soqlQuery = 'SELECT Id'
                                + ' FROM buzz_retail__call__c'
                                + ' WHERE buzz_retail__StartCall__c = true'
                                + ' AND buzz_retail__EndCall__c = false'
                                + ' AND buzz_retail__DoComplete__c = false' // some calls in Labatt prod are in 'Completed' status but not ended and hence this condition
                                + ' AND buzz_retail__Date__c < TODAY' // retrieve calls that were started before 11:59 PM the previous day
                                //+ ' AND Owner.IsActive = true' // if calls are retrieved for inactive owner the processing fails with error 'operation performed with inactive user'
                                + ' AND buzz_retail__IsMobile__c = true';
        buzz_retail__Call__c retrievedcall = Database.query(soqlQuery);
        system.assertEquals(retrievedcall.Id, call.Id);
        
        
        // run batch
        Test.startTest();
        Database.executeBatch(new EndCallBatch(), 1);
        Test.stopTest();
 
        buzz_retail__Call__c call1 = [SELECT buzz_retail__StartCall__c, buzz_retail__EndCall__c, buzz_retail__Date__c, buzz_retail__End__c, buzz_retail__IsMobile__c, buzz_retail__DoComplete__c FROM buzz_retail__Call__c WHERE Id =: call.Id];
        
        // make assertions
        system.assert(call1.buzz_retail__DoComplete__c == true, 'call should be completed');
    }

    static testmethod void endCallWithIncompleteMustDoActionItems() {
        // set org call settings
        buzz_retail__OrgCallSettings__c orgCallSettings = CreateOrgCallSettings();
        upsert orgCallSettings;
        
        // create cip
        buzz_retail__CallInitializationParameters__c cip = CreateCallInitParamters();
        insert cip;
        
        // create account
        Account accountOutlet1 = SetupAccount();
        insert accountOutlet1 ;
        
        // create market
        buzz_retail__TG__c mtObj =  CreateMarketTargetTypeAccount();
        insert mtObj;
        
        // create targeted account
        buzz_retail__TGAC__c tgAcObj = CreateTargetedAccount(mtObj, accountOutlet1);
        insert tgAcObj;
        
        // create ai
        buzz_retail__ActionItem__c aiObj = CreateNewActionItem();
        aiObj.buzz_retail__Start_Date__c = Date.Today() -2;
        aiObj.buzz_retail__End_Date__c = Date.Today() + 30;
        aiObj.buzz_retail__MustDo__c = true;
        insert aiObj;
        
        // create aiTarget or else ai can't be approved
        buzz_retail__ActionItemTarget__c aiTargetObj = CreateActionItemTarget(aiObj, mtObj);
        aiTargetObj.buzz_retail__StartDate__c = Date.Today() - 2;
        aiTargetObj.buzz_retail__EndDate__c = Date.Today() + 30;
        insert aiTargetObj;
        
        // create aiAccount        
        buzz_retail__ActionItemAccount__c aiA = new buzz_retail__ActionItemAccount__c(buzz_retail__ActionItem__c=aiObj.id, 
                                                                    buzz_retail__Account__c=accountOutlet1.id,
                                                                    buzz_retail__StartDate__c = aiTargetObj.buzz_retail__StartDate__c, 
                                                                    buzz_retail__EndDate__c = aiTargetObj.buzz_retail__EndDate__c);
        insert aiA;
        
        // approve ai
        aiObj.buzz_retail__IsApproved__c = true;
        update aiObj;
        
        // create call
        DateTime startDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)); // prev day, so batch will pick it up
        DateTime endDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(9, 0, 0, 0)); // prev day, so batch will pick it up
        buzz_retail__Call__c call = new buzz_retail__Call__c(buzz_retail__Account__c = accountOutlet1.Id, buzz_retail__Date__c = startDate, buzz_retail__End__c = endDate, buzz_retail__Initialize__c = true, buzz_retail__StartCall__c = true, buzz_retail__IsMobile__c = true);
        insert call;
        
        // run batch
        Test.startTest();
        Database.executeBatch(new EndCallBatch(), 1);
        Test.stopTest();
 
        buzz_retail__Call__c callFromDB = [SELECT buzz_retail__StartCall__c, buzz_retail__EndCall__c, buzz_retail__Date__c, buzz_retail__End__c, buzz_retail__IsMobile__c, buzz_retail__DoComplete__c, buzz_retail__CallStatus__c FROM buzz_retail__Call__c WHERE Id =: call.Id];
        
        // make assertions
        system.assert(callFromDB.buzz_retail__DoComplete__c == false, 'call should not be completed');
        system.assert(callFromDB.buzz_retail__CallStatus__c == 'New', 'call status should be New');
        
    }

    static testmethod void endCallWithCompletedMustDoActionItems() {
        // set org call settings
        buzz_retail__OrgCallSettings__c orgCallSettings = CreateOrgCallSettings();
        upsert orgCallSettings;
        
        // create cip
        buzz_retail__CallInitializationParameters__c cip = CreateCallInitParamters();
        insert cip;
        
        // create account
        Account accountOutlet1 = SetupAccount();
        insert accountOutlet1 ;
        
        // create market
        buzz_retail__TG__c mtObj =  CreateMarketTargetTypeAccount();
        insert mtObj;
        
        // create targeted account
        buzz_retail__TGAC__c tgAcObj = CreateTargetedAccount(mtObj, accountOutlet1);
        insert tgAcObj;
        
        // create ai
        buzz_retail__ActionItem__c aiObj = CreateNewActionItem();
        aiObj.buzz_retail__Start_Date__c = Date.Today() -2;
        aiObj.buzz_retail__End_Date__c = Date.Today() + 30;
        aiObj.buzz_retail__MustDo__c = true;
        insert aiObj;
        
        // create aiTarget or else ai can't be approved
        buzz_retail__ActionItemTarget__c aiTargetObj = CreateActionItemTarget(aiObj, mtObj);
        aiTargetObj.buzz_retail__StartDate__c = Date.Today() - 2;
        aiTargetObj.buzz_retail__EndDate__c = Date.Today() + 30;
        insert aiTargetObj;
        
        // create aiAccount        
        buzz_retail__ActionItemAccount__c aiA = new buzz_retail__ActionItemAccount__c(buzz_retail__ActionItem__c=aiObj.id, 
                                                                    buzz_retail__Account__c=accountOutlet1.id,
                                                                    buzz_retail__StartDate__c = aiTargetObj.buzz_retail__StartDate__c, 
                                                                    buzz_retail__EndDate__c = aiTargetObj.buzz_retail__EndDate__c);
        insert aiA;
        
        // approve ai
        aiObj.buzz_retail__IsApproved__c = true;
        update aiObj;
        
        // create call
        DateTime startDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)); // prev day, so batch will pick it up
        DateTime endDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(9, 0, 0, 0)); // prev day, so batch will pick it up
        buzz_retail__Call__c call = new buzz_retail__Call__c(buzz_retail__Account__c = accountOutlet1.Id, buzz_retail__Date__c = startDate, buzz_retail__End__c = endDate, buzz_retail__Initialize__c = true, buzz_retail__StartCall__c = true, buzz_retail__IsMobile__c = true);
        insert call;
        
        // complete must do action items
        buzz_retail__ActionItem_Answer__c aiAns = [SELECT Id, Name, buzz_retail__Answer__c, buzz_retail__Done__c FROM buzz_retail__ActionItem_Answer__c WHERE buzz_retail__Call__c =: call.Id];
        aiAns.buzz_retail__ValueYesNo__c = 'Yes';
        aiAns.buzz_retail__Done__c = true;
        update aiAns;
        
        // run batch
        Test.startTest();
        Database.executeBatch(new EndCallBatch(), 1);
        Test.stopTest();
 
        buzz_retail__Call__c call1 = [SELECT buzz_retail__StartCall__c, buzz_retail__EndCall__c, buzz_retail__Date__c, buzz_retail__End__c, buzz_retail__IsMobile__c, buzz_retail__DoComplete__c FROM buzz_retail__Call__c WHERE Id =: call.Id];
        
        // make assertions
        system.assert(call1.buzz_retail__DoComplete__c == true, 'call should be completed');
    }


    static testmethod void endCallWithNoActionItems() {
        // set org call settings
        buzz_retail__OrgCallSettings__c orgCallSettings = CreateOrgCallSettings();
        upsert orgCallSettings;
        
        // create cip
        buzz_retail__CallInitializationParameters__c cip = CreateCallInitParamters();
        insert cip;
        
        // create account
        Account accountOutlet1 = SetupAccount();
        insert accountOutlet1 ;
        
        // create market
        buzz_retail__TG__c mtObj =  CreateMarketTargetTypeAccount();
        insert mtObj;
        
        // create targeted account
        buzz_retail__TGAC__c tgAcObj = CreateTargetedAccount(mtObj, accountOutlet1);
        insert tgAcObj;
        
        // create call
        DateTime startDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(8, 0, 0, 0)); // prev day, so batch will pick it up
        DateTime endDate = DateTime.newInstance(System.today().addDays(-1), Time.newInstance(9, 0, 0, 0)); // prev day, so batch will pick it up
        buzz_retail__Call__c call = new buzz_retail__Call__c(buzz_retail__Account__c = accountOutlet1.Id, buzz_retail__Date__c = startDate, buzz_retail__End__c = endDate, buzz_retail__Initialize__c = true, buzz_retail__StartCall__c = true, buzz_retail__IsMobile__c = true);
        insert call;
        
        // run batch
        Test.startTest();
        Database.executeBatch(new EndCallBatch(), 1);
        Test.stopTest();
 
        buzz_retail__Call__c call1 = [SELECT buzz_retail__StartCall__c, buzz_retail__EndCall__c, buzz_retail__Date__c, buzz_retail__End__c, buzz_retail__IsMobile__c, buzz_retail__DoComplete__c FROM buzz_retail__Call__c WHERE Id =: call.Id];
        
         // make assertions
        system.assert(call1.buzz_retail__DoComplete__c == true, 'call should be completed');
    }

    public static buzz_retail__OrgCallSettings__c CreateOrgCallSettings() {
        buzz_retail__OrgCallSettings__c orgCallSettings = buzz_retail__OrgCallSettings__c.getOrgDefaults();
        if (orgCallSettings == null) {
            orgCallSettings = new buzz_retail__OrgCallSettings__c();
        }
        orgCallSettings.buzz_retail__CompleteOnCallEnd__c = true;
        return orgCallSettings;
    }
    
    public static buzz_retail__CallInitializationParameters__c CreateCallInitParamters() {
        return new buzz_retail__CallInitializationParameters__c(Name='cip1', buzz_retail__UserRoles__c = getUserObj().buzz_retail__User_role__c, buzz_retail__IsActive__c = true, buzz_retail__Do_Not_Initialize_Action_Items_in_Calls__c = false);
    }
    
    public static Account SetupAccount(){
        /*Account accParent = (Account)db.ins(new Account(Name='Parent', RecordTypeId=AccountRecord.sRECTYPE_CUSTOMER));*/
        
        // get record id for outlet
        RecordType recTypeOutlet = [Select Id, Name, DeveloperName, isActive, sObjectType From RecordType where sObjectType= 'Account' AND Name = 'Outlet'];
        return new Account(Name='Outlet1', RecordTypeId = recTypeOutlet.Id);
    }
    
    public static buzz_retail__ActionItem__c CreateNewActionItem() {
        return new buzz_retail__ActionItem__c(Name='AI1', buzz_retail__Type__c='Task', buzz_retail__AnswerType__c = 'Yes/No', buzz_retail__TargetUserRole__c = getUserObj().buzz_retail__User_role__c);
    }
    
    public static buzz_retail__TG__c CreateMarketTargetTypeAccount(){
        return new buzz_retail__TG__c(Name = 'Target1');
    }

    public static buzz_retail__ActionItemTarget__c CreateActionItemTarget(buzz_retail__ActionItem__c aiRec, buzz_retail__TG__c mtRec){
        return new buzz_retail__ActionItemTarget__c(buzz_retail__MarketTarget__c = mtRec.Id, buzz_retail__ActionItem__c = aiRec.Id );
    }

    public static buzz_retail__TGAC__c CreateTargetedAccount(buzz_retail__TG__c mtRec, Account acRec){
        return new buzz_retail__TGAC__c(buzz_retail__Type__c = 'Manual', buzz_retail__TG__c = mtRec.id, buzz_retail__Account__c = acRec.id);
    }
    
    public static User getUserObj() {
        return [SELECT Id, Name, buzz_retail__User_Role__c FROM User WHERE Id =: UserInfo.getUserId()];
    }
    
}