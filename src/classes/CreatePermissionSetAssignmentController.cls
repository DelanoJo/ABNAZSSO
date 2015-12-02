public with sharing class CreatePermissionSetAssignmentController {

	public SelectOption[] permissionSets {get;set;}
	public Id permissionSetId {get;set;}
	public Permission_Set_Assignment_Rules__c psa {get;set;}

	public CreatePermissionSetAssignmentController(ApexPages.StandardController controller) {
		psa = new Permission_Set_Assignment_Rules__c();
		permissionSets = new SelectOption[]{};
		for(PermissionSet ps : [SELECT ID, Label FROM PermissionSet WHERE NOT (Label LIKE '00e%') ORDER BY Label ASC]){
			permissionSets.add(new SelectOption(ps.Id, ps.Label));
		}
	}

	public pageReference save(){
		psa.Permission_Set_ID__c = permissionSetId;
		psa.Active__c = false;
		insert psa;

		PageReference newPermissionSetAssignmentRuleId = new PageReference('/'+psa.Id);
		return newPermissionSetAssignmentRuleId;

	}
}