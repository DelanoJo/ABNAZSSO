@isTest
private class OrderTriggerTest {  
    
    public static User CreateUserForProfile(Id pProfileId){
        return new User(alias ='standt', 
            email='buzztest@retailbuzz.com', 
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', 
            profileid = pProfileId, 
            timezonesidkey='America/Los_Angeles',
            M_Order_Inventory_Account__c = 0021, 
            username='buzztest@retailbuzz.com');
    }


   static testMethod void OrderTest_Warehouse() {
        
          final ID outletRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet);       
          final ID distributorRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);      
          final ID directStoreDeliveryRecTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery);
          
      //    Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Location__c = true,         
       //                 M_Route_Number__c = 9999,RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),
        //                buzz_retail__Distributor_Type__c = 'SSR', buzz_retail__Account_ID__c = '121212',buzz_retail__IsActive__c = true);
        //insert distributor;
        
          Account distributor = new Account(
            Name = 'Test Accoun 2',
            buzz_retail__Distributor_Type__c = 'SSR',
            buzz_retail__Account_ID__c = '121212',
            buzz_retail__IsActive__c = true, 
            M_Is_Inventory_Location__c = true,
            M_Is_Inventory_Return__c = true,
            M_DefaultReturnLocation__c = true,
            Phone = '5145145145',               
            RecordTypeId = distributorRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street2',
            ShippingCity = 'City2',
            ShippingState = 'State2',  
            ShippingPostalCode = 'PostalCode2',
            ShippingCountry = 'Country2',
            M_Route_Number__c = 9999);  
    
        insert distributor;
        
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;
        
          
         M_OPLI_Settings__c activeOPLI = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,M_Requested_Delivery_Days__c = 10,M_Default_DSC_Return_Account__c=distributor.id);
        insert activeOPLI;
          
                                                        
         Profile p = [select id from profile where name='System Administrator' OR name='Administrateur systÃ¨me'];     
          
          Account outletAccount = new Account(
            Name = 'Test Account 1',
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',               
            RecordTypeId = outletRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            M_Route_Number__c = 8888);
    
        insert outletAccount;
        
        
        User TestUser = new User(
            Username = 'AryaTestUser@gmail.com',
            LastName = 'AryaTestUser',
            Email = 'test@gmail.com',
            CommunityNickname = 'test300',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            M_Order_Inventory_Account__c = 9999,
            Alias = 'test',
            LanguageLocaleKey = 'en_US');
        
        insert TestUser;
        
        
         map<Id,Account> accounts = new map<Id,Account>([select Id,Name,M_Route_Number__c, buzz_retail__Territory__c, buzz_retail__KAM_Territory_ID__c, buzz_retail__Account_ID__c,
                                                buzz_retail__Account_Record_Type_Display__c from Account]);
        
         map<Id,User> allUsers = new map<Id,User>([Select Id, M_Order_Inventory_Account__c from User]);  
                  
        //ORI-029
        M_Order_sigcap_Header__c TestOrder1 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Order',
         M_Inventory_TransactionType__c = 'None'   
        );
        
        Test.startTest();
        insert TestOrder1;
        
        TestOrder1 = [Select Id, M_Distributor__c from M_Order_sigcap_Header__c where Id =: TestOrder1.Id];
        
        System.assertEquals(TestOrder1.M_Distributor__c,activeOPLI.M_Default_DSC_Order_Account__c, 'Warehouse must be populate with OPLISettings.DefaultDSCOrderAccount');
        //---------------------------
                
        //ORI-031 
        M_Order_sigcap_Header__c TestOrder2 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Return',
         M_Inventory_TransactionType__c = 'None'   
        ); 
        
        insert TestOrder2;
        
        TestOrder2 = [Select Id, M_Distributor__c from M_Order_sigcap_Header__c where Id =: TestOrder2.Id];
        
        System.assertEquals(TestOrder2.M_Distributor__c,activeOPLI.M_Default_DSC_Return_Account__c, 'Warehouse must be populate with OPLISettings.DefaultDSCOrderAccount');
        //-----------------------------
        
         //ORI-030
         M_Order_sigcap_Header__c TestOrder3 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Order',
         M_Inventory_TransactionType__c = 'Order',
         OwnerId = TestUser.Id
        );
        
        insert TestOrder3;
        
        TestOrder3 = [Select M_Distributor__c from M_Order_sigcap_Header__c where Id=: TestOrder3.Id]; 
          
        if (activeOPLI.M_DefaultSSROrderSet__c)
             system.assertEquals(TestOrder3.M_Distributor__c,distributor.Id);
        //---------------------------
         //ORI-032
         M_Order_sigcap_Header__c TestOrder4 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Return',
         M_Inventory_TransactionType__c = 'Return',
         OwnerId = TestUser.Id
        );
        
        insert TestOrder4;
        
        TestOrder4 = [Select M_Distributor__c from M_Order_sigcap_Header__c where Id=: TestOrder4.Id]; 
          
        if (activeOPLI.M_DefaultSSROrderSet__c)
             system.assertEquals(TestOrder4.M_Distributor__c,distributor.Id);
        //---------------------------
        
        Test.stopTest();
        
                        
   }
   
   static testMethod void OrderTest_ShippingAddress() {
    
          final ID outletRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet);       
          final ID distributorRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);      
          final ID directStoreDeliveryRecTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery);
          final ID ReplenishmentId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Replenishment);
          
                                                        
         Profile p = [select id from profile where name='System Administrator' OR name='Administrateur systÃ¨me'];
         
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c=true,
                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
       insert distributor;
       
        
         
         M_OPLI_Settings__c activeOPLI = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                            M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                            M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,M_Requested_Delivery_Days__c = 10,M_Default_DSC_Order_Account__c=distributor.id);
        insert activeOPLI;
              
          
          Account outletAccount = new Account(
            Name = 'Test Account 1',
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',               
            RecordTypeId = outletRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            M_Route_Number__c = 2225);
    
        insert outletAccount;
        
          Account disAccount = new Account(
            Name = 'Test Accoun 2',
            buzz_retail__Distributor_Type__c = 'SSR',
            buzz_retail__Account_ID__c = '121212',
            buzz_retail__IsActive__c = true, 
            M_Is_Inventory_Location__c = true,
            Phone = '5145145145',               
            RecordTypeId = distributorRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street2',
            ShippingCity = 'City2',
            ShippingState = 'State2',
            ShippingPostalCode = 'PostalCode2',
            ShippingCountry = 'Country2',
            M_Route_Number__c = 4445);
    
        insert disAccount;
        
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outletAccount.Id,
            buzz_retail__Date__c = system.now()
        );
         insert call;
         
        User TestUser = new User(
            Username = 'AryaTestUser@gmail.com',
            LastName = 'AryaTestUser',
            Email = 'test@gmail.com',
            CommunityNickname = 'test300',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            M_Order_Inventory_Account__c = 4445,
            Alias = 'test',
            LanguageLocaleKey = 'en_US');
        
        insert TestUser;
        
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=disAccount.Id,
            Default_Disbursement_Location__c=true,
            M_Location_City__c ='location',
            M_Location_Street__c = 'Street',
            M_Location_Postal_Code_ZIP__c = 'zip',
            M_Location_State__c='State',
            M_Is_Warehouse__c = true
            
        );
        insert invLoca;

        //ORI-023
         M_Order_sigcap_Header__c TestOrder5 = new M_Order_sigcap_Header__c(
         RecordTypeId = ReplenishmentId,
         M_Status__c = 'Draft',
         M_AccountName__c = disAccount.Id,
         OwnerId = TestUser.Id,
         Inventory_Location__c = invLoca.id
        );
        
        Test.startTest();
        insert TestOrder5;
        
        
         M_Order_sigcap_Header__c TestOrder6 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         OwnerId = TestUser.Id,
         M_Order_Date__c = date.today()
         //Inventory_Location__c = invLoca.Id
        );
        
        insert TestOrder6;
                    
        TestOrder5 = [Select M_Shipping_Address__c,M_Shipping_City__c,M_Shipping_Country__c,M_Shipping_State__c,M_Shipping_ZIP_Postal_Code__c from M_Order_sigcap_Header__c where Id=: TestOrder5.Id]; 
        TestOrder6 = [Select M_Shipping_Address__c,M_Shipping_City__c,M_Shipping_Country__c,M_Shipping_State__c,M_Shipping_ZIP_Postal_Code__c from M_Order_sigcap_Header__c where Id=: TestOrder6.Id]; 
        
        system.assertEquals(TestOrder5.M_Shipping_Address__c,invLoca.M_Location_Street__c );
        system.assertEquals(TestOrder5.M_Shipping_City__c,invLoca.M_Location_City__c );
        system.assertEquals(TestOrder5.M_Shipping_State__c,invLoca.M_Location_State__c );
        system.assertEquals(TestOrder5.M_Shipping_ZIP_Postal_Code__c,  invLoca.M_Location_Postal_Code_ZIP__c );
        system.assertEquals(TestOrder5.M_Shipping_Country__c, null);                                            
        
        system.assertEquals(TestOrder6.M_Shipping_City__c, outletAccount.ShippingCity); 
        system.assertEquals(TestOrder6.M_Shipping_Address__c, outletAccount.ShippingStreet );
        system.assertEquals(TestOrder6.M_Shipping_Country__c, outletAccount.ShippingCountry);
        system.assertEquals(TestOrder6.M_Shipping_ZIP_Postal_Code__c, outletAccount.ShippingPostalCode);
        system.assertEquals(TestOrder6.M_Shipping_State__c,outletAccount.ShippingState );
        
        Test.stopTest();
   }
   
   static testMethod void OrderTest_OrderDate()
   {
          final ID outletRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet);       
          final ID distributorRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);      
          final ID directStoreDeliveryRecTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery);
                 
                                                        
         Profile p = [select id from profile where name='System Administrator' OR name='Administrateur systÃ¨me'];
         
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c=true,
                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
       insert distributor;
       
        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;
              
         M_OPLI_Settings__c activeOPLI = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,M_Requested_Delivery_Days__c = 10,M_Default_DSC_Order_Account__c=distributor.id);
        insert activeOPLI;
          
          Account outletAccount = new Account(
            Name = 'Test Account 1',
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',               
            RecordTypeId = outletRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            M_Route_Number__c = 2222);
    
        insert outletAccount;
        
          Account disAccount = new Account(
            Name = 'Test Accoun 2',
            buzz_retail__Distributor_Type__c = 'SSR',
            buzz_retail__Account_ID__c = '121212',
            buzz_retail__IsActive__c = true, 
            M_Is_Inventory_Location__c = true,
            Phone = '5145145145',               
            RecordTypeId = distributorRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street2',
            ShippingCity = 'City2',
            ShippingState = 'State2',
            ShippingPostalCode = 'PostalCode2',
            ShippingCountry = 'Country2',
            M_Route_Number__c = 4444);
    
        insert disAccount;
        
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outletAccount.Id,
            buzz_retail__Date__c = system.now()
        );
         insert call;
         
        User TestUser = new User(
            Username = 'AryaTestUser@gmail.com',
            LastName = 'AryaTestUser',
            Email = 'test@gmail.com',
            CommunityNickname = 'test300',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            M_Order_Inventory_Account__c = 4444,
            Alias = 'test',
            LanguageLocaleKey = 'en_US');
        
        insert TestUser;
        
        
         M_Order_sigcap_Header__c TestOrder7 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Order',
         M_Inventory_TransactionType__c = 'None',
         OwnerId = TestUser.Id,
         M_Call__c = null
        );
        
        insert TestOrder7;
        
         M_Order_sigcap_Header__c TestOrder8 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Order',
         M_Inventory_TransactionType__c = 'None',
         OwnerId = TestUser.Id,
         M_Call__c = call.Id
        );
        
        Test.startTest();
        insert TestOrder8;
        
        TestOrder7 = [Select M_Order_Date__c from M_Order_sigcap_Header__c where Id=: TestOrder7.Id]; 
        //ORI-014
        System.assertEquals(TestOrder7.M_Order_Date__c, date.today());
    
        TestOrder8 = [Select M_Order_Date__c from M_Order_sigcap_Header__c where Id=: TestOrder8.Id];
        //ORI-015 
        System.assertEquals(TestOrder8.M_Order_Date__c, call.buzz_retail__Date__c.date());
        
        Test.stopTest();
   }
   
   static testMethod void OrderTest_RequestedDeliveryDate()
   {
          final ID outletRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet);       
          final ID distributorRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);      
          final ID directStoreDeliveryRecTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery);
          
                                                        
         Profile p = [select id from profile where name='System Administrator' OR name='Administrateur systÃ¨me'];

        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c=true,
                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
       insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;
         
         M_OPLI_Settings__c activeOPLI = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,M_Requested_Delivery_Days__c = 10,M_Default_DSC_Order_Account__c=distributor.id);
        insert activeOPLI;
     
          Integer RDD = Integer.valueOf(activeOPLI.M_Requested_Delivery_Days__c);
              
          
          Account outletAccount = new Account(
            Name = 'Test Account 1',
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',               
            RecordTypeId = outletRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            M_Route_Number__c = 2221);
    
        insert outletAccount;
        
          Account disAccount = new Account(
            Name = 'Test Accoun 2',
            buzz_retail__Distributor_Type__c = 'SSR',
            buzz_retail__Account_ID__c = '121212',
            buzz_retail__IsActive__c = true, 
            M_Is_Inventory_Location__c = true,
            Phone = '5145145145',               
            RecordTypeId = distributorRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street2',
            ShippingCity = 'City2',
            ShippingState = 'State2',
            ShippingPostalCode = 'PostalCode2',
            ShippingCountry = 'Country2',
            M_Route_Number__c = 4441);
    
        insert disAccount;
        
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outletAccount.Id,
            buzz_retail__Date__c = system.now()
        );
         insert call;
         
        User TestUser = new User(
            Username = 'AryaTestUser@gmail.com',
            LastName = 'AryaTestUser',
            Email = 'test@gmail.com',
            CommunityNickname = 'test300',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            M_Order_Inventory_Account__c = 4441,
            Alias = 'test',
            LanguageLocaleKey = 'en_US');
        
        insert TestUser;

         M_Order_sigcap_Header__c TestOrder9 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         OwnerId = TestUser.Id,      
         M_Call__c = null
         
        );
        
        Test.startTest();
        insert TestOrder9;
        
        TestOrder9 = [Select M_Order_Date__c, M_Required_Delivery_Date__c from M_Order_sigcap_Header__c where Id=: TestOrder9.Id];
        system.debug('TestOrder9'+TestOrder9);

        
        //ORI-015 & ORI-016     
        system.assert(TestOrder9.M_Required_Delivery_Date__c >= TestOrder9.M_Order_Date__c.addDays(RDD), 'The requested delivery date must be ' + RDD + ' days later than the Order Date');
        
        Test.stopTest();
    
    }
   
    static testMethod void OrderTest_Stamp()
    {
          final ID outletRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet);       
          final ID distributorRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);      
          final ID directStoreDeliveryRecTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery);
          
                                                        
         Profile p = [select id from profile where name='System Administrator' OR name='Administrateur systÃ¨me'];

        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c=true,
                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
       insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;
         
         M_OPLI_Settings__c activeOPLI = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,M_Requested_Delivery_Days__c = 10,M_Default_DSC_Order_Account__c=distributor.id);
        insert activeOPLI;
          
          Account outletAccount = new Account(
            Name = 'Last Test Account 1',
            buzz_retail__Account_ID__c = '121212',          
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',               
            RecordTypeId = outletRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            //M_Route_Number__c = 6363,
            buzz_retail__KAM_Territory_ID__c = '11',
            buzz_retail__Territory__c = '12'
            );
    
        insert outletAccount;
        
        User TestUser = new User(
            Username = 'AryaTestUser@gmail.com',
            LastName = 'AryaTestUser',
            Email = 'test@gmail.com',
            CommunityNickname = 'test300',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            M_Order_Inventory_Account__c = 7272,
            Alias = 'test',
            LanguageLocaleKey = 'en_US');
        
        insert TestUser;

         M_Order_sigcap_Header__c TestOrder10 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Order',
         M_Inventory_TransactionType__c = 'Order',
         OwnerId = TestUser.Id,      
         M_Call__c = null
         
        );
        
        insert TestOrder10;
        
        Test.startTest();
        
        TestOrder10 = [Select M_Kam_Territory_Stamp__c,M_Territory_Stamp__c,M_Account_ID_Stamp__c, M_Account_Name_Stamp__c,M_DC_Name_Stamp__c  from M_Order_sigcap_Header__c where Id=: TestOrder10.Id];
        
        //ORI-025
        system.assert(TestOrder10.M_Territory_Stamp__c == outletAccount.buzz_retail__Territory__c);
        //ORI-026
        system.assert(TestOrder10.M_Account_ID_Stamp__c == outletAccount.buzz_retail__Account_ID__c);
        //ORI-028
        system.assert(TestOrder10.M_Account_Name_Stamp__c == outletAccount.Name + ' ' + TestOrder10.M_Account_ID_Stamp__c + ' ' + TestOrder10.M_DC_Name_Stamp__c);
            
        Test.stopTest();
    
    } 
    
    static testMethod void OrderTest_SoldTo_Call()
    {
          final ID outletRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Outlet);       
          final ID distributorRecTypeId = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);      
          final ID directStoreDeliveryRecTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery);
          
                                                        
         Profile p = [select id from profile where name='System Administrator' OR name='Administrateur systÃ¨me'];
         
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c=true,
                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
       insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;
         
         M_OPLI_Settings__c activeOPLI = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,M_Requested_Delivery_Days__c = 10,M_Default_DSC_Order_Account__c=distributor.id);
        insert activeOPLI;
                  
          Account outletAccount = new Account(
            Name = 'Test Account 1',
            buzz_retail__IsActive__c = true, 
            Phone = '5145145145',               
            RecordTypeId = outletRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street1',
            ShippingCity = 'City1',
            ShippingState = 'State1',
            ShippingPostalCode = 'PostalCode1',
            ShippingCountry = 'Country1',
            M_Route_Number__c = 2221);
    
        insert outletAccount;
        
          Account disAccount = new Account(
            Name = 'Test Accoun 2',
            buzz_retail__Distributor_Type__c = 'SSR',
            buzz_retail__Account_ID__c = '121212',
            buzz_retail__IsActive__c = true, 
            M_Is_Inventory_Location__c = true,
            Phone = '5145145145',               
            RecordTypeId = distributorRecTypeId,
            BillingCity = 'Montreal', 
            BillingCountry = 'Canada', 
            BillingPostalCode = 'H1H 1H1', 
            BillingState = 'Quebec', 
            BillingStreet = 'Cote Vertu',
            ShippingStreet = 'Street2',
            ShippingCity = 'City2',
            ShippingState = 'State2',
            ShippingPostalCode = 'PostalCode2',
            ShippingCountry = 'Country2',
            M_Route_Number__c = 4441);
    
        insert disAccount;
        
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outletAccount.Id,
            buzz_retail__Date__c = system.now()
        );
         insert call;
         
        User TestUser = new User(
            Username = 'AryaTestUser@gmail.com',
            LastName = 'AryaTestUser',
            Email = 'test@gmail.com',
            CommunityNickname = 'test300',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_CA',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = p.Id,
            M_Order_Inventory_Account__c = 4441,
            Alias = 'test',
            LanguageLocaleKey = 'en_US');
        
        insert TestUser;

         M_Order_sigcap_Header__c TestOrder11 = new M_Order_sigcap_Header__c(
         RecordTypeId = directStoreDeliveryRecTypeId,
         M_Status__c = 'Draft',
         M_AccountName__c = outletAccount.Id,
         M_Order_Transaction_Type__c = 'Order',
         M_Inventory_TransactionType__c = 'None',
         OwnerId = TestUser.Id,    
         M_Is_Mobile__c = false,     
         M_Call__c = call.Id
        );
        
        insert TestOrder11;
        
        Test.startTest();
        
        TestOrder11 = [Select M_Call__c, M_AccountName__c from M_Order_sigcap_Header__c where Id=: TestOrder11.Id];
        //ORI-034
        System.assert(call.buzz_retail__Account__c  == TestOrder11.M_AccountName__c);
        
        Test.stopTest();
    }
    
    static testMethod void AutomatedOrderDetailsCreationForOrderDSD() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_DefaultOrderLocation__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, 
                                M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Cancelled_Order_Status__c ='Cancelled',M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = GPcustomer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
        
        List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
        system.debug('ipInsertedList:- '+ipInsertedList);
        
        M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
                                        RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery),
                                        M_Status__c = 'Draft',
                                        M_AccountName__c = outlet.Id   
                                        );
        
        system.runas(admin){
            Test.startTest();
            insert TestOrder;
        }
        
        List<M_Order_Detail__c> orderDetailsCreated = [select id from M_Order_Detail__c where M_Order__c =:TestOrder.id];
        system.assertEquals(orderDetailsCreated.size(),2);
        
        TestOrder.M_Status__c = 'Cancelled';
        update TestOrder;
        Test.stoptest();
        
        M_Order_sigcap_Header__c OrderUpdated = [select id, M_CancelledOrder__c from  M_Order_sigcap_Header__c where id =:TestOrder.id limit 1];
        system.assertEquals(OrderUpdated.M_CancelledOrder__c , true);
        List<M_Order_Detail__c> orderDetailsUpdated = [select id, M_Qty_Ordered__c from M_Order_Detail__c where M_Order__c =:TestOrder.id];
        
        for(M_Order_Detail__c od : orderDetailsUpdated){
            system.assertEquals(od.M_Qty_Ordered__c,0);
        }
    }
    
    static testMethod void AutomatedOrderDetailsCreationForOrderSSR() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,M_DefaultOrderLocation__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000, M_Is_Inventory_Location__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Cancelled_Order_Status__c ='Cancelled',M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        

        M_Price_List__c priceList = new M_Price_List__c();//pricelist at first customer level
        priceList.M_Account__c = Pcustomer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
        
        List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
        system.debug('ipInsertedList:- '+ipInsertedList);
            
        //Insert Inventory Capture Transaction
        M_Inventory_Transaction__c newInvCapture = new M_Inventory_Transaction__c(
            RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType, RecType.Name.Inventory_Capture),
            M_Distributor__c=distributor.id,
            M_Inventory_Location__c=invLoca.id, M_Status__c='draft'
        );
        insert newInvCapture;
        
        M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.DSD_from_SSR_Van),
         M_Status__c = 'Draft',
         M_AccountName__c = outlet.Id   
        );
        
        system.runas(admin){
            Test.startTest();
            insert TestOrder;
        }
        
        
        List<M_Transaction_Item__c> itemsCreated = [select id from M_Transaction_Item__c where M_Inventory_Transaction__c =: newInvCapture.id];
        for(M_Transaction_Item__c ti: itemsCreated){
            ti.M_Original_Qty__c = 2;
        }
        update itemsCreated;
        
        newInvCapture.M_Status__c ='Final';
        update newInvCapture;
        Test.stoptest();
        
        List<M_Order_Detail__c> orderDetailsCreated = [select id, M_Inventory__c from M_Order_Detail__c where M_Order__c =:TestOrder.id];
        system.assertEquals(orderDetailsCreated.size(),2);
        for(M_Order_Detail__c od: orderDetailsCreated){
            system.assertNotEquals(od.M_Inventory__c, null);
        }
    }
    
    static testmethod void OrderTest_DeleteDetails()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final', 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli; 
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
                
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outlet.Id,
            buzz_retail__Date__c = system.now()
        );
        insert call;
        
        M_Order_sigcap_Header__c DSDOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
                
        Test.startTest();
                
        system.runas(admin){
            
            insert DSDOrder;
            
            List<M_Order_Detail__c> orderDetailList = [select Id, M_Qty_Ordered__c from M_Order_Detail__c where M_Order__c =:DSDOrder.id and M_Qty_Ordered__c=1];
            
            System.assert(orderDetailList.size() > 0);
            
            for (M_Order_Detail__c od:orderDetailList)
                od.M_Qty_Ordered__c = 0;
                
            update orderDetailList;
            
            //DSDOrder.M_Status__c = 'Final';
            //update DSDOrder;
            
        }
        
        //Integer num = [select count() from M_Order_Detail__c where M_Order__c =:DSDOrder.id];
        //system.debug('\n\n=====================================================\n\n');
        //system.debug(num);
        //system.assertEquals(num, 0);
            
        
        Test.stoptest();
    } 
    
        static testmethod void OrderTest_FinalStatus1()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        Test.startTest();
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final', 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
        
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outlet.Id,
            buzz_retail__Date__c = system.now()
        );
        insert call;
        
        M_Order_sigcap_Header__c DSDOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
        
        M_Order_sigcap_Header__c COFSOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Order_from_SSR),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
        
         M_Order_sigcap_Header__c CRTROrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Returns_to_RDC),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
        
        M_Order_sigcap_Header__c CRTSOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Returns_to_SSR),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );

                
        system.runas(admin){
            
            insert DSDOrder;
                        
            DSDOrder.M_Status__c = 'Final';
            update DSDOrder;
            
        }
                
        M_Order_sigcap_Header__c finalOrder1 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:DSDOrder.id];
        system.assertEquals(finalOrder1.M_FinalOrder__c,true);
                
        Test.stoptest();
    }   

    /*
    static testmethod void OrderTest_FinalStatus2()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        Test.startTest();
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultOrderLocation__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final',M_DefaultSSROrderSet__c = true, 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Order_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
                
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outlet.Id,
            buzz_retail__Date__c = system.now()
        );
        insert call;
        
        
        M_Order_sigcap_Header__c COFSOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Order_from_SSR),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
        
                
        system.runas(admin){
            
            insert COFSOrder;
                        
            COFSOrder.M_Status__c = 'Final';
            update COFSOrder;
            
        }
                
        
        M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:COFSOrder.id];
        system.assertEquals(finalOrder2.M_FinalOrder__c,true);
        
        
        Test.stoptest();
        
    }
    */
    
    /*
    static testmethod void OrderTest_FinalStatus3()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        Test.startTest();
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultReturnLocation__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final',M_DefaultSSROrderSet__c = true, 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Return_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
                
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outlet.Id,
            buzz_retail__Date__c = system.now()
        );
        insert call;
        
        
         M_Order_sigcap_Header__c CRTROrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Returns_to_RDC),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
        
                
        system.runas(admin){
            
            insert CRTROrder;
                        
            CRTROrder.M_Status__c = 'Final';
            update CRTROrder;
        }
                
        
        M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:CRTROrder.id];
        system.assertEquals(finalOrder2.M_FinalOrder__c,true);
        
        
        Test.stoptest();
        
    }
    static testmethod void OrderTest_FinalStatus4()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        Test.startTest();
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory), 
                                M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, 
                                M_Next_Receipt_Number_Web__c=80000,M_Is_Inventory_Location__c = true,M_DefaultReturnLocation__c = true );
        insert distributor;

        M_Inventory_Location__c invLoca=new M_Inventory_Location__c(
            Name='Test Location',
            M_Distributor__c=distributor.Id,
            Default_Disbursement_Location__c=true
        );
        insert invLoca;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id,Final_Order_Status_for_Orders_No_Invent__c ='Final',
                                    Final_Order_Status_for_Orders_w_Invent__c='Final', Final_Order_Status_for_Returns_No_Invent__c = 'Final',
                                    M_Final_Order_Status_for_Returns_w_Inven__c = 'Final',M_DefaultSSROrderSet__c = true, 
                                    M_Automated_Order_Details__c=true,M_Default_DSC_Return_Account__c=distributor.id);
        insert opli;
        Account GPcustomer = new Account(Name='GPcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer));
        insert GPcustomer;
        Account Pcustomer = new Account(Name='Pcustomer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =GPcustomer.id);
        insert Pcustomer;
        
        Account customer = new Account(Name='Customer 1', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Customer),ParentId =Pcustomer.id);
        insert customer;
        
        Account outlet = new Account(Name='Outlet A', RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Outlet), ParentId=customer.Id);
        insert outlet;
        system.debug('outlet id '+outlet +'distributor id' +distributor.Id);
        

        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_Account__c = customer.Id;
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Customer';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p1.Id,
            buzz_retail__FormatCode__c='Eaches',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
            
        prodFormatList.add(prodForm1);
        
        buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
            Name=p1.Name + 'Test',
            buzz_retail__Product__c=p2.Id,
            buzz_retail__FormatCode__c='Case',
            buzz_retail__Conversion_Cases__c = 0.1,
            buzz_retail__Conversion_Eaches__c = 1,
            M_Inventory__c = true,
            M_Active__c = true
            );
        prodFormatList.add(prodForm2);
        
        insert prodFormatList;
        
        List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE,Automated_Order_Item__c=true);
        ipInsertList.add(ip2);
        insert ipInsertList;
                
        buzz_retail__Call__c call = new buzz_retail__Call__c(
            Name = 'Test Call',
            buzz_retail__Account__c = outlet.Id,
            buzz_retail__Date__c = system.now()
        );
        insert call;
        
        
        M_Order_sigcap_Header__c CRTSOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Returns_to_SSR),
         M_Status__c = 'Draft',
         M_Call__c = call.Id   
        );
        
                
        system.runas(admin){
            
            insert CRTSOrder;
                        
            CRTSOrder.M_Status__c = 'Final';
            update CRTSOrder;
        }
                
        
        M_Order_sigcap_Header__c finalOrder2 = [select id, M_FinalOrder__c from M_Order_sigcap_Header__c where id =:CRTSOrder.id];
        system.assertEquals(finalOrder2.M_FinalOrder__c,true);
        
        
        Test.stoptest();
        
    }
    */
}