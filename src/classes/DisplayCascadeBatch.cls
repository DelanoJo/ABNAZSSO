global class DisplayCascadeBatch implements Database.Batchable<sObject> 
{

	
	public Date currentDate = Date.today();
	private String query = 'select Id, Name, lboc_Comments__c, lboc_End_Date__c, lboc_Start_Date__c, lboc_Primary_Brand__c, lboc_Secondary_SKU__c, lboc_Source__c from lboc_Master_Display__c where lboc_Start_Date__c <= :currentDate and lboc_End_Date__c >= :currentDate';
	
    global Database.QueryLocator start(Database.BatchableContext cascadeDisplayBatchContext)
    {  
    	 
    	System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext cascadeDisplayBatchContext, List<lboc_Master_Display__c> masterDisplays)
    {    	
    	System.Debug(LoggingLevel.Info, 'Master Displays Results Size' + masterDisplays.size());
    	if(masterDisplays.size() > 0)
    	{
			DisplayCascadeBatchService displayCascadeBatchService = new DisplayCascadeBatchService(masterDisplays);
    			    		
    		Map<lboc_Master_Display__c, Set<Id>> masterDisplayOutletMap = displayCascadeBatchService.createMasterDisplayOutletMap();
    		List<buzz_retail__Display__c> newDisplays = displayCascadeBatchService.createOutletDisplaysFromMasterDispalys(masterDisplayOutletMap);
    		displayCascadeBatchService.saveOutletDisplays(newDisplays);
    	}
    }	
    
    global void finish(Database.BatchableContext cascadeDisplayBatchContext)
    {
    	
        system.debug('Cascade Display Batch completed');
    }    
	
}