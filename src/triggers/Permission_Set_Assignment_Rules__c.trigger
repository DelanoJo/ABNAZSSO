trigger PermissionSetAssignmentRuleTrigger on Permission_Set_Assignment_Rules__c ( after update, after insert, after undelete, after delete) {

   	Set<Id> ids = new Set<Id>();
   	Set<Id> groupOrPermissionIds = new Set<Id>();
   	List<Permission_Set_Assignment_Rules__c> activeGroupSettings= new List<Permission_Set_Assignment_Rules__c>();
   	List<Permission_Set_Assignment_Rules__c> inactiveGroupSettings = new List<Permission_Set_Assignment_Rules__c>();

    if( trigger.isAfter ){	
    	if( trigger.isUpdate ){
            for(Integer i=0, j=trigger.new.size(); i<j;i++){
            	if(trigger.old[i].Permission_Set_ID__c != trigger.new[i].Permission_Set_ID__c || trigger.old[i].Active__c != trigger.new[i].Active__c){
            		ids.add(trigger.new[i].Id);
            		if( trigger.new[i].Active__c == true){
        				activeGroupSettings.add(trigger.new[i]);
            		}
            		if( trigger.new[i].Active__c == false){
        				inactiveGroupSettings.add(trigger.new[i]);
            		}
            	}
    		}
    	}
        if(trigger.isInsert || trigger.isUndelete){
            for(Integer i=0, j=trigger.new.size(); i<j;i++){
				ids.add(trigger.new[i].Id);
        		if( trigger.new[i].Active__c == true){
    				activeGroupSettings.add(trigger.new[i]);
        		}
        		if( trigger.new[i].Active__c == false){
    				inactiveGroupSettings.add(trigger.new[i]);
        		}
        	}
        }
        if(ids.size() > 0){
        	PermissionSetAssignmentUtils.updateAssignmentRuleNameValues(ids);
        }  
        if(activeGroupSettings.size() > 0){
        	BatchUpdatePermissionAssignments bug = new BatchUpdatePermissionAssignments();
        	bug.PermissionSets = activeGroupSettings;
        	//bug.query = 'SELECT Id FROM Permission_Set_Assignment_Rules__c WHERE Id = ' +  '\'' + activeGroupSettings[0].id + '\'';
        	bug.remove = false;
			system.debug('%%%bug.query: ' + bug.query);
    		Database.executeBatch(bug, 1);
		}
		if(inactiveGroupSettings.size() > 0){
        	BatchUpdatePermissionAssignments bug = new BatchUpdatePermissionAssignments();
        	bug.PermissionSets = inactiveGroupSettings;
        	//bug.query = 'SELECT Id FROM Permission_Set_Assignment_Rules__c WHERE Id = ' + '\'' + inactiveGroupSettings[0].id + '\'';
        	bug.remove = true;
			system.debug('%%%bug.query: ' + bug.query);
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