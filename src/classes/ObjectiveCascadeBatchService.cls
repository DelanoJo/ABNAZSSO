public class ObjectiveCascadeBatchService {
	
	private Map<Id, lboc_Master_Objective__c> masterObjectiveMap;
	private Map<Id, Set<Id>> existingMasterObjectiveForOutletsMap;
	
	public ObjectiveCascadeBatchService(List<lboc_Master_Objective__c> masterObjectives)
	{
		masterObjectiveMap = createMasterObjectiveMap(masterObjectives);
		existingMasterObjectiveForOutletsMap = createExistingMasterObjectiveForOutletsMap();
	}
	
	//convert list of master displays to a map in order to use for querieis and later processing
	private Map<Id, lboc_Master_Objective__c> createMasterObjectiveMap(List<lboc_Master_Objective__c> masterObjectives)
	{		
    	Map<Id, lboc_Master_Objective__c> masterObjectiveMap = new Map<Id, lboc_Master_Objective__c>();
    	for(lboc_Master_Objective__c masterObjective:masterObjectives)
    	{
    		masterObjectiveMap.put(masterObjective.Id, masterObjective);			
    	}
    	return masterObjectiveMap;
	}
	
	//find all the existing displays for outlets that were created from Master Displays
    public Map<Id,Set<Id>> createExistingMasterObjectiveForOutletsMap()
    {
    	Map<Id, Set<Id>> existingObjectivesMap = new Map<Id, Set<Id>>();
   		for(lboc_Objective__c existingObjective:[select Id, lboc_Outlet__c, lboc_Master_Objective__c from lboc_Objective__c 
   												where lboc_Master_Objective__c in :masterObjectiveMap.keyset()])
   		{
   			if(existingObjectivesMap.get(existingObjective.lboc_Master_Objective__c) == null)
   			{
   				existingObjectivesMap.put(existingObjective.lboc_Master_Objective__c, new Set<Id>());
   			}	
   			existingObjectivesMap.get(existingObjective.lboc_Master_Objective__c).add(existingObjective.lboc_Outlet__c);
   		}
   		return existingObjectivesMap;  		
    }		
	
    public Map<lboc_Master_Objective__c, Set<Id>> createOutletMasterObjectiveMap()
    {
     	Map<lboc_Master_Objective__c, Set<Id>> masterObjectiveOutletMap = new Map<lboc_Master_Objective__c, Set<Id>>();
    	
    	//get master objective markets and store in a map of markets that have values of a list of master objectives
		Map<Id, List<Id>> marketMasterObjectiveMap = new Map<Id, List<Id>>();															 
    	List<lboc_Master_Objective_Market__c> masterObjectiveMarkets = [select Id, lboc_Master_Objective__c, lboc_Market__c from lboc_Master_Objective_Market__c 
    																	 where lboc_Master_Objective__c in :masterObjectiveMap.keySet()];
    																	     																	 
		for(lboc_Master_Objective_Market__c masterObjectiveMarket:masterObjectiveMarkets)
		{
			if(marketMasterObjectiveMap.get(masterObjectiveMarket.lboc_Market__c) == null)
			{	
				marketMasterObjectiveMap.put(masterObjectiveMarket.lboc_Market__c, new List<Id>());	
			}	
			marketMasterObjectiveMap.get(masterObjectiveMarket.lboc_Market__c).add(masterObjectiveMarket.lboc_Master_Objective__c);		
		}																 	
    	
    	//get accounts for the markets that are related to our master objectives 
    	Map<Id, List<Id>> targetedAccountsMarketsMap = new Map<Id, List<Id>>();   
    	List<buzz_retail__TGAC__c> targetedAccounts = [select Id, buzz_retail__Account__c, buzz_retail__TG__c 
    												   from buzz_retail__TGAC__c 
    												   where buzz_retail__TG__c in :marketMasterObjectiveMap.keyset()];
		for(buzz_retail__TGAC__c targetedAccount:targetedAccounts)
		{
			if(targetedAccountsMarketsMap.get(targetedAccount.buzz_retail__Account__c) == null)
			{
				targetedAccountsMarketsMap.put(targetedAccount.buzz_retail__Account__c, new List<Id>());
			}	
			targetedAccountsMarketsMap.get(targetedAccount.buzz_retail__Account__c).add(targetedAccount.buzz_retail__TG__c);
		}
    	
    	lboc_Master_Objective__c masterObjective;													 
    	for(Id outletId:targetedAccountsMarketsMap.keyset())
    	{  		
    		for(Id marketId:targetedAccountsMarketsMap.get(outletId))
    		{
    			for(Id masterObjectiveId:marketMasterObjectiveMap.get(marketId))	
    			{
					masterObjective = masterObjectiveMap.get(masterObjectiveId);   
					if(existingMasterObjectiveForOutletsMap.get(masterObjective.Id) == null || !(existingMasterObjectiveForOutletsMap.get(masterObjective.Id).contains(outletId))) 
					{ 									 				
    					if(masterObjectiveOutletMap.get(masterObjective) == null)
    						masterObjectiveOutletMap.put(masterObjective, new Set<Id>());
    					masterObjectiveOutletMap.get(masterObjective).add(outletId); 
					}  				
    			}    			
    		}  		
    	}    	    	
    	return masterObjectiveOutletMap;
    }

	public List<lboc_Objective__c> createOutletObjectivesFromMasterObjectives(Map<lboc_Master_Objective__c, Set<Id>> outletMasterObjectiveMap)
	{
		List<lboc_Objective__c> objectives = new List<lboc_Objective__c>();
    	lboc_Objective__c objective;
    	
    	for(lboc_Master_Objective__c masterObjective:outletMasterObjectiveMap.keyset())
    	{
    		for(Id outletId:outletMasterObjectiveMap.get(masterObjective))
    		{
  				objective = new  lboc_Objective__c(lboc_Assigned_To__c = masterObjective.lboc_Assigned_To__c,
													   lboc_Description__c = masterObjective.lboc_Description__c,
													   lboc_End_Date__c = masterObjective.lboc_End_Date__c,
													   lboc_Start_Date__c = masterObjective.lboc_Start_Date__c,
													   lboc_Source__c = masterObjective.lboc_Source__c,
													   lboc_Master_Objective__c = masterObjective.Id,
													   lboc_Outlet__c = outletId);
				objectives.add(objective); 	


    		}
    	}
    	return objectives;
	}
	
	public void saveObjectives(List<lboc_Objective__c> newObjectives)
	{
		if(newObjectives.size() > 0)
			insert newObjectives;
	}
	
}