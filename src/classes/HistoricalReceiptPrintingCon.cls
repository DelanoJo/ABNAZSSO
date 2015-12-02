/**
 * Controller class for ViewReceipts vf page.
 */
public with sharing class HistoricalReceiptPrintingCon {
    
   public M_Order_sigcap_Header__c  order { get; set; }
   private ApexPages.StandardController con;
   
public HistoricalReceiptPrintingCon(ApexPages.StandardController controller) {
   con = controller;
   Id orderId= con.getId();
        
   string squery = 'Select m.SystemModstamp, m.SAP_Submitted_Date__c, m.SAP_Received_Date__c, m.SAP_Order_Number__c, m.RecordTypeId, m.OwnerId, m.Name, m.M_Total_Net_Amount__c, m.M_Total_CUT_Print__c, m.M_Total_CUT_Eaches__c, m.M_Total_CUT_Cases__c, m.M_Total_CUT_Cases_Eaches__c, m.M_Total_Amount__c, m.M_Total_Amount_Signed__c, m.M_Territory_Stamp__c, m.M_Taxes__c, m.M_Status__c, m.M_Signature__c, m.M_Shipping_ZIP_Postal_Code__c, m.M_Shipping_State__c, m.M_Shipping_Instructions__c, m.M_Shipping_Country__c, m.M_Shipping_City__c, m.M_Shipping_Address__c, m.M_SAP_Submitted_Date__c, m.M_SAP_Received_Date__c,';
   //, m.CurrencyIsoCode
   squery = squery + ' m.M_Route_Number__c, m.M_Required_Delivery_Date__c, m.M_Record_Type__c, m.M_Receipt_Print_Time__c, m.M_Receipt_Print_Date_c__c, m.M_Receipt_Number__c, m.M_Receipt_Copies__c, m.M_Read_Only__c, m.M_P_O_Number__c, m.M_Order__c, m.M_Order_Transaction_Type__c, m.M_Order_Suffix__c, m.M_Order_Item_Discounts__c, m.M_Order_Inventory_Account__c, m.M_Order_Discount__c, m.M_Order_Date__c, m.M_Number_of_Items__c, m.M_Last_Receipt_Number__c, m.M_Kam_Territory_Stamp__c, m.M_Is_Mobile__c, m.M_Inventory_TransactionType__c, m.M_Inventory_Submitted__c, m.M_First_Print__c, m.M_FinalOrder__c, m.M_ERP_Order_No__c, m.M_Duplicate_Original__c, m.M_Document_Number__c, m.M_Document_Description__c, m.M_Distributor__c, m.M_DetailIsCloned__c, m.M_DC_Name_Stamp__c, m.M_Customer_Reference__c, m.M_Contact__c, m.M_CheckSoldTo__c, m.M_CancelledOrder__c, m.M_Call__c, m.M_Call_Date__c, m.M_Account_Name_Stamp__c, m.M_Account_ID_Stamp__c, m.M_AccountName__c, m.LastModifiedDate, m.LastModifiedById, m.LastActivityDate, m.IsDeleted, m.Inventory_Location__c, m.Id, m.CreatedDate, m.CreatedById, m.Call_Account_Id__c, m.Account_RecordTypeId__c, m.Account_Is_Inventory_Location__c From M_Order_sigcap_Header__c m';
   squery = squery + ' where id= ' + '\'' +orderId +'\'';
    
    
   system.debug('********LN Query ' + squery);
   this.order = database.query(squery);     
      
}
  
	@RemoteAction
	public static List<M_Historical_Receipt_Printings__c> loadHRP(String OrderId) {
		// add required fields to the map
		Map<String, String> fieldsMap = new Map<String, String>();
		fieldsMap.put('Name', null);
		fieldsMap.put('M_Siganture__c', null);
		fieldsMap.put('M_Requested_Delivery_Date__c', null);
		fieldsMap.put('M_Receipt_Print_Time__c', null);
		fieldsMap.put('M_Receipt_Print_Date__c', null);
		fieldsMap.put('M_Receipt_Date__c', null);
		fieldsMap.put('M_Order__c', null);
		fieldsMap.put('M_Order_Total_Net__c', null);
		fieldsMap.put('M_Order_Status_When_Printed__c', null);
		fieldsMap.put('M_Order_Number__c', null);
		fieldsMap.put('M_Order_Line_Items__c', null);
		fieldsMap.put('M_Order_CUT__c', null);
		fieldsMap.put('M_HTML_Last_Section__c', null);
		fieldsMap.put('M_HTML_First_Section__c', null);
		fieldsMap.put('M_Copy_Number__c', null);

		// add fields from fieldset to make it a complete list of fields to query
		for (FieldSetMember fs : Schema.SObjectType.M_Historical_Receipt_Printings__c.fieldSets.getMap().get('HRPList').getFields()) {
			fieldsMap.put(fs.getFieldPath(), null);
		}
		
		string sQuery = 'Select '
						+ Util.buildDelimitedString(fieldsMap.keyset(), ',')
						+ ' From M_Historical_Receipt_Printings__c'
						+ ' where M_Order__c = ' + '\'' + orderId + '\''
						+ ' order by  M_Receipt_Date_Time__c';
						
		List<M_Historical_Receipt_Printings__c> ListHRP = Database.query(sQuery);
		system.debug('HRP' + ListHRP);

		if (ListHRP == null)
			return new List<M_Historical_Receipt_Printings__c> ();
		else
			return ListHRP;                                                        
	}
  
  /**
   * Navigate back to account page
   */
    public PageReference close() {
      return new PageReference('/' + this.order.Id);
    }
    
  public String nameSpace {
        get {
            if(nameSpace == null) {
                nameSpace = Util.getBuzzNamespace();
            }
            return nameSpace;
        }
        private set;   
  }
    
}