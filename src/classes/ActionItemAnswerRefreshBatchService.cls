/**
 *   Class to implement the logic to populate the Last value on Action Item Answer
 *   object.
 */
public class ActionItemAnswerRefreshBatchService 
{
	
	public static void populateAnswerFromLastCall(List<buzz_retail__ActionItem_Answer__c> actItemAnsResultSet)
	{
		
		
		// Map to store all the "Action Item Answers" record that needs to be updated.
		Map<String,buzz_retail__ActionItem_Answer__c> nextDayCallsMap = new Map<String,buzz_retail__ActionItem_Answer__c>();
		
		// Sets to store all the "Accounts Labatt Outlet IDs" to query in order to get previous completed calls.
		Set<String> uniqueOutletIds = new Set<String>();
		// Map to store all the "Action Item Answers" of the previous last completed Call from where the data needs to be read.
		Map<String,buzz_retail__ActionItem_Answer__c> prevDayCallsMap = new Map<String,buzz_retail__ActionItem_Answer__c>();
			
		// Loop through the "actItemAnsResultSet" to get all the Accounts & Action Item answer records that needs to be updated.
		for(buzz_retail__ActionItem_Answer__c nextCallActItemAnsRec : actItemAnsResultSet)
		{
			// Debug statements to review the data.
			system.debug('NextDayCalls :: Action Item Answer Name ::  ' + nextCallActItemAnsRec.Name);
	    	system.debug('NextDayCalls :: Labatt Outlet ID ::  ' + nextCallActItemAnsRec.buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c);
	    	system.debug('NextDayCalls :: Call Name :: ' + nextCallActItemAnsRec.buzz_retail__Call__r.Name);
	    	system.debug('NextDayCalls :: Last Value::  ' + nextCallActItemAnsRec.lboc_Last_Value__c);
	    		
	    	// Create a Unique key usinng the Action Item Name + Labatt Outlet ID to create a map of "ActionItemAnswer"
	    	// records which needs to be updated, once a previous call is identified with same Action Item and on same Account.
	    	String uniqueActItemAnsKey = nextCallActItemAnsRec.Name + nextCallActItemAnsRec.buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c;
	    	system.debug('NextDayCalls :: uniqueActItemAnswerKey :: ' + uniqueActItemAnsKey);
	    		
	    	// Populate all the ActionItemAnswer records.
	    	nextDayCallsMap.put(uniqueActItemAnsKey,nextCallActItemAnsRec);
	    		
	    	// Populate all the Labatt Outlet IDs
	    	uniqueOutletIds.add(nextCallActItemAnsRec.buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c);
	 	}
	 		
	 	if(uniqueOutletIds !=null && uniqueOutletIds.size() > 0)
	 	{
		 	// Loop through the "actItemAnsResultSet" using the LabattOutletID for all previous calls to get the Last value associated with them.
			for(buzz_retail__ActionItem_Answer__c prevCallActItemAnsRec : [Select Name,buzz_retail__Call__r.Name,buzz_retail__Answer__c, 
					buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c from buzz_retail__ActionItem_Answer__c where 
		        	buzz_retail__Call__r.buzz_retail__Date__c < TOMORROW and 
		        	buzz_retail__Call__r.buzz_retail__CallStatus__c = 'Completed'  and
		        	buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c =: uniqueOutletIds 
		        	ORDER BY buzz_retail__Call__r.buzz_retail__End__c DESC NULLS LAST])
			{
		    	// Debug statements to review the data.
				system.debug('PrevDayCalls :: Action Item Answer Name ::  ' + prevCallActItemAnsRec.Name);
		    	system.debug('PrevDayCalls :: Labatt Outlet ID ::  ' + prevCallActItemAnsRec.buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c);
		    	system.debug('PrevDayCalls :: Call Name :: ' + prevCallActItemAnsRec.buzz_retail__Call__r.Name);
		    	system.debug('PrevDayCalls :: Answer::  ' + prevCallActItemAnsRec.buzz_retail__Answer__c);
		    		
		    		
		    	// Create a Unique key usinng the Action Item Name + Labatt Outlet ID to create a map of "ActionItemAnswer"
		    	// records which needs to be updated, once a previous call is identified with same Action Item and on same Account.
		    	String uniqueActItemAnsKey = prevCallActItemAnsRec.Name + prevCallActItemAnsRec.buzz_retail__Account__r.lboc_Labatt_Outlet_Id__c;
		    	system.debug('PrevDayCalls :: uniqueActItemAnswerKey :: ' + uniqueActItemAnsKey);
		    		
		    	if(!prevDayCallsMap.containsKey(uniqueActItemAnsKey))
		    	{
		        	prevDayCallsMap.put(uniqueActItemAnsKey,prevCallActItemAnsRec);
		    	}
			}
	 	}	
			
			
		// Create a new List object to store all the Action Item Answer records that needs to be updated.
		List<buzz_retail__ActionItem_Answer__c> actionItemAnswerList = new List<buzz_retail__ActionItem_Answer__c>();
			
		// Loop throuh the two Maps created to store the Next & Prev action item answers & populate the last value where
		// match found.
		if(nextDayCallsMap != null && nextDayCallsMap.size() > 0 && prevDayCallsMap != null && prevDayCallsMap.size() > 0)
		{
			for(String nextDayCallId : nextDayCallsMap.keySet())
			{
	    		if(prevDayCallsMap.containsKey(nextDayCallId))
	   			{
	        		buzz_retail__ActionItem_Answer__c actionItemAnswerRecord = nextDayCallsMap.get(nextDayCallId);
	        		actionItemAnswerRecord.lboc_Last_Value__c = prevDayCallsMap.get(nextDayCallId).buzz_retail__Answer__c;
	        		actionItemAnswerList.add(actionItemAnswerRecord);
	    		}
			}
				
			if(actionItemAnswerList != null && actionItemAnswerList.size() > 0)
			{
				update actionItemAnswerList;
			}			
		}
	}	

}