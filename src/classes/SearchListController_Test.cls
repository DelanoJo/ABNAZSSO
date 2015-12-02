/***********************************************************************
 Class 			: SearchListController_Test
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Provide test coverage to SearchListController.cls
 ************************************************************************/
@isTest
private class SearchListController_Test {
	
	// Method to test search functionality
    static testMethod void testSearchListFunctionality() {
        
        createTestData();
        
        Test.startTest();
        
	        SearchListController controller = new SearchListController();
	        // Setting attributes for searching
	        controller.fieldsCSV = 'Name,NumberOfEmployees';
	        controller.sortDirection = 'asc';
	        controller.objectName = 'Account';
	        controller.pageSize = 5;
	        controller.searchFieldName = 'Name';
	        controller.searchFieldValue = 'Test';
	        controller.orderByFieldName = 'Name';
	        controller.sortByField	= 'Name';
	        controller.filter = '';
	        controller.title = 'Accounts';
	        controller.returnUrl = '/001/0';
	        controller.newRecordUrl	=	'/001/e';
	        controller.isSearchUsingSOSL = false;

	        // Calling search method
	        controller.getSearchResult();
	        system.assertEquals(controller.records.size(), 5, 'Search method should return 5 records.');
	        
	        
	        controller.getShowNewButton();
	        controller.sortByFieldAction();
	        
	        controller.deleteRecordId = controller.records.get(0).id;
	        controller.deleteRecord();
	        system.assertEquals(controller.records.size(), 4, 'After delete, size of the record list should be 4.');
	        
	        controller.newRedirectPage();
        
        Test.stopTest();
    }
    
    // Method to test validations
    static testMethod void testValidation() {
    	createTestData();
    	Test.startTest();
    		SearchListController controller = new SearchListController();
    		// Setting attributes for searching
	        controller.objectName = 'Account';
	        controller.pageSize = 5;
	        controller.searchFieldName = 'Name';
	        controller.searchFieldValue = '';
	        controller.orderByFieldName = 'Name';
	        controller.sortByField	= 'Name';
	        controller.filter = '';
	        controller.title = 'Accounts';
	        controller.returnUrl = '/001/0';
	        controller.newRecordUrl	=	'/001/e';
	        controller.isSearchUsingSOSL = false;
	        
    		
    		// Calling search method without field list
	        controller.getSearchResult();
    		System.assert(ApexPages.getMessages().get(0).getSummary().contains('fieldList or fieldsCSV attribute must be defined.') );
    		
    		// Setting field list
    		List<String> fieldList = new List<String>();
    		fieldList.add('Name');
    		fieldList.add('NumberOfEmployees');
    		controller.fieldsList = fieldList;
    		
    		// Calling search method with incorrect sortDirection
    		controller.sortDirection = 'xyz';
    		controller.getSearchResult();
    		System.assert(ApexPages.getMessages().get(1).getSummary().contains('sortDirection attribute must have value of "asc" or "desc"') );
    		
    		controller.sortDirection = 'asc';
    		controller.getSearchResult();
    	
    	Test.stopTest();
    	
    }
    
    
    // Method to create test data
    private static void createTestData(){
    	
    	List<Account> listAccount = new List<Account>();
    	for(Integer indx=1; indx <= 5; indx ++){
    		Account account = new Account(Name = 'Test' + String.valueOf(indx));
    		listAccount.add(account);
    	}
    	insert listAccount;
    }
}