public without sharing class OpenLookupPopupCtrl {

    public List<Sobject> listRecords {get;set;}
    public List<String> listFieldNames {get; set;}
    public String selectedObject;
    public String fieldName;
    public String searchText{get;set;}
    public String fieldSetName;
    public String filterName {get;set;}
    public String filterValue {get;set;}
  
  public OpenLookupPopupCtrl(){
      selectedObject = ApexPages.currentPage().getParameters().get('Object');
      fieldName = ApexPages.currentPage().getParameters().get('fieldName');
      searchText = ApexPages.currentPage().getParameters().get('searchText');
      fieldSetName = ApexPages.currentPage().getParameters().get('fieldSetName');
      filterName = ApexPages.currentPage().getParameters().get('filterName');
      filterValue = ApexPages.currentPage().getParameters().get('filterValue');
      
      List<SObject> listRecords = new List<SObject>();
      runSearch();
    }
    
    /********************************************************************************************************************
    * Method to run the search with parameters passed via Page Parameters
    *********************************************************************************************************************/
    public PageReference runSearch() {
        
        String fieldsToFetch = getFieldsForSelectedObject();
        String whereClause = ''; 
        if(fieldsToFetch != null && fieldsToFetch != ''){
          String searchString = 'Select ' + fieldsToFetch + ' From ' + selectedObject;
          if(searchText != '' && searchText != null){
            whereClause = ' Where ' + fieldName  + ' LIKE \'%' + String.escapeSingleQuotes(searchText)+'%\'';
          }
          
          if(filterName != null && filterName != '' && filterValue != null && filterValue != ''){
          	if(whereClause != '' ){
          		whereClause += ' and ' + filterName + '=\'' + filterValue + '\'';
          	} else{ 
          		whereClause += ' Where ' + filterName + '=\'' + filterValue + '\'';
          	}
          }
          listRecords = Database.query(searchString + whereClause + ' order by Name  limit 50');
        }
        return null;
    }
    
    /********************************************************************************************************************
    * Method to Get all Fields of the selected object
    *********************************************************************************************************************/
    public String getFieldsForSelectedObject(){    
       listFieldNames = new List<String>(); 
       List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>();
       String fieldsToFetch = '';
       try{
           if(selectedObject != null && selectedObject != ''){             

                Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
          Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(selectedObject);
          Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
          
          if(DescribeSObjectResultObj.FieldSets.getMap().ContainsKey(fieldSetName)){
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            fieldSetMemberList =  fieldSetObj.getFields(); 
          }
          
          for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            listFieldNames.add(string.ValueOf(fieldSetMemberObj.getFieldPath()));
        }
            }
           
           //Building Query with the fields
      Integer i = 0; 
      Integer len = listFieldNames.size();
      for(String temp:listFieldNames){
        if(i==len-1){
          fieldsToFetch = fieldsToFetch + temp;
        } else {
          fieldsToFetch = fieldsToFetch + temp + ',';
        }
        i++;
      }
        }catch(Exception ex){          
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                'There is no Field for selected Object!'));
        }       
        if(fieldsToFetch != '') return fieldsToFetch;
        else return 'Name';
        
    }  
}