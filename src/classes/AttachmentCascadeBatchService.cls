public class AttachmentCascadeBatchService {
	
	private Map<Id, lboc_Master_Attachment__c> masterAttachmentMap;
	private Map<Id, Set<Id>> existingMasterAttachmentForOutletsMap;
	
	public AttachmentCascadeBatchService(List<lboc_Master_Attachment__c> masterAttachments)
	{
		this.masterAttachmentMap = createMasterAttachmentMap(masterAttachments);
		this.existingMasterAttachmentForOutletsMap = createExistingMasterAttachmentForOutletsMap();
	}
	
	private Map<Id, lboc_Master_Attachment__c> createMasterAttachmentMap(List<lboc_Master_Attachment__c> masterAttachments)
	{		
    	Map<Id, lboc_Master_Attachment__c> masterAttachmentMap = new Map<Id, lboc_Master_Attachment__c>();
    	for(lboc_Master_Attachment__c masterAttachment:masterAttachments)
    	{
    		masterAttachmentMap.put(masterAttachment.Id, masterAttachment);			
    	}
    	return masterAttachmentMap;
	}
	
	public Map<lboc_Master_Attachment__c, Set<Id>> createMasterAttachmentOutletMap()
    {
     	Map<lboc_Master_Attachment__c, Set<Id>> masterAttachmentOutletMap = new Map<lboc_Master_Attachment__c, Set<Id>>();
    	
    	//get master objective markets and store in a map of markets that have values of a list of master objectives
		Map<Id, List<Id>> marketMasterAttachmentMap = new Map<Id, List<Id>>();															 
    	List<lboc_Master_Attachment_Market__c> masterAttachmentMarkets = [select Id, lboc_Master_Attachment__c, lboc_Market__c from lboc_Master_Attachment_Market__c 
    																	 where lboc_Master_Attachment__c in :masterAttachmentMap.keySet()];
    																	     																	 
		for(lboc_Master_Attachment_Market__c masterAttachmentMarket:masterAttachmentMarkets)
		{
			if(marketMasterAttachmentMap.get(masterAttachmentMarket.lboc_Market__c) == null)	
				marketMasterAttachmentMap.put(masterAttachmentMarket.lboc_Market__c, new List<Id>());	
			marketMasterAttachmentMap.get(masterAttachmentMarket.lboc_Market__c).add(masterAttachmentMarket.lboc_Master_Attachment__c);		
		}																 	
    	
    	//get accounts for the markets that are related to our master objectives 
    	Map<Id, List<Id>> targetedAccountsMarketsMap = new Map<Id, List<Id>>();   
    	List<buzz_retail__TGAC__c> targetedAccounts = [select Id, buzz_retail__Account__c, buzz_retail__TG__c 
    												   from buzz_retail__TGAC__c 
    												   where buzz_retail__TG__c in :marketMasterAttachmentMap.keyset()];
		for(buzz_retail__TGAC__c targetedAccount:targetedAccounts)
		{
			if(targetedAccountsMarketsMap.get(targetedAccount.buzz_retail__Account__c) == null)
				targetedAccountsMarketsMap.put(targetedAccount.buzz_retail__Account__c, new List<Id>());
			targetedAccountsMarketsMap.get(targetedAccount.buzz_retail__Account__c).add(targetedAccount.buzz_retail__TG__c);
		}
    	
    	lboc_Master_Attachment__c masterAttachment;													 
    	for(Id outletId:targetedAccountsMarketsMap.keyset())
    	{  		
    		for(Id marketId:targetedAccountsMarketsMap.get(outletId))
    		{
    			for(Id masterAttachmentId:marketMasterAttachmentMap.get(marketId))	
    			{
					masterAttachment = masterAttachmentMap.get(masterAttachmentId);
					//check if the attachment already exists for this outlet for this master attachment
					if(existingMasterAttachmentForOutletsMap.get(masterAttachment.Id) == null || !(existingMasterAttachmentForOutletsMap.get(masterAttachment.Id).contains(outletId))) 
					{				
    					if(masterAttachmentOutletMap.get(masterAttachment) == null)
    						masterAttachmentOutletMap.put(masterAttachment, new Set<Id>());
    					masterAttachmentOutletMap.get(masterAttachment).add(outletId);   
					}				
    			}    			
    		}  		
    	}    	    	
    	return masterAttachmentOutletMap;
    }

    public Map<Id,Set<Id>> createExistingMasterAttachmentForOutletsMap()
    {
    	Map<Id, Set<Id>> existingMasterAttachmentForOutletsMap = new Map<Id, Set<Id>>();
   		for(lboc_Master_Attachment_Outlet__c existingAttachment:[select Id, lboc_Outlet__c, lboc_Master_Attachment__c from lboc_Master_Attachment_Outlet__c 
   												where lboc_Master_Attachment__c in :masterAttachmentMap.keyset()])
   		{
   			if(existingMasterAttachmentForOutletsMap.get(existingAttachment.lboc_Master_Attachment__c) == null)
   				existingMasterAttachmentForOutletsMap.put(existingAttachment.lboc_Master_Attachment__c, new Set<Id>());
   			existingMasterAttachmentForOutletsMap.get(existingAttachment.lboc_Master_Attachment__c).add(existingAttachment.lboc_Outlet__c);
   		}
   		System.debug(LoggingLevel.Info,'Existing Master Attachment Size ' + existingMasterAttachmentForOutletsMap.size());
   		return existingMasterAttachmentForOutletsMap;  	
    }

	public List<Attachment> createOutletAttachmentsFromMasterAttachments(Map<lboc_Master_Attachment__c, Set<Id>> masterAttachmentOutletsMap, Map<Id, List<Attachment>> masterAttachmentAttachmentsMap)
	{
		List<Attachment> outletAttachments = new List<Attachment>();
    	Attachment outletAttachment;
    	
    	for(lboc_Master_Attachment__c masterAttachment:masterAttachmentOutletsMap.keyset())
    	{
    		for(Id outletId:masterAttachmentOutletsMap.get(masterAttachment))
    		{
    			if(masterAttachmentAttachmentsMap.get(masterAttachment.Id) != null)
    			{
    				for(Attachment attachment:masterAttachmentAttachmentsMap.get(masterAttachment.Id))
    				{
    					outletattachment = new  Attachment(Name = attachment.Name, Body = attachment.Body, Description = attachment.Description, ParentId = outletId );													   
						outletAttachments.add(outletattachment);
    				}
    			}	
    		}
    	}
    	return outletAttachments;
	}
	
	public void addMasterAttachmentOutletIntersections(Map<lboc_Master_Attachment__c, Set<Id>> masterAttachmentOutletsMap)
	{
		List<lboc_Master_Attachment_Outlet__c> masterAttachmentOutlets = new List<lboc_Master_Attachment_Outlet__c>();
		lboc_Master_Attachment_Outlet__c masterAttachmentOutlet;
		
		for(lboc_Master_Attachment__c masterAttachment:masterAttachmentOutletsMap.keyset())
		{
			for(Id outletId:masterAttachmentOutletsMap.get(masterAttachment))
			{
				System.Debug(LoggingLevel.Info, 'Master Attachment and Outlet Id: ' + masterAttachment.Id + ' ' + outletId);
				masterAttachmentOutlet = new lboc_Master_Attachment_Outlet__c(lboc_Master_Attachment__c = masterAttachment.Id, lboc_Outlet__c = outletId);
				masterAttachmentOutlets.add(masterAttachmentOutlet);
			}
		}
		
		System.Debug(LoggingLevel.Info, 'Master Attachment Outlet Size: ' + masterAttachmentOutlets.size());
		
		if(masterAttachmentOutlets.size() > 0)
			insert masterAttachmentOutlets;
	}
	
	public List<Note> createOutletNotesFromMasterAttachments(Map<lboc_Master_Attachment__c, Set<Id>> masterAttachmentOutletsMap, Map<Id, List<Note>> masterAttachmentNotesMap)
	{
		List<Note> outletNotes = new List<Note>();
    	Note outletNote;
    	
    	for(lboc_Master_Attachment__c masterAttachment:masterAttachmentOutletsMap.keyset())
    	{
    		for(Id outletId:masterAttachmentOutletsMap.get(masterAttachment))
    		{
    			if(masterAttachmentNotesMap.get(masterAttachment.Id) != null)
    			{
    				for(Note note:masterAttachmentNotesMap.get(masterAttachment.Id))
    				{
    					outletNote = new Note(Body = note.Body, ParentId = outletId, Title = note.Title );													   
						outletNotes.add(outletNote);
    				}	
    			}
    		}
    	}
    	return outletNotes;
	}	
	
	public Map<Id, List<Attachment>> getAttachmentsForMasterAttachments()
	{
		List<Attachment> attachments = [select Id, Name, Body, ParentId, Description from Attachment where ParentId in :masterAttachmentMap.keyset()];
		System.debug(LoggingLevel.Info, 'Attachments List Size' + attachments.size());
		Map<Id, List<Attachment>> masterAttachmentAttachmentMap = new Map<Id, List<Attachment>>();
		for(Attachment attachment:attachments)
		{
			if(masterAttachmentAttachmentMap.get(attachment.ParentId) == null)
				masterAttachmentAttachmentMap.put(attachment.ParentId, new List<Attachment>());
			masterAttachmentAttachmentMap.get(attachment.ParentId).add(attachment);
		}
		return masterAttachmentAttachmentMap;	
	}
	
	public Map<Id, List<Note>> getNotesForMasterAttachments()
	{
		List<Note> notes = [select Id, Body, ParentId, Title from Note where ParentId in :masterAttachmentMap.keyset()];
		Map<Id, List<Note>>	masterAttachmentNoteMap = new Map<Id, List<Note>>();
		for(Note note:notes)
		{
			if(masterAttachmentNoteMap.get(note.ParentId) == null)
				masterAttachmentNoteMap.put(note.ParentId, new List<Note>());
			masterAttachmentNoteMap.get(note.ParentId).add(note);
		}
		return masterAttachmentNoteMap;			
	}	
	
	public void saveOutletAttachments(List<sObject> newAttachments)
	{
		if(newAttachments.size() > 0)
			insert newAttachments;
	}

}