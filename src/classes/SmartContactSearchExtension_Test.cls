/***********************************************************************
 Class 			: SmartContactSearchExtension_Test
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Provide test coverage to SmartContactSearchExtension.cls
 ************************************************************************/
@isTest
private class SmartContactSearchExtension_Test {

    static testMethod void testContactSearch() {
    	
    	Test.startTest();
    	
	        SmartContactSearchExtension controller = new SmartContactSearchExtension();
	        controller.contactFirstNameToSearch = 'FirstName';
	        controller.contactLastNameToSearch = 'LastName';
	        controller.contactEmail = 'test@test.com';
	        controller.contactAccount = 'Test Account';
	        
	        System.assert(controller.contactFieldCsv != null , 'If fieldset does not exist then "Name" field should be the default value in the contactFieldCsv else the fields from the fieldset will be set');
	        System.assert(controller.leadFieldCsv != null , 'If fieldset does not exist then "Name" field should be the default value in the leadFieldCsv else the fields from the fieldset will be set');
	        
	        controller.performSearch();
	        System.assertEquals(controller.contactFirstNameToSearch, controller.leadFirstNameToSearch, 'Contact first name and lead first name should be same.' );
	        System.assertEquals(controller.contactLastNameToSearch, controller.leadLastNameToSearch, 'Contact last name and lead last name should be same.' );
	        System.assertEquals(controller.contactEmail, controller.leadEmail, 'Contact email and lead email should be same.' );
	        System.assertEquals(controller.contactAccount, controller.leadAccount, 'Contact account and lead account should be same.' );
	        
	        System.assertEquals(controller.filterCriteria.trim(), 'Account.Name like \'%Test Account%\' AND LastName like \'%LastName%\' AND Email like \'%test@test.com%\'');
	        System.assertEquals(controller.filterLeadCriteria.trim(), 'LastName like \'%LastName%\' AND Email like \'%test@test.com%\' AND Company like \'%Test Account%\'');

			controller.resetTextBoxName = '1';	        
	        controller.resetSearchStatus();
	        System.assertEquals(controller.contactFirstNameToSearch, '');
	        
	        controller.resetTextBoxName = '2';	        
	        controller.resetSearchStatus();
	        System.assertEquals(controller.contactLastNameToSearch, '');
	        
	        controller.resetTextBoxName = '3';	        
	        controller.resetSearchStatus();
	        System.assertEquals(controller.contactEmail, '');
	        
	        controller.resetTextBoxName = '4';	        
	        controller.resetSearchStatus();
	        System.assertEquals(controller.contactAccount, '');
	        
	        controller.resetTextBoxName = '';
	        controller.resetSearchStatus();
	        
	        ApexPages.StandardController std = new ApexPages.StandardController(new Contact(LastName = 'Test Contact'));
	        controller = new SmartContactSearchExtension(std);
	        
	        controller.createNewContact();
	        controller.createNewLead();
	        
        Test.stopTest();
        
    }
}