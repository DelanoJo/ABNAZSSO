@isTest
private class DelegatedAdministratorControllerTest {
	
	
	@isTest static void simulateDelegatedAdmin() {

        Profile communityProfile =[select id from Profile where Name LIKE '%Customer Community Delegated Admin%' limit 1];
        Profile administrator =[select id from Profile where Name LIKE '%System Administrator%' limit 1];
        Account acc1 = TestDataUtil.createAccounts( 1, true, new Map<string, object>{ 'Industry' => 'test', 'Name' => 'TestA','Type' => 'Wholesaler'})[0];
        Account acc2 = TestDataUtil.createAccounts( 1, true, new Map<string, object>{ 'Industry' => 'test', 'Name' => 'TestB','ParentId' => acc1.Id, 'Type' => 'Retailer'})[0];
        User admin = TestDataUtil.createUsers( 1, true, new Map<string, object>{
                                                                        'FirstName' => 'FT38stName',                 
                                                                        'LastName' => 'LT38stName',                 
                                                                        'Alias' => 'tsadmin',                 
                                                                        'Email' => 'adminguy124@dolby.com',                 
                                                                        'Username' => 'adminguy124@abc.com',                 
                                                                        'CommunityNickname' => 'test345',                 
                                                                        'emailencodingkey' => 'UTF-8',                 
                                                                        'languagelocalekey' => 'en_US',                 
                                                                        'localesidkey' => 'en_US',                                 
                                                                        'timezonesidkey' => 'America/Los_Angeles',
                                                                        'profileId' => administrator.Id} )[0];
        Contact con1 = TestDataUtil.createContacts( 1, true, new Map<string, object>{ 'AccountId' => acc1.Id , 'OwnerId' => admin.Id} )[0];
        User user5 = TestDataUtil.createUsers( 1, true, new Map<string, object>{
                                                                        'FirstName' => 'FT38stName',                 
                                                                        'LastName' => 'LT38stName',                 
                                                                        'Alias' => 'tstN8',                 
                                                                        'Email' => 'test8@dolby.com',                 
                                                                        'Username' => '5partner8@abc.com',                 
                                                                        'CommunityNickname' => 'tes1345',                 
                                                                        'emailencodingkey' => 'UTF-8',                 
                                                                        'languagelocalekey' => 'en_US',                 
                                                                        'localesidkey' => 'en_US',                                 
                                                                        'timezonesidkey' => 'America/Los_Angeles',
                                                                        'profileId' => communityProfile.Id,
                                                                        'ContactId' => con1.Id } )[0];

		system.runAs(user5){

        	DelegatedAdministratorController de = new DelegatedAdministratorController();
        	de.init();
        	de.conFirstName = 'SuperTester';
        	de.conLastName = 'Guy1';
        	de.conEmail = 'supertesterguy1238sao@company.biz';
        	de.accId = acc1.Id;
        	de.createContact();

        	de.contactIdToModify = con1.Id;
        	de.resetUserPassword();
        	de.contactIdToModify = con1.Id;
        	de.changeUserActiveStatus();

		}
	}

}