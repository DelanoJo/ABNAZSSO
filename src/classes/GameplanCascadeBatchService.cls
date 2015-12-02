/*
 *  Gameplan Batch Service to execute the logic to create Gameplan Report for each Sales Rep user.
 */
public class GameplanCascadeBatchService 
{
	// Method to create the Gameplan Detail record.
	public static void createGameplanDetailRecords(List<buzz_retail__Promotion_Account__c> promoAcctResultSet)
	{
		// List to store all Gameplan Detail records.
	    List<lboc_Gameplan__c> gameplanList = new List<lboc_Gameplan__c>();
		for(buzz_retail__Promotion_Account__c promoAcct : promoAcctResultSet)
    	{
    		lboc_Gameplan__c gamePlanRec = new lboc_Gameplan__c();
    		system.debug('***************************START****************************');
    		system.debug('Promotion ID :: ' + promoAcct.buzz_retail__Promotion__c);
    		gamePlanRec.lboc_Promotion_Name__c = promoAcct.buzz_retail__Promotion__c;
    		system.debug('Account ID :: ' + promoAcct.buzz_retail__Account__c);
    		gamePlanRec.lboc_Account_Name__c = promoAcct.buzz_retail__Account__c;
    		system.debug('Promotion Account Id ::' + promoAcct.Id);
    		gamePlanRec.lboc_Promotion_Account__c = promoAcct.Id;
    		system.debug('Promotion Account in Store Start Date :: ' + promoAcct.buzz_retail__In_Store_Start_Date__c);
    		gamePlanRec.lboc_In_Store_Start_Date__c = promoAcct.buzz_retail__In_Store_Start_Date__c;
    		system.debug('Promotion Account in Store End Date  :: ' + promoAcct.buzz_retail__In_Store_End_Date__c);
    		gamePlanRec.lboc_In_Store_End_Date__c = promoAcct.buzz_retail__In_Store_End_Date__c;
    		system.debug('Account Owner Id ::' + promoAcct.buzz_retail__Account__r.OwnerId);
    		gamePlanRec.OwnerId = promoAcct.buzz_retail__Account__r.OwnerId;
    		system.debug('Account Sales Territory ::' + promoAcct.buzz_retail__Account__r.lboc_Sales_Territory__c);
    		gamePlanRec.lboc_Sales_Territory__c = promoAcct.buzz_retail__Account__r.lboc_Sales_Territory__c;
    		system.debug('Account Region ::' + promoAcct.buzz_retail__Account__r.lboc_Region__c);
    		gamePlanRec.lboc_Region__c = promoAcct.buzz_retail__Account__r.lboc_Region__c;
    		system.debug('Account District ::' + promoAcct.buzz_retail__Account__r.lboc_District__c);
    		gamePlanRec.lboc_District__c = promoAcct.buzz_retail__Account__r.lboc_District__c;
    		system.debug('Account Area ::' + promoAcct.buzz_retail__Account__r.lboc_Area__c);
    		gamePlanRec.lboc_Area__c = promoAcct.buzz_retail__Account__r.lboc_Area__c;
    		
   			
   			Decimal soldInKits = 0;
    		for(lboc_Promotion_Sold_in_Kit__c promoSoldKit : promoAcct.Promotion_Sold_in_Kits__r)
    		{
        		system.debug('Promotion Sold In Kit ::' + promoSoldKit.lboc_No_Kits_Sold_in__c);
        		soldInKits += promoSoldKit.lboc_No_Kits_Sold_in__c;
    		}
    		gamePlanRec.lboc_Allocation_Utilized__c = soldInKits;
    		//Qualified by default 1
    		gamePlanRec.lboc_Qualified__c = 1;
    		
    		system.debug('Promotion Sell in status ::' + promoAcct.lboc_Promotion_Sell_in_Status__c);
    		
    		// Promotion Sell in status logic.
    		if(promoAcct.lboc_Promotion_Sell_in_Status__c == 'Sold-In')
    		{
    			gamePlanRec.lboc_Accepted__c = 1;	
    		}
    		else if(promoAcct.lboc_Promotion_Sell_in_Status__c == 'Not Planned')
    		{
    			gamePlanRec.lboc_Executed__c = 1;
    		}
    		else if(promoAcct.lboc_Promotion_Sell_in_Status__c == 'Denied')
    		{
    			gamePlanRec.lboc_Denied__c = 1;
    		}
    		else if(promoAcct.lboc_Promotion_Sell_in_Status__c == 'Planning')
    		{
    			gamePlanRec.lboc_Planned__c = 1;
    		}
    		
    		
    		String sortOrder = 'D-' + promoAcct.buzz_retail__Account__r.lboc_Sales_Territory__c;
			gamePlanRec.lboc_Sort_Order__c = sortOrder; 
    		
    		// Set the Gameplan Type
    		gamePlanRec.lboc_type__c = 'Detail Record';
    		 
    		system.debug('***************************END****************************');
    		gameplanList.add(gamePlanRec);
    	}
    	
    	
    	
    	
    	insert gameplanList;
	}
	
	// Method to create the Gameplan Summary Records
	public static void createGameplanSummaryRecords()
	{
		
		
		
		Map<String,Decimal> kitsAllocation = new Map<String,Decimal>();
		for(AggregateResult ar : [select lboc_Promotion__c,lboc_Sales_Territory__c,
									SUM(lboc_Total_Kits_Available__c) totKitsAvail
									from lboc_Kit__c Group by 
									lboc_Promotion__c,lboc_Sales_Territory__c])
		{
			String concatKey = ar.get('lboc_Promotion__c') + '_' + ar.get('lboc_Sales_Territory__c');
			kitsAllocation.put(concatKey,(Decimal)ar.get('totKitsAvail'));
			system.debug('ID :::: ' + ar.get('lboc_Promotion__c'));
    		system.debug('ID :::: ' + ar.get('lboc_Sales_Territory__c'));
    		system.debug('ID :::: ' + ar.get('totKitsAvail'));
		}
		
		
		
		// List to store all Gameplan Summary records.
		List<lboc_Gameplan__c> summaryGameplanList = new List<lboc_Gameplan__c>();
		// Group the Gameplan records by Promotion & Sales Territory to create the summary records.
		for(AggregateResult ar : [select lboc_Promotion_Name__c,lboc_Sales_Territory__c,lboc_Region__c,lboc_District__c,lboc_Area__c,
									lboc_Promotion_Name__r.buzz_retail__In_Store_Start_Date__c stDate,
									lboc_Promotion_Name__r.buzz_retail__In_Store_End_Date__c edDate,
									OwnerId,
									SUM(lboc_Accepted__c) totAccepted,SUM(lboc_Denied__c) totDenied,
									SUM(lboc_Allocated__c) totAllocated,SUM(lboc_Planned__c) totPlanned,
									SUM(lboc_Executed__c) totExecuted,SUM(lboc_Qualified__c) totQualified,
									SUM(lboc_Allocation_Utilized__c) totAllocationUtil
									from lboc_Gameplan__c Group by 
									lboc_Promotion_Name__c,lboc_Sales_Territory__c,lboc_Region__c,lboc_District__c,lboc_Area__c,OwnerId,
									lboc_Promotion_Name__r.buzz_retail__In_Store_Start_Date__c,lboc_Promotion_Name__r.buzz_retail__In_Store_End_Date__c])
			
		{
			String concatKey = ar.get('lboc_Promotion_Name__c') + '_' + ar.get('lboc_Sales_Territory__c');
			lboc_Gameplan__c gamePlanRec = new lboc_Gameplan__c();
   			system.debug('Promotion :: ' + ar.get('lboc_Promotion_Name__c'));
   			gamePlanRec.lboc_Promotion_Name__c = (ID)ar.get('lboc_Promotion_Name__c');
   			
   			system.debug('In Store Start Date ::' + ar.get('stDate'));
   			gamePlanRec.lboc_In_Store_Start_Date__c = (Date)ar.get('stDate');
   			
			system.debug('In Store End Date ::' + ar.get('edDate'));
   			gamePlanRec.lboc_In_Store_End_Date__c = (Date)ar.get('edDate');
   			
   			system.debug('Owner Id ::' + ar.get('OwnerId'));
   			gamePlanRec.OwnerId = (Id)ar.get('OwnerId');
   			
   			
  			system.debug('Total Sold-in :: ' + ar.get('totAccepted'));
  			gamePlanRec.lboc_Accepted__c = (Decimal)ar.get('totAccepted');
  			
			system.debug('Total Denied :: ' + ar.get('totDenied'));
			gamePlanRec.lboc_Denied__c = (Decimal)ar.get('totDenied');
			
			system.debug('Total Planned :: ' + ar.get('totPlanned'));
			gamePlanRec.lboc_Planned__c = (Decimal)ar.get('totPlanned');
			
			system.debug('Total Not Planned :: ' + ar.get('totExecuted'));
			gamePlanRec.lboc_Executed__c = (Decimal)ar.get('totExecuted');
			
			system.debug('Total Allocation Utilized :: ' + ar.get('totAllocationUtil'));
			gameplanRec.lboc_Allocation_Utilized__c = (Decimal)ar.get('totAllocationUtil');
			
			
			if(kitsAllocation.containsKey(concatKey))
			{
				system.debug('Total Allocated :: ' + ar.get('totAllocated'));
				gamePlanRec.lboc_Allocated__c = kitsAllocation.get(concatKey);
			}	
			
			system.debug('Total Qualified :: ' + ar.get('totQualified'));
			gamePlanRec.lboc_Qualified__c = (Decimal)ar.get('totQualified');
			
			system.debug('Sales Territory ::' + ar.get('lboc_Sales_Territory__c'));
			gamePlanRec.lboc_Sales_Territory__c = (String)ar.get('lboc_Sales_Territory__c');
			
			system.debug('Region ::' + ar.get('lboc_Region__c'));
			gamePlanRec.lboc_Region__c = (String)ar.get('lboc_Region__c');
			
			system.debug('Area ::' + ar.get('lboc_Area__c'));
			gamePlanRec.lboc_Area__c = (String)ar.get('lboc_Area__c');
			
			system.debug('District ::' + ar.get('lboc_District__c'));
			gamePlanRec.lboc_District__c = (String)ar.get('lboc_District__c');
			
			String sortOrder = 'A-' + (String)ar.get('lboc_Sales_Territory__c');
			gamePlanRec.lboc_Sort_Order__c = sortOrder; 
			
			// Set the Gameplan Type
    		gamePlanRec.lboc_type__c = 'Summary Record';
			summaryGameplanList.add(gamePlanRec);
		}
		insert summaryGameplanList;
		
	}
	
}