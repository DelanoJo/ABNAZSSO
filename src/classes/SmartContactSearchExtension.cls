/***********************************************************************
 Class 			: SmartContactSearchExtension
 Author 		: Appirio
 Created Date 	: 4 march 2014
 Descritption 	: Provide functionality to contact search.
 ************************************************************************/

public without sharing class SmartContactSearchExtension {
    
    //Search criteria fields
    public String contactFirstNameToSearch {set;get;}
    public String contactLastNameToSearch {set;get;}
    public String contactEmail {set;get;}
    public STring contactAccount {get;set;}
    public String leadFirstNameToSearch {set;get;}
    public String leadLastNameToSearch {set;get;}
    public String leadEmail {set;get;}
    public STring leadAccount {get;set;}
    public String resetTextBoxName {set; get;}
    public String filterCriteria {get;set;}
    public String filterLeadCriteria {get;set;}
    public String contactFieldCsv {get;set;}
    public String leadFieldCsv {get;set;}
    public String soslSearchStringForContact {get;set;}
    public String soslSearchStringForLead {get;set;}
    public Boolean isContactSearchWithSOSL {get;set;}
    public Boolean isLeadSearchWithSOSL {get;set;}
    
    //Constructor
    public SmartContactSearchExtension(ApexPages.StandardController controller) {         
        init();
    }    
    
    //Constructor
    public SmartContactSearchExtension() {            
        init();
    }
    
    private void init(){
    	isContactSearchWithSOSL = DuplicateContact__c.getInstance().Search_Using_SOSL__c;
    	isLeadSearchWithSOSL =  DuplicateLead__c.getInstance().Search_Using_SOSL__c; 
    	resetSearchStatus(); 
    	contactAccount = ApexPages.currentPage().getParameters().get('accName');
        createContactFieldCsv();
        createLeadFieldCsv();
    }
    
    // Method for create csv of field from fieldset of Contact
    private void createContactFieldCsv(){
	    contactFieldCsv = SmartSearchUtility.createFieldCsv('Contact','Contact_Search_Result');
    }
    
    // Method for create csv of field from fieldset of Lead
    private void createLeadFieldCsv(){
	    leadFieldCsv = SmartSearchUtility.createFieldCsv('Lead', 'lead_search_result' );
    }

    //set to default status of page
    public void resetSearchStatus(){        
        //Reset Contact fields
        
        if(resetTextBoxName != ''){
            if(resetTextBoxName=='1'){
                 contactFirstNameToSearch = '';
            }
            else if(resetTextBoxName=='2'){
                 contactLastNameToSearch = '';
            }
            else if(resetTextBoxName=='3'){
                 contactEmail = '';
            }
            else if(resetTextBoxName=='4'){
                 contactAccount = '';
            }  
            performSearch();      
        }
        else{    
            contactFirstNameToSearch = '';
            contactLastNameToSearch = '';
            contactEmail = '';
            contactAccount = ApexPages.currentPage().getParameters().get('accName');
            filterCriteria = '';
            filterLeadCriteria = '';
            soslSearchStringForContact = '';
            soslSearchStringForLead = '';
            populateLeadFields();
        }
    }
    
    //Method for populate lead fields from contact fields for search
    public void populateLeadFields(){
    	leadFirstNameToSearch = contactFirstNameToSearch ;
        leadLastNameToSearch = contactLastNameToSearch ;
        leadEmail = contactEmail ;
        leadAccount = contactAccount ;
    }
    
    
    // Method to create filter criteria string for contact search
    public String findSearchCondition(){     
      
      String query = '';
      soslSearchStringForContact = '';
      
      if(String.isNotBlank(contactAccount)){
          contactAccount = contactAccount.replace('*','');
          contactAccount = String.escapeSingleQuotes(contactAccount);
		  
		  if(isContactSearchWithSOSL){
		  	
        String dynamicQuery = 'FIND \'' + contactAccount.Trim() + '*\' IN ALL FIELDS RETURNING Account ( Name, Id ) LIMIT 100';
		  	List<List<SObject>>searchList=search.query(dynamicQuery);
		  	for(sObject obj : searchList[0]){
		  		query += 'AccountId = \'' + String.valueOf(obj.get('Id')) + '\' OR ';
		  	}
        if(String.isNotBlank(query)){
          query = ' (' + query.substring(0,query.lastindexof('OR ')) + ') AND';
        }
			isContactSearchWithSOSL = false;  
		  }
		  else{
		  	query += ' Account.Name like \'%' + contactAccount.Trim() + '%\' AND';
		  }
      }
      
      if(isContactSearchWithSOSL && String.isNotBlank(contactFirstNameToSearch)){
      	soslSearchStringForContact += contactFirstNameToSearch + ' OR ';
      }
      
      if(String.isNotBlank(contactLastNameToSearch)){
          contactLastNameToSearch = contactLastNameToSearch.replace('*','');
          contactLastNameToSearch = String.escapeSingleQuotes(contactLastNameToSearch);
          query += ' LastName like \'%' + contactLastNameToSearch.Trim() + '%\' AND';
          if(isContactSearchWithSOSL){
          	soslSearchStringForContact += contactLastNameToSearch.Trim() + ' OR ';
          }
      }
      if(String.isNotBlank(contactEmail)){
          contactEmail = contactEmail.replace('*','');
          contactEmail = String.escapeSingleQuotes(contactEmail);
          query += ' Email like \'%' + contactEmail.Trim() + '%\' AND';
          if(isContactSearchWithSOSL){
          	soslSearchStringForContact += contactEmail.Trim() + ' OR ';
          }
      }
      
     
      
      if(String.isNotBlank(query)){
      	query = query.substring(0,query.lastindexof('AND'));
      }
      if(isContactSearchWithSOSL && String.isNotBlank(soslSearchStringForContact)){
      	soslSearchStringForContact = soslSearchStringForContact.substring(0,soslSearchStringForContact.lastindexof(' OR '));
      }
      system.debug(query);
      system.debug(soslSearchStringForContact);
    return query;
  }
    
  // Method to create filter criteria string for lead search
  public String findLeadSearchCondition(){     
      
      String query = '';
      
      soslSearchStringForLead = '';
      
      if(isLeadSearchWithSOSL && String.isNotBlank(leadFirstNameToSearch)){
      	soslSearchStringForLead += leadFirstNameToSearch + ' OR ';
      }
      
      if(String.isNotBlank(leadLastNameToSearch)){
          leadLastNameToSearch = leadLastNameToSearch.replace('*','');
          leadLastNameToSearch = String.escapeSingleQuotes(leadLastNameToSearch);
          query += ' LastName like \'%' + leadLastNameToSearch.Trim() + '%\' AND';
          
          if(isLeadSearchWithSOSL){
          	soslSearchStringForLead += leadLastNameToSearch.Trim() + ' OR ';
          }
      }
      if(String.isNotBlank(leadEmail)){
          leadEmail = leadEmail.replace('*','');
          leadEmail = String.escapeSingleQuotes(leadEmail);
          query += ' Email like \'%' + leadEmail.Trim() + '%\' AND';
          
          if(isLeadSearchWithSOSL){
          	soslSearchStringForLead += leadEmail.Trim() + ' OR ';
          }
      }
      
      if(String.isNotBlank(leadAccount)){
          leadAccount = leadAccount.replace('*','');
          leadAccount = String.escapeSingleQuotes(leadAccount);
          query += ' Company like \'%' + leadAccount.Trim() + '%\' AND';
          
          if(isLeadSearchWithSOSL){
          	soslSearchStringForLead += leadAccount.Trim() + ' OR ';
          }
      }
      
      if(String.isNotBlank(query)){
      	query = query.substring(0,query.lastindexof('AND'));
      }
      
      if(isLeadSearchWithSOSL && String.isNotBlank(soslSearchStringForLead)){
      	soslSearchStringForLead = soslSearchStringForLead.substring(0,soslSearchStringForLead.lastindexof(' OR '));
      }
      
      return query;
   }
    
   public void performSearch() {
    	populateLeadFields();
    	filterCriteria = findSearchCondition();	
    	filterLeadCriteria = findLeadSearchCondition();       
   } 
   
   public pagereference createNewContact(){
   	    String recordType = ApexPages.currentPage().getParameters().get('RecordType');
   		Pagereference pg = new Pagereference('/' + SmartSearchUtility.getPrefix('Contact') + '/e?retURL=/apex/SmartContactSearch&nooverride=1&name_firstcon2=' + contactFirstNameToSearch + '&name_lastcon2=' + contactLastNameToSearch + '&con15=' + contactEmail + '&con4=' + contactAccount + (String.isEmpty(recordType) ? '' : '&RecordType=' + recordType ));
		pg.setRedirect(true);
		return pg;
	}
	
	public pagereference createNewLead(){
		Pagereference pg = new Pagereference('/' + SmartSearchUtility.getPrefix('Lead') + '/e?retURL=/apex/SmartContactSearch&nooverride=1&name_firstlea2=' + leadFirstNameToSearch + '&name_lastlea2=' + leadLastNameToSearch + '&lea11=' + leadEmail + '&lea3=' + leadAccount);
		pg.setRedirect(true);
		return pg;
	}   

}