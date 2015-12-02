trigger PRM_VMEM_PermissionSetAssignmentRules on Permission_Set_Assignment_Rules__c ( after update, after insert, after undelete, after delete) {

   	Set<Id> ids = new Set<Id>();
   	Set<Id> groupOrPermissionIds = new Set<Id>();

    if( trigger.isAfter ){	
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Group Assignment' LIMIT 1];
    	if( trigger.isUpdate ){
            for(Integer i=0, j=trigger.new.size(); i<j;i++){
            	if(trigger.old[i].Permission_Set_ID__c != trigger.new[i].Permission_Set_ID__c || trigger.old[i].Active__c != trigger.new[i].Active__c){
            		ids.add(trigger.new[i].Id);
            	}
    		}
    	}
        if(trigger.isInsert || trigger.isUndelete){
            for(Integer i=0, j=trigger.new.size(); i<j;i++){
				ids.add(trigger.new[i].Id);
        	}
        }
        if(ids.size() > 0){
        	PermissionSetAssignmentUtils.updateAssignmentRuleNameValues(ids);
        }  
    }
    if(trigger.isAfter && trigger.isDelete){
    	for(Permission_Set_Assignment_Rules__c p: trigger.old){
			groupOrPermissionIds.add(p.Permission_Set_ID__c);
        }
        if(groupOrPermissionIds.size() > 0){

	        PermissionSetAssignment[] pa = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId=:groupOrPermissionIds];
	        Database.delete(pa);

        }
    }	
}