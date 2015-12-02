/**====================================================================
* Appirio, Inc
* Name: ProductSearchController
* Description: Controller class for MandateProductSearch, ProductExclusion, and ProductSearch pages
* Created Date: 27 August 2015
* Created By: Matt Salpietro (Appirio)
* 
* Date Modified                Modified By                  Description of the update
* 
=====================================================================*/
public without sharing class ProductSearchController {
  
  /* standard set controller used to filter data */
    private ApexPages.StandardSetController setCon {get;set;}

    /* returns the current page set records*/
    public List<SelectableProduct> records{
      get{
        List<SelectableProduct> result = new List<SelectableProduct>();
        for(US_Product__c p : (List<US_Product__c>)setCon.getRecords()){
          SelectableProduct sp = this.selectedProducts.get(p.Id);
          if(sp != null)
            result.add(sp);
          else
            result.add(new SelectableProduct(p,false,this));
        }
          return result;
      }
    }
    /* size of the result set */
    public Integer resultSize{
      get{
        return setCon.getResultSize();
      }
    }
    
    /* size of current page */
    public Integer pageSize{
      get{
        return setCon.getPageSize();
      }
    }
    
    /* size of current page */
    public Integer pageNumber{
      get{
        return setCon.getPageNumber();
      }
    }
    
    /* new page size */
    public Integer newPageSize{get;set;}
    
    /* total number of pages */
    public Integer totalPages{
      get{
        return (Integer)Math.ceil((Double)resultSize / (Double)pageSize);
      }
    }
    
    /* sorting field */
    public String sortField{get;set;}

    /* used to store the search filters */
    public String productName{get;Set;}
    public String productBrand{get;Set;}
    public String productFamily{get;Set;}
    public String productClass{get;Set;}

    /* selected all search results */
    public Boolean selectedAll{get;Set;}

    /* picklist value map */
    public Map<String,List<SelectOption>> picklistMap{get;Set;}
    
    /* selected products */
    public Map<ID,SelectableProduct> selectedProducts{get;Set;}
    
    /* maps values */
    public List<SelectableProduct> selectedProductsValues{
      get{
        List<SelectableProduct> result = this.selectedProducts.values();
        result.sort();
        return result;
      }
    }
    
    /* items selected? */
    public Boolean itemsSelected{
      get{
        return this.selectedProducts.size() > 0;
      }
    }
    
    /* given opportunity */
    public sObject parent{get;Set;}

    public String CHILD_OBJECT{get;Set;}
    public String CHILD_OBJECT_REL{get;Set;}
    public String PARENT_OBJECT{get;Set;}
    public String PARENT_FIELD{get;Set;}

    /* show step second step */
    public Boolean isSecondStep{get;Set;}
    
    /* items to be created */
    public List<SelectableProduct> lineItems{get;Set;}
    
    /* 
      utility class to handle product selection
      Has a link to the main controller to handle item selection 
    */
    public class SelectableProduct implements Comparable{
      //product
      public US_Product__c product{get;Set;}
      //is selected?
      public Boolean selected{get;Set;}
      //is selected?
      //public String status{get;Set;}
      //opportunityLineItem
      public sObject lineItem{get;Set;}
      //main controller
      public ProductSearchController controller{get;Set;}
      //exists on program
      public Boolean existing{get;Set;}
      /*
        Constructor
        @p - product
        @selected - selected item
        @controller - main controller
      */
      public SelectableProduct(US_Product__c p, Boolean selected, ProductSearchController controller){
        this.product = p;
        this.controller = controller;
        this.selected = selected;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(this.controller.CHILD_OBJECT);
        this.lineItem = targetType.newSObject();
        this.lineItem.put('Product__c', this.product.Id);
        this.existing = false;
      }
      
      /* adds or removes a selected item */
      public void selectItem(){
        SelectableProduct p  = this.controller.selectedProducts.get(this.product.Id);
        if(this.selected){
          if(p == null){
            this.controller.selectedProducts.put(this.product.Id,this);
          }else{
            //nothing to do: item is already selected
          }
        }else{
          this.controller.selectedProducts.remove(this.product.Id);
        }
      }
      
      /*
        Removes an item from the selected list
      */
      public void removeSelected(){
        this.selected = false;
        this.selectItem();
      }
      
      /* Comparable interace */
      public Integer compareTo(Object compareTo) {
        if((compareTo instanceof SelectableProduct) == false) return 1;
          SelectableProduct compareToSP = (SelectableProduct)compareTo;
          return this.product.Name.compareTo(compareToSP.product.Name);       
      }
      
      /* postback when selecting a linte item on step 2*/
      public void selectLineItem(){}
    }

    /*
      Select All records in set controller
    */
    public void selectAll(){
      Integer setPage = this.setCon.getPageNumber();
      Integer setSize = this.setCon.getPageSize();
      this.setCon.setPageSize(2000);
      for(Integer j = 1; j <= totalPages; j++) {
        this.setCon.setPageNumber(j);
        for(US_Product__c p : (List<US_Product__c>)setCon.getRecords()){
          SelectableProduct sp = this.selectedProducts.get(p.Id);
          if(sp == null && this.selectedAll){
            sp = new SelectableProduct(p,true,this);
            this.selectedProducts.put(p.Id,sp);
          } else if(sp != null && !this.selectedAll) {
            this.selectedProducts.remove(p.Id);
          }
        }
      }
      this.setCon.setPageSize(setSize);
      this.setCon.setPageNumber(setPage);
    }

    /*
      Get distinct values of fields on object for picklists
    */
    public Map<String,List<SelectOption>> getDistinctPicklistValues(Set<String> fields, String objectName){
      Map<String,Set<SelectOption>> selectOptionMap = new Map<String,Set<SelectOption>>();
      Map<String,List<SelectOption>> selectOptionLists = new Map<String,List<SelectOption>>();

      String queryString = 'SELECT Id';
      for(String f:fields){
        queryString += (queryString==''?'':',')+f;
        selectOptionMap.put(f, new Set<SelectOption>());
      }
      queryString += ' FROM '+objectName;

      for(sObject o : Database.query(queryString)){
        for(String f:fields){
          if((String)o.get(f) != null){
            selectOptionMap.get(f).add(new SelectOption((String)o.get(f),(String)o.get(f)));
          }
        }
      }

      for(String f:selectOptionMap.keySet()){
        List<SelectOption> options = new List<SelectOption>();
        options.addAll(selectOptionMap.get(f));
        options.sort();
        selectOptionLists.put(f,options);
      }
      return selectOptionLists;
    }
    
    /* constructor */
    public ProductSearchController(ApexPages.StandardController controller){

      this.parent = controller.getRecord();
      
      this.CHILD_OBJECT = ApexPages.currentPage().getParameters().get('child');
      this.PARENT_OBJECT = this.parent.getSObjectType().getDescribe().getName();
      for(Schema.ChildRelationship cr : this.parent.getSObjectType().getDescribe().getChildRelationships()){
        if(cr.getChildSObject().getDescribe().getName() == this.CHILD_OBJECT){
          this.CHILD_OBJECT_REL = (String)cr.getRelationshipName();
          this.PARENT_FIELD = (String)cr.getField().getDescribe().getName();
        }
      }
      String childQueryFields = '';
      Map<String, Schema.SObjectField> childObjectFields = Schema.getGlobalDescribe().get(CHILD_OBJECT).getDescribe().fields.getMap();
	  for(String s : childObjectFields.keySet()) {
	    childQueryFields += ' ' + s + ', ';
	  }

      this.selectedProducts = new Map<ID,SelectableProduct>();
      
      if(this.parent == null || String.isBlank((String)this.parent.get('Id'))){
        this.parent = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.parent.getSObjectType().getDescribe().getLabel()+'is required'));
        return;
      }
      
      this.parent = Database.query('SELECT Id, Name, (SELECT'+childQueryFields
        +' Product__r.Id, Product__r.Name, Product__r.PDCN_CD_US__c, Product__r.BRND_NM_US__c, Product__r.BRND_FAMLY_NM_US__c, Product__r.BRND_CTGY_NM_US__c, Product__r.SUBCTGY_NM_US__c,' 
        +' Product__r.CONT_CLASS_NM_US__c, Product__r.Container_Type__c FROM '+CHILD_OBJECT_REL+') FROM '+PARENT_OBJECT+' WHERE Id = \''+this.parent.get('Id')+'\'');
      for(sObject child : this.parent.getSObjects(CHILD_OBJECT_REL)) {
      	if(child.getSObject('Product__r') != null){
	        SelectableProduct sp = new SelectableProduct((US_Product__c)child.getSObject('Product__r'), true, this);
	        sp.existing = true;
	        sp.lineItem = child;
	        sp.selectItem();
    	}
      }

      this.productName = '';
      this.productFamily = '';
      this.productBrand = '';

      this.newPageSize = 10; 
      this.sortField = 'Name ASC';
      this.isSecondStep = false;
      this.selectedAll = false;
      
      picklistMap = getDistinctPicklistValues(new Set<String>{'BRND_NM_US__c', 'BRND_FAMLY_NM_US__c', 'CONT_CLASS_NM_US__c'},'US_Product__c');
      
      loadData();
    }
    
    /* go to first page */
    public void goToFirstPage(){
      this.setCon.first();
    }
    
    /* go to last page */
    public void goToLastPage(){
      this.setCon.last();
    }
    
    /* go to next page */
    public void goToNextPage(){
      this.setCon.next();
    }
    
    /* go to next 2 page */
    public void goToNext2Page(){
      goToNextPage();
      goToNextPage();
    }
    
    /* go to prev page */
    public void goToPrevPage(){
      this.setCon.previous();
    }
    
    /* go to prev 2 page */
    public void goToPrev2Page(){
      goToPrevPage();
      goToPrevPage();
    }
    
    /* return to program */
    public PageReference cancel(){
      PageReference pg = new PageReference('/'+this.parent.get('Id'));
      pg.setRedirect(true);
      return pg;
    }
    
    /* sort the recordset */
    public void sortRecordset(){
      Integer currentPage = this.pageNumber;
      loadData();
      this.setCon.setPageNumber(currentPage);
    }
    
    /* suggests product name*/
    @RemoteAction
    public static List<AggregateResult> searchFilters(String searchTerm, String searchField) {
        return Database.query('Select '+searchField+' from US_Product__c '
              +' where '+searchField+' like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' '
              +' GROUP BY '+searchField+' LIMIT 100');
    }
    
    /*
      Get all picklist values from a picklist field
    */
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
    List<String> lstPickvals=new List<String>();
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
      Sobject Object_name = targetType.newSObject();
      Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(a.getValue());//add the value  to our final list
       }
       lstPickvals.sort();
      return lstPickvals;
    }
     
     
    /*
      Reload the standard set controller with the new query
    */
    public void loadData(){
      //sorting
      String orderBy = this.sortField;
      if(orderBy.endsWith(' ASC')) orderBy += ' NULLS LAST';
      else orderBy += ' NULLS FIRST';
      String query = 'SELECT Id, Name, PDCN_CD_US__c, BRND_NM_US__c, BRND_FAMLY_NM_US__c, BRND_CTGY_NM_US__c, SUBCTGY_NM_US__c, CONT_CLASS_NM_US__c, Container_Type__c FROM US_Product__c ';
      List<String> andConditions = new List<String>();
        
      //filter name
      if (String.isBlank(this.productName) == false) {
        andConditions.add('Name LIKE \'%{!0}%\''.replace('{!0}',String.escapeSingleQuotes(this.productName)));
      }

      //filter BRND_NM_US__c
      if(String.isBlank(this.productBrand) == false){
        andConditions.add('BRND_NM_US__c = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.productBrand)));
      }

      //filter BRND_FAMLY_NM_US__c
      if(String.isBlank(this.productFamily) == false){
        andConditions.add('BRND_FAMLY_NM_US__c = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.productFamily)));
      }

      //filter CONT_CLASS_NM_US__c
      if(String.isBlank(this.productClass) == false){
        andConditions.add('CONT_CLASS_NM_US__c = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.productClass)));
      }
      
      //aggregate conditions
      if(andConditions.size() > 0){
        query += 'WHERE ('+String.join(andConditions,') AND (')+')';
      }
      
      query+=' Order By '+orderBy;
      query+=' limit 10000';

      if(andConditions.size() > 0){
        this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        this.setCon.setPageNumber(1);
        this.setCon.setPageSize(this.newPageSize);
      } else {
        this.setCon = new ApexPages.StandardSetController(new List<US_Product__c>());
      }
    }
    
    /*
      Save items
    */
    public PageReference saveData(){
      List<sObject> insertList = new List<sObject>();
      for (SelectableProduct sp : this.selectedProductsValues) {
        if(sp.existing != true){
          sp.lineItem.put(this.PARENT_FIELD, this.parent.get('Id'));
          insertList.add(sp.lineItem);
        }
      }
      try{
        insert insertList;
      }catch(DMLException e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
        return null;
      }
      PageReference pg = new PageReference('/'+this.parent.get('Id'));
      pg.setRedirect(true);
      return pg;
    }
}