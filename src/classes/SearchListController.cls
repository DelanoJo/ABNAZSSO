public with sharing class SearchListController {

    String objectLabel;
    String objectLabelPlural;
    Boolean showNewButton;
    public ApexPages.StandardSetController ssc {get; set;}
    public List<String> fieldNames {get; set;}
    public Map<String,String> fieldAlignMap {get; set;}
    public Map<String,String> nameLabelMap {get; set;}
    transient Schema.DescribeSObjectResult objectDescribe;
    public Id deleteRecordId {get; set;}
    public String sortByField {get; set;}
    public Map<String,String> fieldSortDirectionMap {get; set;}
    
    public String newRecordUrl{get;set;}
    public Integer pageNumber {get;set;}
    public Boolean isSearchStarted {get;set;}
    
    //----Variables set from attributes defined in the component----
    public String objectName {get; set;}
    public String fieldsCSV {get; set;}
    public List<String> fieldsList {get; set;}
    public String searchFieldName {get; set;}
    public String searchFieldValue {get; set;}
    public String filter {get; set;}
    public String orderByFieldName {get; set;}
    public String sortDirection {get; set;}
    public Integer pageSize {get; set;}
    public String title {get;set;}
    public String returnUrl {get;set;}
    public String soslSearchString {get;set;}
    public Boolean isSearchUsingSOSL {get;set;}
    
    private string previousSearchFieldValue;
    private string previousFilter;
    
    public List<sObject> records {
    	get{
            if(String.IsBlank(searchFieldValue) && String.IsBlank(filter)){
                isSearchStarted = false;
                return new List<sObject>();
            }
    		if(ssc != null){

    			if(previousSearchFieldValue != searchFieldValue || previousFilter != filter){
    				
    				if(String.IsBlank(searchFieldValue) && String.IsBlank(filter)){
		    			return new List<sObject>();
		    		}
    				previousSearchFieldValue = searchFieldValue;
    				previousFilter = filter;
    				return getSearchResult();
    			}
    			else{
	    			pageNumber = ssc.getPageNumber();
	    			return ssc.getRecords();
    			}
    			
    		} 
    		else if(String.IsNotBlank(searchFieldValue) || String.IsNotBlank(filter)){
    			getSearchResult();
    		}
    		return new List<sObject>();
    	}
    	set;
    }
    	
    public SearchListController(){
    	records = new List<sObject>();
    	isSearchStarted = false;
    }
    
    
    public List<sObject> getSearchResult(){
    	
        //Do validation to ensure required attributes are set and attributes have correct values
        //fieldList or fieldsCSV must be defined
        Boolean validationPass = true;
        
        if(fieldsList == null && fieldsCSV == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'fieldList or fieldsCSV attribute must be defined.'));
            validationPass = false;
        }
        
        //Ensure sortDirection attribute has value of 'asc' or 'desc'
        if(sortDirection != null && sortDirection != 'asc' && sortDirection != 'desc'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'sortDirection attribute must have value of "asc" or "desc"'));
            validationPass = false;
        }
        
        //Ensure search string for SOSL should be provided if searching using SOSL'
        if(isSearchUsingSOSL == true && String.isBlank(soslSearchString)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Should provide search string for SOSL query.'));
            validationPass = false;
        }
        
        //Proceed with returning the related list if validation passed
        if(validationPass == false){
            return null;
        }else{
        	
        	isSearchStarted = true;
            //Build the query string dynamically
            String queryString = isSearchUsingSOSL ? 'FIND \'' : 'SELECT ';
            
            /*If field CSV was defined use this and also add fields to the fieldNames
            List so they can be used with Visualforce dynamic binding to define coloumns*/
            if(fieldsCSV != null){
                fieldNames = fieldsCSV.split(',');
            }else{
                //Add fields to fieldNames list so it can be used with VF dynamic binding to define coloumns
                fieldNames = fieldsList.clone();
            }
        	
                               
            String filterCriteria = ''; 
            if(String.isNotBlank(searchFieldValue)){
            	filterCriteria += searchFieldName + ' LIKE \'%' + searchFieldValue.trim() + '%\'';
            }
            
            //Add any addtional filter criteria to query string if it was defined in component
            if(filter != null && filter.length() > 0 ){
                filterCriteria += ( String.isBlank(filterCriteria) ? '' : ' AND ' ) + filter;             
            }
            
            
            
            queryString += isSearchUsingSOSL ? ( soslSearchString + '\' IN ALL FIELDS RETURNING ' + objectName + '(' +  String.Join(fieldNames, ',') ) 
            			   : ( String.Join(fieldNames, ',') + ' FROM ' + objectName  ) ;   
            
	        queryString += String.IsNotBlank(filterCriteria) ? ( ' WHERE ' + filterCriteria ) : '' ;
	          
            //Add order by field to query if defined in component
            //If sortByField != null then user has clicked a header and sort by this field
            if(sortByField != null){
                queryString += ' ORDER BY ' + sortByField;
            }else if(orderByFieldName != null){
                queryString += ' ORDER BY ' + orderByFieldName;
            }
            
            //If sortByField != null then user has clicked a header, sort based on values stored in map
            if(sortByField != null){
                //Use a map to store the sort direction for each field, on first click of header sort asc
                //and then alternate between desc
                if(fieldSortDirectionMap == null){
                    fieldSortDirectionMap = new Map<String,String>();                   
                }
                
                String direction = '';
                
                //check to see if field has direction defined, if not or it is asc, order by asc 
                if(fieldSortDirectionMap.get(sortByField) == null || fieldSortDirectionMap.get(sortByField) == 'desc' ){
                    direction = 'asc';
                    fieldSortDirectionMap.put(sortByField,'asc');
                }else{
                    direction = 'desc';
                    fieldSortDirectionMap.put(sortByField,'desc');
                }
                
                queryString += ' ' + direction; 
            }else if(sortDirection != null){
                //Add sort direction to query if defined in component
                queryString += ' ' + sortDirection;             
            }
            
            queryString += isSearchUsingSOSL ? ' ) ' : ( ' limit ' + (Limits.getLimitQueryRows() - Limits.getQueryRows()));  
	            
                 
            System.debug('--Query--: ' + queryString);
            
            //Query records and setup standard set controller for pagination
            if(isSearchUsingSOSL){
	            List<List<SObject>>searchList=search.query(queryString);
	            ssc = new ApexPages.StandardSetController(searchList[0]);
            }
            else{
            	ssc = new ApexPages.StandardSetController(Database.query(queryString));
            }
            
            //Check to see if more than 10,000 records where return, if so display warning as standard set controller can only process 10,000 recores
            if(ssc.getCompleteResult() == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There were more related records than could be processed. This is a partially complete list.'));
            }
            
            //Set pagination size based on value set in component
            if(pageSize != null){
                ssc.setPageSize(pageSize);
            }       
                
            /*For the fields that will be displayed identify the field type and set styleClass for
            cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
            //Get the meta data info for the fields is the related object
            Map<String, Schema.SObjectField> fieldMap = getObjectDescribe().fields.getMap(); 
            
            //For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
            fieldAlignMap = new Map<String,String>();
            nameLabelMap = new Map<String,STring>();
            for(String fld : fieldNames){
            	fld = fld.trim();
            	if(fieldMap.containsKey(fld)){
                    String fieldType = fieldMap.get(fld).getDescribe().getType().name();    

                    if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
                        fieldAlignMap.put(fld,'alignRight');
                    }else{
                        fieldAlignMap.put(fld,'alignLeft');
                    }   
                    
                    //Add to name->label map
                    String label = fieldMap.get(fld).getDescribe().getLabel().removeEnd(' ID');
                    nameLabelMap.put(fld,label);
            	}
            	
            }
    	}
        if(ssc != null){
        	records = ssc.getRecords();
        }
        system.debug('----records----' + records);
        return records;
    }
   
    
    public PageReference newRedirectPage()
    {
        if(newRecordurl!='' && newrecordurl!=null)
        {    
            PageReference pageRef = new PageReference(newRecordurl);
            pageRef.setRedirect(false);
            return pageRef;
        }
        else
        return null;
    }
    
    public Boolean getShowNewButton(){
        //Display new button if user has create permission for related object
        return getObjectDescribe().isCreateable();
    }
    
    public DescribeSObjectResult getObjectDescribe(){
        /*Returns object describe for list object. This is used in many places so we are using a dedicated method that only invokes 
        Schema describe calls once as these count against Apex limits. Because this method returns a DescribeSObjectResult all the get 
        methods for this object can be used directly in Visualforce: {!objectDescribe.label}*/
        if(objectDescribe == null){
            objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();  
        }
        return objectDescribe;
    }
    
    public void sortByFieldAction(){
        //Making ssc variable null will cause getRecords method to requery records based on new sort by field clicked by user
        ssc = null;
        getSearchResult();
    }
      
    public void deleteRecord(){
        //Delete the selected object
        for(sObject obj : ssc.getRecords()){
            if(obj.get('Id') == deleteRecordId){
                delete obj;
                break;              
            }
        }
        
        /*There is no way to modify the collecton used in a standard set controller so we will make it null and call getRecord
        method. This will reload the set of records*/
        //Save the current page number so we can keep user on same page in the set after delete
        Integer pageNumber = ssc.getPageNumber();
        
        //Make ssc variable null and execute get method
        ssc = null;
        getSearchResult();
        
        /*Set the correct page number. If record deleted was a single record on the last page set the number of pages in 
        the new set will decrease by 1, need to check for this. If the total number of pages is less than than the previous 
        page number set the current page to the previous last page - 1 */
        Decimal rSize = ssc.getResultSize();
        Decimal pageSize = ssc.getPageSize();
        
        if(( rSize / pageSize).round(System.RoundingMode.UP) < pageNumber){
            ssc.setPageNumber(pageNumber - 1);
        }else{
            ssc.setPageNumber(pageNumber);
        }
    }
    
    
}