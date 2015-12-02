public without sharing class PermissionSetAssignmentUtils {
	


    @future
    public static void updateAssignmentRuleNameValues(Set<Id> ids){

        Set<Id> permissionSetOrPermissionSetIds = new Set<Id>();
        Permission_Set_Assignment_Rules__c[] psars = [SELECT Permission_Set_ID__c,Permission_Set_Name__c
                                                      FROM Permission_Set_Assignment_Rules__c WHERE id =: ids];
        for(Permission_Set_Assignment_Rules__c p : psars){
            permissionSetOrPermissionSetIds.add(p.Permission_Set_ID__c);
        }


        PermissionSet[] ps = [SELECT Id, Name, Label FROM PermissionSet WHERE Id =: permissionSetOrPermissionSetIds];
        for(PermissionSet p : ps){
            for(Permission_Set_Assignment_Rules__c psa : psars){
                if(psa.Permission_Set_ID__c == p.Id){
                    psa.Permission_Set_Name__c = p.Label;
                }
            }
        } 

        if(psars.size() > 0){
            update psars;
        }

    }

    public static void setGroups(String q, Id permissionId){
        Permission_Set_Assignment_Rules__c p = [SELECT Permission_Set_ID__c FROM Permission_Set_Assignment_Rules__c WHERE Id =: permissionId LIMIT 1];
        Contact[] cons = Database.query(q);
        PermissionSetAssignment[] permissionSetAssignmentsToInsert = new PermissionSetAssignment[]{};
        PermissionSetAssignment[] permissionSetAssignmentsToRemove = new PermissionSetAssignment[]{};
        Set<Id> userIds = new Set<Id>();
        User[] users = new User[]{};
        for(Contact c : cons){
            userIds.add(c.User__c);
        }
        for(PermissionSetAssignment gm :[SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId=:p.Permission_Set_ID__c]){
            permissionSetAssignmentsToRemove.add(gm);
        }
        if(permissionSetAssignmentsToRemove.size() > 0){
            system.debug('$$$permissionSetAssignmentsToRemove: ' + permissionSetAssignmentsToRemove);
            delete permissionSetAssignmentsToRemove;
        }
        for(User u :[SELECT Id FROM User WHERE Id =: userIds AND IsActive = true]){
            PermissionSetAssignment groupAssign = new PermissionSetAssignment();
            groupAssign.PermissionSetId = p.Permission_Set_ID__c;
            groupAssign.AssigneeId = u.Id;
            permissionSetAssignmentsToInsert.add(groupAssign);
        }
        if(permissionSetAssignmentsToInsert.size() > 0){
            insert permissionSetAssignmentsToInsert;
        }
    }

    /***called from batch process instantiated by trigger***/
    public static void removeGroups(String q, Id permissionId){
        Permission_Set_Assignment_Rules__c p = [SELECT Permission_Set_ID__c FROM Permission_Set_Assignment_Rules__c WHERE Id =: permissionId LIMIT 1];
        Contact[] cons = Database.query(q);
        PermissionSetAssignment[] permissionSetAssignmentsToRemove = new PermissionSetAssignment[]{};
        Set<Id> userIds = new Set<Id>();
        //Set<Id> userIds = new Set<Id>();
        for(Contact c : cons){
            userIds.add(c.User__c);
        }
        /*for(User u :[SELECT Id FROM User WHERE ContactId =: userIds AND IsActive = true]){
            userIds.add(u.Id);
        }*/
        for(PermissionSetAssignment gm :[SELECT ID FROM PermissionSetAssignment WHERE AssigneeId =: userIds AND PermissionSetId=:p.Permission_Set_ID__c]){
            permissionSetAssignmentsToRemove.add(gm);
        }
        if(permissionSetAssignmentsToRemove.size() > 0){
            delete permissionSetAssignmentsToRemove;
        }
    }
}