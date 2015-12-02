public class RecType {
 
    public enum Name {
    
        //Account
        Customer,
        Distribution_Center,
        Distribution_Center_with_Inventory,
        Manufacturer,
        Outlet,
        Territory,
        // Order
        Customer_Order_from_SSR,
        Customer_Returns_to_RDC, 
        Customer_Returns_to_SSR,
        Direct_Store_Delivery,
        Replenishment,
        Customer_Return_to_RDS,
        Customer_Return_to_SSR_Van,
        DSD_from_SSR_Van,
        //Inventory Transaction
        Adjustment,
        Break_Case,
        Inbound_Transfer,
        Inventory_Capture,
        Order,
        Returns,
        Outbound_Transfer,
        Sample_Drop,
        Item
        //
                 
    }
    private static final String SEPARATOR = '::::';
    private static Map<String, Id> CACHE;
    /**
     * Get the Id that can be set on or compared with an SOBject's RecordTypeId field.
     * Backed by a cache of all record type ids for the duration of a request.
     */
    public static Id getId(SObjectType sobType, Name developerName) {
        if (CACHE == null) {
            CACHE = new Map<String, Id>();
            for (RecordType rt :  [
                    SELECT Id, SObjectType, DeveloperName
                        FROM RecordType
                        WHERE DeveloperName in :getNames()]) {
                CACHE.put(rt.SObjectType + SEPARATOR + rt.DeveloperName, rt.Id);
            }
        }
        String devName = developerName.name();

        return CACHE.get(String.valueOf(sobType) + SEPARATOR + devName);
    }
    
    
    private static Set<String> getNames() {
        Set<String> names = new Set<String>();
        for (Name name : Name.values()) 
            names.add(name.name());
            
        return names;
    }


	// ------------------------------------------------------------------------------
	// Input Parameter 1- SObject API Name , e.g. Account, Contact, CustomObject__c
	// Input Parameter 2- RecordType Name , e.g. Business Account, Person Account
	// ------------------------------------------------------------------------------
	// Returns- Id of RecordType 
	// e.g ID RecordTypeId = getRecordTypeId('Account' , 'Record Type Label'); 
	// ------------------------------------------------------------------------------
    public static id getRecordTypeId(String ObjectType, String RecordTypeLabel)  
    {   
		SObject OBJ;  
		// Describing Schema  
		Schema.SObjectType Res = Schema.getGlobalDescribe().get(ObjectType);  
		if (Res != null){  
			OBJ = Res.newSObject();  
	  		// Describing Object   
	  		Schema.DescribeSObjectResult DesRes = OBJ.getSObjectType().getDescribe();   
	  		if (DesRes != null){  
	    		Map<String, Schema.RecordTypeInfo> RecordTypeMap=DesRes.getRecordTypeInfosByName();  
	    		if (RecordTypeMap != null){  
	        		Schema.RecordTypeInfo RecordTypeRes = RecordTypeMap.get(RecordTypeLabel);  
	        		if (RecordTypeRes != null){  
	           			return RecordTypeRes.getRecordTypeId();  
	        		}  
	      		}  
	   		}  
   		}  
		return null;  
    }

}