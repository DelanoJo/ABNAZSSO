trigger OrderTrigger on M_Order_sigcap_Header__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    M_OPLI_Settings__c activeOPLI = OPLIRecord.getActiveOPLISetting();
     
    Integer RDD = Integer.valueOf(activeOPLI.M_Requested_Delivery_Days__c);
    
    //LN item#700
    map<string,Delivery_Lead_Time__c> MapDLT = new map<string,Delivery_Lead_Time__c>();

                                                        
    for(Delivery_Lead_Time__c d : [Select State__c, Delivery_Lead_Days__c 
                                   From Delivery_Lead_Time__c   where OPLI_Settings__r.M_IsActive__c = true ]){
              MapDLT.put(d.State__c,d);
    }

    if (trigger.isBefore && trigger.isInsert){
        
        //ORI023
        list<M_Order_sigcap_Header__c> allOrders= trigger.new;
        set<Id> allAccountIds = new set<id>();
        set<Id> allCallIds = new set<id>();
        
        // ORI-022 JLEDEZMA 16OCT2012 BEGIN 
        set<Id> allInvLocIds = new set<id>();
        // ORI-022 JLEDEZMA 16OCT2012 END

        for (M_Order_sigcap_Header__c ord: allOrders)
        {

          //LN  -- Item 684
            if ( ord.M_Order__c == null && ord.M_AccountName__c ==null && ord.M_Call__c ==null){
                 ord.addError(system.label.ORI_020_CALL_SOLD_TO);
                  break;
            }


            if (ord.M_Is_Mobile__c == false){
                
                allAccountIds.add(ord.M_AccountName__c);
                if (ord.M_Call__c != null)
                    allCallIds.add(ord.M_Call__c);
                    
                // ORI-022 JLEDEZMA 16OCT2012 BEGIN
                if (ord.Inventory_Location__c != null)
                    allInvLocIds.add(ord.Inventory_Location__c);
                // ORI-022 JLEDEZMA 16OCT2012 END
                    
            }
            
        }
        
        map<Id,buzz_retail__Call__c> calls = new map<Id,buzz_retail__Call__c>([select Id, buzz_retail__Account__c from buzz_retail__Call__c
                                                                        Where Id in: allCallIds]);
                                                                        
        for(buzz_retail__Call__c call : calls.values() )
        {
            if (call.buzz_retail__Account__c != null)
                allAccountIds.add(call.buzz_retail__Account__c);
        }
        
        map<Id,Account> accounts = new map<Id,Account>([select Id,ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, 
                                                        ShippingCity from Account Where Id IN: allAccountIds]); 


        // ORI-022 JLEDEZMA 16OCT2012 BEGIN
        map<Id,M_Inventory_Location__c> invlocations = new map<Id,M_Inventory_Location__c>([select Id, M_Distributor__c, M_Location_City__c, M_Location_Postal_Code_ZIP__c, M_Location_State__c, M_Location_Street__c, M_Inventory_Location_ID__c from M_Inventory_Location__c
                                                                        Where Id in: allInvLocIds]);
        // ORI-022 JLEDEZMA 16OCT2012 END
                                                                
        Account accountHandle;
        // ORI-022 JLEDEZMA 16OCT2012 BEGIN
        M_Inventory_Location__c invlocHandle;
        // ORI-022 JLEDEZMA 16OCT2012 END
                                                
        for (M_Order_sigcap_Header__c ord: allOrders){
            if (ord.M_Is_Mobile__c == false){
                
               //ORI-023 : If there is a Call then Call's shipping address should be used else SoldTo's shipping address 
               if (ord.M_Call__c != null)
                    accountHandle = accounts.get(calls.get(ord.M_Call__c).buzz_retail__Account__c);
                // ORI-022 JLEDEZMA 16OCT2012 BEGIN
               // else if (ord.Inventory_Location__c != null)
                                  //system.debug(' JLJLJL ord.Inventory_Location__c: ' + ord.Inventory_Location__c);
                
                    //accountHandle = accounts.get(invlocations.get(ord.Inventory_Location__c).M_Distributor__c);
                // ORI-022 JLEDEZMA 16OCT2012 END
                else      
                    accountHandle = accounts.get(ord.M_AccountName__c);        
                                
                // ORI-022 JLEDEZMA 16OCT2012 BEGIN
                if (ord.Inventory_Location__c != null){
                    invlocHandle = invlocations.get(ord.Inventory_Location__c);
                    if (invlocHandle != null){
                        ord.M_Shipping_Address__c = Util.IsNull(invlocHandle.M_Location_Street__c, '');        
                        ord.M_Shipping_City__c = Util.IsNull(invlocHandle.M_Location_City__c, '');
                        ord.M_Shipping_State__c = Util.IsNull(invlocHandle.M_Location_State__c, '');
                        ord.M_Shipping_ZIP_Postal_Code__c = Util.IsNull(invlocHandle.M_Location_Postal_Code_ZIP__c, '');

                                                
                    }                
                }
                // ORI-022 JLEDEZMA 16OCT2012 END
                else if (accountHandle != null){
                    //system.debug('JLJLJL accountHandle:  '+accountHandle.Name);
                    
                    ord.M_Shipping_Address__c = Util.IsNull(accountHandle.ShippingStreet, '');
                    ord.M_Shipping_City__c = Util.IsNull(accountHandle.ShippingCity, '');
                    ord.M_Shipping_State__c = Util.IsNull(accountHandle.ShippingState, '');
                    ord.M_Shipping_ZIP_Postal_Code__c = Util.IsNull(accountHandle.ShippingPostalCode, '');
                    ord.M_Shipping_Country__c = Util.IsNull(accountHandle.ShippingCountry,'');
                }
                 
                 //ORI-14 : Today date is the default value for Order Date. But if there is a call the call.date should be replaced with today date.                           
                 if (ord.M_Call_Date__c!=null)
                     ord.M_Order_Date__c=ord.M_Call_Date__c;
                     
                                 
                     
                 //ORI-016       
                 /*LN Commented this out - check with Karina if still needed
                 if (ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'None')
                 { 
                    if  (ord.M_Required_Delivery_Date__c == null || ord.M_Order_Date__c.daysBetween(ord.M_Required_Delivery_Date__c) < RDD)
                    
                         ord.M_Required_Delivery_Date__c = ord.M_Order_Date__c.addDays(RDD);
                 }  */

            }
        } 
        
    }
    
    //LN item 700 
    if (trigger.isBefore && trigger.isUpdate){
        
        //ORI023
        list<M_Order_sigcap_Header__c> allOrders= trigger.new;
        set<Id> allAccountIds = new set<id>();
        set<Id> allCallIds = new set<id>();
        
        // ORI-022 JLEDEZMA 16OCT2012 BEGIN 
        set<Id> allInvLocIds = new set<id>();
        // ORI-022 JLEDEZMA 16OCT2012 END
        
        
        for (M_Order_sigcap_Header__c ord: allOrders)
        {
            
            If (ord.M_Order__c != null &&  !ord.M_Is_Mobile__c)
            { 

                if ( ord.M_Order__c == null && ord.M_AccountName__c ==null && ord.M_Call__c ==null){
                    ord.addError(system.label.ORI_020_CALL_SOLD_TO);
                    break;
                }
    
                if (ord.M_Is_Mobile__c == false){
                    
                    allAccountIds.add(ord.M_AccountName__c);
                    if (ord.M_Call__c != null)
                        allCallIds.add(ord.M_Call__c);
                        
                    // ORI-022 JLEDEZMA 16OCT2012 BEGIN
                    if (ord.Inventory_Location__c != null)
                        allInvLocIds.add(ord.Inventory_Location__c);
                    // ORI-022 JLEDEZMA 16OCT2012 END
                        
                }
            
            }
        
            map<Id,buzz_retail__Call__c> calls = new map<Id,buzz_retail__Call__c>([select Id, buzz_retail__Account__c from buzz_retail__Call__c
                                                                            Where Id in: allCallIds]);
    
            for(buzz_retail__Call__c call : calls.values() )
            {
                if (call.buzz_retail__Account__c != null)
                    allAccountIds.add(call.buzz_retail__Account__c);
            }
        
            map<Id,Account> accounts = new map<Id,Account>([select Id,ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, 
                                                            ShippingCity from Account Where Id IN: allAccountIds]); 
    
            // ORI-022 JLEDEZMA 16OCT2012 BEGIN
            map<Id,M_Inventory_Location__c> invlocations = new map<Id,M_Inventory_Location__c>([select Id, M_Distributor__c, M_Location_City__c, M_Location_Postal_Code_ZIP__c, M_Location_State__c, M_Location_Street__c, M_Inventory_Location_ID__c from M_Inventory_Location__c
                                                                            Where Id in: allInvLocIds]);
            // ORI-022 JLEDEZMA 16OCT2012 END
                                                                    
            Account accountHandle;
            // ORI-022 JLEDEZMA 16OCT2012 BEGIN
            M_Inventory_Location__c invlocHandle;
            // ORI-022 JLEDEZMA 16OCT2012 END
                                                
            for (M_Order_sigcap_Header__c ordd: allOrders)
            {
            
                if (ordd.M_Order__c != null &&  !ordd.M_Is_Mobile__c)
                {
                
                    //ORI-023 : If there is a Call then Call's shipping address should be used else SoldTo's shipping address 
                    if (ordd.M_Call__c != null)
                        accountHandle = accounts.get(calls.get(ordd.M_Call__c).buzz_retail__Account__c);
                    // ORI-022 JLEDEZMA 16OCT2012 BEGIN
                    // else if (ord.Inventory_Location__c != null)
                    //system.debug(' JLJLJL ord.Inventory_Location__c: ' + ord.Inventory_Location__c);
                    
                    //accountHandle = accounts.get(invlocations.get(ord.Inventory_Location__c).M_Distributor__c);
                    // ORI-022 JLEDEZMA 16OCT2012 END
                    else      
                        accountHandle = accounts.get(ordd.M_AccountName__c);        
                                
                    // ORI-022 JLEDEZMA 16OCT2012 BEGIN
                    if (ordd.Inventory_Location__c != null)
                    {
                        invlocHandle = invlocations.get(ordd.Inventory_Location__c);
                        if (invlocHandle != null)
                        {
                            ordd.M_Shipping_Address__c = Util.IsNull(invlocHandle.M_Location_Street__c, '');        
                            ordd.M_Shipping_City__c = Util.IsNull(invlocHandle.M_Location_City__c, '');
                            ordd.M_Shipping_State__c = Util.IsNull(invlocHandle.M_Location_State__c, '');
                            ordd.M_Shipping_ZIP_Postal_Code__c = Util.IsNull(invlocHandle.M_Location_Postal_Code_ZIP__c, '');                           
                        }                
                    }
                    // ORI-022 JLEDEZMA 16OCT2012 END
                    else if (accountHandle != null)
                    {                       
                        ordd.M_Shipping_Address__c = Util.IsNull(accountHandle.ShippingStreet, '');
                        ordd.M_Shipping_City__c = Util.IsNull(accountHandle.ShippingCity, '');
                        ordd.M_Shipping_State__c = Util.IsNull(accountHandle.ShippingState, '');
                        ordd.M_Shipping_ZIP_Postal_Code__c = Util.IsNull(accountHandle.ShippingPostalCode, '');
                        ordd.M_Shipping_Country__c = Util.IsNull(accountHandle.ShippingCountry,'');
                    }
                 
                    //ORI-14 : Today date is the default value for Order Date. But if there is a call the call.date should be replaced with today date.                           
                    if (ordd.M_Call_Date__c!=null)
                      ordd.M_Order_Date__c=ord.M_Call_Date__c;
    
                }    
            }
        }    
    }
    
    //all stamp triggers and ORI-034
    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate)){
        
        
        list<M_Order_sigcap_Header__c> allOrders= trigger.new;
        list<M_Order_sigcap_Header__c> ordersMobile = new list<M_Order_sigcap_Header__c>();
        
        set<Id> allAccountIds = new set<id>();
        set<Id> allCallIds = new set<id>();
        set<Id> allDistributorIds = new set<id>();
        set<Id> allUserIds = new set<id>();

        // ORI-022 JLEDEZMA 16OCT2012 BEGIN
        set<Id> allInvLocIds = new set<id>();
        // ORI-022 JLEDEZMA 16OCT2012 END
        
        set<Id> soldToIds = new set<id>();
        
        for (M_Order_sigcap_Header__c ord: allOrders)
        {

            if (MapDLT.containsKey(ord.M_Shipping_State__c))
                RDD = Integer.valueOf(MapDLT.get(ord.M_Shipping_State__c).Delivery_Lead_Days__c);

            //ORI-016       
            if (ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'None')
            { 
                if ((ord.M_Required_Delivery_Date__c == null || ord.M_Order_Date__c.daysBetween(ord.M_Required_Delivery_Date__c) < RDD)&&(ord.M_AccountName__c !=null || ord.M_Call__c !=null))
                    ord.M_Required_Delivery_Date__c = ord.M_Order_Date__c.addDays(RDD);
            }  


            if (trigger.isInsert && ord.M_Order__c == null && ord.M_AccountName__c ==null && ord.M_Call__c ==null)
            {
                ord.addError(system.label.ORI_020_CALL_SOLD_TO);
                break;
            }
            else if (trigger.isupdate  && ord.M_AccountName__c ==null && ord.M_Call__c ==null)
            {
                ord.addError(system.label.ORI_020_CALL_SOLD_TO);
                break;
            }
            
            if (trigger.isupdate &&  ord.M_AccountName__c <> null && ord.M_Order__c <> null)
                ord.M_CheckSoldTo__c = true;
                
            // JLEDEZMA 22OCT2012 END.
            soldToIds.add(ord.M_AccountName__c);
            
            // ORI-022 JLEDEZMA 16OCT2012 BEGIN
            if (ord.Inventory_Location__c != null)
                allInvLocIds.add(ord.Inventory_Location__c);
            // ORI-022 JLEDEZMA 16OCT2012 END
 
             // ORI 0344 Cancelled Status Calculation 
            if(ord.M_Status__c == activeOPLI.Cancelled_Order_Status__c && !ord.M_Is_Mobile__c){
                ord.M_CancelledOrder__c = true;
            }
            
            // ORI 0342 Final Status Calculation
//            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'None' &&  ord.M_Status__c == activeOPLI.Final_Order_Status_for_Orders_No_Invent__c && !ord.M_Is_Mobile__c){
            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'None' &&  ord.M_Status__c == activeOPLI.Final_Order_Status_for_Orders_No_Invent__c){
                ord.M_FinalOrder__c = true;
            }
            
//            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'Order' &&  ord.M_Status__c == activeOPLI.Final_Order_Status_for_Orders_w_Invent__c && !ord.M_Is_Mobile__c){
            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'Order' &&  ord.M_Status__c == activeOPLI.Final_Order_Status_for_Orders_w_Invent__c){
                ord.M_FinalOrder__c = true;
            }
            
//            if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'Return' &&  ord.M_Status__c == activeOPLI.M_Final_Order_Status_for_Returns_w_Inven__c && !ord.M_Is_Mobile__c){
            if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'Return' &&  ord.M_Status__c == activeOPLI.M_Final_Order_Status_for_Returns_w_Inven__c){
                ord.M_FinalOrder__c = true;
            }
            
//            if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'None' &&  ord.M_Status__c == activeOPLI.Final_Order_Status_for_Returns_No_Invent__c && !ord.M_Is_Mobile__c){
            if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'None' &&  ord.M_Status__c == activeOPLI.Final_Order_Status_for_Returns_No_Invent__c){
                ord.M_FinalOrder__c = true;
            }
            
            allAccountIds.add(ord.M_AccountName__c);
            allAccountIds.add(ord.M_Distributor__c);
            allUserIds.add(ord.OwnerId);
            if (ord.M_Call__c != null && ord.M_Is_Mobile__c == false)
            {
                allCallIds.add(ord.M_Call__c);
            }
        }
        
        map<Id,buzz_retail__Call__c> calls = new map<Id,buzz_retail__Call__c>([select Id, buzz_retail__Account__c from buzz_retail__Call__c
                                                                                Where Id in: allCallIds]);
        
        map<Id,Account> accounts = new map<Id,Account>([select Id,Name,RecordTypeId,M_Route_Number__c, buzz_retail__Territory__c, buzz_retail__KAM_Territory_ID__c, buzz_retail__Account_ID__c,
                                                        buzz_retail__Account_Record_Type_Display__c from Account Where Id IN:allAccountIds ]);
        
        map<Id,User> allUsers = new map<Id,User>([Select Id, M_Order_Inventory_Account__c, Name from User where id in: allUserIds]);
        
        // ORI-022 JLEDEZMA 16OCT2012 BEGIN
        map<Id,M_Inventory_Location__c> invlocations = new map<Id,M_Inventory_Location__c>([select Id, M_Distributor__c, M_Location_City__c, M_Location_Postal_Code_ZIP__c, M_Location_State__c, M_Location_Street__c, M_Inventory_Location_ID__c from M_Inventory_Location__c
                                                                        Where Id in: allInvLocIds]);
        // ORI-022 JLEDEZMA 16OCT2012 END
                
        set<Decimal> orderInventoryAccounts = new set<Decimal>();     
        
        for(User userHandle: allUsers.values()){
            orderInventoryAccounts.add(userHandle.M_Order_Inventory_Account__c);
        }   
        
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select Id, RecordTypeId from Account where Id IN :soldToIds]);    
        
        Account accountHandle;
        
        // ORI-022 JLEDEZMA 16OCT2012 BEGIN
        M_Inventory_Location__c invlocHandle;
        // ORI-022 JLEDEZMA 16OCT2012 END
        
        for (M_Order_sigcap_Header__c ord: allOrders){
                        
            if (trigger.isInsert && ord.M_Order__c == null && ord.M_AccountName__c ==null && ord.M_Call__c ==null){
                ord.addError(system.label.ORI_020_CALL_SOLD_TO);
                break;
            }
            else if (trigger.isupdate  && ord.M_AccountName__c ==null && ord.M_Call__c ==null){
                ord.addError(system.label.ORI_020_CALL_SOLD_TO);
                break;
            }

            Id accountRecType = RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory);
            Id orderRecType = RecType.getId(M_Order_sigcap_Header__c.SObjectType, RecType.Name.Replenishment);
                            
            //ORD-001
            ord.M_Route_Number__c = allUsers.get(ord.OwnerId).M_Order_Inventory_Account__c;                     

            //ORI-034
            if (ord.M_Call__c != null && ord.M_Is_Mobile__c == false)
            {
                ord.M_AccountName__c = calls.get(ord.M_Call__c).buzz_retail__Account__c;
            }

            //ORI-029
            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'None'){
                
                ord.M_Distributor__c = activeOPLI.M_Default_DSC_Order_Account__c;
            }
            //ORI-030
            else if(ord.M_Order_Transaction_Type__c == 'Order' && ord.M_Inventory_TransactionType__c == 'Order'){
                
                if (activeOPLI.M_DefaultSSROrderSet__c)
                {                   
                    for (Account account:accounts.values())
                    {
                        if (account.M_Route_Number__c != null && 
                            account.M_Route_Number__c != 0 && 
                           (account.M_Route_Number__c == allUsers.get(ord.OwnerId).M_Order_Inventory_Account__c))
                        {
                            ord.M_Distributor__c = account.Id;
                            break;
                        } 
                    }
                }
            }
            //ORI-031
            else if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'None'){
                
                ord.M_Distributor__c = activeOPLI.M_Default_DSC_Return_Account__c;
            }
            //ORI-032
            else if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'Return'){
                
                if (activeOPLI.M_DefaultSSROrderSet__c)
                {
                    for (Account account:accounts.values())
                    {
                        if (account.M_Route_Number__c != null && account.M_Route_Number__c != 0 && (account.M_Route_Number__c == allUsers.get(ord.OwnerId).M_Order_Inventory_Account__c))
                        {
                            ord.M_Distributor__c = account.Id;
                            break;
                        } 
                    }
                }
            }
                
            //ORI-027
            if (accounts != null && accounts.size() > 0 && ord.M_Distributor__c != null && accounts.containsKey(ord.M_Distributor__c))
                ord.M_DC_Name_Stamp__c = accounts.get(ord.M_Distributor__c).Name;
  
            if (accounts != null && accounts.size() > 0 && accounts.containsKey(ord.M_AccountName__c))
                accountHandle = accounts.get(ord.M_AccountName__c);
    
            if (accountHandle != null)           
            {
                //ORI-025               
                ord.M_Kam_Territory_Stamp__c  = accountHandle.buzz_retail__KAM_Territory_ID__c;
                //ORI-024
                ord.M_Territory_Stamp__c = accountHandle.buzz_retail__Territory__c;
                
                //ORI-026
                ord.M_Account_ID_Stamp__c = accountHandle.buzz_retail__Account_ID__c;
                
                string accntStamp = accountHandle.Name + ' ' + ord.M_Account_ID_Stamp__c + ' ' + ord.M_DC_Name_Stamp__c;
                //ORI-028 
                if(accntStamp.length() < 255)   
                    ord.M_Account_Name_Stamp__c = accntStamp;
                else
                    ord.M_Account_Name_Stamp__c = accntStamp.substring(0, 252) + '...';
            }

            if (ord.Inventory_Location__c != null)
            {
                invlocHandle = invlocations.get(ord.Inventory_Location__c);
                if (invlocHandle != null)
                    ord.M_Account_ID_Stamp__c = Util.IsNull(invlocHandle.M_Inventory_Location_ID__c, '');
                else
                    ord.M_Account_ID_Stamp__c = '';
            }
 
             //ORD-050
            if (accounts != null && accounts.size() > 0 && ord.M_AccountName__c != null && accounts.containsKey(ord.M_AccountName__c) )
            {
                if (accounts.get(ord.M_AccountName__c).buzz_retail__Account_Record_Type_Display__c == 'Distribution Center with Inventory' && ord.M_Order_Transaction_Type__c == 'Order')
                    ord.M_Order_Suffix__c = 'VR';                   
                else if (accounts.get(ord.M_AccountName__c).buzz_retail__Account_Record_Type_Display__c == 'Outlet' && 
                    ord.M_Order_Transaction_Type__c == 'Order' && ord.M_Inventory_TransactionType__c == 'None' )
                    ord.M_Order_Suffix__c = 'VM';
                else if (accounts.get(ord.M_AccountName__c).buzz_retail__Account_Record_Type_Display__c == 'Outlet' && 
                    ord.M_Order_Transaction_Type__c == 'Order' && ord.M_Inventory_TransactionType__c == 'Order' )
                    ord.M_Order_Suffix__c = 'BO';
                else if (accounts.get(ord.M_AccountName__c).buzz_retail__Account_Record_Type_Display__c == 'Outlet' && 
                    ord.M_Order_Transaction_Type__c == 'Return' && ord.M_Inventory_TransactionType__c == 'Return' )
                    ord.M_Order_Suffix__c = 'RT';
                else if (accounts.get(ord.M_AccountName__c).buzz_retail__Account_Record_Type_Display__c == 'Outlet' && 
                    ord.M_Order_Transaction_Type__c == 'Return' && ord.M_Inventory_TransactionType__c == 'None' )
                    ord.M_Order_Suffix__c = 'RB';
                else            
                    ord.M_Order_Suffix__c  = '';
            }                       
            if ((!ord.M_Is_Mobile__c && trigger.isInsert)||(!ord.M_Is_Mobile__c && trigger.isUpdate && ord.M_Receipt_Number__c== null && ord.M_CheckSoldTo__c==true)){//
                //RN-001 Produce order Receipt No. on creation only
                    ordersMobile.add(ord);
            }
        }//for loop
        
        //Check if Distributor (Warehouse) have a valid Inventory Location (Disbursement =true)
        Set<Id> Distributors = new set<Id>();
        for (M_Order_sigcap_Header__c ord: allOrders)
            Distributors.add(ord.M_Distributor__c);
        
        Map<Id,M_Inventory_Location__c> MapDistInveLocation = new Map<Id,M_Inventory_Location__c>();
        for (M_Inventory_Location__c il:[select id,M_Distributor__c from M_Inventory_Location__c where Default_Disbursement_Location__c=true and M_Distributor__c in:Distributors])
            MapDistInveLocation.put(il.M_Distributor__c,il);
        
        
        for (M_Order_sigcap_Header__c ord: allOrders){
            if (ord.M_Is_Mobile__c!=true&&ord.M_Distributor__c!=null&&
                (ord.M_Inventory_TransactionType__c=='Order'||ord.M_Inventory_TransactionType__c=='Return')
                 &&!MapDistInveLocation.containsKey(ord.M_Distributor__c))
                ord.addError('Warehouse does not have a valid disbursement inventory location');
        }  
       
        
        //this method is called after the Ord.RouteNumber,Ord.M_Order_Suffix__c are set
        if(ordersMobile.size()>0){ 
             OrderRecord.createReceiptNumber(ordersMobile);
        }
    }
    
    if(trigger.isAfter && !OrderRecord.preventUpateTrigger &&(trigger.isInsert||trigger.isUpdate))
    {
        
        //ORI-0341 - delete 0 qty items when orders are finalized--------------------------------------------
        list<M_Order_sigcap_Header__c> allOrders= trigger.new;
        set<Id> orderIds = new set<id>();
        set<Id> cancelledOrdRetIds = new set<id>();
        list<M_Order_sigcap_Header__c> updatedOrders = new list<M_Order_sigcap_Header__c>();
        list<M_Order_sigcap_Header__c> autoOrderDetails = new list<M_Order_sigcap_Header__c>();
        list<M_Order_sigcap_Header__c> readOnlyOrders = new list<M_Order_sigcap_Header__c>();
        if(trigger.isInsert)
        {
            for (M_Order_sigcap_Header__c ord: allOrders)
            {
                //ORI-035 Automated Order Details Creation on Automated List
                if(!ord.M_Is_Mobile__c )
                {
                    if(activeOPLI.M_Automated_Order_Details__c)
                    autoOrderDetails.add(ord);
                }
            }
            
            if(autoOrderDetails.size()>0){
                OrderRecord.AutomatedOrderDetailsCreation(autoOrderDetails);
            }
        }
        
        //ORI-013   READ ONLY FLAG CALCULATION (Read Only) done in a separate method since stopping of trigger has to be done using static variable
        //done after setting the final flag  that' is why it is done in after trigger
        if(!OrderRecord.preventUpateTrigger)
        {
            system.debug('setReadOnlyFlags'+!OrderRecord.preventUpateTrigger);
            OrderRecord.setReadOnlyFlags(allOrders);
        }
        
        for (M_Order_sigcap_Header__c ord: allOrders)
        {
            //ORI-0341 - delete 0 qty items when orders are finalized-
            if(ord.M_FinalOrder__c == true )
                orderIds.add(ord.id);
            
            //ORI-0343 Cancelled Status
            if(ord.M_CancelledOrder__c && !ord.M_Is_Mobile__c){
                cancelledOrdRetIds.add(ord.id);
            }
                
            //ORI-012 Status (Validation)
            M_Order_sigcap_Header__c oldOrder = (trigger.oldmap == null) ? null: trigger.oldmap.get(ord.id);
            system.debug('ROOrder'+OrderRecord.preventUpateTrigger+ord.M_Read_Only__c);
            if(ord.M_Read_Only__c) { 
                //orderROIds.add(ord.id);
                system.debug('ROOrder'+readOnlyOrders);
                // M015 - JLEDEZMA START: ADDING THE FIELDS M_Document_Description__c, M_First_Print__c, M_Receipt_Print_Date_c__c, M_Receipt_Print_Time__c,  M_Receipt_Copies__c TO THE EXCEPTIONS.
                //if((oldOrder.M_Status__c != ord.M_Status__c && ord.M_Status__c != null)  || (oldOrder.M_Inventory_Submitted__c != ord.M_Inventory_Submitted__c) || (oldOrder.M_Read_Only__c != ord.M_Read_Only__c) || (oldOrder.M_ERP_Order_No__c != ord.M_ERP_Order_No__c)){
                if((oldOrder.M_Status__c != ord.M_Status__c && ord.M_Status__c != null)  || (oldOrder.M_Inventory_Submitted__c != ord.M_Inventory_Submitted__c) || (oldOrder.M_Read_Only__c != ord.M_Read_Only__c) || (oldOrder.M_ERP_Order_No__c != ord.M_ERP_Order_No__c) || (oldOrder.M_Receipt_Print_Date_c__c != ord.M_Receipt_Print_Date_c__c) || (oldOrder.M_Receipt_Print_Time__c != ord.M_Receipt_Print_Time__c) || (oldOrder.M_Receipt_Copies__c != ord.M_Receipt_Copies__c) || (oldOrder.M_Document_Description__c != ord.M_Document_Description__c) || (oldOrder.M_First_Print__c != ord.M_First_Print__c)){
                // M015 - JLEDEZMA END.
                    readOnlyOrders.add(ord);
                }
                else{
                    system.debug('error should not modify order');
                    ord.addError(system.label.ReadonlyOrder);
                }
            }
                
        }
        
        //ORI-0343 - set OrderDetail.Qty Ordered = 0
        List<M_Order_Detail__c> ODToUpdate = new List<M_Order_Detail__c>([select id,M_Qty_Ordered__c from M_Order_Detail__c where M_Order__c IN : cancelledOrdRetIds]);
        List<M_Order_Detail__c> ODToUpdate1 = new List<M_Order_Detail__c>();
        for(M_Order_Detail__c od : ODToUpdate){
            od.M_Qty_Ordered__c = 0;
            ODToUpdate1.add(od);
        }
        if (ODToUpdate1.size()>0){
            update ODToUpdate1;
        }
                        
        //ORI-0341 - delete 0 qty items when orders are finalized-
        List<M_Order_Detail__c> DetailsTODelete = new List<M_Order_Detail__c>([select id,M_Qty_Ordered__c from M_Order_Detail__c where (M_Qty_Ordered__c=null OR M_Qty_Ordered__c=0) AND M_Order__c in: orderIds]);
        if (DetailsTODelete.size()>0)
            delete(DetailsTODelete);
            
            
        //ORI-012 Status (Validation)
        if(readOnlyOrders.size()>0 && trigger.oldmap.size()>0){
            system.debug('readOnlyOrders'+readOnlyOrders);
            OrderRecord.saveOrderInReadOnly(readOnlyOrders,trigger.oldmap);
        }                 
                    
    }
    
    if (trigger.isAfter && (trigger.isInsert||trigger.isUpdate)) {
        //ITRL-0032 PROCESS ORDER AND RETURNS WHEN INVENTORY SUBMITTED = TRUE--------------------------------
        InventoryTransactionRecord.ProcessSubmittedOrdersAndReturns(trigger.new);
    }
    
    //LN  -- Item 684 cloning details
    Decimal dItemPrice ;
    String  dItemPriceId ;
    string sOwnerId;
    Map<String,M_Inventory__c> inventoryMap = new Map<String,M_Inventory__c>();
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        list<M_Order_sigcap_Header__c> allOrders= trigger.new;
        list<M_Order_sigcap_Header__c> allClonedOrders= new list<M_Order_sigcap_Header__c>();
        
        set<Id> ClonedOrderIds = new set<id>();
        for (M_Order_sigcap_Header__c ord: allOrders){
        If (ord.M_Order__c != null &&  !ord.M_Is_Mobile__c  && !ord.M_detailIsCloned__c)
            
            {   sOwnerId = ord.OwnerId;
                ClonedOrderIds.add(ord.M_Order__c);
                allClonedOrders.add(ord);
            }
        }       
                
        Map<Id,List<M_Order_Detail__c>> AllDetailsToCloneMap = new Map<Id,List<M_Order_Detail__c>>();
        for (M_Order_Detail__c OrdDet:[select M_Order__c,M_Product_Name__c,M_Product_Format__c,M_Qty_Ordered__c ,
                                       M_Item_Price__c ,M_Item_Price_ID__c,M_Inventory__c ,M_detailIsCloned__c,M_Product_Format_Code__c
                                       from M_Order_Detail__c 
                                       where M_Order__c in: ClonedOrderIds])
                                       
        {   
            List<M_Order_Detail__c> TempOrdDetList = new List<M_Order_Detail__c>();
            if (AllDetailsToCloneMap.containsKey(OrdDet.M_Order__c))
                TempOrdDetList = AllDetailsToCloneMap.get(OrdDet.M_Order__c);
            TempOrdDetList.add(OrdDet);
            AllDetailsToCloneMap.put(OrdDet.M_Order__c,TempOrdDetList);
        }   
           
        //Link to Inventory
        if (AllDetailsToCloneMap.size()>0)
        {
            //if order.owner.M_Order_Inventory_Account__c = Account. Route Number  
            User user =  [select M_Order_Inventory_Account__c from User where id =:sOwnerId limit 1];   
            Decimal userInvAcc = (user==null)? 0 :user.M_Order_Inventory_Account__c;
            List<Account> DCwithInv = [select Id from Account where M_Route_Number__c =:userInvAcc limit 1];
            Id accRouteNumEqualsUserInvAcct;
            if(DCwithInv == null ||DCwithInv.size()==0 )
                accRouteNumEqualsUserInvAcct = null;
            else 
                accRouteNumEqualsUserInvAcct = DCwithInv[0].id;
            //Map<String,M_Inventory__c> inventoryMap = new Map<String,M_Inventory__c>();
            
            for(M_Inventory__c i : [select id, M_ProductProductFormat__c, M_Inventory_Location__r.Default_Disbursement_Location__c, M_Distributor__c from M_Inventory__c where M_Inventory_Location__r.Default_Disbursement_Location__c = true and M_Distributor__c =: accRouteNumEqualsUserInvAcct]){
                inventoryMap.put(i.M_ProductProductFormat__c,i);
            }
            
        }//Link to Inventory
        
        system.debug('trigger.isInsert:' + trigger.isInsert); 
        system.debug('trigger.isInsert:' + trigger.isupdate);
       
        List<M_Order_sigcap_Header__c>OrderToupdate = new List<M_Order_sigcap_Header__c>();
        for (M_Order_sigcap_Header__c ord: allOrders)
        {
            If (ord.M_Order__c != null &&  !ord.M_Is_Mobile__c  && !ord.M_detailIsCloned__c)
            {
            
                if (AllDetailsToCloneMap.containsKey(ord.M_Order__c))
                {
                    //Get the Price List items for that Order
                    List<M_Item_Price__c> PriceListItem = OrderDetailsManageCon.loadItemPrices(ord.Id);
                    List<M_Order_Detail__c> TempOrdDetList2 = new List<M_Order_Detail__c>();
                  
                    TempOrdDetList2 = AllDetailsToCloneMap.get(ord.M_Order__c);
                                   
                    List<M_Order_Detail__c> OrdDetToInsert  = new list<M_Order_Detail__c>();
                    for  (M_Order_Detail__c OrdDt: TempOrdDetList2)
                    {  
                        dItemPrice=0;
                        dItemPriceId =null; 
                            //Get the Price
                        for(M_Item_Price__c PI: PriceListItem) 
                        {
                                
                            if( (OrdDt.M_Product_Name__c ==PI.M_Item__c) && (OrdDt.M_Product_Format__c==PI.M_Product_Format__c))
                            { 
                               if (ord.M_Order_Transaction_Type__c== 'Order')
                                   dItemPrice =PI.M_Selling_Price__c ;
                               else
                                   if (ord.M_Order_Transaction_Type__c== 'Return')
                                       dItemPrice =PI.M_Return_Price__c ;
                                
                                dItemPriceId = PI.Id;
                            }
                        }
                       
                        String prodProductFormat = ((String)OrdDt.M_Product_Name__c).substring(0,15) + ((String)OrdDt.M_Product_Format__c).substring(0,15);//field concatenated since formula concatenates only id of length 15
                        string sInventory = (inventoryMap.get(prodProductFormat) == null) ? null: (inventoryMap.get(prodProductFormat)).id;
                        if ((dItemPrice != null)&& (dItemPrice != 0))
                        {   
                            M_Order_Detail__c   newOrderdetail = new M_Order_Detail__c(
                            M_Order__c = ord.Id,
                            M_Product_Name__c =OrdDt.M_Product_Name__c,
                            M_Product_Format__c=OrdDt.M_Product_Format__c,
                            M_Qty_Ordered__c=OrdDt.M_Qty_Ordered__c,
                            M_Item_Price__c =dItemPrice,
                        //  M_Item_Price_ID__c =dItemPriceId,
                            M_Inventory__c = sInventory,
                            M_Product_Format_Code__c =OrdDt.M_Product_Format_Code__c,
                            M_detailIsCloned__c = true);
                            OrdDetToInsert.add(newOrderdetail); 
                        }    
                        
                     }
                    
                     if (OrdDetToInsert.size()>0)                                                                                
                         insert OrdDetToInsert;
                    
                }    
            }
        } 
    }
     
}