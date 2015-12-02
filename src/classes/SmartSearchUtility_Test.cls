/***********************************************************************
 Class 			: SmartSearchUtility_Test
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Provide test coverage to SmartSearchUtility.cls
 ************************************************************************/
 
@isTest
private class SmartSearchUtility_Test {

    static testMethod void testGetAutoFillValues() {
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = account.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        	List<String> lstAutoFillResult = SmartSearchUtility.getAutoFillValues('Test', 'Account', 'Name');
        	System.assertEquals(lstAutoFillResult[0], 'Test Account', 'Method should return the name value "Test Account"');
        Test.stopTest();
    }
    
    static testMethod void testCreateFieldCsv() {
    	
    	// We can not create fieldset in the test class, so passing a rendom field set name
    	String fieldCSV = SmartSearchUtility.createFieldCsv('Account', 'testFieldSet');
    	System.assertEquals(fieldCSV, 'Name,Id', 'If field set does not exist then "Name,Id" should be the default value return by the method.');
    }
}