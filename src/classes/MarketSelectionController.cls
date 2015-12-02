/**====================================================================
 * Appirio, Inc
 * Name: MarketSelectionController
 * Description: Controller for MarketSelection.page
 * Created Date: 20 August 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 21 Aug 2015                  Parul Gupta                  Added tasks Creation functionality
 =====================================================================*/
public without sharing class MarketSelectionController {

    /* record type names and id map */
    private static final String TASK_RT_RETAILER = 'Retailer Alignment';
    private static final String TASK_RT_WHOLESALER = 'Wholesaler Alignment';
    private static final String PROGRAM_TASK_OBJ_NAME = 'Milestone1_Task__c';
    private static Map<String,Schema.RecordTypeInfo> rtMapByName;
    static{
         rtMapByName = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName();
    }

    /* given program */
    public Milestone1_Project__c program{get;Set;}
    
    /* returns the current search results */
    public List<SelectableAccount> records{
      get{
        List<SelectableAccount> result = new List<SelectableAccount>();
        if(searchCon.getPage(searchPage) != null){
          for(SelectableAccount sa : (getWrapperList(searchCon.getPage(searchPage)))){
            SelectableAccount saSelected = this.selectedAccounts.get(sa.account.Id);
            if(saSelected != null)
              result.add(saSelected);
            else
              result.add(sa);
          }
        }
          return result;
      } set;
    }

    /* returns list of selected wholesalers */
    public List<selectableAcct> selectedWSLRs{
      get{
        if(wslrCon.totalRecords > 0){
          if(wslrCon.getPage(wslrPage) != null){
            return getAcctWrapperList(wslrCon.getPage(wslrPage));
          } else {
            return getAcctWrapperList(wslrCon.getPage(1));
          }
        } else {
          return new List<SelectableAcct>();
        }
      } set;
    }
    
    /* returns list of selected decision points */
    public List<SelectableAccount> selectedAccountsValues{
      get{
        retailerCon.setPagination(this.selectedAccounts.values());
        if(retailerCon.getPage(retailerPage) != null){
          return getWrapperList(retailerCon.getPage(retailerPage));
        } else {
          return getWrapperList(retailerCon.getPage(1));
        }
      }
    }

    /* new page size */
    public Integer newPageSize{get;Set;}
    
    /* sorting field */
    public String sortField{get;Set;}
    
    /* selected all results */
    public Boolean selectedAll{get;Set;}

    /* total Selected POCs */
    public Integer totalPOCCount{
      get{
        Integer pocCount = 0;
        for(SelectableAccount acct : selectedAccounts.values()){
          pocCount += acct.pocIdSet.size();
        }
        return pocCount;
      }
    }

    /* used to store the search filters */
    public String accountName{get;Set;}
    public String parentName{get;Set;}
    public String accountState{get;Set;}
    public String retailSegment{get;Set;}
    
    public List<SelectOption> stateList{
      get{
        if(stateSelectOptions == null){
          stateSelectOptions = new List<SelectOption>();
          for(US_State_Codes__c sc : US_State_Codes__c.getall().values()){
            stateSelectOptions.add(new SelectOption(sc.Code__c,sc.Code__c));
          }
        }
        return stateSelectOptions;
      }
    }

    public List<SelectOption> segmentList{
      get{
        if(segmentSelectOptions == null){
          segmentSelectOptions = new List<SelectOption>();
          for(String s : getPicklistValues('Account','RTL_SEG_NM_US__c')){
            segmentSelectOptions.add(new SelectOption(s,s));
          }
        }
        return segmentSelectOptions;
      }
    }

    private List<SelectOption> segmentSelectOptions;
    private List<SelectOption> stateSelectOptions;

    /* map of selected decision points */
    public Map<ID,SelectableAccount> selectedAccounts{get;Set;}

    /* items selected? */
    public Boolean itemsSelected{
      get{
        return this.selectedAccounts.size() > 0;
      }
    }
    
    /* show step second step */
    public Boolean isSecondStep{get;Set;}
    
    /* Integration User Id */
    private String integrationUserId {get;set;}

    /* set controllers */
    public PaginationUtility retailerCon {get; set;}
    public PaginationUtility searchCon {get; set;}
    public PaginationUtility dpCon {get; set;}
    public PaginationUtility wslrCon {get; set;}
  
    /* controller page numbers */
    public Integer retailerPage {get; set;}
    public Integer dpPage {get; set;}
    public Integer wslrPage {get; set;}
    public Integer searchPage {get; set;}

    public Integer newConPage {get; set;}
    public Integer curCon {get; set;}
    
    /* constructor */
    public MarketSelectionController(ApexPages.StandardController controller){
      wslrPage = 1;
      dpPage = 1;
      retailerPage = 1;
      searchPage = 1;
      selectedAll = false;

      //this.fakeAccount = new Account();

      this.program = (Milestone1_Project__c)controller.getRecord();
      
      this.selectedAccounts = new Map<ID,SelectableAccount>();

      if(this.program == null || String.isBlank(this.program.Id)){
        this.program = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Program is required'));
        return;
      }
      
      this.program = [SELECT Id, Name, OwnerId, (SELECT Participant__r.Id, Participant__r.Parent.BillingCity,
                      Participant__r.Parent.BillingState, Participant__r.Parent.Id, Participant__r.Parent.Name, Participant__r.Parent.Parent.Name,
                      Participant__r.Parent.Parent.Parent.Name, Participant__r.Parent.RTL_SEG_NM_US__c FROM Participants__r),
                                                                    (Select Product__r.Id, Product__r.Name, Product__r.PDCN_CD_US__c from Market_Ready_Products__r) 
                                                                      FROM Milestone1_Project__c 
                                                                      WHERE Id = :this.program.Id];

      for(Market_Ready_Participant__c mrp : this.program.Participants__r){
        SelectableAccount sa;
        if(this.selectedAccounts.containsKey(mrp.Participant__r.Parent.Id)){
          sa = this.selectedAccounts.get(mrp.Participant__r.Parent.Id);
        } else {
          sa = new SelectableAccount(mrp.Participant__r.Parent,false,this);
          sa.selected = true;
          sa.existing = true;
        }
        sa.pocIdSet.add(mrp.Participant__r.Id);
        this.selectedAccounts.put(mrp.Participant__r.Parent.Id,sa);
      }

      this.accountName = '';
      this.newPageSize = 10; 
      this.sortField = 'Parent.Name ASC';
      this.isSecondStep = false;
      
      // Get integration User id
      List<User> users = [SELECT Id FROM User WHERE Profile.Name LIKE '%Integration User%'];
      if (users.size() > 0){
        integrationUserId = users[0].id;
      }

      retailerCon = new PaginationUtility();
      retailerCon.pageSize = 10;
      dpCon = new PaginationUtility();
      dpCon.pageSize = 10;
      wslrCon = new PaginationUtility();
      wslrCon.pageSize = 10;
      searchCon = new PaginationUtility();
      searchCon.pageSize = 10;

      loadData();
    }

    private List<SelectableAcct> getAcctWrapperList(List<Object> currentList) {
      List<SelectableAcct> accountList = new List<SelectableAcct>();
      for(Object obj : currentList) {
        accountList.add((SelectableAcct)obj);
      }
      return accountList;
    }

    private List<SelectableAccount> getWrapperList(List<Object> currentList) {
      List<SelectableAccount> accountList = new List<SelectableAccount>();
      for(Object obj : currentList) {
        accountList.add((SelectableAccount)obj);
      }
      return accountList;
    }

    /*
      Select All records in set controller
    */
    public void selectAll(){
      if(this.searchCon.totalRecords+this.selectedAccounts.size()<=3000){
        for(SelectableAccount p : (getWrapperList(this.searchCon.getAll()))){
          SelectableAccount sp = this.selectedAccounts.get(p.account.Id);
          if(sp == null && this.selectedAll){
            p.selected = true;
            this.selectedAccounts.put(p.account.Id,p);
          } else if(sp != null && !sp.existing && !this.selectedAll) {
            sp.selected = false;
            this.selectedAccounts.remove(sp.account.Id);
          }
        }
      } else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only 3000 Accounts can be selected.'));
      }
    }

    /* return to program */
    public PageReference cancel(){
      PageReference pg = new PageReference('/'+this.program.Id);
      pg.setRedirect(true);
      return pg;
    }

    public void setPage(){
      if(curCon == 1){
        retailerPage = newConPage;
      } else if(curCon == 2){
        dpPage = newConPage;
      } else if(curCon == 3){
        wslrPage = newConPage;
      } else if(curCon == 4){
        searchPage = newConPage;
      }
    }

    /* sort the recordset */
    public void sortRecordset(){
      Integer currentPage = searchCon.selectedPageNumber;
      loadData();
      searchCon.getPage(currentPage);
    }
    
    @RemoteAction
    public static Set<String> searchFilters(String searchTerm, String searchField) {
      Set<String> filterResults = new Set<String>();

      for(Account acct : Database.query('SELECT '+searchField+' FROM Account '
              +' WHERE '+searchField+' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' '
              +' AND Type = \'Decision Point\''
              +' LIMIT 100')){
        filterResults.add((String)acct.get(searchField));
      }
      return filterResults;
    }
     
    /*
      Reload the standard set controller with the new query
    */
    public void loadData(){
      this.selectedAll = false;
      //sorting
      String orderBy = this.sortField;
      if(orderBy.endsWith(' ASC')) orderBy += ' NULLS LAST';
      else orderBy += ' NULLS FIRST';
      String query = 'SELECT Id, Name, Parent.Name, Parent.Id, Parent.BillingState, Parent.BillingCity, Parent.Parent.Name, Parent.Parent.Parent.Name, Parent.RTL_SEG_NM_US__c';
      query += ' FROM Account ';

      List<String> andConditions = new List<String>();
      
      //filter parent
      if (String.isBlank(this.parentName) == false) {
        andConditions.add('Parent.Name LIKE \'%{!0}%\''.replace('{!0}',String.escapeSingleQuotes(this.parentName)));
      }

      //filter state
      if (String.isBlank(this.accountState) == false) {
        andConditions.add('BillingState = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.accountState)));
      }

      //filter segment
      if (String.isBlank(this.retailSegment) == false) {
        andConditions.add('RTL_SEG_NM_US__c = \'{!0}\''.replace('{!0}',String.escapeSingleQuotes(this.retailSegment)));
      }
      
      //aggregate conditions
      if(andConditions.size() > 0){
        andConditions.add('Type = \'POC\'');
        andConditions.add('ParentId != null');
        query += 'WHERE ('+String.join(andConditions,') AND (')+')';
      }

      query+=' Order By '+orderBy;
      query+=' LIMIT 10000';

      if(andConditions.size() > 0){
        Map<Id,SelectableAccount> selectableAccountMap = new Map<Id,SelectableAccount>();
        for(Account a : Database.query(query)){
          SelectableAccount sa;
          if(selectableAccountMap.containsKey(a.Parent.Id)){
            sa = selectableAccountMap.get(a.Parent.Id);
          } else {
            sa = new SelectableAccount(a.Parent,false,this);
          }
          sa.pocIdSet.add(a.Id);
          selectableAccountMap.put(a.Parent.Id,sa);
        }
        searchCon.setPagination(selectableAccountMap.values());
      } else {
        searchCon.setPagination(new List<SelectableAccount>());
      }
    }
    
    /*
      Go to 2nd step: details on selected products
    */
    public void goSecondStep() {
      this.isSecondStep = true;
      this.searchCon = null;

      List<selectableAcct> selectedWSLRsList = new List<selectableAcct>();
      List<Account> wholesalerAcc = new List<Account>();
      Set<Id> unselectedWSLRId = new Set<Id>();
      Set<Id> wslrIdSet = new Set<Id>();
      Set<Id> pocIds = new Set<Id>();
      for(SelectableAccount sa : selectedAccounts.values()){
        pocIds.addAll(sa.pocIdSet);
      }
      for(Account a : [SELECT Wholesaler__r.Id, Wholesaler__r.Name, Type, Wholesaler__c, Wholesaler__r.BillingState, Wholesaler__r.BillingCity
                       FROM Account 
                       WHERE Id IN :pocIds
                       ORDER BY Wholesaler__r.Name]){
        if(a.Type == 'POC' && a.Wholesaler__c != null) {
          wholesalerAcc.add(a.Wholesaler__r);
        }
      }
      if(!this.program.Market_Ready_Products__r.isEmpty()) {
        Set<Id> productIds = new Set<Id>();
          for(Market_Ready_Product__c mrp : this.program.Market_Ready_Products__r) {
            productIds.add(mrp.Product__c);
          }
          for(WSLR_Territory_Product_Exclusion__c wtpe : [SELECT Account__r.Name, Account__r.Id
                                                          FROM WSLR_Territory_Product_Exclusion__c
                                                          WHERE Account__c IN : wholesalerAcc
                                                          AND Product__c IN : productIds]) {
            unselectedWSLRId.add(wtpe.Account__r.Id);
          }
      }
      for(Account wAcc : wholesalerAcc){
        if(!wslrIdSet.contains(wAcc.Id)){
          selectableAcct selectAcc = new selectableAcct(wAcc);
          if(unselectedWSLRId.contains(wAcc.Id)) {
            selectAcc.selected = false;
            selectAcc.excluded = true;
          }
          selectedWSLRsList.add(selectAcc);
          wslrIdSet.add(wAcc.Id);
        }
      }
      wslrCon.setPagination(selectedWSLRsList);
    }
    
    /*
      Save items
    */
    public PageReference saveData(){
      List<Market_Ready_Participant__c> insertList = new List<Market_Ready_Participant__c>();
      for(SelectableAccount sa : selectedAccounts.values()){
        if(!sa.existing){
          for(Id acctId : sa.pocIdSet){
            insertList.add(new Market_Ready_Participant__c(Program__c = this.Program.Id, Participant__c = acctId));
          }
        }
      }
      
      Map<String, String> mapDMWholesalers = new Map<String, String>();
        Map<String, String> mapNRSKAM = new Map<String, String>();
        populateAccountTeamMemberMaps(mapDMWholesalers, mapNRSKAM, selectedWSLRs, selectedAccounts.values());
      
      // List of New Tasks
      List<Milestone1_Task__c> newTasks = new List<Milestone1_Task__c>();
      
      // List of Milestone1_Task__c records (Wholesaler List)
      List<Milestone1_Task__c> wlsrTaskList = [SELECT Id, Name, Project_Milestone__c, Task_Lead_Time__c
                                               ,Task_Expected_Duration__c, Task_Owner_Role__c
                                               , Project_Milestone__r.Project__r.Deadline__c, Due_Date__c, Start_Date__c
                                               , Class__c, Description__c, Priority__c, Task_Stage__c
                                               FROM Milestone1_Task__c
                                               WHERE Project_Milestone__r.Project__c = :this.program.Id
                                               AND Clone_by_Wholesaler__c = true];
      for (Object o : wslrCon.getAll()){
        SelectableAcct wslr = (SelectableAcct) o;
        if (wslr.selected == true){
          for (Milestone1_Task__c t : wlsrTaskList){              
            newTasks.add(createTask(t.clone(false,true), rtMapByName.get(TASK_RT_WHOLESALER).getRecordTypeId(), 
              false, (String)wslr.account.get('Id'), (String)wslr.account.get('Name'), mapDMWholesalers, mapNRSKAM, null, null, t.Id));
          }
        }
      }
      
      // List of Milestone1_Task__c records (Decision Point List)
      List<Milestone1_Task__c> dpTaskList = [SELECT Id, Name, Project_Milestone__c, Task_Lead_Time__c
                                             ,Task_Expected_Duration__c, Task_Owner_Role__c
                                             , Project_Milestone__r.Project__r.Deadline__c, Due_Date__c, Start_Date__c
                                             , Class__c, Description__c, Priority__c, Task_Stage__c
                                             FROM Milestone1_Task__c
                                             WHERE Project_Milestone__r.Project__c = :this.program.Id
                                             AND Clone_by_Retailer__c = true];

      for(SelectableAccount dp : selectedAccounts.values()){
        if (dp.selected == true){
          for (Milestone1_Task__c t : dpTaskList){
            newTasks.add(createTask(t.clone(false,true), rtMapByName.get(TASK_RT_RETAILER).getRecordTypeId(), 
              true, dp.account.Id, dp.account.Name, mapDMWholesalers, mapNRSKAM, null, null, t.Id));
          }
        }
      }

      //// List of Milestone1_Task__c records (Wholesaler List)                                                                           
      List<Milestone1_Task__c> wslrPdcnTaskList = [SELECT Id, Name, Project_Milestone__c, Task_Lead_Time__c
                                                  ,Task_Expected_Duration__c, Task_Owner_Role__c
                                                  , Project_Milestone__r.Project__r.Deadline__c, Product__c 
                                                  , Clone_by_WSLR_PDCN__c, Product__r.Name, Due_Date__c, Start_Date__c
                                                  , Class__c, Description__c, Priority__c, Task_Stage__c
                                                  FROM Milestone1_Task__c
                                                  WHERE Project_Milestone__r.Project__c = :this.program.Id
                                                  AND Clone_by_WSLR_PDCN__c = true];                          

      for (Object o : wslrCon.getAll()){
        SelectableAcct wslr = (SelectableAcct) o;
        if (wslr.selected == true){
          for(Market_Ready_Product__c product : program.Market_Ready_Products__r){
            for (Milestone1_Task__c t : wslrPdcnTaskList){
              newTasks.add(createTask(t.clone(false,true), rtMapByName.get(TASK_RT_WHOLESALER).getRecordTypeId(), 
                false, (String)wslr.account.get('Id'), (String)wslr.account.get('Name'), mapDMWholesalers, 
                mapNRSKAM, product.Product__r.Name, product, t.Id));
            }
          }
        }
      }
      this.program.Market_Selected__c = true;
      try{
        update this.program;
        insert insertList;
        insert newTasks;
      }catch(DMLException e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
        return null;
      }
      PageReference pg = new PageReference('/'+this.program.Id);
      pg.setRedirect(true);
      return pg;
    }
    
    /*
      Method creates task 
    */
    private Milestone1_Task__c createTask(Milestone1_Task__c newTask, String recordTypeId, 
                                boolean isRetailer, String accountId, String accountName, 
                                Map<String, String> mapDMWholesalers, Map<String, String> mapNRSKAM,
                                String productName, Market_Ready_Product__c product,
                                String clonedId){
      newTask.recordTypeId = recordTypeId;
      if(productName != null){
          newTask.Name = accountName + ' - ' + productName + ' - ' + newTask.Name;
      } else {
      newTask.Name = accountName + ' - ' + newTask.Name;
      }
      newTask.Name = newTask.Name.abbreviate(80);
      if(isRetailer){
        newTask.Retailer__c = accountId;
      } else {
        newTask.Wholesaler__c = accountId;
        if(product != null){
          newTask.Product__c = product.Product__r.Id;
          newTask.PDCN__c = product.Product__r.PDCN_CD_US__c;
        }
      }

      newTask.Cloned_From__c = clonedId;

      if(newTask.Task_Owner_Role__c != null){
        newTask.Assigned_To__c = getAssignedTo(newTask.Task_Owner_Role__c, accountId, mapDMWholesalers, mapNRSKAM);
      }
      return  newTask;
    }
    
    /*
      Method populates Account Team Members map having accountId as key and UserId as value
    */
    private void populateAccountTeamMemberMaps(Map<String, String> mapDMWholesalers, Map<String, String> mapNRSKAM, 
                                                                                        List<selectableAcct> selectedWSLRs, List<SelectableAccount> selectedDps){
      Set<String> accountIds = new Set<String>();
      for(selectableAcct acct : selectedWSLRs){
        if(acct.account != null) {
          accountIds.add(acct.account.id);
        }
      }
      for(SelectableAccount acct : selectedDPs){
        if(acct.account != null) {
          accountIds.add(acct.account.id);
        }
      }
      for (AccountTeamMember accTM : [SELECT UserId, TeamMemberRole, AccountId  
                                      FROM AccountTeamMember 
                                      WHERE AccountId in : accountIds 
                                      AND (TeamMemberRole = 'DM (Wholesalers Only)' OR TeamMemberRole = 'NRS KAM')]){
        if (accTM.TeamMemberRole == 'DM (Wholesalers Only)')    {
          mapDMWholesalers.put(accTM.accountId, accTM.UserId);
        } else if(accTM.TeamMemberRole == 'NRS KAM'){
          mapNRSKAM.put(accTM.accountId, accTM.UserId);
        }                                       
      }
    }
    
    /*
      Method returns User id according to task owner role
    */
    private String getAssignedTo(String taskOwnerRole, String accountId, Map<String, String> mapDMWholesalers, Map<String, String> mapNRSKAM){
      if (taskOwnerRole == 'CPPM' || taskOwnerRole == 'RPPM' || taskOwnerRole == 'BSC' || taskOwnerRole == 'Program Owner'){
        return this.program.OwnerId;
      } else if (taskOwnerRole == 'Integration User'){            
        return integrationUserId;           
      } else if(taskOwnerRole == 'Wholesaler DM'){            
        if (mapDMWholesalers.get(accountId) != null){
          return mapDMWholesalers.get(accountId);
        }
      } else if (taskOwnerRole == 'KAM'){
        if (mapNRSKAM.get(accountId) != null){
          return mapNRSKAM.get(accountId);
        }
      }
      return null;
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

    public class selectableAcct{
      public Account account {get;set;}
      public Boolean selected {get;set;}
      public Boolean excluded {get;set;}
      public Boolean existing {get;set;}

      public selectableAcct(Account a){
        this.account = a;
        this.selected = true;
        this.excluded = false;
      }
    }

    /* 
      utility class to handle product selection
      Has a link to the main controller to handle item selection 
    */
    public class SelectableAccount implements Comparable{
      //poc list
      public Set<Id> pocIdSet{get;Set;}
      //poc count
      public Integer pocCount{
        get{
          return pocIdSet.size();
        }
      }
      //account
      public Account account{get;Set;}
      //is selected?
      public Boolean selected{get;Set;}
      //main controller
      public MarketSelectionController controller{get;Set;}
      //exists on program
      public Boolean existing{get;Set;}

      public SelectableAccount(Account a, Boolean selected, MarketSelectionController controller){
        this.account = a;
        this.pocIdSet = new Set<Id>();
        this.controller = controller;
        this.selected = selected;
        this.existing = false;
      }
      
      /* adds or removes a selected item */
      public void selectItem(){
        SelectableAccount a  = this.controller.selectedAccounts.get((String)this.account.Id);
        if(this.selected){
          if(a == null){
            if(this.controller.selectedAccounts.size()<3000){
              this.controller.selectedAccounts.put((String)this.account.Id,this);
              } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only 3000 Accounts can be selected.'));
              }
          }else{
            //nothing to do: item is already selected
          }
        }else{
          this.controller.selectedAccounts.remove((String)this.account.Id);
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
        if((compareTo instanceof SelectableAccount) == false) return 1;
          SelectableAccount compareToA = (SelectableAccount)compareTo;
          return this.account.Name.compareTo(compareToA.account.Name);       
      }
      
    }
    
}