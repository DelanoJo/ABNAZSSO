global class BatchUpdatePermissionAssignments implements Database.Batchable<sObject>, Database.Stateful{
	
	public String query;
	public Boolean remove;
	public Set<Id> ids;
	public List<Permission_Set_Assignment_Rules__c> PermissionSets = new List<Permission_Set_Assignment_Rules__c>();
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('PermissionSets: ' + PermissionSets);
		return Database.getQueryLocator([SELECT Id, Permission_Set_Id__c FROM Permission_Set_Assignment_Rules__c WHERE ID IN: PermissionSets]);
	}

   	global void execute(Database.BatchableContext BC, List<Permission_Set_Assignment_Rules__c> scope) {


    	for(Permission_Set_Assignment_Rules__c p: scope){
	   		QueryBuilder builder = new QueryBuilder(p);
			String query = builder.getQuery();
			system.debug('$$$query: ' + query);
			system.debug(query);
			if(remove ==true){
				PermissionSetAssignmentUtils.removeGroups(query, p.Id);
			}else{
				PermissionSetAssignmentUtils.setGroups(query, p.Id);
			}
		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}