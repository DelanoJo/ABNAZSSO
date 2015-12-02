/***********************************************************************
 Class 			: SmartSearchUtility
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Class contains utility methods for smart search
 ************************************************************************/

global class SmartSearchUtility {
	
	// Method for query an sobject and return the list of values for the search field
	WebService static List<String> getAutoFillValues(String searchValue, String objectApiName, String fieldApiNameToSearch) {
	 	List<String> lstExistingValues = new List<String>();
	 	
	 	if(String.isNotBlank(searchValue)){
		 	
		 	String dynamicQuery = 'FIND \'' + searchValue.Trim() + '*\' IN ALL FIELDS RETURNING ' + objectApiName + '(' + fieldApiNameToSearch + ') LIMIT 10';
		 	List<List<SObject>>searchList=search.query(dynamicQuery);
		 	
		 	for(sObject obj : searchList[0]){
		 		lstExistingValues.add(String.valueOf(obj.get(fieldApiNameToSearch)));
		 	}
		 	
	 	}
		return lstExistingValues;
    }
    
    // Method to return CSV values of the API names of the fields based on the fieldset values of an object
    public static string createFieldCsv(String objectApiName, String fieldSetName){
    	
    	string fieldCsv = '';
    	try{
    		if(String.isNotBlank(objectApiName) && String.isNotBlank(fieldSetName)){
		    	for(Schema.FieldSetMember fieldSetMember : Schema.getGlobalDescribe().get(objectApiName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields()) {
			        fieldCsv += fieldSetMember.getFieldPath() + ',';
			    }
			    Set<String> setFieldsApi = new Set<String>(fieldCsv.split(','));
			    if(!setFieldsApi.contains('Id')){
			    	fieldCsv += 'Id,';
			    }
    		}
		    if(String.isBlank(fieldCsv)){
		    	fieldCsv += 'Name,Id,';
		    }
    	}
    	catch(Exception ex){
    		fieldCsv += 'Name,Id,';
    	}
	    fieldCsv = fieldCsv.subString(0,fieldCsv.lastIndexOf(','));
	    return fieldCsv;
    } 
    
    
    public static string getPrefix(String objectApiName){
		String objPrefix = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getkeyprefix();
		return objPrefix;
    }
    

}