/*
 * Handler class to execute the Logic to update the Item Price list records.
 */
public class ItemPriceListUpdateHandler 
{
	
	// Method to update the Item Price records.
	public static void updateItemPriceListRecords(List<M_Order_sigcap_Header__c> updOrdersList)
	{
		// Map to store the Order detail record from where data needs to be read and populate into the Price list.
		Map<String,M_Order_Detail__c> prevOrderDetail1Map = new Map<String,M_Order_Detail__c>();
		Map<String,M_Order_Detail__c> prevOrderDetail2Map = new Map<String,M_Order_Detail__c>();
		
		// Map to store the Final Orders that needs to be processed.
		Map<Id,M_Order_sigcap_Header__c> finalOrderIdsMap = new Map<Id,M_Order_sigcap_Header__c>();
		
		// Set to store "Account Id" that needs to be processed.
		Set<Id> accountIds = new Set<Id>();
		
		// Item Price Ids associated with the Order Detail Records.
		Set<String> prev1ItemPriceIds = new Set<String>();
		Set<String> prev2ItemPriceIds = new Set<String>();
		
		// Loop through the Orders which are updated and execute the logic if order status is Final.
		system.debug('Orders to update :: ' + updOrdersList.size());
		for(M_Order_sigcap_Header__c orderRec : updOrdersList)
		{
			system.debug('Status of Order :: ' + orderRec.M_Status__c + ' ::: ' + orderRec.Name);
			
			if(orderRec.M_Status__c == 'Final')
			{
				finalOrderIdsMap.put(OrderRec.Id,orderRec);
				accountIds.add(orderRec.M_AccountName__c);
			}
			
		}
		
		if(finalOrderIdsMap != null && finalOrderIdsMap.size() > 0)
		{
			// Populate all the prevOrderDetail1List.
			for(M_Order_Detail__c prevOrderDetail1Rec : [Select Id,Name,M_Qty_Ordered__c,M_Item_Price__c,M_Order__r.M_AccountName__c,M_Item_Price_ID__c,M_Product_Name__r.name from M_Order_Detail__c where M_Order__c =: finalOrderIdsMap.keySet()])
			{
				system.debug('Order Detail Stuff :: ' + prevOrderDetail1Rec.Id + ' :::: ' + prevOrderDetail1Rec.Name);
				prevOrderDetail1Map.put(prevOrderDetail1Rec.M_Item_Price_ID__c,prevOrderDetail1Rec);
			}
		    
		    // Get the last 3 updated records.
			for(M_Order_sigcap_Header__c ordRecord : [Select Id, Name, M_AccountName__c, (Select Id,Name,M_Qty_Ordered__c,M_Item_Price__c,M_Item_Price_ID__c,M_Product_Name__r.name from Order_Details__r ) from M_Order_sigcap_Header__c where M_AccountName__c =: accountIds and M_Status__c = 'Final' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 2])
			{
				
				if(!finalOrderIdsMap.containsKey(ordRecord.Id))
				{
					for(M_Order_Detail__c prevOrderDetail2Rec : ordRecord.Order_Details__r)
					{
						prevOrderDetail2Map.put(prevOrderDetail2Rec.M_Item_Price_ID__c,prevOrderDetail2Rec);	
					}
				}
			}
		
		
			//Get all the Item Price records that needs to be updated.
			List<M_Item_Price__c> prev1ItemPriceList = new List<M_Item_Price__c>();
			List<M_Item_Price__c> prev2ItemPriceList = new List<M_Item_Price__c>();
			
			for(M_Item_Price__c itemPriceRec : [Select Id,lboc_Prev_Qty_Ordered_1__c,lboc_Prev_PTR_1__c from M_Item_Price__c where M_Item_Price__c.M_Price_List__r.M_Account__c =: accountIds])
			{
				
				// Populate Prev 1 values.
				if(prevOrderDetail1Map.containsKey(itemPriceRec.Id))
				{
					
					M_Order_Detail__c orderDetailRecord = prevOrderDetail1Map.get(itemPriceRec.Id);
					system.debug('Prev Qty Ordered 1 :: ' + orderDetailRecord.M_Qty_Ordered__c);
					itemPriceRec.lboc_Prev_Qty_Ordered_1__c = orderDetailRecord.M_Qty_Ordered__c;
					itemPriceRec.lboc_Prev_PTR_1__c = orderDetailRecord.M_Item_Price__c;
				}
				else
				{
					itemPriceRec.lboc_Prev_Qty_Ordered_1__c = 0;
				}
				prev1ItemPriceList.add(itemPriceRec);
			}
			
			update prev1ItemPriceList;
			
			
			for(M_Item_Price__c itemPriceRec : [Select Id,lboc_Prev_PTR_2__c,lboc_Prev_Qty_Ordered_2__c from M_Item_Price__c where M_Item_Price__c.M_Price_List__r.M_Account__c =: accountIds])
			{
				
				// Populate Prev 2 values.
				if(prevOrderDetail2Map.containsKey(itemPriceRec.Id))
				{
					M_Order_Detail__c orderDetailRecord = prevOrderDetail2Map.get(itemPriceRec.Id);
					itemPriceRec.lboc_Prev_Qty_Ordered_2__c = orderDetailRecord.M_Qty_Ordered__c;
					itemPriceRec.lboc_Prev_PTR_2__c = orderDetailRecord.M_Item_Price__c;
				}
				else
				{
					itemPriceRec.lboc_Prev_Qty_Ordered_2__c = 0;
				}
				prev2ItemPriceList.add(itemPriceRec);
			}
			
			update prev2ItemPriceList;
	
		}	
	}
}