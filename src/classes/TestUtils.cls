/**
 This class contains nessesary steps for test classes
 
 Created by Minh-Dien Le @ 04-Sept-2013
 Modified by:
 - Name@Date
 - Reasons
 - Descriptions
 */
@isTest
public class TestUtils {
	
	//Test User profile
	//e.g User testAdminUser = createTestUserWithProfile('System Administrator');
	public static User createTestUserWithProfile(String profileName){
		
		Profile testProfile = [select id from Profile where name =: profileName limit 1];
		
		User testUser = new User(alias ='standt', 
			email='buzztest@retailbuzz.com', 
			emailencodingkey='UTF-8', 
			lastname='Testing', 
			languagelocalekey='en_US', 
			localesidkey='en_US', 
			profileid = testProfile.Id, 
			timezonesidkey='America/Los_Angeles',
			M_Order_Inventory_Account__c = 0021, 
			username='buzztest@retailbuzz.com');
		
		return testUser;
	}

	//Test account
	//Return Account object
	//e.g Account testAccount = TestUtils.createTestAccount('Test Account','Customer',null);
    public static Account createTestAccount(String AccountName, String AccountType, id ParentId) {
    	
    	Account testAccount = new Account();
    	
    	//assign test name
    	testAccount.Name = AccountName;
    	
    	//check if there is parent
    	if (ParentId!=null){
    		testAccount.ParentId = ParentId;
    	}
		
		
		//assign nessesary required values  	
    	if(AccountType=='Customer'){
  			testAccount.RecordTypeId = getRecordTypeId('Account','Customer');
    	}else if (AccountType=='Outlet'){
    		testAccount.RecordTypeId = getRecordTypeId('Account','Outlet');	 	
    	}else if (AccountType=='Distribution Center'){
    		testAccount.RecordTypeId = getRecordTypeId('Account','Distribution Center');	
    	}else if (AccountType=='Distribution Center with Inventory'){
    	    testAccount.buzz_retail__Distributor_Type__c = 'SSR';
    	    testAccount.buzz_retail__Account_ID__c = '121212';
            testAccount.buzz_retail__IsActive__c = true;
            testAccount.M_Is_Inventory_Location__c = true;
            testAccount.M_Is_Inventory_Return__c = true;
            testAccount.M_Route_Number__c = 9999;
            testAccount.RecordTypeId = getRecordTypeId('Account','Distribution Center with Inventory');    	
    	}else if (AccountType=='Manufacturer'){
    		testAccount.RecordTypeId = getRecordTypeId('Account','Manufacturer');  	
    	}else if (AccountType=='Territory'){
    		testAccount.RecordTypeId = getRecordTypeId('Account','Territory');
    	}
    	   	
      	return testAccount;
    }
    
    //Test inventory location
    //Return M_Inventory_Location__c object
    public static M_Inventory_Location__c createTestInventoryLocation(String locationName, Id accountId, Boolean isDisbursement, Boolean isReception){
		M_Inventory_Location__c invLocation = new M_Inventory_Location__c();
		invLocation.Name = locationName;
		invLocation.M_Distributor__c = accountId;
		invLocation.Default_Disbursement_Location__c = isDisbursement;
		return invLocation;    	
    }
    
    //Test product list
    //Return List<buzz_retail__Product__c>
    public static List<buzz_retail__Product__c> createTestProductList(Integer listSize){
    	
    	List<buzz_retail__Product__c> prodLists = new List<buzz_retail__Product__c>();
    	for(Integer n=0; n < listSize; n++){
    		
    		//M_Merck_Product_Code__c='00000000000000000'+String.ValueOf(n),
    		buzz_retail__Product__c p = new buzz_retail__Product__c(Name ='Product number '+String.ValueOf(n),
  																M_AllowInventory__c = true, 
  																M_Allow_Returns__c=true,
  																buzz_retail__IsActive__c=true,
  																buzz_retail__Allow_Ordering__c=true,
  																buzz_retail__UPC_Code__c='00000000000000000'+String.ValueOf(n), 
  																RecordTypeId=getRecordTypeId('buzz_retail__Product__c', 'Item'));
  			prodLists.add(p);
    	
    	}
    	return prodLists;
    	
    }
    
    
    //*******************************************************************************
    //Utility methods
    
    // Get RecordType ID by Object Recordtype label
	// Returns Id of RecordType 
	// e.g ID RecordTypeId = getRecordTypeId('Account' , 'Record Type Label'); 
    public static id getRecordTypeId(String ObjectType, String RecordTypeLabel)  
    {   
		SObject OBJ;  
		// Describing Schema  
		Schema.SObjectType Res = Schema.getGlobalDescribe().get(ObjectType);  
		if (Res != null){  
			OBJ = Res.newSObject();  
	  		// Describing Object   
	  		Schema.DescribeSObjectResult DesRes = OBJ.getSObjectType().getDescribe();   
	  		if (DesRes != null){  
	    		Map<String, Schema.RecordTypeInfo> RecordTypeMap=DesRes.getRecordTypeInfosByName();  
	    		if (RecordTypeMap != null){  
	        		Schema.RecordTypeInfo RecordTypeRes = RecordTypeMap.get(RecordTypeLabel);  
	        		if (RecordTypeRes != null){  
	           			return RecordTypeRes.getRecordTypeId();  
	        		}  
	      		}  
	   		}  
   		}  
		return null;  
    }
    
}