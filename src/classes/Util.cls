public with sharing class Util {

    public static String NS_DEFAULT = 'NS_BUZZ';
    private static String sBuzzNameSpace = NS_DEFAULT;
    
    public static String getBuzzNamespace(){

        Schema.DescribeSobjectResult pObjDescr = (new buzz_retail__Call__c()).getsObjectType().getDescribe();

        // Give back the cached value, if present
        if(!sBuzzNameSpace.equals(NS_DEFAULT) || pObjDescr == null)
            return sBuzzNameSpace;

        String reqName = pObjDescr.getName();

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        // Loop until we find something in the form of a namespace: namespaceprefix__objname__c
        for(SObjectType sObfjType: gd.values()){
            String name = sObfjType.getDescribe().getName();

            if(name != null && name.equalsIgnoreCase(reqName)){
                List<String> nameParts = name.split('__');
                if(nameParts.size() == 3){
                    sBuzzNameSpace = nameParts[0];
                    break;
                }
            }
        } // end loop

        return sBuzzNameSpace;
    }
    
    // Returns the output if the input is null.
    public static String IsNull(String input, String output)
    {
      String result = input;
      
      //TODO: NEED TO RAISE AN ERROR MESSAGE IF THE OUTPUT IS NULL 
      //if (output == null)
      //    input.addError('Util.IsNull: Output parameter cannot be null');
                  
      if (result == null)
            result = output;
            
      return result;    
    }
    
    //copied methods needed for ApexServices.copyFields only
    /********************************************************************************/
    public static boolean isString(SObjectField pField){
        return contains(STRING_TYPES, pField.getDescribe().getType());
    }

    public static boolean isInteger(SObjectField pField){
        return contains(INTEGER_TYPES, pField.getDescribe().getType());
    }

    public static boolean isID(SObjectField pField){
        return contains(ID_TYPES, pField.getDescribe().getType());
    }

    public static boolean isDouble(SObjectField pField){
        return contains(DOUBLE_TYPES, pField.getDescribe().getType());
    }

    public static boolean isDate(SObjectField pField){
        return contains(DATE_TYPES, pField.getDescribe().getType());
    }

    public static boolean isDateTime(SObjectField pField){
        return contains(DATETIME_TYPES, pField.getDescribe().getType());
    }

    public static boolean isBoolean(SObjectField pField){
        return contains(BOOLEAN_TYPES, pField.getDescribe().getType());
    }
    
    private static Boolean contains(List<Schema.DisplayType> pListActingAsSet, Schema.DisplayType pTypeToCheck){
        if(pListActingAsSet != null && pListActingAsSet.size() > 0){
            for(Schema.DisplayType aType : pListActingAsSet){
                if(aType == pTypeToCheck)
                    return true;
            }
        }
        return false;
    }
    
    private static final List<Schema.DisplayType> STRING_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.base64
        ,Schema.DisplayType.Email
        ,Schema.DisplayType.MultiPicklist
        ,Schema.DisplayType.Phone
        ,Schema.DisplayType.Picklist
        ,Schema.DisplayType.String
        ,Schema.DisplayType.TextArea
        ,Schema.DisplayType.URL
    };
    private static final List<Schema.DisplayType> INTEGER_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.Integer
    };
    private static final List<Schema.DisplayType> ID_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.ID
        ,Schema.DisplayType.Reference
    };
    private static final List<Schema.DisplayType> DOUBLE_TYPES  = new List<Schema.DisplayType>{
        Schema.DisplayType.Currency
        ,Schema.DisplayType.Double
        ,Schema.DisplayType.Percent
    };
    private static final List<Schema.DisplayType> DATETIME_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.DateTime
    };
    private static final List<Schema.DisplayType> DATE_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.Date
    };
    private static final List<Schema.DisplayType> BOOLEAN_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.Boolean
        ,Schema.DisplayType.Combobox
    };
    
    private static Map<String, Map<String, Schema.SObjectField>> sCashedFields = new Map<String, Map<String, Schema.SObjectField>>();
    
    public static Map<String, Schema.SObjectField> fields(Schema.SObjectType pObjType){
        if(sCashedFields.containsKey(pObjType.getDescribe().getName()))
            return sCashedFields.get(pObjType.getDescribe().getName());

        Map<String, Schema.SObjectField> fields = pObjType.getDescribe().fields.getMap();
        sCashedFields.put(pObjType.getDescribe().getName(), fields);
        return fields;
    }
    
    public static SObject copyFields(SObject pSource,  SObject pDestination, boolean pForceNulls){
        Map<String, Schema.SObjectField> sourceFields = fields(pSource.getSObjectType());
        Map<String, Schema.SObjectField> destinationFields = fields(pDestination.getSObjectType());
        // Keep only matching fields, based on the name, and field that were retreived in the source record.
        Set<String> copyFields = new Set<String>();
        for(String fieldName: destinationFields.keySet()){
            try{
                if(sourceFields.containsKey(fieldName)){
                    pSource.get(fieldName);
                    copyFields.add(fieldName);
                }
            }
            catch(System.SObjectException e){/* Do Nothing; skip field if it was not retrieved */}
        }
     
        for(String fieldName: copyFields){
            Schema.SObjectField sourceField = sourceFields.get(fieldName);
            Schema.SObjectField destinationField = destinationFields.get(fieldName);
            // AZ: do not change these conditions. Very sensitive code.
            boolean isCopyPermitted = !destinationField.getDescribe().isAutoNumber()
                && !destinationField.getDescribe().isCalculated()
                && sourceField.getDescribe().getType() == destinationField.getDescribe().getType()
                && sourceField.getDescribe().isAccessible()
                && destinationField.getDescribe().isAccessible()
                && destinationField.getDescribe().isUpdateable()
                && (pDestination.ID == null && destinationField.getDescribe().isCreateable()
                    || pDestination.ID != null && destinationField.getDescribe().isUpdateable())
                && (pForceNulls || pSource.get(fieldName) != null);
            
            if(isCopyPermitted){
                if(isID(destinationField)){
                    pDestination.put(destinationField, (Id)pSource.get(sourceField));                   
                }
                else if(isString(destinationField)){
                    pDestination.put(destinationField, (String)pSource.get(sourceField));                   
                }
                else if(isInteger(destinationField)){
                    pDestination.put(destinationField, (Integer)pSource.get(sourceField));                                  
                }
                else if(isDouble(destinationField)){
                    pDestination.put(destinationField, (Double)pSource.get(sourceField));                   
                }
                else if(isDate(destinationField)){
                    pDestination.put(destinationField, (Date)pSource.get(sourceField));                                 
                }
                else if(isDateTime(destinationField)){
                    pDestination.put(destinationField, (DateTime)pSource.get(sourceField));                 
                }
                else if(isBoolean(destinationField)){
                    pDestination.put(destinationField, (Boolean)pSource.get(sourceField));                  
                }
                else{
                    pDestination.put(destinationField, pSource.get(sourceField));
                }
            }
        }
        return pDestination;
    }
    
    /**
     * Create a string of all the passed IDs
     */
    public static String buildDelimitedString(Set<String> st, String delimiter) {
        String result = '';
        if (st == null || st.isEmpty()) {
            return result;
        }
        
        for (String s : st) {
            if (result.length() == 0) {
                result = s;
            } else {
                result += delimiter + s;
            }
        }
        
        return result;
    }
        
    /********************************************************************************/
    
    
    // Get RecordType ID by Object Recordtype label
    // Returns Id of RecordType 
    // e.g ID RecordTypeId = getRecordTypeId('Account' , 'Record Type Label'); 
    // Added CBINOVI 10-8-2015
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