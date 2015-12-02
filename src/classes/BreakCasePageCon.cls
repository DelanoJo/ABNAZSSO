global with sharing class BreakCasePageCon {

    private ApexPages.StandardController con;

	string AccountId;

	public String selectedInventoriesString {get; set;}

    public BreakCasePageCon(ApexPages.StandardController controller) {
        con = controller;
        AccountId = con.getid();
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

    public Id GetInvLocation{get;set;}

    public List<SelectOption> GetInvLocationList() {
    	List<SelectOption> options = new List<SelectOption>();
    	for (M_Inventory_Location__c il: [select Id,Name,Default_Disbursement_Location__c from M_Inventory_Location__c where M_Distributor__c=:AccountId ORDER BY Name]) {
			options.add(new SelectOption(il.id,il.name));
			if (il.Default_Disbursement_Location__c==true)
				GetInvLocation=il.id;
    	}

		return options;
    }

    public PageReference doNothing() {
        return null;
    }

    public PageReference Close(){
        return new PageReference('/' + AccountId);
    }

    @RemoteAction
    global static List<M_Inventory__c> loadInventories(Id InvLocationId) {
    	//M_Merck_Product_Code__c,
        return [SELECT Id, Name,M_Inventory_Location__c,M_Distributor__c,
        			M_BreakCase__c,M_BatchExpiration__c,M_IsMobile__c,M_LastCaseBorken__c,
        			M_Owner__c,M_Product__c,M_Product_Format__c,M_ProductBatch__c,M_UPC_Code__c,M_StockQtyAtHand__c,M_StockQtyinTransit__c
                    FROM M_Inventory__c
                    WHERE M_Inventory_Location__c =:InvLocationId and M_FormatCode__c='Case'];
    }

    //Break Case
    public void BreakSelectedItems() {
    	List<Id> selectedInventories = ListFromIdString(selectedInventoriesString);

  	    if (selectedInventories.size()==0 || selectedInventories==null ||selectedInventoriesString==''||selectedInventoriesString==null ) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Select at least one inventory.');
            ApexPages.addMessage(myMsg);
		}
		else {
			//Check if "Each" exist for all products
			set<Id> PossibleProducts = new Set<Id>();
	    	for (M_Inventory__c inv :[select Id, M_Product__c from M_Inventory__c where Id in:selectedInventories] )
	    		PossibleProducts.add(inv.M_Product__c);

			Map<Id,Id> MapProductEaches = new Map<Id,Id>();
			for (buzz_retail__ProductFormat__c pf:[select Id,buzz_retail__Product__c from buzz_retail__ProductFormat__c where buzz_retail__Product__c in :PossibleProducts and buzz_retail__FormatCode__c='Each'])
	    		MapProductEaches.put(pf.buzz_retail__Product__c,pf.id);	
			boolean MissingEach=false;

			for (Id prodId:PossibleProducts) {
				if (!MapProductEaches.containsKey(prodId))
					MissingEach=true;
			}
			if (MissingEach==true) {
	    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'One of the selected inventory product does not have an "Each" format defined.');
	            ApexPages.addMessage(myMsg);
	    	}
			else {
				//Process
				InventoryTransactionRecord.ProcessInventoryBreak(selectedInventories);
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Operation succesfully completed.');
            	ApexPages.addMessage(myMsg);

				Close();
			}
		}
    }

    private static List<Id> ListFromIdString(String idListString) {
		if (idListString.trim() == '')
			return new List<Id>();

		List<Id> idList = new List<Id>();

		for(String s : idListString.split(',')) {
	   		idList.add((Id)s.trim());
		}
		return idList;
	}
}