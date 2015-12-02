global class AttachmentCascadeBatch implements Database.Batchable<sObject>  {
	
	public Date currentDate = Date.today();
	private String query = 'select Id, Name from lboc_Master_Attachment__c where lboc_Start_Date__c <= :currentDate and lboc_End_Date__c >= :currentDate';
	
    global Database.QueryLocator start(Database.BatchableContext cascadeAttachmentBatchContext)
    {   
    	System.Debug(LoggingLevel.Info, 'Query ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext cascadeAttachmentBatchContext, List<lboc_Master_Attachment__c> masterAttachments)
    {    	
    	System.Debug(LoggingLevel.Info, 'Master Attachments Results Size' + masterAttachments.size());
    	if(masterAttachments.size() > 0)
    	{    		
    		AttachmentCascadeBatchService attachmentCascadeBatchService = new AttachmentCascadeBatchService(masterAttachments);
    		 		
    		Map<lboc_Master_Attachment__c, Set<Id>> masterAttachmentOutletMap = attachmentCascadeBatchService.createMasterAttachmentOutletMap();

			//Attachments
       		Map<Id, List<Attachment>> masterAttachmentAttachmentsMap = attachmentCascadeBatchService.getAttachmentsForMasterAttachments();  
       		if(masterAttachmentAttachmentsMap.size() > 0)
       		{	
    			List<Attachment> newAttachments = attachmentCascadeBatchService.createOutletAttachmentsFromMasterAttachments(masterAttachmentOutletMap, masterAttachmentAttachmentsMap);		
    			attachmentCascadeBatchService.saveOutletAttachments(newAttachments);
       		}
       		
    		//Notes
    		Map<Id, List<Note>> masterAttachmentNotesMap = attachmentCascadeBatchService.getNotesForMasterAttachments(); 
    		if(masterAttachmentNotesMap.size() > 0)
    		{
    			List<Note> newNotes = attachmentCascadeBatchService.createOutletNotesFromMasterAttachments(masterAttachmentOutletMap, masterAttachmentNotesMap); 	   		
    			attachmentCascadeBatchService.saveOutletAttachments(newNotes);
    		}
    		if(masterAttachmentAttachmentsMap.size() > 0 || masterAttachmentNotesMap.size() > 0)
    			attachmentCascadeBatchService.addMasterAttachmentOutletIntersections(masterAttachmentOutletMap);
    	}
    }	
    
    global void finish(Database.BatchableContext cascadeAttachmentBatchContext)
    {
        system.debug('Cascade Attachment Batch completed');
    }    
	
}