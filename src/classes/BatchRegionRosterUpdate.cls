/**====================================================================
 * Appirio, Inc
 * Name: BatchRegionRosterUpdate
 * Description: Batch class to update Account Team from Region Roster
 * Created Date: 1 October 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
global class BatchRegionRosterUpdate implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, Region_Roster_Account__c, Region_Roster_User__c
										 , RRST_DIM_ACTV_FLG_US__c, RRST_POSIT_CD__c
										 FROM Region_Roster__c]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		Map<String, Region_Roster_Mapping__c> rrMap = Region_Roster_Mapping__c.getall();

		Set<String> accountIds = new Set<String>();
		Set<String> roleNames = new Set<String>();
		Set<String> userIds = new Set<String>();

		//Set to hold mapping of AccId and Role for all Updated RRs (Inactive)
		Set<String> inactiveRRs = new Set<String>();
		//Set to hold mapping of AccId and Role and UserId for all active RRs
		Map<String,Region_Roster__c> accountUserRoleMap = new Map<String,Region_Roster__c>();

		String key = '';
		for(sObject s : scope) {
			Region_Roster__c rr = (Region_Roster__c)s;
			// Condition to find relevant Region Rosters
			if(rr.Region_Roster_Account__c != null && rr.Region_Roster_User__c != null &&  rr.RRST_POSIT_CD__c != null && rrMap.containsKey(rr.RRST_POSIT_CD__c)) {
				String accountTeamRole = rrMap.get(rr.RRST_POSIT_CD__c).Account_Team_Role__c;

				roleNames.add(accountTeamRole);
				accountIds.add(rr.Region_Roster_Account__c);
				userIds.add(rr.Region_Roster_User__c);

				key = rr.Region_Roster_Account__c + '~' + rr.Region_Roster_User__c + '~' + accountTeamRole;
					
				if(rr.RRST_DIM_ACTV_FLG_US__c){
					accountUserRoleMap.put(key,rr);
				}else if(!rr.RRST_DIM_ACTV_FLG_US__c){
					inactiveRRs.add(key);
				}
			}
		}

		Map<Id, User> userMap = new Map<Id, User>([SELECT Id, IsActive FROM User WHERE Id IN :userIds]);

		List<AccountTeamMember> accTeamMemToDelete = new List<AccountTeamMember>();
		List<AccountTeamMember> accTeamMemToInsert = new List<AccountTeamMember>();
		//String key1 = '';
		Set<String> existingRoles = new Set<String>();

		for(AccountTeamMember atm : [SELECT UserId, TeamMemberRole, Id, AccountId, Account.OwnerId 
									 FROM AccountTeamMember 
									 WHERE AccountId IN :accountIds
									 AND TeamMemberRole IN :roleNames]) {
			key = atm.AccountId + '~' + atm.UserId + '~' + atm.TeamMemberRole;
			
			if(inactiveRRs.contains(key)){
				accTeamMemToDelete.add(new AccountTeamMember(Id = atm.Id));
			} else {
				existingRoles.add(key);
			}
		}

		for(String s : accountUserRoleMap.keySet()){
			if(!existingRoles.contains(s) && userMap.get(accountUserRoleMap.get(s).Region_Roster_User__c).IsActive){
				accTeamMemToInsert.add(new AccountTeamMember(UserId = accountUserRoleMap.get(s).Region_Roster_User__c
					, AccountId = accountUserRoleMap.get(s).Region_Roster_Account__c
					, TeamMemberRole = rrMap.get(accountUserRoleMap.get(s).RRST_POSIT_CD__c).Account_Team_Role__c));
			}
		}

		if(!accTeamMemToDelete.isEmpty()){
			delete accTeamMemToDelete;
		}
		if(!accTeamMemToInsert.isEmpty()){
			insert accTeamMemToInsert;
		}

	}

	global void finish(Database.BatchableContext BC) {

	}

}