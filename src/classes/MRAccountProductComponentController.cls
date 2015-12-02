/**====================================================================
 * Appirio, Inc
 * Name: MRAccountProductComponentController
 * Description: Controller for MRAccountProductComponent
 * Created Date: 2 November 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
public without sharing class MRAccountProductComponentController {
	public Milestone1_Project__c program {get;set;}

	public List<SelectOption> accountOptions {get;set;}

	public String selectedAccountId {get;set;}
	public String initialAccountId {get;set;}

	public Account selectedAccount {get;set;}

	public List<SObject> retAuthList {get;set;}

  	private Map<Id,SObject> mraMap;

  	public String fieldsCSV {get;set;}

  	public Id recordId {
  		get{
  			getRecords();
  			return initialRecordId;
  		}
  		set{
  			initialRecordId = value;
  		}
  	}

  	private Id initialRecordId;

  	public String accountField {get;set;}

  	public String childObject {get;set;}

  	public String programId {get;set;}

  	public List<String> fieldNames {get;set;}

  	public Map<String,String> nameLabelMap {get;set;}

	public MRAccountProductComponentController() {}

	public void getRecords(){
        //String objectType = initialRecordId.getSobjectType().getDescribe().getName();

        //if(objectType == 'Milestone1_Project__c'){
        //  programId = initialRecordId;
        //} else if(objectType == 'Milestone1_Task__c'){
        //  programId = [SELECT Project_Milestone__r.Project__c FROM Milestone1_Task__c WHERE Id = :initialRecordId LIMIT 1].Project_Milestone__r.Project__c;
        //}

		if(initialRecordId == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Program or Task and Account is required'));
			return;
		}

		if(fieldsCSV != null){ 
	        fieldNames = fieldsCSV.split(',');
        }

        String objectType = initialRecordId.getSobjectType().getDescribe().getName();

        if(objectType == 'Milestone1_Project__c'){
        	programId = initialRecordId;
        } else if(objectType == 'Milestone1_Task__c'){
        	programId = [SELECT Project_Milestone__r.Project__c FROM Milestone1_Task__c WHERE Id = :initialRecordId LIMIT 1].Project_Milestone__r.Project__c;
        }

		program = [SELECT Name FROM Milestone1_Project__c WHERE Id = :programId];

		accountOptions = new List<SelectOption>();
      	if(initialAccountId==null){
      		String query = 'SELECT '+accountField+'__r.Id RetailerId, '+accountField+'__r.Name RetailerName '+
	      				   'FROM Milestone1_Task__c '+
	      				   'WHERE Project_Milestone__r.Project__c = \''+programId+'\' '+
	      				   'AND '+accountField+'__c != null '+
	      				   'GROUP BY '+accountField+'__r.Name, '+accountField+'__r.Id '+
	      				   'ORDER BY '+accountField+'__r.Name';
      		for(AggregateResult ar : Database.query(query)){
      			accountOptions.add(new SelectOption((String)ar.get('RetailerId'),(String)ar.get('RetailerName')));
      			system.debug(((String)ar.get('RetailerId')));
      		}
      	} else {
      		selectedAccount = [SELECT Id, Name FROM Account WHERE Id = :initialAccountId];
      		accountOptions.add(new SelectOption(selectedAccount.Id,selectedAccount.Name));
      	}

      	if(accountOptions.size()>0){
      		SObjectType childObjectType = Schema.getGlobalDescribe().get(childObject);
			Map<String,Schema.SObjectField> objectFields = childObjectType.getDescribe().fields.getMap();

			nameLabelMap = new Map<String,String>();
	        for(String fld : fieldNames){
	        	fld = fld.trim();
	        	if(objectFields.containsKey(fld)){
	            	String label = objectFields.get(fld).getDescribe().getLabel();
	        		nameLabelMap.put(fld,label);
	            }
	        }

      		selectedAccountId = accountOptions[0].getValue();
      		loadData();
      		//return retAuthList;
      	} else {
      		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Retailers or Wholesalers found for Program'));
	        return;
      	}
	}

    public void loadData(){
    	system.debug(selectedAccountId);
    	retAuthList = new List<SObject>();
    	mraMap = new Map<Id,SObject>();
    	String query = 'SELECT Id,';
    	query += fieldsCSV;
    	query += ',MR_Product__c,MR_Product__r.Product__r.Name,MR_Product__r.Product__c,MR_Product__r.Product__r.Container_Type__c,LastModifiedById,LastModifiedDate';
    	query += ' FROM '+childObject;
    	query += ' WHERE MR_Product__r.Program__c = \''+program.Id+'\'';
    	query += ' AND '+accountField+'__c = \''+selectedAccountId+'\'';
    	system.debug(query);
    	for(SObject mra : Database.query(query)){
    		mraMap.put((Id)mra.getSObject('MR_Product__r').get('Product__c'),mra);
    	}
    	Schema.SObjectType childObjectType = Schema.getGlobalDescribe().get(childObject);
    	for(Market_Ready_Product__c mrp : [SELECT Id, Product__r.Name, Product__r.Container_Type__c, Product__r.Id, Product__c
    									   FROM Market_Ready_Product__c
    									   WHERE Program__c = :program.Id
    									   AND (NOT Product__r.Id IN :mraMap.keySet())]){

    		SObject newMRA = childObjectType.newSObject();
    		newMRA.put(accountField+'__c', selectedAccountId);
    		newMRA.putSObject('MR_Product__r', mrp);
    		newMRA.put('MR_Product__c', mrp.Id);

    		mraMap.put(mrp.Product__c,newMRA);
		}
		retAuthList.addAll(mraMap.deepClone().values());
		if(retAuthList.size() == 0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Products found for Program'));
	        return;
		}
    }

    //----------------------------------------------------------------------------------------------------------
    // Returns true if field value is added or changed
    //----------------------------------------------------------------------------------------------------------
    public static Boolean isNewOrChanged(Sobject obj, String fldNames, Sobject oldObj) {
      if (obj != null && fldNames != null && oldObj != null) {
        for(String fldName : fldNames.split(',')){
          system.debug('Old Value: ' + oldObj.get(fldName) + ' New Value: '+ obj.get(fldName));
          if(obj.get(fldName) != oldObj.get(fldName)){
            return true;
          }
        }
      }
      return false;
    }

    public Boolean saveData(){
      List<SObject> updatedAuthorizations = new List<SObject>();
      List<SObject> newAuthorizations = new List<SObject>();
      for(SObject pa : retAuthList){
        SObject oldPA = mraMap.get((Id)pa.getSObject('MR_Product__r').get('Product__c'));
        if(isNewOrChanged(pa,fieldsCSV,oldPA)){
        	if(pa.get('Id')==null){
        		newAuthorizations.add(pa);
        	} else {
        		updatedAuthorizations.add(pa);
        	}
        }
      }
      try{
        update updatedAuthorizations;
        insert newAuthorizations;
        return true;
      }catch(DMLException e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)+' for Product: '+retAuthList[e.getDmlIndex(0)].getSObject('MR_Product__r').getSObject('Product__r').get('Name')));
        return false;
      }
    }

    public PageReference save(){
    	if(saveData()){
        loadData();
    	  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Saved'));
      }
    	return null;
    }

    public PageReference saveAndClose(){
    	saveData();
    	PageReference pg = new PageReference('/'+initialRecordId);
      	pg.setRedirect(true);
      	return pg;
    }

}