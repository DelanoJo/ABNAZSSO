@isTest 
private class HistoricalReceiptPrintingCon_TEST {

        
      	
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
    

       
    static testMethod void myUnitTest() {
        
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

      
        
        M_Order_sigcap_Header__c TestOrder = new M_Order_sigcap_Header__c(
         RecordTypeId = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Direct_Store_Delivery),
         M_Status__c = 'Draft',
         M_AccountName__c = outlet.Id   
        );
        
        system.runas(admin){
            insert TestOrder;
        }
        
        Test.setCurrentPage(Page.OrderCloneRedirect);
        ApexPages.currentPage().getParameters().put('id', TestOrder.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(TestOrder);
        HistoricalReceiptPrintingCon con = new HistoricalReceiptPrintingCon(sc);
        con.close();
        HistoricalReceiptPrintingCon.loadHRP(TestOrder.Id);
        
    }
}