/**=====================================================================
 * Appirio, Inc
 * Name: SpacePlanResetExtension
 * Description: Controller for Space Plan Reset steps
 * Created Date: 17 Sept 2015 T-433463
 * Created By: Poonam Varyani (Appirio)
 * 
 * Date Modified                Modified By       Description of the update
 * 28th Sep 2015                Parul Gupta       T-436454 - Modified saveRecords()
 * 30th Sep 2015                Parul Gupta       T-436939 - Added capability to add attachments
 * 30th Sep 2015                Parul Gupta       T-437336 - Modified to support id parameter to clone Space Plan 
 * 1st  Oct 2015                Parul Gupta       T-437338 - Modified Wrapper constructor
 * 8th  Oct 2015              Nimisha Prashant    T-439611 - Updated the Task Lead Time and Task Expected Duration before task creation.
 =====================================================================*/
public with sharing class SpacePlanResetExtension {
    
    public String searchVal {get; set;}
    public String selection {get; set;}
    public Map<Id, Space_Plan_Reset__c> spacePlanTemplateMap {get; set;}
    public Space_Plan_Reset__c selectedSpacePlanTemplate {get; set;}
    public Space_Plan_Reset__c newSpacePlan {get; set;}
    public String spacePlan {get;set;}
    public String spacePlanName {get;set;}
    public List<Reset_Milestones__c> MilestonesAndTasks;
    public List<MilestoneWrapper> milestones {get; set;}
    public String nameOfAccount {get; set;}
    public String selectedRecordType {get; set;}
    public String accountName {get; set;}
    public boolean isCloned {get; set;}
   
    private static final String SPACE_PLAN_OBJ_NAME = 'Space_Plan_Reset__c';  
    private static final String SPACEPLAN_RT_STANDARD = 'Space Plan Reset';
    private static final String SPACEPLAN_RT_TEMPLATE = 'Master Template';
    private static final String RESET_MILESTONE_OBJ_NAME = 'Reset_Milestones__c';
    private static final String MILESTONE_RT_STANDARD = 'Reset Milestone';
    private static final String TASK_RT_MASTER = 'Master Template';
    private static final String TASK_RT_TASK = 'Reset Task';
    private static final String TASK_RT_WHOLESALER = 'Wholesaler Reset';
    private static final String RESET_TASK_OBJ_NAME = 'Reset_Tasks__c';
   
   
    /* standard set controller used to filter data */
    private ApexPages.StandardSetController setCon {get;set;}
    public PaginationUtility retailerCon {get; set;}
    public Integer newConPage {get; set;}
    public Integer retailerPage {get; set;}
    public String sortField{get;Set;}
    public Map<ID,SelectableAccount> selectedAccounts{get;Set;}
    
    
    /* returns the current page set records*/
    public List<SelectableAccount> records{
      get{
        List<SelectableAccount> result = new List<SelectableAccount>();
        for(Account a : (List<Account>)setCon.getRecords()){
          SelectableAccount sa = this.selectedAccounts.get(a.Id);
          if(sa != null)
            result.add(sa);
          else
            result.add(new SelectableAccount(a,false,this));
        }
          return result;
      } set;
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
    public Integer newPageSize{get;Set;}
    
    /* total number of pages */
    public Integer totalPages{
      get{
        return (Integer)Math.ceil((Double)resultSize / (Double)pageSize);
      }
    }  
    
     /* maps values */
        public List<SelectableAccount> selectedAccountsValues{
      get{
        System.debug('>>>>this.selectedAccounts.values()>>>>'+this.selectedAccounts.values());
        retailerCon.setPagination(this.selectedAccounts.values());
        System.debug('>>>>retailerCon>>>>'+retailerCon);
        if(retailerCon.getPage(retailerPage) != null){
          return getWrapperList(retailerCon.getPage(retailerPage));
        } else {
          return getWrapperList(retailerCon.getPage(1));
        }      
      }
    }
    
    /* items selected? */
    public Boolean itemsSelected{
      get{
        return this.selectedAccounts.size() > 0;
      }
    }
    
    /* selected all results */
    public Boolean selectedAll{get;Set;}
    
    
    public SpacePlanResetExtension () { }
    
    /*---------------------------------------------------------------------------
    Constructor
    --------------------------------------------------------------------------*/
        public SpacePlanResetExtension (ApexPages.StandardController sc) {
        searchVal = '';
        accountName = '';
        isCloned = false;
        spacePlanTemplateMap = fetchSpacePlanTemplates();
        if(ApexPages.currentPage().getParameters().get('Id') != null 
            && ApexPages.currentPage().getParameters().get('Id') != ''){
            selection = ApexPages.currentPage().getParameters().get('Id');
            isCloned = true;
            selectedSpacePlanTemplate = fetchSpacePlanReset();
            newSpacePlan = new Space_Plan_Reset__c();
        }
    }
  
  
    /*---------------------------------------------------------------------------
    getter method for Template selection picklist on Page 1
    --------------------------------------------------------------------------*/
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        for(Space_Plan_Reset__c splan : spacePlanTemplateMap.values()) {
        options.add(new SelectOption(splan.Id, splan.Name));
        }
        return options;
    }
  
    /*------------------------------------------------------------------------------
    Method to return to Page 1 from Page 2 by clicking Previous
    ------------------------------------------------------------------------------*/
    public PageReference step1() {
        return Page.SpacePlanResetStep1;
    }
  
    /*------------------------------------------------------------------------------
    Method to return to move to Step 2 if a template is chosen and next is hit
    ------------------------------------------------------------------------------*/
    public PageReference step2() {
        if(selection == null || selection == '') {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select a Template'));
          return null;
        }
        else {
          if(newSpacePlan == null){
            selectedSpacePlanTemplate = spacePlanTemplateMap.get((Id)selection);
            newSpacePlan = new Space_Plan_Reset__c();
          }
          return Page.SpacePlanResetStep2;
        }
    }
  
    /*------------------------------------------------------------------------------
    Method to return to move to Step 3 if Name is completed and next is hit
   ------------------------------------------------------------------------------*/
    public PageReference step3() {
        if(newSpacePlan.Name == null || newSpacePlan.Name == '') {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select a Space Plan Template'));
          return null;
        } else if(newSpacePlan.Merchandising_Start_Date__c > newSpacePlan.Merchandising_Start_Date__c) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a valid date'));
          return null;
        }
        selectedRecordType = 'Decision Point';
       	selectedAll = false;
      	this.selectedAccounts = new Map<ID,SelectableAccount>();
       	this.newPageSize = 10; 
      	this.sortField = 'Name ASC';
       	retailerCon = new PaginationUtility();
       	retailerCon.pageSize = 10;
       	retailerPage = 1;
        loadData();
        return Page.SpacePlanResetStep3;    
    }
  
    /*------------------------------------------------------------------------------
    Method to return to move to Step 3 if Name is completed and next is hit
    ------------------------------------------------------------------------------*/
    public PageReference step4() {
        if(newSpacePlan.Name == null || newSpacePlan.Name == '') {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select a Space Plan Template'));
          return null;
        } else if(selectedAccounts.size() == 0) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select accounts'));
          return null;
        }
        populateMilestoneWrapper();
        return Page.SpacePlanResetStep4;    
    }
  
    /*--------------------------------------------------------------------------------------
    Method to clone and finally save the Program, Milestones and Tasks
    ----------------------------------------------------------------------------------------*/
    public PageReference saveRecords() {
        Savepoint sp = Database.setSavepoint();
        Space_Plan_Reset__c projectToInsert = selectedSpacePlanTemplate.clone(false, true);
        projectToInsert.Name = newSpacePlan.Name;
        projectToInsert.Reset_Date_US__c = newSpacePlan.Reset_Date_US__c;
        projectToInsert.Merchandising_Start_Date__c = newSpacePlan.Merchandising_Start_Date__c;
        projectToInsert.RecordTypeId = fetchRecordTypeId(SPACE_PLAN_OBJ_NAME, SPACEPLAN_RT_STANDARD);
        projectToInsert.Status__c = 'Planning';
        projectToInsert.Purpose__c = newSpacePlan.Purpose__c;
        projectToInsert.Reset_Start_Date_US__c = newSpacePlan.Reset_Start_Date_US__c;
        projectToInsert.Reset_Season__c = newSpacePlan.Reset_Season__c;
        //projectToInsert.Reset_Type__c = selectedSpacePlanTemplate.Reset_Type__c;
        
        try {
          insert projectToInsert;
          insertAttachments(new Set<Id>{selectedSpacePlanTemplate.id}, new List<Space_Plan_Reset__c>{projectToInsert});       
        }
        catch(Exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
          Database.rollback(sp);
          projectToInsert = projectToInsert.clone(false);
          return null;
        }
        if(selectedAccounts.size() > 0) {
            List<Space_Plan_Reset_Retailer__c> participants = new List<Space_Plan_Reset_Retailer__c>();
            for(String accountId : selectedAccounts.keyset()){
            participants.add(new Space_Plan_Reset_Retailer__c(Space_Plan_Reset__c = projectToInsert.Id, Account__c = accountId));
            }
          try {
            insert participants;
          }
          catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            Database.rollback(sp);
    
            return null;
          }  
        }
        List<Reset_Milestones__c> milestonesToInsert = new List<Reset_Milestones__c>();
        Set<Id> milestoneIds = new Set<Id>();

        for(Reset_Milestones__c mw : MilestonesAndTasks) {
          if(!milestoneIds.contains(mw.Id)) {
            Reset_Milestones__c clonedMilestone = mw.clone(false, true);
            clonedMilestone.Reset__c = projectToInsert.Id;
            clonedMilestone.RecordTypeId = fetchRecordTypeId(RESET_MILESTONE_OBJ_NAME, MILESTONE_RT_STANDARD);
            clonedMilestone.Status__c = 'Not Started';
            if(mw.Predecessor_Milestone__c != null) {
                clonedMilestone.Predecessor_Milestone__c = mw.Predecessor_Milestone__c;
            }
            milestoneIds.add(mw.Id);
            milestonesToInsert.add(clonedMilestone);
          }
        }
        try {
          insert milestonesToInsert;
            insertAttachments(milestoneIds, milestonesToInsert);
        } catch(Exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
          Database.rollback(sp);
          return null;
        }  

        Map<Id,Date> msStartDate = new Map<Id,Date>();
        Map<Id,Date> msDueDate = new Map<Id,Date>();
        List<Reset_Tasks__c> tasksToInsert = new List<Reset_Tasks__c>();
        Integer startIndex = 0;
        Set<Id> oldTasksIds = new Set<Id>();
        for(Integer i = 0 ; i < MilestonesAndTasks.size() ; i++) {
          Reset_Milestones__c newMilestone = MilestonesAndTasks[i];
          for(Integer j = startIndex ; j < startIndex + newMilestone.Reset_Tasks__r.size() ; j++) {
            oldTasksIds.add(milestones[j].task.id);
            Reset_Tasks__c newTask = milestones[j].task.clone(false);
    
            // Map Milestones to Max Due Date and Min Start Dates of Tasks
            if(newTask.Start_Date__c != null && (!msStartDate.containsKey(milestonesToInsert[i].Id)
               || msStartDate.get(milestonesToInsert[i].Id) > newTask.Start_Date__c)){
              msStartDate.put(milestonesToInsert[i].Id,newTask.Start_Date__c);
            }
            if(newTask.Due_Date__c != null && (!msDueDate.containsKey(milestonesToInsert[i].Id)
               || msDueDate.get(milestonesToInsert[i].Id) < newTask.Due_Date__c)){
              msDueDate.put(milestonesToInsert[i].Id,newTask.Due_Date__c);
            }
    
            newTask.Milestone__c = milestonesToInsert[i].Id;
            newTask.Task_Stage__c = 'Not Started';
            if(newTask.Class__c == TASK_RT_TASK) {
              newTask.RecordTypeId = fetchRecordTypeId(RESET_TASK_OBJ_NAME, TASK_RT_TASK);
            }
            else {
              if(newTask.Class__c == TASK_RT_WHOLESALER) {
                  newTask.RecordTypeId = fetchRecordTypeId(RESET_TASK_OBJ_NAME, TASK_RT_WHOLESALER);
                }
                else {
                  newTask.RecordTypeId = fetchRecordTypeId(RESET_TASK_OBJ_NAME, TASK_RT_TASK);
                }
            }
            //NP 08/11 : Added as per task T-439611
            if(newtask.Start_Date__c != null && newtask.Due_Date__c != null) {
                newtask.Task_Lead_Time__c = newtask.Due_Date__c.daysBetween(newSpacePlan.Reset_Date_US__c) + 1;
                newtask.Task_Expected_Duration__c = newtask.Start_Date__c.daysBetween(newtask.Due_Date__c) + 1;
            }
            tasksToInsert.add(newtask);
          }
          startIndex += newMilestone.Reset_Tasks__r.size();
        }
        try {
          insert tasksToInsert;
          insertAttachments(oldTasksIds, tasksToInsert);
        } catch(Exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
          Database.rollback(sp);
          return null;
        }  
    
        // Update Milestone Deadline and Start Date with Max due date and Min start dates from tasks
        Integer index = 0;
        for(Reset_Milestones__c ms : milestonesToInsert){
          ms.Deadline__c = msDueDate.get(ms.Id);
          ms.Kickoff__c = msStartDate.get(ms.Id);
          if(ms.Predecessor_Milestone__c != null){
            ms.Predecessor_Milestone__c = milestonesToInsert.get(index-1).id;
          }
          index++;
        }
        try {
          update milestonesToInsert;
        } catch(Exception ex) {
          if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your first task date preceeds your Planned Kickoff date.  Please re-set your Planned Kickoff date to account for changes to your schedule.'));
          } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
          }
          Database.rollback(sp);
          return null;
        }  
        
        return new PageReference('/'+projectToInsert.Id); 
        return null;
    }
  
    /*--------------------------------------------------------------------------------------
    Action Function to Update the Dates on change of STR Date on Page 3
    ----------------------------------------------------------------------------------------*/
    public PageReference updateDates() {
        Date strDate = newSpacePlan.Reset_Date_US__c;
        for(MilestoneWrapper mileWrap : milestones) {
          if(mileWrap.task.Task_Lead_Time__c != null) {
            Date dueDate = strDate.addDays(-(Integer.valueOf(mileWrap.task.Task_Lead_Time__c)));
            mileWrap.task.Due_Date__c = dueDate;
          }
          if(mileWrap.task.Task_Expected_Duration__c != null && mileWrap.task.Due_Date__c != null) {
            Date startDate = mileWrap.task.Due_Date__c.addDays(-(Integer.valueOf(mileWrap.task.Task_Expected_Duration__c)));
            mileWrap.task.Start_Date__c = startDate;
          }
        }
        newSpacePlan.Name = newSpacePlan.Name.subString(0, newSpacePlan.Name.lastIndexOf(' - '));
        newSpacePlan.Name += ' - '+ String.valueOf(strDate.month())+'/'+String.valueOf(strDate.day())+'/'+String.valueOf(strDate.year()) ;
        return null;
    }
  
    /*---------------------------------------------------------------------------
    Method to fetch List of Program Records with RT = Master Template
    --------------------------------------------------------------------------*/
    private Map<Id, Space_Plan_Reset__c> fetchSpacePlanTemplates() {
        spacePlanTemplateMap = new Map<Id, Space_Plan_Reset__c>([SELECT Id, Name, Reset_Start_Date_US__c, Reset_Date_US__c
                                                              FROM Space_Plan_Reset__c 
                                                              WHERE RecordType.Name = :SPACEPLAN_RT_TEMPLATE]);
        return spacePlanTemplateMap;
    }
    
    /*---------------------------------------------------------------------------
    Method to fetch existing Space Plan Reset Record
    --------------------------------------------------------------------------*/
    private Space_Plan_Reset__c fetchSpacePlanReset() {
        for(Space_Plan_Reset__c spacePlanReset : [SELECT Id, Name, Reset_Start_Date_US__c, Reset_Date_US__c, Reset_Type__c
                                                              FROM Space_Plan_Reset__c 
                                                              WHERE id = :selection]){
        return spacePlanReset;                                                      
      }
        return null;
    }
  
    /*--------------------------------------------------------------------------------------
    Method to populate the Wrapper with with Milestones and Tasks of the chosen Template
    ----------------------------------------------------------------------------------------*/
    private void populateMilestoneWrapper() {
        milestones = new List<MilestoneWrapper>();
        MilestonesAndTasks = getMilestonesAndTasks();
        for(Reset_Milestones__c milestone : MilestonesAndTasks) {
          for(Reset_Tasks__c task : milestone.Reset_Tasks__r) {
            milestones.add(new MilestoneWrapper(milestone, task, newSpacePlan.Reset_Date_US__c, 
            														isCloned, selectedSpacePlanTemplate.Reset_Date_US__c));
          }
        }
        system.debug('milestones >>>> '+ milestones);
    }
  
   /*---------------------------------------------------------------------------
    getter method for account level picklist on Page 3
   --------------------------------------------------------------------------*/
    public List<SelectOption> getAccountRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Decision Point', 'Decision Point'));
        options.add(new SelectOption('POC', 'POC'));
        options.add(new SelectOption('Banner', 'Banner'));
        options.add(new SelectOption('Chain', 'Chain'));    
        return options;
    }
    
    /*------------------------------------------------------------------------------
    T-436939 - Method returns attachments related to parentIds
   ------------------------------------------------------------------------------*/
    private Map<Id, List<Attachment>> getAttachments(Set<Id> parentIds){
    
        Map<Id, List<Attachment>> parentAttachmentList = new Map<Id, List<Attachment>>();
        for(Attachment attachment : [Select Id, ParentId, Name, ContentType, body, BodyLength, Description 
                                                                From Attachment 
                                                                where ParentId in : parentIds]){
            if(parentAttachmentList.get(attachment.parentId) == null){
                parentAttachmentList.put(attachment.parentId, new List<Attachment>());
            }
            parentAttachmentList.get(attachment.parentId).add(attachment);
        }
        return parentAttachmentList;
    }
    
    /*------------------------------------------------------------------------------
    T-436939 - Method to find the attachments related to oldParentIds and associate them with newParent
   ------------------------------------------------------------------------------*/
    private void insertAttachments(Set<Id> oldParentIds, List<sObject> newParentList){
        List<Attachment> attachmentList = new List<Attachment>();
        Map<Id, List<Attachment>> parentAttachments = getAttachments(oldParentIds);
      Integer index = 0;
      for(Id parentId : oldParentIds){
        if(parentAttachments.get(parentId) != null){
            List<Attachment> attachments = parentAttachments.get(parentId);
            for(Attachment oldAtt : attachments){
                Attachment newAttachment = oldAtt.clone();
                newAttachment.parentId = newParentList[index].id;
                attachmentList.add(newAttachment);
            }
        }
        index++;
        }
        if(attachmentList.size() > 0){
            insert attachmentList;
        }
    }
  
    /*------------------------------------------------------------------------------
    Method to fetch the Milestones and Tasks Associated with the Selected Program
   ------------------------------------------------------------------------------*/
    private List<Reset_Milestones__c> getMilestonesAndTasks() {
        system.debug('selection >>> '+ selection);
        List<Reset_Milestones__c> mileStones = new List<Reset_Milestones__c>([Select id, Predecessor_Milestone__c, Name, Description__c, 
                                                                        (Select Id, Name, Due_Date__c, Start_Date__c, Task_Lead_Time__c,
                                                                        Predecessor_Task__c, Class__c, Task_Expected_Duration__c, 
                                                                        Description__c, Wholesaler__c, Assigned_To__c From Reset_Tasks__r ORDER BY Task_Lead_Time__c DESC) 
                                                                    From Reset_Milestones__c  Where Reset__c =: selection ORDER BY Order__c ASC]);
                                                                       
        return mileStones;
    } 
  
    /*----------------------------------------------------------------------------------------------------------
    Method to fetch the RecordType Map
    -----------------------------------------------------------------------------------------------------------*/
    private static String fetchRecordTypeId(String sObjectName, String recordTypeLabel){
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        map<String, Schema.RecordTypeInfo> rtMap = gd.get(sObjectName).getDescribe().getRecordTypeInfosByName();   
        String rtId = rtMap.get(recordTypeLabel).getRecordTypeId();
        return rtId;
    }
   
    /*----------------------------------------------------------------------------------------------------------------
    Wrapper Class for Milestone and Associated Tasks
    ----------------------------------------------------------------------------------------------------------------*/
    public class MilestoneWrapper {
        public String milestoneName {get; set;}
        public Reset_Milestones__c milestone {get; set;}
        public Reset_Tasks__c task {get; set;}
        
        public MilestoneWrapper(Reset_Milestones__c milestone, Reset_Tasks__c mileTask, Date strDate, boolean isCloned, Date existingResetDate) {
          this.milestone = milestone;
          this.milestoneName = milestone.Name;
          //task = new Reset_Tasks__c(Name = mileTask.Name, Task_Lead_Time__c = mileTask.Task_Lead_Time__c, Task_Expected_Duration__c = mileTask.Task_Expected_Duration__c);
          this.task = mileTask;
          
          // T-437338 - Calculate Lead time and Expected Duration based on exising Start Date of the Reset record and Due Date of the Task records
          if (isCloned){
          	if (existingResetDate != null && this.task.Due_Date__c != null){
          		this.task.Task_Lead_Time__c = this.task.Due_Date__c.daysBetween(existingResetDate);
          	}
          	if (this.task.Due_Date__c != null && this.task.Start_Date__c != null){
							this.task.Task_Expected_Duration__c = this.task.Start_Date__c.daysBetween(this.task.Due_Date__c);
          	}
          }
          if(this.task.Task_Lead_Time__c != null) {
            Date dueDate = strDate.addDays(-(Integer.valueOf(this.task.Task_Lead_Time__c)));
            this.task.Due_Date__c = dueDate;
          }
          if(this.task.Task_Expected_Duration__c != null && this.task.Due_Date__c != null) {
            Date startDate = this.task.Due_Date__c.addDays(-(Integer.valueOf(this.task.Task_Expected_Duration__c)));
            this.task.Start_Date__c = startDate;
          }
        }
    }
  
    /*-------------------------Methods used at Page 3-------------------------------*/
    
    /*
      Reload the standard set controller with the new query
    */
    public void loadData(){
      //sorting
      String orderBy = this.sortField;
      if(orderBy.endsWith(' ASC')) orderBy += ' NULLS LAST';
      else orderBy += ' NULLS FIRST';
      String query = 'SELECT Id, Name FROM Account ';
      query += 'WHERE  Type = \'' + selectedRecordType + '\'';

      //filter name
      if (String.isBlank(this.accountName) == false) {
        query += ' AND Name LIKE \'%{!0}%\''.replace('{!0}',String.escapeSingleQuotes(this.accountName));
      }

      query+=' Order By '+orderBy;
      query+=' LIMIT 10000';
      this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
      this.setCon.setPageNumber(1);
      this.setCon.setPageSize(this.newPageSize);
    }
    
    /*
      Retruns selected accounts wrapper list
    */
    private List<SelectableAccount> getWrapperList(List<Object> currentList) {
      List<SelectableAccount> accountList = new List<SelectableAccount>();
      for(Object obj : currentList) {
        accountList.add((SelectableAccount)obj);
      }
      return accountList;
    }
    
    /* Select All account */
    public void selectAll(){   	
      if(resultSize+selectedAccounts.size()<=3000){
        Integer setPage = this.setCon.getPageNumber();
        Integer setSize = this.setCon.getPageSize();
        this.setCon.setPageSize(2000);
        for(Integer j = 1; j <= totalPages; j++) {
          this.setCon.setPageNumber(j);
          for(Account p : (List<Account>)setCon.getRecords()){
            SelectableAccount sp = this.selectedAccounts.get(p.Id);
            if(sp == null && this.selectedAll){
              sp = new SelectableAccount(p,true,this);
              this.selectedAccounts.put(p.Id,sp);
            } else if(sp != null && !this.selectedAll) {
              this.selectedAccounts.remove(p.Id);
            }
          }
        }
        this.setCon.setPageSize(setSize);
        this.setCon.setPageNumber(setPage);
      } else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only 3000 Accounts can be selected.'));
        this.selectedAll = false;
      }      
    }
    
    /* Set page */
    public void setPage(){
       retailerPage = newConPage;
    }

    /* sort the recordset */
    public void sortRecordset(){
      Integer currentPage = this.pageNumber;
      loadData();
      this.setCon.setPageNumber(currentPage);
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
  
    /* SelectableAccount wrapper class */
        public class SelectableAccount implements Comparable{
     
      public Account account{get;Set;}
      public Boolean selected{get;Set;}
      
      public SpacePlanResetExtension controller{get;Set;}
      
      public SelectableAccount(Account a, Boolean selected, SpacePlanResetExtension controller){
        this.account = a;
        this.controller = controller;
        this.selected = selected;
      }
      
      /* adds or removes a selected item */
      public void selectItem(){
        SelectableAccount a  = this.controller.selectedAccounts.get(this.account.Id);
        if(this.selected){
          if(a == null){
            if(this.controller.selectedAccounts.size()<3000){
              this.controller.selectedAccounts.put(this.account.Id,this);
              } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only 3000 Accounts can be selected.'));
              }
          }else{
            //nothing to do: item is already selected
          }
        }else{
          this.controller.selectedAccounts.remove(this.account.Id);
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

    @RemoteAction
    public static List<AggregateResult> searchFilters(String searchTerm, String searchField, String rt) {
        return Database.query('SELECT '+searchField+' from Account '
              +' WHERE '+searchField+' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' '
              +' AND Type = \''+rt+'\''
              +' GROUP BY '+searchField+' LIMIT 100');
    }
}