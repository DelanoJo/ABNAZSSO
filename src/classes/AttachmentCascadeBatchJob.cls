global class AttachmentCascadeBatchJob implements Schedulable {
	
	global void execute(SchedulableContext ctx) {
    	AttachmentCascadeBatch attachmentCascadeBatch = new AttachmentCascadeBatch();    
        Id batchprocessid = Database.executeBatch(attachmentCascadeBatch);
	}
}