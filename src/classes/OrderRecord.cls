public class OrderRecord {
    
    public static boolean preventUpateTrigger = false; //to prevent the recursion of update trigger 
    public static M_OPLI_Settings__c activeOPLI = OPLIRecord.getActiveOPLISetting();    
    
    public static void AutomatedOrderDetailsCreation(List<M_Order_sigcap_Header__c> orders) {
        
        //TriggerControl.FreezeInventoryTrigger=true;
        
        //for any order i should have 1 pricelist at a time?
        Map<Id,M_Price_List__c> orderPriceListMap = new Map<Id,M_Price_List__c>();
        
        Set<Id> priceListIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        
        
        for(M_Order_sigcap_Header__c o : orders){
            system.debug('order inserted'+o);
            M_Price_List__c priceList = PriceListRecord.getPriceListForOrder(o.id);
            system.debug(priceList+'priceList');
            orderPriceListMap.put(o.id,priceList);
            priceListIds.add(priceList.Id);
            ownerIds.add(o.ownerid);
        }
        system.debug('start ' + ownerIds+priceListIds+orderPriceListMap);
        
        List<M_Item_Price__c> itemPricesList = [select id,M_Item__c, M_Product_Format__c, M_Selling_Price__c, M_Product_Format__r.buzz_retail__FormatCode__c, M_Active_for_Order__c, Automated_Order_Item__c, M_Allow_Inventory__c, M_Price_List__c from M_Item_Price__c where M_Price_List__c IN :priceListIds];
        
        Map<Id,List<M_Item_Price__c>> priceListItemPricesMap = new Map<Id,List<M_Item_Price__c>>();
        
        List <M_Order_Detail__c> orderDetails = new List<M_Order_Detail__c>();
        
        
        //Link to Inventory Record if any
        Set<Decimal> inventoryAccounts = new Set<Decimal>();
        for( User user :[select M_Order_Inventory_Account__c from User where id IN :ownerIds]){
            inventoryAccounts.add(user.M_Order_Inventory_Account__c);
        }
            
        system.debug('## userInvAcc: ' + inventoryAccounts);
        
        Set<Id> distributorIds = new Set<Id>();
        for(Account distributorInv : [select Id from Account where M_Route_Number__c =:inventoryAccounts]){
            distributorIds.add(distributorInv.id);
        }
        
        Map<String,M_Inventory__c> inventoryMap = new Map<String,M_Inventory__c>();
        
        for(M_Inventory__c i : [select id, M_ProductProductFormat__c, M_Inventory_Location__r.Default_Disbursement_Location__c, M_Distributor__c from M_Inventory__c where M_Inventory_Location__r.Default_Disbursement_Location__c = true and M_Distributor__c  IN :distributorIds]){
            inventoryMap.put(i.M_ProductProductFormat__c,i);
        }
        
        system.debug('LB inventoryMap: ' + inventoryMap);
        
        for (M_Item_Price__c ip : itemPricesList) {
            List<M_Item_Price__c> currentIPList = priceListItemPricesMap.get(ip.M_Price_List__c);
            if (currentIPList == null) {
                currentIPList = new List<M_Item_Price__c>();
                priceListItemPricesMap.put(ip.M_Price_List__c,currentIPList);
            }
            currentIPList.add(ip);
        }
        
        system.debug('## priceListItemPricesMap: ' + priceListItemPricesMap);
        
        M_Order_Detail__c OrderDetailTemp;
        
        for(M_Order_sigcap_Header__c o : orders){
            system.debug('Current order id '+o);
            if(o.M_Order_Transaction_Type__c == 'Order'  && o.M_Inventory_TransactionType__c == 'None' ){
                system.debug('order criteria met');
                Id orderPR = orderPriceListMap.get(o.id).id;
                system.debug('orderPR '+orderPR);
                if(orderPR != null){
                    List<M_Item_Price__c> itemPrices = priceListItemPricesMap.get(orderPR);
                    system.debug('itemPrices '+itemPrices);
                    if( itemPrices.size()>0){
                        for(M_Item_Price__c ip : itemPrices){
                            
                            if(ip.M_Active_for_Order__c && ip.Automated_Order_Item__c){
                                system.debug('itemPrices '+itemPrices);
                                OrderDetailTemp = new M_Order_Detail__c();
         
                                OrderDetailTemp.M_Order__c = o.id;
                                OrderDetailTemp.M_Product_Name__c = ip.M_Item__c;
                                OrderDetailTemp.M_Product_Format__c = ip.M_Product_Format__c;
                                OrderDetailTemp.M_Item_Price__c = ip.M_Selling_Price__c;
                                OrderDetailTemp.M_Product_Format_Code__c =ip.M_Product_Format__r.buzz_retail__FormatCode__c;
                                OrderDetailTemp.M_Qty_Ordered__c = 1;
                                String prodProductFormat = ((String)OrderDetailTemp.M_Product_Name__c).substring(0,15) + ((String)OrderDetailTemp.M_Product_Format__c).substring(0,15);//field concatenated since formula concatenates only id of length 15
                                system.debug('inventoryMap.get(OrderDetailTemp.M_ProductProductFormat__c) '+prodProductFormat+inventoryMap.get(prodProductFormat));
                                OrderDetailTemp.M_Inventory__c = (inventoryMap.get(prodProductFormat) == null) ? null: (inventoryMap.get(prodProductFormat)).id;
                    
                                orderDetails.add(OrderDetailTemp);
                            }
                        }
                    }
                }
                
                
            }
            
            if(o.M_Order_Transaction_Type__c == 'Order'  && o.M_Inventory_TransactionType__c == 'Order'){
                Id orderPR = orderPriceListMap.get(o.id).id;
                system.debug('orderPR '+orderPR);
                if(orderPR!=null){
                    List<M_Item_Price__c> itemPrices = priceListItemPricesMap.get(orderPR);
                    system.debug('itemPrices '+itemPrices);
                    if(itemPrices.size()>0){
                        for(M_Item_Price__c ip : itemPrices){
                            if(ip.M_Active_for_Order__c && ip.Automated_Order_Item__c && ip.M_Allow_Inventory__c){
                                OrderDetailTemp = new M_Order_Detail__c();
         
                                OrderDetailTemp.M_Order__c = o.id;
                                OrderDetailTemp.M_Product_Name__c = ip.M_Item__c;
                                OrderDetailTemp.M_Product_Format__c = ip.M_Product_Format__c;
                                OrderDetailTemp.M_Item_Price__c = ip.M_Selling_Price__c;
                                OrderDetailTemp.M_Product_Format_Code__c =ip.M_Product_Format__r.buzz_retail__FormatCode__c;
                                OrderDetailTemp.M_Qty_Ordered__c = 1;
                                String prodProductFormat = ((String)OrderDetailTemp.M_Product_Name__c).substring(0,15) + ((String)OrderDetailTemp.M_Product_Format__c).substring(0,15);//field concatenated since formula concatenates only id of length 15
                                system.debug('inventoryMap.get(OrderDetailTemp.M_ProductProductFormat__c) '+prodProductFormat+inventoryMap.get(prodProductFormat));
                                OrderDetailTemp.M_Inventory__c = (inventoryMap.get(prodProductFormat) == null) ? null: (inventoryMap.get(prodProductFormat)).id;
                    
                                orderDetails.add(OrderDetailTemp);
                            }
                        }
                        
                    }
                    
                }
            }
        
        }
        
        if(orderDetails.size()>0){
            insert orderDetails;
            system.debug('orderDetails inserted'+orderDetails);
        }
        
    }
    
    public static void setReadOnlyFlags(List<M_Order_sigcap_Header__c> orders) {
        List<M_Order_sigcap_Header__c> ordersRetrieved = [select M_Order_Transaction_Type__c, M_Inventory_TransactionType__c, M_Status__c, M_Read_Only__c from M_Order_sigcap_Header__c where id in : orders];
        List<M_Order_sigcap_Header__c> ordersToUpdate = new List<M_Order_sigcap_Header__c> ();
        for(M_Order_sigcap_Header__c ord : ordersRetrieved){
            //ORI-013   READ ONLY FLAG CALCULATION (Read Only)
            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'None' &&  ord.M_Status__c == activeOPLI.Read_Only_Status_for_Orders_No_Invento__c){
                ord.M_Read_Only__c = true;
                ordersToUpdate.add(ord);
            }
            
            if(ord.M_Order_Transaction_Type__c == 'Order'  && ord.M_Inventory_TransactionType__c == 'Order' &&  ord.M_Status__c == activeOPLI.Read_Only_Status_for_Orders_w_Inventory__c){
                ord.M_Read_Only__c = true;
                ordersToUpdate.add(ord);
            }
            
            if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'Return' &&  ord.M_Status__c == activeOPLI.M_Read_Only_Status_for_Returns_w_Invent__c){
                ord.M_Read_Only__c = true;
                ordersToUpdate.add(ord);
            }
            
            if(ord.M_Order_Transaction_Type__c == 'Return'  && ord.M_Inventory_TransactionType__c == 'None' &&  ord.M_Status__c == activeOPLI.M_Read_Only_Status_for_Returns_No_Invent__c){
                ord.M_Read_Only__c = true;
                ordersToUpdate.add(ord);
            }
        }
        
        if(ordersToUpdate.size() > 0){
            preventUpateTrigger = true;
            update ordersToUpdate;
        }
    }
    
    public static void saveOrderInReadOnly(List<M_Order_sigcap_Header__c> ROOrder,Map<id,M_Order_sigcap_Header__c> oldOrders) {
        List<M_Order_sigcap_Header__c> ordersRetrieved = [select ID, M_Inventory_Submitted__c, M_Status__c, M_Read_Only__c from M_Order_sigcap_Header__c where id in: ROOrder];
        List<M_Order_sigcap_Header__c> ordersToUpdate = new List<M_Order_sigcap_Header__c> ();
        
        for(M_Order_sigcap_Header__c ord : ordersRetrieved){
            M_Order_sigcap_Header__c oldOrder = oldOrders.get(ord.id);
            //ORI-012 Status (Validation)
            // FYI M_Inventory_Submitted__c is updated in trigger
            String saveStatus = ord.M_Status__c;
            system.debug('can modify order status');
            Boolean inventorySubmitted = ord.M_Inventory_Submitted__c;
            Util.copyFields(oldOrder, ord, false);
            ord.M_Status__c = saveStatus;
            ord.M_Inventory_Submitted__c = inventorySubmitted;
            M_Order_sigcap_Header__c order1 = new M_Order_sigcap_Header__c(id=ord.id,M_Status__c=saveStatus,M_Inventory_Submitted__c=inventorySubmitted);
            ordersToUpdate.add(order1);

        }
            
        if(ordersToUpdate.size() > 0){
            preventUpateTrigger = true;
            update ordersToUpdate;
        }
    }
        
    public static Map<Id,List<M_Order_Detail__c>> BuildOrderDetailMap(List<M_Order_sigcap_Header__c> orders) {
        
        Map<Id,List<M_Order_Detail__c>> MapOrderDetail=new Map<Id,List<M_Order_Detail__c>>();
        
        for (M_Order_Detail__c od: [select Id, M_Order__c,M_Product_Name__c, M_Product_Format__c,M_Qty_Ordered__c
              from M_Order_Detail__c where M_Order__c in :orders]) {
        
            List<M_Order_Detail__c> tmpList = MapOrderDetail.containsKey(od.M_Order__c)?MapOrderDetail.get(od.M_Order__c):new List<M_Order_Detail__c>();
            tmpList.add(od);
            MapOrderDetail.put(od.M_Order__c,tmpList);          
        }
        
        return MapOrderDetail;
    }
    
    public static Map<Id,Id> BuildDistributorLocationMap(List<M_Order_sigcap_Header__c> InitialOrder) {
        
        set<Id> PossibleDistributors = new set<Id>();
        Map<Id,Id> MapDistributorLocation = new Map<Id,Id>();
        
        for (M_Order_sigcap_Header__c ord:InitialOrder)
            PossibleDistributors.add(ord.M_Distributor__c);
        
        for (M_Inventory_Location__c il:[Select Id,M_Distributor__c from M_Inventory_Location__c where M_Distributor__c in:PossibleDistributors and Default_Disbursement_Location__c=true]) 
            MapDistributorLocation.put(il.M_Distributor__c,il.Id);
        
        return MapDistributorLocation;
    }
    
    public static String lPad(String text,Integer length,String paddingCharacter){
        
        String result = text;  
        while (result.length() < length)   
          {  
          result = paddingCharacter + result;  
          }  
        return result;  
    }
    
    public static void createReceiptNumber(List<M_Order_sigcap_Header__c> orders) {
        system.debug('createReceiptNumber');
        
        Set<Id> ownerIds = new Set<Id>();
        Set<Decimal> allAccountRounteNums = new Set<Decimal>();
        List <Account> accWebReceiptIncrement = new List <Account>();
        for(M_Order_sigcap_Header__c o :orders){
            ownerIds.add(o.OwnerId);
        }
        
        map<Id,User> allUsers = new map<Id,User>();
        for(User u : [Select Id, M_Order_Inventory_Account__c, Name from User where id in: ownerIds])
        {
            allUsers.put(u.Id, u);
            if(u.M_Order_Inventory_Account__c != null)
                allAccountRounteNums.add(u.M_Order_Inventory_Account__c);
        }
        
        map<Decimal,Account> accountRouteNums = new map<Decimal,Account>();
        
        for(Account a:[select Id,Name,M_Route_Number__c, M_Next_Receipt_Number_Web__c, M_Web_Receipt_End__c, M_Web_Receipt_Start__c,
                                                        buzz_retail__Account_Record_Type_Display__c from Account WHERE RecordTypeId = :RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory)])
        {
            accountRouteNums.put(a.M_Route_Number__c,a);
        }
                                                        
        for(M_Order_sigcap_Header__c o :orders)
        {
            Decimal userInventory = allUsers.get(o.OwnerId) == null ? null : allUsers.get(o.OwnerId).M_Order_Inventory_Account__c;
            system.debug('userInventory'+userInventory);
            Account accIdentifiedForOrder  = accountRouteNums.get(userInventory) == null ? null : accountRouteNums.get(userInventory) ;
            system.debug('accIdentifiedForOrder'+accIdentifiedForOrder);
            
            if (accIdentifiedForOrder != null)
            {
                system.debug('accIdentifiedForOrder not null '+accIdentifiedForOrder);
                o.M_Document_Number__c = accIdentifiedForOrder.M_Next_Receipt_Number_Web__c;
                system.debug('accIdentifiedForOrder not null '+o.M_Document_Number__c+'accIdentifiedForOrder.M_Next_Receipt_Number_Web__c'+accIdentifiedForOrder.M_Next_Receipt_Number_Web__c);
                
                if(o.M_Route_Number__c != null && o.M_Document_Number__c!= null && o.M_Order_Suffix__c != null)
                {
                    //condition added since if a user does nnot have the proper setup on Distributor with In Acc the code fails 
                    String routeNum = String.valueOf(o.M_Route_Number__c);
                    String documentNum = String.valueOf(o.M_Document_Number__c);
                    String OrderSuffix = String.valueOf(o.M_Order_Suffix__c);
                    // The format of the Receipt Number 000011111XX as a string representations
                    o.M_Receipt_Number__c = lpad(String.valueOf(o.M_Route_Number__c),4,'0')+lpad(String.valueOf(o.M_Document_Number__c),5,'0')+o.M_Order_Suffix__c;
                }
                
                system.debug('o.M_Receipt_Number__c '+o.M_Receipt_Number__c);
                system.debug('accWebReceiptIncrement '+accWebReceiptIncrement);
                
                if(accIdentifiedForOrder.M_Next_Receipt_Number_Web__c != null && accIdentifiedForOrder.M_Web_Receipt_End__c != null && accIdentifiedForOrder.M_Next_Receipt_Number_Web__c != null){//condition added since if a user does not have the proper setup on Distributor with In Acc the code fails
                    
                    if(accIdentifiedForOrder.M_Next_Receipt_Number_Web__c ==  accIdentifiedForOrder.M_Web_Receipt_End__c){
                        system.debug('M_Next_Receipt_Number_Web__c equals M_Web_Receipt_End__c'+accIdentifiedForOrder.M_Next_Receipt_Number_Web__c);
                        accIdentifiedForOrder.M_Next_Receipt_Number_Web__c = accIdentifiedForOrder.M_Web_Receipt_Start__c;
                    }
                    else{
                        system.debug('increment M_Next_Receipt_Number_Web__c');
                        accIdentifiedForOrder.M_Next_Receipt_Number_Web__c += 1;
                    }
                    accWebReceiptIncrement.add(accIdentifiedForOrder);
                }
                
            }
            
            if(accWebReceiptIncrement.size()>0){
                update accWebReceiptIncrement;
                system.debug(' update acc '+accWebReceiptIncrement);
            }
            
        }
        
    }

}