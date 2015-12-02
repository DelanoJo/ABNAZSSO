/**====================================================================
 * Appirio, Inc
 * Name: BatchRegionRosterUpdateTest
 * Description: Test Class for BatchRegionRosterUpdate
 * Created Date: 1 October 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class BatchRegionRosterUpdateTest {
	private static Region_Roster__c testRR;
	private static Region_Roster__c testRR2;
	static testMethod void testUpdateAccountTeamMember() {
	  createTestData();
	  Test.startTest();
	  	BatchRegionRosterUpdate b = new BatchRegionRosterUpdate();
	  	Database.executeBatch(b);
	  Test.stopTest();

	  Integer i = [SELECT COUNT()
	  			   FROM AccountTeamMember
	  			   WHERE AccountId = :testRR.Region_Roster_Account__c
	  			   AND UserId = :testRR.Region_Roster_User__c
	  			   AND TeamMemberRole = 'Test Role 1'];

	  System.assertEquals(i, 1);
	}
	private static void createTestData() {
		Account testAccount = TestUtils.createTestAccount('Customer Corporate', 'Customer', null);
		insert testAccount;

		User testUser = TestUtils.createTestUserWithProfile('Standard User');
		insert testUser;

		Region_Roster_Mapping__c rrm = new Region_Roster_Mapping__c(Name = 'Test1', Account_Team_Role__c = 'Test Role 1');
		insert rrm;
		Region_Roster_Mapping__c rrm2 = new Region_Roster_Mapping__c(Name = 'Test2', Account_Team_Role__c = 'Test Role 2');
		insert rrm2;

	    AccountTeamMember testATM = new AccountTeamMember();
		testATM.AccountId = testAccount.Id;
		testATM.UserId = testUser.Id;
		testATM.TeamMemberRole = 'Test Role 2';
		insert testATM;

		testRR = new Region_Roster__c();
		testRR.Region_Roster_Account__c = testAccount.Id;
		testRR.Region_Roster_User__c = UserInfo.getUserId();
		testRR.RRST_DIM_ACTV_FLG_US__c = true;
		testRR.RRST_POSIT_CD__c = 'Test1';
		insert testRR;

		testRR2 = new Region_Roster__c();
		testRR2.Region_Roster_Account__c = testAccount.Id;
		testRR2.Region_Roster_User__c = UserInfo.getUserId();
		testRR2.RRST_DIM_ACTV_FLG_US__c = false;
		testRR2.RRST_POSIT_CD__c = 'Test2';
		insert testRR2;
	}
}