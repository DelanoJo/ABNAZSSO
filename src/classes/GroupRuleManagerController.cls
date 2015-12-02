public without sharing class GroupRuleManagerController {

    public Permission_Set_Assignment_Rules__c dynamicGroup { get; private set; }
    private Integer nextId = 0;
    private String selectedId;
    private FieldSelectOptions recordFields { get; private set; }
    public List<ConditionRow> conditions { get; private set; } 
    private List<Group_Rule__c> deleted = new List<Group_Rule__c>();
    private Set<String> delIds = new Set<String>();
    private List<SelectOption> options = null;

    public GroupRuleManagerController(ApexPages.StandardController controller) {

        final String groupRuleId = ApexPages.currentPage().getParameters().get('id');
        final String dynamicGroupId = ApexPages.currentPage().getParameters().get('dynamicgroupid');
        if (groupRuleId != null) {
            Group_Rule__c groupRule = [Select Assignment_Rule__c from Group_Rule__c where Id = :groupRuleId ];
            this.dynamicGroup = [SELECT Id, Permission_Set_ID__c, Active__c, Name FROM Permission_Set_Assignment_Rules__c WHERE Id = :groupRule.Assignment_Rule__c];           
        } else if (dynamicGroupId != null) {
            this.dynamicGroup = [Select Id, Permission_Set_ID__c, Active__c, Name from Permission_Set_Assignment_Rules__c where Id =:dynamicGroupId];
        } else {
            Group_Rule__c rule = (Group_Rule__c) controller.getRecord();
//            System.debug('rule.Dynamic_Group__c = ' + rule.Dynamic_Group__c);
            this.dynamicGroup = [Select Id, Permission_Set_ID__c, Active__c, Name from Permission_Set_Assignment_Rules__c where Id = :rule.Assignment_Rule__c];
        }
        conditions = new List<ConditionRow>();
        recordFields = new FieldSelectOptions('Contact');

    }

    public PageReference onLoad() {

        for (Group_Rule__c cond : [SELECT Record_Field__c, Operator__c, Value__c FROM Group_Rule__c WHERE Assignment_Rule__c = :dynamicGroup.Id]) {
            nextId++;
            conditions.add(new ConditionRow(String.valueOf(nextId), cond));
        }
        
        if (conditions.size() == 0) {
            nextId++;
            conditions.add(new ConditionRow(String.valueOf(nextId), new Group_Rule__c()));
        }
        
        return null;
    }

    public class ConditionRow {
        private String id;
        private Group_Rule__c condition;
        private Map<String, List<SelectOption>> objectOptionsMap = new Map<String, List<SelectOption>>();
        
        public ConditionRow(String id, Group_Rule__c condition) {
            this.id = id;
            this.condition = condition;
        }
        
        public String getId() {
            return id;
        }
        
        public Group_Rule__c getCondition() {
            return condition;
        }
    }


    public PageReference onAddCondition() {
        String selectedId = ApexPages.currentPage().getParameters().get('selectedId');
        if (selectedId != null) {
            for (Integer i=0;i<conditions.size();i++) {
                ConditionRow row = conditions.get(i);
                System.debug('onAdd getRowId() = '+ row.getId());
                System.debug('selectId = '+selectedId);
                if (row.getId().equals(selectedId)) {
                    nextId++;
                    Group_Rule__c ruleGroupLocal = new Group_Rule__c();
                    ruleGroupLocal.Operator__c = 'equals';
                    if (i == (conditions.size() - 1)) {
                        conditions.add(new ConditionRow(String.valueOf(nextId), ruleGroupLocal));
                    } else {
                        conditions.add(i + 1, new ConditionRow(String.valueOf(nextId), ruleGroupLocal));
                    }
                    return null;
                }
            }
        }
        return null;
    }
    
    public PageReference onRemoveCondition() {
        String selectedId = ApexPages.currentPage().getParameters().get('selectedId');
        if (selectedId != null) {
            for (Integer i=0;i<conditions.size();i++) {
                ConditionRow row = conditions.get(i);
                String s = row.getId();
                System.debug('onRemove getRowId() = '+ s + ' s.length()');
                System.debug('selectId = '+selectedId+' selectedId.length()');
                if (row.getId().equals(selectedId)) {
                    conditions.remove(i);
                    if (row.getCondition().Id != null) {
                    		deleted.add(row.getCondition());
  	
                    }
                    return null;
                }
            }
        }
        return null;
    }

    public List<SelectOption> getRecordFieldOptions() {
        return recordFields.getOptions();
    }

    public PageReference onSave() {
        delete deleted;
        String message = '';
        try {
        QueryBuilder.Meta mdata = new QueryBuilder.Meta('Contact');
        List<Group_Rule__c> batch = new List<Group_Rule__c>();
        Set<string> batchId= new Set<string> ();
        for (ConditionRow row : conditions) {
            Group_Rule__c cond = row.getCondition();
            if (cond.Id == null) {
                cond.Assignment_Rule__c = dynamicGroup.Id;
            }
            System.debug('mdata = '+mdata);
            System.debug('RF = '+cond.Record_Field__c);
            Schema.DescribeFieldResult f = mdata.getFieldDescribe(cond.Record_Field__c);
            if ((cond.Operator__c == Operators.CNTN ||cond.Operator__c == Operators.NOT_CNTN ) && 
            	(f.getType() != DisplayType.MultiPicklist))
            {
                message = '\'Contains\' OR \'Does not Contains\' operators are only valid for multipicklist fields.';
            }

            if ((f.getType() == DisplayType.MultiPicklist) && 
            	(
            		(cond.Operator__c == Operators.LT)
		            ||(cond.Operator__c == Operators.LTE)||(cond.Operator__c == Operators.GT)
		            ||(cond.Operator__c == Operators.GTE) || (cond.Operator__c == Operators.EQ)
		            || (cond.Operator__c == Operators.NEQ))
				)		          
            {
                message = cond.Operator__c + ' operator is not valid for multipicklist fields.';
            }
         
            if(cond.Id==null)   
            batch.add(cond);
            else
            {
            	if(!batchId.contains(cond.Id))
            	{
            		batchId.add(cond.Id);
            		batch.add(cond);
            	}
            }
        }
        
        Database.Upsert(batch,false);
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,message)); 
            return null;
        }
        
        return new PageReference('/' + dynamicGroup.Id);
    }

    public PageReference onCancel() {
        return new PageReference('/' + dynamicGroup.Id);
    }
}