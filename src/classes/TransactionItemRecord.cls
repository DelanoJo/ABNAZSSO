public class TransactionItemRecord {

	public static List<buzz_retail__ProductFormat__c> BuildListProductAndProductFormatForInventoryCapture() {		
		List<buzz_retail__Product__c> PossibleProducts = new List<buzz_retail__Product__c>([select Id from buzz_retail__Product__c where buzz_retail__Allow_Ordering__c=true and M_AllowInventory__c=true]);			
		return new List<buzz_retail__ProductFormat__c>([select Id,buzz_retail__Product__c from buzz_retail__ProductFormat__c where buzz_retail__Product__c in:PossibleProducts and M_Inventory__c=true]);		
	}

	public static Map<string,List<M_Inventory__c>> BuildMapInventoryForManualTransactions(set<string> DistributorsLocationsKeys,set<Id> PossibleDistributors) {
		
		Map<string,List<M_Inventory__c>> result= new Map<string,List<M_Inventory__c>>();
		For (M_Inventory__c i:[select id,M_Product__c,M_Product_Format__c,M_Distributor__c,M_Inventory_Location__c from M_Inventory__c where M_Distributor__c in:PossibleDistributors]) {
			string key=i.M_Distributor__c+''+i.M_Inventory_Location__c;
			if (DistributorsLocationsKeys.contains(key)) {
				List<M_Inventory__c> tmpList=result.containsKey(key)?result.get(key):new List<M_Inventory__c>();
				tmpList.add(i);
				result.put(key,tmpList);			
			}
		}				
		return result;
	}

	public static Map<Id,List<M_Transaction_Item__c>> BuildMapTransactionitems(List<M_Inventory_Transaction__c> InventoryTrans) {
		
		//Build Map of Outbound Transaction Items
		Map<Id,List<M_Transaction_Item__c>> MapTransItem = new Map<Id,List<M_Transaction_Item__c>>();
		for (M_Transaction_Item__c ti:[select Id, M_Actual_Qty__c,M_Adjustment_Type__c,M_Inventory_Transaction__c,M_Completed__c,M_Credit_Transaction__c,
		      M_From__c,M_Inventory__c,M_Inventory_Capture__c,M_Inventory_Count__c,M_IsMobile__c,M_Net_Qty__c,M_Order_Detail_Reference__c,
		      M_Product__c,M_Product_Format__c,M_Original_Qty__c,M_Qty_in_Transit__c,M_Qty_Transferred__c,M_Reason_for_Discrepancy__c,M_Record_Type__c,
		      M_OrderDetailReference__c,M_To__c,M_Transaction_Date__c
		      from M_Transaction_Item__c where M_Inventory_Transaction__c in :InventoryTrans]) {
			
			List<M_Transaction_Item__c> tmpList = MapTransItem.containsKey(ti.M_Inventory_Transaction__c)?MapTransItem.get(ti.M_Inventory_Transaction__c):new List<M_Transaction_Item__c>();
			tmplist.add(ti);
			MapTransItem.put(ti.M_Inventory_Transaction__c,tmpList);			
		}
		
		return MapTransItem;
		
	}
}