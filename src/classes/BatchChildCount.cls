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
global class BatchChildCount implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id FROM Account WHERE Type = 'Chain' OR Type = 'Banner' OR Type = 'Decision Point']);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> accountIds = new Set<Id>();
		List<Account> updatedAccts = new List<Account>();
		Map<Id,Integer> storeCount = new Map<Id,Integer>();
		for(sObject s : scope) {
			Account acct = (Account)s;
			accountIds.add(acct.Id);
		}

		AggregateResult[] ar = [SELECT Count(Id) Children, ParentId FROM Account WHERE ParentId IN :accountIds AND Type = 'POC' GROUP BY ParentId];

		for(AggregateResult r : ar){
			storeCount.put((Id) r.get('ParentId'),(Integer) r.get('Children'));
		}
		
		for(Id acctId : accountIds){
			Account a = new Account(Id = acctId
								  , buzz_retail__NumberofLocations__c = storeCount.containsKey(acctId) ? storeCount.get(acctId) : 0);
			updatedAccts.add(a);
		}

		update updatedAccts;
	}

	global void finish(Database.BatchableContext BC) {

	}

}