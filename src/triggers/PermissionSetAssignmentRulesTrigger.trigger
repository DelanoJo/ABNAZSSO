trigger PermissionSetAssignmentRulesTrigger on Permission_Set_Assignment_Rules__c ( after update, after insert, after undelete, after delete) {

   	Set<Id> ids = new Set<Id>();
   	Set<Id> groupOrPermissionIds = new Set<Id>();
   	List<Permission_Set_Assignment_Rules__c> activePermissionSets= new List<Permission_Set_Assignment_Rules__c>();
   	List<Permission_Set_Assignment_Rules__c> inactivePermissionSets = new List<Permission_Set_Assignment_Rules__c>();

    if( trigger.isAfter ){	
    	if( trigger.isUpdate ){
            for(Integer i=0, j=trigger.new.size(); i<j;i++){
            	if(trigger.old[i].Permission_Set_ID__c != trigger.new[i].Permission_Set_ID__c || trigger.old[i].Active__c != trigger.new[i].Active__c){
            		ids.add(trigger.new[i].Id);
            	}
				if(trigger.old[i].Active__c == false && trigger.new[i].Active__c == true){
					activePermissionSets.add(trigger.new[i]);
				}
				if(trigger.old[i].Active__c == true && trigger.new[i].Active__c == false){
					inactivePermissionSets.add(trigger.new[i]);
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
        for(Integer i=0, j=trigger.new.size(); i<j;i++){
		}
        if(activePermissionSets.size() > 0){
        	BatchUpdatePermissionAssignments bug = new BatchUpdatePermissionAssignments();
        	bug.PermissionSets = activePermissionSets;
        	bug.remove = false;
    		Database.executeBatch(bug, 1);
		}
		if(inactivePermissionSets.size() > 0){
        	BatchUpdatePermissionAssignments bug = new BatchUpdatePermissionAssignments();
        	bug.PermissionSets = inactivePermissionSets;
        	bug.remove = true;
    		Database.executeBatch(bug, 1);

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