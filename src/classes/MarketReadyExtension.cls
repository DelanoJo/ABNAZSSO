/**====================================================================
 * Appirio, Inc
 * Name: MarketReadyExtension
 * Description: Controller for MarketReadyStep1.page, MarketReadyStep2.page, MarketReadyStep3.page
 * Created Date: 19 August 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
public with sharing class MarketReadyExtension {
  
  public String searchVal {get; set;}
  public String selection {get; set;}
  public Map<Id, Milestone1_Project__c> projectTemplateMap {get; set;}
  public Milestone1_Project__c selectedProjectTemplate {get; set;}
  public Milestone1_Project__c newProject {get; set;}
  public String product {get;set;}
  public String productName {get;set;}
  public List<Milestone1_Milestone__c> MilestonesAndTasks;
  public List<MilestoneWrapper> milestones {get; set;}
  
  private static final String PROJECT_RT_TEMPLATE = 'Master Template';
  private static final String PROJECT_RT_STANDARD = 'Standard Program';
  private static final String MARKET_PROGRAM_OBJ_NAME = 'Milestone1_Project__c';
  private static final String MILESTONE_RT_STANDARD = 'Standard Program Milestone';
  private static final String PROGRAM_MILESTONE_OBJ_NAME = 'Milestone1_Milestone__c';
  private static final String TASK_RT_STANDARD = 'Standard Program Task';
  private static final String TASK_RT_RETAILER = 'Retailer Alignment';
  private static final String TASK_RT_WHOLESALER = 'Wholesaler Alignment';
  private static final String PROGRAM_TASK_OBJ_NAME = 'Milestone1_Task__c';
  
  public MarketReadyExtension () {
     
  } 
  /*---------------------------------------------------------------------------
    Constructor
   --------------------------------------------------------------------------*/
  public MarketReadyExtension (ApexPages.StandardController sc) {
    searchVal = '';
    projectTemplateMap = fetchProjectTemplates();
  }
  
  /*---------------------------------------------------------------------------
    getter method for Template selection picklist on Page 1
   --------------------------------------------------------------------------*/
  public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
    for(Milestone1_Project__c proj : projectTemplateMap.values()) {
      options.add(new SelectOption(proj.Id, proj.Name));
    }
    return options;
  }
  
  /*---------------------------------------------------------------------------
    Method to fetch List of Program Records with RT = Template
   --------------------------------------------------------------------------*/
  private Map<Id, Milestone1_Project__c> fetchProjectTemplates() {
    projectTemplateMap = new Map<Id, Milestone1_Project__c>([SELECT Id, Name, Region__c, Deadline__c, Program_Type__c
                                                              FROM Milestone1_Project__c 
                                                              WHERE RecordType.Name = :PROJECT_RT_TEMPLATE]);
    return projectTemplateMap;
  }
  
  /*------------------------------------------------------------------------------
    Method to fetch the Milestones and Tasks Associated with the Selected Program
   ------------------------------------------------------------------------------*/
  private List<Milestone1_Milestone__c> getMilestonesAndTasks() {
    List<Milestone1_Milestone__c> mileStones = new List<Milestone1_Milestone__c>([SELECT Id, Project__c, Name, Description__c, Order__c,
                                                                                  (SELECT Id, Name, Start_Date__c, Task_Lead_Time__c, Task_Expected_Duration__c, 
                                                                                    Due_Date__c, Class__c, Clone_by_Retailer__c, Clone_by_Wholesaler__c,
                                                                                    Clone_by_WSLR_PDCN__c, Clone_by_Region__c, Description__c, Predecessor_Task__c,
                                                                                    Priority__c
                                                                                   FROM Project_Tasks__r
                                                                                   ORDER BY Task_Lead_Time__c DESC) 
                                                                                  FROM Milestone1_Milestone__c
                                                                                  WHERE Project__c = : selection
                                                                                  ORDER BY Order__c ASC]);
     return mileStones;
  }
  
  /*------------------------------------------------------------------------------
    Method to return to Page 1 from Page 2 by clicking Previous
   ------------------------------------------------------------------------------*/
  public PageReference step1() {
    return Page.MarketReadyStep1;
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
      if(newProject == null){
        selectedProjectTemplate = projectTemplateMap.get((Id)selection);
        newProject = new Milestone1_Project__c();
      }
      return Page.MarketReadyStep2;
    }
  }
  
  /*------------------------------------------------------------------------------
    Method to return to move to Step 3 if Name is completed and next is hit
   ------------------------------------------------------------------------------*/
  public PageReference step3() {
    if(newProject.Name == null || newProject.Name == '') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select a Product, Region and STR Date'));
      return null;
    } else if(newProject.Kickoff__c > newProject.Deadline__c) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a Planned Kickoff Date that is before STR Date'));
      return null;
    }
    else {
      populateMilestoneWrapper();
      return Page.MarketReadyStep3;
    }
  }

  /*------------------------------------------------------------------------------
    Method to return to cancel out of wizard
   ------------------------------------------------------------------------------*/
  public PageReference cancel() {
    Schema.DescribeSObjectResult r = Milestone1_Project__c.sObjectType.getDescribe();
    String keyPrefix = r.getKeyPrefix();
    PageReference pg = new PageReference('/'+keyPrefix);
    pg.setRedirect(true);
    return pg;
  }
  
  /*--------------------------------------------------------------------------------------
    Method to populate the Wrapper with with Milestones and Tasks of the chosen Template
  ----------------------------------------------------------------------------------------*/
  private void populateMilestoneWrapper() {
    milestones = new List<MilestoneWrapper>();
    MilestonesAndTasks = getMilestonesAndTasks();
    for(Milestone1_Milestone__c milestone : MilestonesAndTasks) {
      for(Milestone1_Task__c task : milestone.Project_Tasks__r) {
        milestones.add(new MilestoneWrapper(milestone, task, newProject.Deadline__c));
      }
    }
  }
  
  /*--------------------------------------------------------------------------------------
    Action Function to Update the Dates on change of STR Date on Page 3
  ----------------------------------------------------------------------------------------*/
  public PageReference updateDates() {
    Date strDate = newProject.Deadline__c;
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
    newProject.Name = newProject.Name.subString(0, newProject.Name.lastIndexOf(' - '));
    newProject.Name += ' - '+ String.valueOf(strDate.month())+'/'+String.valueOf(strDate.day())+'/'+String.valueOf(strDate.year()) ;
    return null;
  }
  
  /*--------------------------------------------------------------------------------------
    Method to clone and finally save the Program, Milestones and Tasks
  ----------------------------------------------------------------------------------------*/
  public PageReference saveRecords() {
    Savepoint sp = Database.setSavepoint();
    Milestone1_Project__c projectToInsert = selectedProjectTemplate.clone(false, true);
    projectToInsert.Region__c = newProject.Region__c; 
    projectToInsert.Name = newProject.Name;
    projectToInsert.Deadline__c = newProject.Deadline__c;
    projectToInsert.Program_Type__c = newProject.Program_Type__c;
    projectToInsert.Description__c = newProject.Description__c;
    projectToInsert.RecordTypeId = fetchRecordTypeId(MARKET_PROGRAM_OBJ_NAME, PROJECT_RT_STANDARD);
    projectToInsert.Status__c = 'Planning';
    projectToInsert.Kickoff__c = newProject.Kickoff__c;
    try {
      insert projectToInsert;
    }
    catch(Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      Database.rollback(sp);
      projectToInsert = projectToInsert.clone(false);
      return null;
    }
    if(product != '') {
      Market_Ready_Product__c marketProduct = new Market_Ready_Product__c(Program__c = projectToInsert.Id, Product__c = (Id)product);
      try {
        insert marketProduct;
      }
      catch(Exception ex) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        Database.rollback(sp);

        return null;
      }  
    }
    List<Milestone1_Milestone__c> milestonesToInsert = new List<Milestone1_Milestone__c>();
    Set<Id> milestoneIds = new Set<Id>();

    for(Milestone1_Milestone__c mw : MilestonesAndTasks) {
      if(!milestoneIds.contains(mw.Id)) {
        Milestone1_Milestone__c clonedMilestone = mw.clone(false, true);
        clonedMilestone.Project__c = projectToInsert.Id;
        clonedMilestone.RecordTypeId = fetchRecordTypeId(PROGRAM_MILESTONE_OBJ_NAME, MILESTONE_RT_STANDARD);
        clonedMilestone.Status__c = 'Not Started';
        milestoneIds.add(mw.Id);
        milestonesToInsert.add(clonedMilestone);
      }
    }
    try {
      insert milestonesToInsert;
    } catch(Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      Database.rollback(sp);
      return null;
    }  

    Map<Id,Date> msStartDate = new Map<Id,Date>();
    Map<Id,Date> msDueDate = new Map<Id,Date>();
    List<Milestone1_Task__c> tasksToInsert = new List<Milestone1_Task__c>();
    Integer startIndex = 0;
    for(Integer i = 0 ; i < MilestonesAndTasks.size() ; i++) {
      Milestone1_Milestone__c newMilestone = MilestonesAndTasks[i];
      for(Integer j = startIndex ; j < startIndex + newMilestone.Project_Tasks__r.size() ; j++) {
        Milestone1_Task__c newTask = milestones[j].task.clone(false);

        // Map Milestones to Max Due Date and Min Start Dates of Tasks
        if(newTask.Start_Date__c != null && (!msStartDate.containsKey(milestonesToInsert[i].Id)
           || msStartDate.get(milestonesToInsert[i].Id) > newTask.Start_Date__c)){
          msStartDate.put(milestonesToInsert[i].Id,newTask.Start_Date__c);
        }
        if(newTask.Due_Date__c != null && (!msDueDate.containsKey(milestonesToInsert[i].Id)
           || msDueDate.get(milestonesToInsert[i].Id) < newTask.Due_Date__c)){
          msDueDate.put(milestonesToInsert[i].Id,newTask.Due_Date__c);
        }

        newTask.Project_Milestone__c = milestonesToInsert[i].Id;
        newTask.Task_Stage__c = 'Not Started';
        if(newTask.Class__c == TASK_RT_RETAILER) {
          newTask.RecordTypeId = fetchRecordTypeId(PROGRAM_TASK_OBJ_NAME, TASK_RT_RETAILER);
        }
        else {
          if(newTask.Class__c == TASK_RT_WHOLESALER) {
	          newTask.RecordTypeId = fetchRecordTypeId(PROGRAM_TASK_OBJ_NAME, TASK_RT_WHOLESALER);
	        }
	        else {
	          newTask.RecordTypeId = fetchRecordTypeId(PROGRAM_TASK_OBJ_NAME, TASK_RT_STANDARD);
	        }
        }
        tasksToInsert.add(newtask);
      }
      startIndex += newMilestone.Project_Tasks__r.size();
    }
    try {
      insert tasksToInsert;
    } catch(Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      Database.rollback(sp);
      return null;
    }  

    // Update Milestone Deadline and Start Date with Max due date and Min start dates from tasks
    for(Milestone1_Milestone__c ms : milestonesToInsert){
      ms.Deadline__c = msDueDate.get(ms.Id);
      ms.Kickoff__c = msStartDate.get(ms.Id);
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
    public Milestone1_Milestone__c milestone {get; set;}
    public Milestone1_Task__c task {get; set;}
    
    public MilestoneWrapper(Milestone1_Milestone__c milestone, Milestone1_Task__c mileTask, Date strDate) {
      this.milestone = milestone;
      this.milestoneName = milestone.Name;
      //task = new Milestone1_Task__c(Name = mileTask.Name, Task_Lead_Time__c = mileTask.Task_Lead_Time__c, Task_Expected_Duration__c = mileTask.Task_Expected_Duration__c);
      this.task = mileTask.clone();
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
}