public with sharing class ItemPriceRecord {
    
    public static boolean calledFromBatch = false;// to prevent dml operations on trigger.new when code is called from trigger
    public static boolean preventUpateTrigger = false; //to prevent the recursion of update trigger     
    
    public static void setUnsetFlags(List <M_Item_Price__c> itemPriceList){
              
        Map <id,M_Item_Price__c> itemPriceSetUnsetFlags = new Map<Id,M_Item_Price__c>();
        if(!(OPLIRecord.getActiveOPLISetting().M_Item_Price_unique_product__c)){
            
            for(M_Item_Price__c a : itemPriceList){             
                
                if(System.today() >= a.M_Selling_From__c && System.today() <= a.M_Selling_Until__c){
                
                    if (a.M_Active_for_Order__c == false){
                                            
                        system.debug('set order flag'+a.Name);
                        a.M_Active_for_Order__c = true;
                        itemPriceSetUnsetFlags.put(a.id,a);
                    }
                }
                else{
                
                    if (a.M_Active_for_Order__c == true){
                    
                        system.debug('Unset order flag'+a.Name);
                        a.M_Active_for_Order__c = false;
                        itemPriceSetUnsetFlags.put(a.id,a);
                    }                   
                }
                  
                if(System.today() >= a.M_Returning_From_c__c && System.today() <= a.M_Returning_Until__c){
                    if (a.M_Active_for_Returns__c==false){
                        if (itemPriceSetUnsetFlags.containsKey(a.id)) {
                            itemPriceSetUnsetFlags.get(a.id).M_Active_for_Returns__c=true;
                        }
                        else {
                            a.M_Active_for_Returns__c=true;
                            itemPriceSetUnsetFlags.put(a.id,a);
                        }
                        system.debug('set return flag'+a.Name);
                    }
                }
                else{
                    if (a.M_Active_for_Returns__c==true){
                        if (itemPriceSetUnsetFlags.containsKey(a.id)) {                         
                            itemPriceSetUnsetFlags.get(a.id).M_Active_for_Returns__c=false;
                        }
                        else {
                            a.M_Active_for_Returns__c = false;
                            itemPriceSetUnsetFlags.put(a.id,a);                         
                        }
                        system.debug('Unset return flag'+a.Name);
                    }
                }
                
            }
                        
            if(itemPriceSetUnsetFlags.size()>0 && calledFromBatch){
                        
                preventUpateTrigger = true;
                update itemPriceSetUnsetFlags.values();
            }
            
        } //End if
    } 
    
    
    public static void removeDuplicates(List<Id> ProductIds)
    {
    	/*
        system.debug('removeDuplicates'+preventUpateTrigger);
        if(!(OPLIRecord.getActiveOPLISetting().M_Item_Price_unique_product__c)){
        
            //List of all records ordered  by Product and Product Format so that it is easier to compare
            List <M_Item_Price__c> itemPriceOrders = new List<M_Item_Price__c>([select id,M_PriceListProductProductFormat__c,M_ProductProductFormat__c, M_IntNameValue__c, M_Item__c, M_Product_Format__c, M_Active_for_Order__c, M_Selling_From__c,M_Selling_Until__c from M_Item_Price__c where M_Item__c in:ProductIds and M_Active_for_Order__c = true order by M_PriceListProductProductFormat__c asc, M_IntNameValue__c desc]);
            List <M_Item_Price__c> itemPriceReturns = new List<M_Item_Price__c>([select id,M_PriceListProductProductFormat__c,M_ProductProductFormat__c, M_IntNameValue__c, M_Item__c, M_Product_Format__c, M_Active_for_Returns__c, M_Returning_From_c__c, M_Returning_Until__c from M_Item_Price__c where M_Item__c in:ProductIds and M_Active_for_Returns__c = true order by  M_PriceListProductProductFormat__c asc, M_IntNameValue__c desc]);
            
            system.debug('itemPriceOrders'+itemPriceOrders.size()+itemPriceOrders);
            system.debug('itemPriceReturns'+itemPriceReturns.size()+itemPriceReturns);
            
            Map <id,M_Item_Price__c> itemPriceUnsetFlags = new Map<Id,M_Item_Price__c>();
            //detect return duplicates
            String previousPProdFormat = 'start';
            for(M_Item_Price__c ip:itemPriceReturns){
                
                                        
                system.debug('compare for retun '+previousPProdFormat+' with ' +ip.M_PriceListProductProductFormat__c + ' Id:' + ip.id);
                if(ip.M_PriceListProductProductFormat__c.equals(previousPProdFormat)){      //Duplicate detected.. Uncheck it           
                    system.debug('return previousPProdFormat is equal to current');
                    ip.M_Active_for_Returns__c = false;
                    if(itemPriceUnsetFlags.containsKey(ip.id)){
                        itemPriceUnsetFlags.get(ip.id).M_Active_for_Returns__c = false;
                    }
                    else{
                        itemPriceUnsetFlags.put(ip.id,ip);
                    }                   
                }
                                
                previousPProdFormat = ip.M_PriceListProductProductFormat__c;
            }
            
            //detect order duplicates
            previousPProdFormat = 'start';
            for(M_Item_Price__c ip : itemPriceOrders){
                                
                system.debug('compare for order '+previousPProdFormat+' with ' +ip.M_PriceListProductProductFormat__c+ ' Id:' +ip.id);
                if(ip.M_PriceListProductProductFormat__c.equals(previousPProdFormat)){              
                    system.debug('order previousPProdFormat is equal to current'); //Duplicate detected.. Uncheck it    
                    ip.M_Active_for_Order__c = false;
                    if(itemPriceUnsetFlags.containsKey(ip.id)){
                        itemPriceUnsetFlags.get(ip.id).M_Active_for_Order__c = false;
                    }
                    else{
                        itemPriceUnsetFlags.put(ip.id,ip);
                    }                   
                }               
                previousPProdFormat = ip.M_PriceListProductProductFormat__c;
            }
            
            if(itemPriceUnsetFlags.size()>0){
                system.debug('updatating unsetflags'+itemPriceUnsetFlags);
                preventUpateTrigger = true;
                update itemPriceUnsetFlags.values();
            }
        }
        
        system.debug('UPDATED unsetflags'+preventUpateTrigger);
        */
    }
    
    public static void removeDuplicatesInBatch(List <M_Item_Price__c> itemPriceList){
        system.debug('removeDuplicates'+preventUpateTrigger);
        if(!(OPLIRecord.getActiveOPLISetting().M_Item_Price_unique_product__c)){
        
            //List of all records ordered  by Product and Product Format so that it is easier to compare
            List <M_Item_Price__c> itemPriceOrders = new List<M_Item_Price__c>([select M_PriceListProductProductFormat__c,M_ProductProductFormat__c, M_IntNameValue__c, M_Item__c, M_Product_Format__c, M_Active_for_Order__c, M_Selling_From__c,M_Selling_Until__c from M_Item_Price__c where M_Active_for_Order__c = true  and Id in: itemPriceList order by M_PriceListProductProductFormat__c asc, M_IntNameValue__c desc]);
            List <M_Item_Price__c> itemPriceReturns = new List<M_Item_Price__c>([select M_PriceListProductProductFormat__c,M_ProductProductFormat__c, M_IntNameValue__c, M_Item__c, M_Product_Format__c, M_Active_for_Returns__c, M_Returning_From_c__c, M_Returning_Until__c from M_Item_Price__c where M_Active_for_Returns__c = true and Id in: itemPriceList order by  M_PriceListProductProductFormat__c asc, M_IntNameValue__c desc]);
            
            system.debug('itemPriceOrders'+itemPriceOrders.size()+itemPriceOrders);
            system.debug('itemPriceReturns'+itemPriceReturns.size()+itemPriceReturns);
            
            Map <id,M_Item_Price__c> itemPriceUnsetFlags = new Map<Id,M_Item_Price__c>();
            //detect return duplicates
            String previousPProdFormat = null;
            for(M_Item_Price__c ip:itemPriceReturns){
                
                
                if(previousPProdFormat == null){
                    system.debug('previousPProdFormat for first time');
                    previousPProdFormat = ip.M_PriceListProductProductFormat__c;
                    continue;
                }
                
                system.debug('compare: '+ip.M_IntNameValue__c+ip.M_PriceListProductProductFormat__c+' with ' +ip.M_IntNameValue__c+ip.M_PriceListProductProductFormat__c);
                if(!ip.M_PriceListProductProductFormat__c.equals(previousPProdFormat)){
                    system.debug('return previousPProdFormat is not equal to current');
                    ip.M_Active_for_Returns__c = true;
                }
                else{
                    system.debug('return previousPProdFormat is equal to current');
                    ip.M_Active_for_Returns__c = false;
                    
                    //update unset flags map
                    if(itemPriceUnsetFlags.containsKey(ip.id)){
                        itemPriceUnsetFlags.get(ip.id).M_Active_for_Returns__c = false;
                    }                   else{
                        itemPriceUnsetFlags.put(ip.id,ip);
                    }
                }
                
                system.debug('return setting previousPProdFormat  to current item Price');
                previousPProdFormat = ip.M_PriceListProductProductFormat__c;
            }
            
            //detect order duplicates
            previousPProdFormat = null;
            for(M_Item_Price__c ip : itemPriceOrders){
                
                if(previousPProdFormat == null){
                    system.debug('order previousPProdFormat for first time');
                    previousPProdFormat = ip.M_PriceListProductProductFormat__c;
                    continue;
                }
                system.debug('compare'+ip.M_PriceListProductProductFormat__c+' with ' +ip.M_PriceListProductProductFormat__c);
                if(!ip.M_PriceListProductProductFormat__c.equals(previousPProdFormat)){
                    system.debug('order previousPProdFormat is not equal to current');
                    ip.M_Active_for_Order__c = true;
                }
                else{
                    system.debug('order previousPProdFormat is equal to current');
                    ip.M_Active_for_Order__c = false;
                    
                    //update unset flags map
                    if(itemPriceUnsetFlags.containsKey(ip.id)){
                        itemPriceUnsetFlags.get(ip.id).M_Active_for_Order__c = false;
                    }
                    else{
                        itemPriceUnsetFlags.put(ip.id,ip);
                    }
                }
                system.debug('order setting previousPProdFormat  to current item Price');
                previousPProdFormat = ip.M_PriceListProductProductFormat__c;
            }
            
            if(itemPriceUnsetFlags.size()>0){
                system.debug('updatating unsetflags'+itemPriceUnsetFlags);
                preventUpateTrigger = true;
                update itemPriceUnsetFlags.values();
            }
        }
        system.debug('UPDATED unsetflags'+preventUpateTrigger);
        
    }
    
    public static void sendEmailJobFinish(Database.BatchableContext bc, String pJobName){
        AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedDate, CreatedBy.Email FROM AsyncApexJob where Id = :BC.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String jobStatus = (a.NumberOfErrors > 0)? (a.Status + ' ' + 'With Errors' + ' (' + a.NumberOfErrors + ')'): a.Status;
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);

        // TODO: handle date locale. Display the date in user format/time
        mail.setSubject(a.CreatedDate + ' ' + 'Apex Job' + ' [' + pJobName + ']: '+ jobStatus);
        String bodyText = + 'APEX JOB PROCESSED' + ' [' + a.JobItemsProcessed + '] ' + 'Items With'
        + ' ' + a.NumberOfErrors + ' ' + 'With Errors' + '. \n' +
            '\n' + 'Total Items' + ': ' + a.TotalJobItems +
            '\n' + 'Processed Items' + ': ' + a.JobItemsProcessed +
            '\n' + 'Errors' + ': ' + a.NumberOfErrors +
            '\n\n' + ((a.ExtendedStatus == null)? '': a.ExtendedStatus) +
            '\n\n' ;
        mail.setPlainTextBody(bodyText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    
}