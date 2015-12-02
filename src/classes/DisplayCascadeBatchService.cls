//
// DisplayCascadeBatchService
//
//
public class DisplayCascadeBatchService {
	
	private Map<Id, lboc_Master_Display__c> masterDisplayMap;
	private Map<Id, Set<Id>> existingMasterDisplayForOutletsMap;
	
	public DisplayCascadeBatchService(List<lboc_Master_Display__c> masterDisplays)
	{
		masterDisplayMap = createMasterDisplayMap(masterDisplays);
		existingMasterDisplayForOutletsMap = createExistingMasterDisplayForOutletsMap();
	}
	
	//convert list of master displays to a map in order to use for querieis and later processing
	private Map<Id, lboc_Master_Display__c> createMasterDisplayMap(List<lboc_Master_Display__c> masterDisplays)
	{		
    	Map<Id, lboc_Master_Display__c> masterDisplayMap = new Map<Id, lboc_Master_Display__c>();
    	for(lboc_Master_Display__c masterDisplay:masterDisplays)
    	{
    		masterDisplayMap.put(masterDisplay.Id, masterDisplay);			
    	}
    	return masterDisplayMap;
	}
	
	//find all the existing displays for outlets that were created from Master Displays
    public Map<Id,Set<Id>> createExistingMasterDisplayForOutletsMap()
    {
    	Map<Id, Set<Id>> existingDisplaysMap = new Map<Id, Set<Id>>();
   		for(buzz_retail__Display__c existingDisplay:[select Id, buzz_retail__Account__c, lboc_Master_Display__c from buzz_retail__Display__c 
   												where lboc_Master_Display__c in :masterDisplayMap.keyset()])
   		{
   			if(existingDisplaysMap.get(existingDisplay.lboc_Master_Display__c) == null)
   				existingDisplaysMap.put(existingDisplay.lboc_Master_Display__c, new Set<Id>());
   			existingDisplaysMap.get(existingDisplay.lboc_Master_Display__c).add(existingDisplay.buzz_retail__Account__c);
   		}
   		return existingDisplaysMap;  		
    }	

	//create a map of master display that need to be cascaded down to outlets	
    public Map<lboc_Master_Display__c, Set<Id>> createMasterDisplayOutletMap()
    {
     	Map<lboc_Master_Display__c, Set<Id>> masterDisplayOutletMap = new Map<lboc_Master_Display__c, Set<Id>>();
    	
    	//get master objective markets and store in a map of markets that have values of a list of master objectives
		Map<Id, List<Id>> marketMasterDisplayMap = new Map<Id, List<Id>>();															 
    	List<lboc_Master_Display_Market__c> masterDisplayMarkets = [select Id, lboc_Master_Display__c, lboc_Market__c from lboc_Master_Display_Market__c 
    																	 where lboc_Master_Display__c in :masterDisplayMap.keySet()];
    																	     																	 
		for(lboc_Master_Display_Market__c masterDisplayMarket:masterDisplayMarkets)
		{
			if(marketMasterDisplayMap.get(masterDisplayMarket.lboc_Market__c) == null)	
				marketMasterDisplayMap.put(masterDisplayMarket.lboc_Market__c, new List<Id>());	
			marketMasterDisplayMap.get(masterDisplayMarket.lboc_Market__c).add(masterDisplayMarket.lboc_Master_Display__c);		
		}																 	
    	
    	//get accounts for the markets that are related to our master objectives and store in a map
    	Map<Id, List<Id>> targetedAccountsMarketsMap = new Map<Id, List<Id>>();   
    	List<buzz_retail__TGAC__c> targetedAccounts = [select Id, buzz_retail__Account__c, buzz_retail__TG__c 
    												   from buzz_retail__TGAC__c 
    												   where buzz_retail__TG__c in :marketMasterDisplayMap.keyset()];
		for(buzz_retail__TGAC__c targetedAccount:targetedAccounts)
		{
			if(targetedAccountsMarketsMap.get(targetedAccount.buzz_retail__Account__c) == null)
				targetedAccountsMarketsMap.put(targetedAccount.buzz_retail__Account__c, new List<Id>());
			targetedAccountsMarketsMap.get(targetedAccount.buzz_retail__Account__c).add(targetedAccount.buzz_retail__TG__c);
		}
    	
    	lboc_Master_Display__c masterDisplay;													 
    	for(Id outletId:targetedAccountsMarketsMap.keyset())
    	{  		
    		for(Id marketId:targetedAccountsMarketsMap.get(outletId))
    		{
    			for(Id masterDisplayId:marketMasterDisplayMap.get(marketId))	
    			{
					masterDisplay = masterDisplayMap.get(masterDisplayId);   
					if(existingMasterDisplayForOutletsMap.get(masterDisplay.Id) == null || !(existingMasterDisplayForOutletsMap.get(masterDisplay.Id).contains(outletId))) 
					{ 				
    					if(masterDisplayOutletMap.get(masterDisplay) == null)
    						masterDisplayOutletMap.put(masterDisplay, new Set<Id>());
    					masterDisplayOutletMap.get(masterDisplay).add(outletId);
					}   				
    			}    			
    		}  		
    	}    	    	
    	return masterDisplayOutletMap;
    }

	//create the outlet displays from the master displays
	public List<buzz_retail__Display__c> createOutletDisplaysFromMasterDispalys(Map<lboc_Master_Display__c, Set<Id>> masterDisplayOutletMap)
	{
		
		List<buzz_retail__Display__c> displays = new List<buzz_retail__Display__c>();
    	buzz_retail__Display__c display;
    	
    	for(lboc_Master_Display__c masterDisplay:masterDisplayOutletMap.keyset())
    	{
    		for(Id outletId:masterDisplayOutletMap.get(masterDisplay))
    		{
    			display = new  buzz_retail__Display__c(Name = masterDisplay.Name,
													   buzz_retail__Start_Date__c = masterDisplay.lboc_Start_Date__c,
													   buzz_retail__End_Date__c = masterDisplay.lboc_End_Date__c,
													   lboc_Master_Display__c = masterDisplay.Id,
													   buzz_retail__Account__c = outletId,
													   lboc_Source__c = masterDisplay.lboc_Source__c,
													   lboc_Primary_Brand__c = masterDisplay.lboc_Primary_Brand__c,
													   lboc_Comments__c = masterDisplay.lboc_Comments__c,
													   lboc_Secondary_SKU__c = masterDisplay.lboc_Secondary_SKU__c,
													   lboc_Status__c = 'Cascaded'
													   );
													   
				displays.add(display);
    		}
    	}
    	return displays;
	}
	
	//save newly created displays for outlets
	public void saveOutletDisplays(List<buzz_retail__Display__c> newDisplays)
	{
		if(newDisplays.size() > 0)
			insert newDisplays;
	}

}