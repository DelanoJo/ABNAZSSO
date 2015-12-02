global class ObjectiveCascadeBatch implements Database.Batchable<sObject> {
	
	public Date currentDate = Date.today();
	private String query = 'select Id, lboc_Assigned_To__c,lboc_Description__c, lboc_End_Date__c, lboc_Start_Date__c,lboc_Source__c from lboc_Master_Objective__c where lboc_Start_Date__c <= :currentDate and lboc_End_Date__c >= :currentDate';
	
    global Database.QueryLocator start(Database.BatchableContext cascadeObjectiveBatchContext)
    {   
    	System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext cascadeObjectiveBatchContext, List<lboc_Master_Objective__c> masterObjectives)
    {    	
    	System.Debug(LoggingLevel.Info, 'Master Objectives Results Size' + masterObjectives.size());
    	if(masterObjectives.size() > 0)
    	{		  
 			ObjectiveCascadeBatchService objectiveCascadeBatchService = new ObjectiveCascadeBatchService(masterObjectives);
    			    		
    		Map<lboc_Master_Objective__c, Set<Id>> masterObjectiveOutletMap = objectiveCascadeBatchService.createOutletMasterObjectiveMap();
    		List<lboc_Objective__c>	newObjectives = objectiveCascadeBatchService.createOutletObjectivesFromMasterObjectives(masterObjectiveOutletMap);
    		objectiveCascadeBatchService.saveObjectives(newObjectives);
    	}
    }	
    
    global void finish(Database.BatchableContext cascadeObjectiveBatchContext)
    {
    	
        system.debug('Cascade Objective Batch completed');
    }    
}