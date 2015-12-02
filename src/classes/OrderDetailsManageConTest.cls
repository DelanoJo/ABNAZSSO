@isTest
private class OrderDetailsManageConTest {
    
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
    

       
    static testMethod void createOrderDetailsForOrderDSD() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        System.debug('profile Id : '+profiles.get('System Administrator'));
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        //Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true, RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000);
        
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true, RecordTypeId=RecType.getRecordTypeId('Account','Distribution Center with Inventory'),M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000);

		
		
		insert distributor;
		
        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id);
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
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
        ipInsertList.add(ip1);
        M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-2, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-2, 
                            M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE);
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
            insert TestOrder;
        }
        
        Test.setCurrentPage(Page.OrderDetailsManagePage);
        ApexPages.currentPage().getParameters().put('id', TestOrder.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(TestOrder);
        OrderDetailsManageCon con = new OrderDetailsManageCon(sc);
        system.debug('selectedItemPriceIdString'+ ipInsertedList[0].id);
        con.selectedPriceItemIdString = ipInsertedList[0].id;
        
        Test.startTest();
        List<M_Item_Price__c> ListOfAvailableItemPrices = new List<M_Item_Price__c> (OrderDetailsManageCon.loadItemPrices(TestOrder.id));
        boolean found = false;
        /*
        for (M_Item_Price__c thisProduct : ipInsertList) {
            for (M_Item_Price__c thisAvailableProduct : ListOfAvailableItemPrices) {
                if (thisProduct.Id == thisAvailableProduct.Id)
                found = true;
            }
            system.assert (found == true, 'The list of available products is not visible and should be.');
        }
        */
        //add order details
        con.addOrderItems();
        
        //List<M_Order_Detail__c> order
        
        boolean a = con.IsOrder;
        a = con.IsReturn;
        //List<M_Item_Price__c> itemPricesReturned = con.
        
       //system.assert(itemPricesReturned.size(),ipInsertList.size());
        String str = con.buttonName;
        String str1 = con.nameSpace;
        
        PageReference p = con.Close();
        Test.stoptest();
    }
    
    static testMethod void createOrderDetailsForOrderSSR() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),M_Web_Receipt_Start__c=80000, 
                                M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000, M_Is_Inventory_Location__c = true );
        insert distributor;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id);
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
            buzz_retail__Product__c=p1.Id,
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
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
        ipInsertList.add(ip1);
        insert ipInsertList;
        
        List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
        system.debug('ipInsertedList:- '+ipInsertedList);
        
        M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_RDS),
         M_Status__c = 'Draft',
         M_AccountName__c = outlet.Id   
        );

        
        system.runAs(admin){
            insert TestOrder;
        }
        
        Test.setCurrentPage(Page.OrderDetailsManagePage);
        ApexPages.currentPage().getParameters().put('id', TestOrder.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(TestOrder);
        OrderDetailsManageCon con = new OrderDetailsManageCon(sc);
        system.debug('selectedItemPriceIdString'+ ipInsertedList[0].id);
        con.selectedPriceItemIdString = ipInsertedList[0].id;
        con.addOrderItems();//need to create appropriate data for receipt numbering, create DVw/ Inv
        
        boolean a = con.IsOrder;
        a = con.IsReturn;
        //List<M_Item_Price__c> itemPricesReturned = con.
        
       //system.assert(itemPricesReturned.size(),ipInsertList.size());
        String str = con.buttonName;
        String str1 = con.nameSpace;
        PageReference p = con.Close();
    }
    
    static testMethod void createOrderDetailsForReturnsSSR() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000 );
        insert distributor;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id);
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
            buzz_retail__Product__c=p1.Id,
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
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
        ipInsertList.add(ip1);
        insert ipInsertList;
        
        List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
        system.debug('ipInsertedList:- '+ipInsertedList);
        
        M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_SSR_Van),
         M_Status__c = 'Draft',
         M_AccountName__c = outlet.Id   
        );
        
        system.runAs(admin){
            insert TestOrder;
        }
        
        M_Order_sigcap_Header__c orderCreated = [select id,M_Document_Number__c,M_Receipt_Number__c from M_Order_sigcap_Header__c where id =: TestOrder.id];
        System.assertEquals(orderCreated.M_Document_Number__c,distributor.M_Next_Receipt_Number_Web__c);
        System.assertEquals(orderCreated.M_Receipt_Number__c,'0021'+orderCreated.M_Document_Number__c+'RT' );
        
        Test.setCurrentPage(Page.OrderDetailsManagePage);
        ApexPages.currentPage().getParameters().put('id', TestOrder.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(TestOrder);
        OrderDetailsManageCon con = new OrderDetailsManageCon(sc);
        system.debug('selectedItemPriceIdString'+ ipInsertedList[0].id);
        con.selectedPriceItemIdString = ipInsertedList[0].id;
        con.addOrderItems();//need to create appropriate data for receipt numbering, create DVw/ Inv
        
        boolean a = con.IsOrder;
        a = con.IsReturn;
        //List<M_Item_Price__c> itemPricesReturned = con.
        
       //system.assert(itemPricesReturned.size(),ipInsertList.size());
        String str = con.buttonName;
        String str1 = con.nameSpace;
        PageReference p = con.Close();
    }
    
    static testMethod void createOrderDetailsForReturnsRDC() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Standard User' or name ='System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = CreateUserForProfile(profiles.get('System Administrator'));
        insert admin;
            
        Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory),M_Web_Receipt_Start__c=80000, M_Web_Receipt_End__c=99999, M_Route_Number__c=0021, M_Next_Receipt_Number_Web__c=80000 );
        insert distributor;

        M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id);
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
            buzz_retail__Product__c=p1.Id,
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
                            M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
        ipInsertList.add(ip1);
        insert ipInsertList;
        
        List<M_Item_Price__c> ipInsertedList = [select id, M_Allow_Inventory__c,M_Active_for_Order__c, M_Active_for_Returns__c from M_Item_Price__c where id in:ipInsertList];
        system.debug('ipInsertedList:- '+ipInsertedList);
        
        M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Customer_Return_to_RDS),
         M_Status__c = 'Draft',
         M_AccountName__c = outlet.Id   
        );
        
        system.runAs(admin){
            insert TestOrder;
        }
        
        M_Order_sigcap_Header__c orderCreated = [select id,M_Document_Number__c,M_Receipt_Number__c from M_Order_sigcap_Header__c where id =: TestOrder.id];
        System.assertEquals(orderCreated.M_Document_Number__c,distributor.M_Next_Receipt_Number_Web__c);
        System.assertEquals(orderCreated.M_Receipt_Number__c,'0021'+orderCreated.M_Document_Number__c+'RB' );
        
        Test.setCurrentPage(Page.OrderDetailsManagePage);
        ApexPages.currentPage().getParameters().put('id', TestOrder.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(TestOrder);
        OrderDetailsManageCon con = new OrderDetailsManageCon(sc);
        system.debug('selectedItemPriceIdString'+ ipInsertedList[0].id);
        con.selectedPriceItemIdString = ipInsertedList[0].id;
        con.addOrderItems();//need to create appropriate data for receipt numbering, create DVw/ Inv
        
        boolean a = con.IsOrder;
        a = con.IsReturn;
        //List<M_Item_Price__c> itemPricesReturned = con.
        
       //system.assert(itemPricesReturned.size(),ipInsertList.size());
        String str = con.buttonName;
        String str1 = con.nameSpace;
        PageReference p = con.Close();
    }
    
    
    
    
}