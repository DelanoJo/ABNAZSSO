/**
 *  Trigger to create the Account Detail & Account Performance records 
 *  when Account is added for the first time. 
 *
 * Modified:
 * Matt Salpietro      Appirio      10/1/2015    Add check for NRS record types
 */

trigger AccountSummaryTrigger on Account (after insert) 
{
    
    private static final Set<String> nrsRTNames = new Set<String>{'Banner','Chain','Decision Point','POC','Wholesaler'};
    private static final Set<Id> nrsRTIds = new Set<Id>();

    for(String rt : nrsRTNames){
        nrsRTIds.add(Util.getRecordTypeId('Account', rt));
    }

    List<lboc_Account_Performance__c> acctPerfList = new List<lboc_Account_Performance__c>();
    List<lboc_Account_Detail__c> acctDetailList = new List<lboc_Account_Detail__c>();
    
    
    for(Account acctRec : Trigger.new)
    {
        if(!nrsRTIds.contains(acctRec.RecordTypeId)){
            lboc_Account_Detail__c acctDetailRec = new lboc_Account_Detail__c();
            lboc_Account_Performance__c acctPerfRec = new lboc_Account_Performance__c();
            
            system.debug('Size List ID ::: ' + acctRec.Id);
            acctDetailRec.lboc_Account__c = acctRec.Id;
            acctPerfRec.lboc_Account__c = acctRec.Id;
            
            acctPerfList.add(acctPerfRec);
            acctDetailList.add(acctDetailRec);
        }
    }
    
    if(acctDetailList != null && acctDetailList.size() > 0)
    {
        insert acctDetailList;
    }
    
    if(acctPerfList != null && acctPerfList.size() > 0)
    {
        insert acctPerfList;
    }

}