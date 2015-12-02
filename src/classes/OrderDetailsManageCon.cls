public with sharing class OrderDetailsManageCon {

    private ApexPages.StandardController con;
    public String selectedPriceItemIdString {get; set;}
    M_Order_sigcap_Header__c orderItem; 
    M_OPLI_Settings__c activeOPLI = OPLIRecord.getActiveOPLISetting();
        
    public OrderDetailsManageCon(ApexPages.StandardController controller) {
        con = controller;
        orderItem =[SELECT id, Name,M_Order_Transaction_Type__c,M_Inventory_TransactionType__c,M_Status__c, M_Is_Mobile__c, OwnerId, M_Read_Only__c,
                           M_Record_Type__c 
                                        FROM M_Order_sigcap_Header__c 
                                        WHERE id =:con.getId()];
    }

    public String nameSpace {
        get {
            if(nameSpace == null) {
                nameSpace = Util.getBuzzNamespace();
            }
            return nameSpace;
        }
        private set;
    }
    
    public boolean IsOrder{
        get {
                if (orderItem.M_Order_Transaction_Type__c=='Order')
                    return true;
                else
                    return false; 
            }
        private set;
    } 
    public boolean IsReturn{
        get {
                if (orderItem.M_Order_Transaction_Type__c=='Return')
                    return true;
                else
                    return false; 
            }
        private set;
    } 
    
    public String buttonName{
        get{
            if(IsOrder)
                return system.label.AddOrderDetails;
            else 
                return system.label.AddReturnDetails;
        }
        private set;
    } 
    
    public Boolean orderIsReadOnly{
        get{
            //ORI-013   READ ONLY FLAG CALCULATION (Read Only)
            if(orderItem.M_Order_Transaction_Type__c == 'Order'  && orderItem.M_Inventory_TransactionType__c == 'None' &&  orderItem.M_Status__c == activeOPLI.Read_Only_Status_for_Orders_No_Invento__c){
                system.debug('check 2');
                return true;
            }
            
            if(orderItem.M_Order_Transaction_Type__c == 'Order'  && orderItem.M_Inventory_TransactionType__c == 'Order' &&  orderItem.M_Status__c == activeOPLI.Read_Only_Status_for_Orders_w_Inventory__c){
                system.debug('check 3');
                return true;
            }
            
            if(orderItem.M_Order_Transaction_Type__c == 'Return'  && orderItem.M_Inventory_TransactionType__c == 'Return' &&  orderItem.M_Status__c == activeOPLI.M_Read_Only_Status_for_Returns_w_Invent__c){
                system.debug('check4');
                return true;
            }
            
            if(orderItem.M_Order_Transaction_Type__c == 'Return'  && orderItem.M_Inventory_TransactionType__c == 'None' &&  orderItem.M_Status__c == activeOPLI.M_Read_Only_Status_for_Returns_No_Invent__c){
                system.debug('check 5');
                return true;
            }
            if(orderItem.M_Read_Only__c){
                system.debug('check 1');
                return true;
            }
            system.debug('check end');
            return false;
        }
        private set;
    }
    
    @RemoteAction
    public static List<M_Item_Price__c> loadItemPrices(id orderId) {
        
        // get the current order fields for the filters and finding the proper Account for Price List
        M_Order_sigcap_Header__c orderRecord = [SELECT Id, M_AccountName__c,
                                                                M_Order_Transaction_Type__c, 
                                                                M_Inventory_TransactionType__c 
                                                                FROM M_Order_sigcap_Header__c
                                                                WHERE id =: orderId Limit 1];

        system.debug('Mani orderRecord: ' + orderRecord);
        
//*****************************************************************************************
        M_Price_List__c PriceListOfOrder = PriceListRecord.getPriceListForOrder(orderId);
        //system.debug('LB PriceListOfOrder: ' + PriceListOfOrder);

/***********************************************************************************************/
        if(PriceListOfOrder == null){
             system.debug('PriceListOfOrder == null: ');
            return new List<M_Item_Price__c>();
            
        }else{
            //M_Merck_Product_Code__c ,
            
            // add required fields to the map
            Map<String, String> fieldsMap = new Map<String, String>();
            fieldsMap.put('UPC_Code__c', null);
            fieldsMap.put('M_Available_for_Central_Orders__c', null);
            fieldsMap.put('M_Return_Price__c', null);
            fieldsMap.put('M_Product_Format__c', null);
            fieldsMap.put('M_Price_List__c', null);
            fieldsMap.put('M_Item__c', null);
            fieldsMap.put('M_Allow_Inventory__c', null);
            fieldsMap.put('M_Active_for_Returns__c', null);
            fieldsMap.put('M_Active_for_Order__c', null);
            fieldsMap.put('Automated_Order_Item__c', null);
            fieldsMap.put('M_Promotion_Product__c', null);
            fieldsMap.put('M_Returning_From_c__c', null);
            fieldsMap.put('M_Returning_Until__c', null);
            fieldsMap.put('M_Selling_From__c', null);
            fieldsMap.put('M_Selling_Price__c', null);
            fieldsMap.put('M_Selling_Until__c', null);
            
            // add fields from fieldset to make it a complete list of fields to query
            for (FieldSetMember fs : Schema.SObjectType.M_Item_Price__c.fieldSets.getMap().get('ItemPrice').getFields()) {
                fieldsMap.put(fs.getFieldPath(), null);
            }
            
            String sQuery = 'Select ' 
                            + Util.buildDelimitedString(fieldsMap.keyset(), ',')
                            + ' From M_Item_Price__c  WHERE M_Price_List__c = ' + '\'' + PriceListOfOrder.Id + '\'';
            
            /*
            String sQuery = 'Select UPC_Code__c,M_Available_for_Central_Orders__c, M_Return_Price__c, M_Product_Format__c, M_Price_List__c, M_Item__c, M_Allow_Inventory__c, M_Active_for_Returns__c, M_Active_for_Order__c,  Automated_Order_Item__c, M_Promotion_Product__c, M_Returning_From_c__c, M_Returning_Until__c, M_Selling_From__c, M_Selling_Price__c, M_Selling_Until__c '+
                                ' From M_Item_Price__c  WHERE M_Price_List__c = '+ '\'' +PriceListOfOrder.Id+'\'';
            */
            if(orderRecord.M_Order_Transaction_Type__c == 'Order')
            {
                sQuery += ' AND M_Active_for_Order__c = TRUE ';
                
                if(orderRecord.M_Inventory_TransactionType__c == 'Order')
                {
                    sQuery += ' AND M_Allow_Inventory__c = TRUE ';          
                }
                else if (orderRecord.M_Inventory_TransactionType__c=='None') {
                    sQuery += ' AND M_Available_for_Central_Orders__c=True ';
                }
            }
    
            if(orderRecord.M_Order_Transaction_Type__c == 'Return')
            {
                sQuery += ' AND M_Active_for_Returns__c = TRUE ';
                if(orderRecord.M_Inventory_TransactionType__c == 'Return')
                {
                    sQuery += ' AND M_Allow_Inventory__c = TRUE ';
                }
            }
            
            String prodFormatIdsString = '';
            
            List<M_Order_Detail__c> existingOrderDetails = new List<M_Order_Detail__c>([select M_ProductProductFormat__c from M_Order_Detail__c where M_Order__c =: orderId]);
            system.debug('existingOrderDetails: ' + existingOrderDetails);
            
            //populate a string of product format ids in a format to be use in query string 
            for(M_Order_Detail__c od : existingOrderDetails){
                prodFormatIdsString += '\''+od.M_ProductProductFormat__c +'\''+',';
                system.debug('populate prodFormatIdsString: ' + prodFormatIdsString);
            }
            
            if(prodFormatIdsString.endsWith(',')){
                    prodFormatIdsString = prodFormatIdsString.substring(0,prodFormatIdsString.length()-1);
                    system.debug('remove last comma prodFormatIdsString: ' + prodFormatIdsString);
                }
                prodFormatIdsString = '('+prodFormatIdsString+')';
            
            if((prodFormatIdsString != '' || prodFormatIdsString != null) && existingOrderDetails.size()>0){
                sQuery += ' AND M_ProductProductFormat__c NOT IN '+prodFormatIdsString;
            }
    
            //sQuery += ' Limit 1000 '; should we limit the query???
    
            system.debug('Final sQuery: ' + sQuery);
    
            List<M_Item_Price__c> itemPrices = Database.query(sQuery);
            system.debug('items Prices'+itemPrices);
            return itemPrices;  
            }
    }
        


    public void addOrderItems() {
        
        List<Id> selectedItemPriceIds = ListFromIdString(selectedPriceItemIdString);

        system.debug('Mani selectedPriceItemIdString: ' + selectedPriceItemIdString);
        system.debug('Mani selectedItemPriceIds: ' + selectedItemPriceIds);

        //M_Merck_Product_Code__c,
        Map<Id,M_Item_Price__c> itemPricesMap = new Map<Id,M_Item_Price__c>([SELECT  Id, UPC_Code__c, 
                                            M_Selling_Until__c, M_Selling_Price__c, M_Selling_From__c, 
                                            M_Returning_Until__c, M_Returning_From_c__c, M_Return_Price__c, 
                                            M_Promotion_Product__c, M_Product_Format__c, M_Price_List__c, 
                                             M_Item__c, M_Allow_Inventory__c, 
                                            M_Active_for_Returns__c, M_Active_for_Order__c, M_ProductProductFormat__c, 
                                            Automated_Order_Item__c,M_Product_Format__r.buzz_retail__FormatCode__c
                                            
                                                FROM M_Item_Price__c
                                                WHERE Id IN: selectedItemPriceIds]);
                                                
        system.debug('Mani itemPricesMap: ' + itemPricesMap);
        
        //Link to Inventory Record if any
        //if order.owner.M_Order_Inventory_Account__c = Account. Route Number  
        User user =  [select M_Order_Inventory_Account__c from User where id =:orderItem.OwnerId limit 1];  
        Decimal userInvAcc = (user==null)? 0 :user.M_Order_Inventory_Account__c;
        system.debug('## userInvAcc: ' + userInvAcc);
        List<Account> DCwithInv = [select Id from Account where M_Route_Number__c =:userInvAcc limit 1];
        Id accRouteNumEqualsUserInvAcct;
        if(DCwithInv == null ||DCwithInv.size()==0 )
            accRouteNumEqualsUserInvAcct = null;
        else 
            accRouteNumEqualsUserInvAcct = DCwithInv[0].id;
        system.debug('## DCwithInv: ' + DCwithInv);
        Map<String,M_Inventory__c> inventoryMap = new Map<String,M_Inventory__c>();
        
        for(M_Inventory__c i : [select id, M_ProductProductFormat__c, M_Inventory_Location__r.Default_Disbursement_Location__c, M_Distributor__c from M_Inventory__c where M_Inventory_Location__r.Default_Disbursement_Location__c = true and M_Distributor__c =: accRouteNumEqualsUserInvAcct]){
            inventoryMap.put(i.M_ProductProductFormat__c,i);
        }
        
        system.debug('LB inventoryMap: ' + inventoryMap);
        
        //get the list of picklist values of Reason for Return from Order Detail obj
        List<String> returnReasons = new List<String>();
        Schema.DescribeFieldResult fieldResult = M_Order_Detail__c.M_Reason_for_Return__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
           returnReasons.add(f.getValue());
        }
        
        list <M_Order_Detail__c> OrderDetail2Add = new list<M_Order_Detail__c>();
        M_Order_Detail__c OrderDetailTemp;
        
        // CHANGED BY MM ON 06-15-2013 - Caused bY Support Issue where the order detail could not be added because of the isMobile Flag
        //if(orderItem.M_Order_Transaction_Type__c == 'Order' && !orderItem.M_Is_Mobile__c)
        system.debug('NTT: Order Transaction Type :: ' + orderItem.M_Order_Transaction_Type__c);
        if(orderItem.M_Order_Transaction_Type__c == 'Order')
        {
            for (Id ThisitemPrices : itemPricesMap.keyset())
            {
                OrderDetailTemp = new M_Order_Detail__c();
     
                OrderDetailTemp.M_Order__c = (ID)orderItem.id;
                system.debug('OrderDetailManaheCon.AddOrderDetails Product Id: ' + itemPricesMap.get(ThisitemPrices).M_Item__c);
                OrderDetailTemp.M_Product_Name__c = itemPricesMap.get(ThisitemPrices).M_Item__c;
                OrderDetailTemp.M_Product_Format__c = itemPricesMap.get(ThisitemPrices).M_Product_Format__c;
                OrderDetailTemp.M_Item_Price__c = itemPricesMap.get(ThisitemPrices).M_Selling_Price__c;
                OrderDetailTemp.M_Product_Format_Code__c =itemPricesMap.get(ThisitemPrices).M_Product_Format__r.buzz_retail__FormatCode__c;
                OrderDetailTemp.M_Qty_Ordered__c = 1;
                
                //Custom NTT Code
                system.debug('NTT: Inside Order Details Managed Con :: ' + itemPricesMap.get(ThisitemPrices).Id);
                OrderDetailTemp.M_Item_Price_ID__c = itemPricesMap.get(ThisitemPrices).Id;
                
                
                
                String prodProductFormat = ((String)OrderDetailTemp.M_Product_Name__c).substring(0,15) + ((String)OrderDetailTemp.M_Product_Format__c).substring(0,15);//field concatenated since formula concatenates only id of length 15
                system.debug('inventoryMap.get(OrderDetailTemp.M_ProductProductFormat__c) '+prodProductFormat+inventoryMap.get(prodProductFormat));
                OrderDetailTemp.M_Inventory__c = (inventoryMap.get(prodProductFormat) == null) ? null: (inventoryMap.get(prodProductFormat)).id;
    
                OrderDetail2Add.add(OrderDetailTemp);
            }       
            //insert OrderDetail2Add;
            try{
                system.debug('leela OrderDetail2Add'+OrderDetail2Add);
                insert OrderDetail2Add;
            }
            catch(DmlException ex){
                system.debug('leela OrderDetail2Add'+ex);
                ApexPages.addMessages(ex);
            }
        }
                
        // CHANGED BY MM ON 06-15-2013 - Caused bY Support Issue where the order detail could not be added because of the IsMobile Flag
        //if(orderItem.M_Order_Transaction_Type__c == 'Return' && !orderItem.M_Is_Mobile__c)
        if(orderItem.M_Order_Transaction_Type__c == 'Return')
        {
            for (Id ThisitemPrices : itemPricesMap.keyset())
            {
                for(  String reason : returnReasons){
                    OrderDetailTemp = new M_Order_Detail__c();
     
                    OrderDetailTemp.M_Order__c = (ID)orderItem.id;
                    OrderDetailTemp.M_Product_Name__c = itemPricesMap.get(ThisitemPrices).M_Item__c;
                    OrderDetailTemp.M_Product_Format__c = itemPricesMap.get(ThisitemPrices).M_Product_Format__c;
                    OrderDetailTemp.M_Item_Price__c = itemPricesMap.get(ThisitemPrices).M_Return_Price__c;
                    OrderDetailTemp.M_Product_Format_Code__c =itemPricesMap.get(ThisitemPrices).M_Product_Format__r.buzz_retail__FormatCode__c;
                    OrderDetailTemp.M_Qty_Ordered__c = 0;
                    String prodProductFormat1 = ((String)OrderDetailTemp.M_Product_Name__c).substring(0,15)+ ((String)OrderDetailTemp.M_Product_Format__c).substring(0,15);
                    system.debug('1 inventoryMap.get(OrderDetailTemp.M_ProductProductFormat__c) '+prodProductFormat1+inventoryMap.get(prodProductFormat1));
                    OrderDetailTemp.M_Inventory__c = (inventoryMap.get(prodProductFormat1) == null) ? null: (inventoryMap.get(prodProductFormat1)).id;
                    OrderDetailTemp.M_Reason_for_Return__c = reason;
                    OrderDetail2Add.add(OrderDetailTemp);
                } 
                 
            }  
        
            //insert OrderDetail2Add;
            try{
                system.debug('leela OrderDetail2Add'+OrderDetail2Add);
                insert OrderDetail2Add;
            }
            catch(DmlException ex){
                system.debug('leela OrderDetail2Add'+ex);
                ApexPages.addMessages(ex);
            }
        }
    }

    @RemoteAction
    public static List<M_Order_Detail__c> loadOrderDetails(Id orderId, String transactionType) {//make sure all fields in the fieldset is listed in this query
        // add required fields to the map
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('M_isMobile__c', null);
        fieldsMap.put('M_UPC_Code__c', null);
        fieldsMap.put('M_Transaction_Type__c', null);
        fieldsMap.put('M_Transaction_Item__c', null);
        fieldsMap.put('M_Stock_Qty__c', null);
        fieldsMap.put('M_Status__c', null);
        fieldsMap.put('M_Reason_for_Return__c', null);
        fieldsMap.put('M_Qty_Single_ea_c__c', null);
        fieldsMap.put('M_Qty_Ordered__c', null);
        fieldsMap.put('M_Qty_Cases__c', null);
        fieldsMap.put('M_Product_Name__c', null);
        fieldsMap.put('M_Product_Format__c', null);
        fieldsMap.put('M_Product_Format_Code__c', null);
        fieldsMap.put('M_Line_Item_Discount__c', null);
        fieldsMap.put('M_Item_Price__c', null);
        fieldsMap.put('M_Item_Net_Amount__c', null);
        fieldsMap.put('M_Item_Discount__c', null);
        fieldsMap.put('M_Item_Amount__c', null);
        fieldsMap.put('M_Inventory__c', null);
        fieldsMap.put('M_ERP_TRX_Reference__c', null);
        fieldsMap.put('M_CUT_Print__c', null);
        
        // add fields from fieldset to make it a complete list of fields to query
        for (FieldSetMember fs : Schema.SObjectType.M_Order_Detail__c.fieldSets.getMap().get(transactionType == 'Order' ? 'OrderDetail' : 'ReturnDetail').getFields()) {
            fieldsMap.put(fs.getFieldPath(), null);
        }
        
        String sQuery = 'Select ' 
                        + Util.buildDelimitedString(fieldsMap.keySet(), ',') 
                        + ' FROM M_Order_Detail__c WHERE M_Order__c = ' + '\'' + orderId + '\'';
        system.debug('OrderDetailsManageCon.loadOrderDetails(): query=' + sQuery);
        
        return Database.query(sQuery);
        
        //M_Merck_Product_Code__c,
        /*
        return [Select M_isMobile__c, M_UPC_Code__c, M_Transaction_Type__c, M_Transaction_Item__c, M_Stock_Qty__c, M_Status__c, M_Reason_for_Return__c, M_Qty_Single_ea_c__c, M_Qty_Ordered__c, 
                    M_Qty_Cases__c,M_Product_Name__c, M_Product_Format__c, M_Product_Format_Code__c, M_Line_Item_Discount__c, M_Item_Price__c, M_Item_Net_Amount__c, M_Item_Discount__c, 
                    M_Item_Amount__c,M_Inventory__c,    M_ERP_TRX_Reference__c, M_CUT_Print__c
                FROM M_Order_Detail__c
                WHERE M_Order__c =: orderId];
        */
    }


    // Create a string of all the passed IDs
    private static List<Id> ListFromIdString(String idListString)
    {
        system.debug('idListString'+idListString);
        if(idListString == null){
            return null;    
        }
        else{
            if (idListString.trim() == '')
                return new List<Id>();
    
            List<Id> idList = new List<Id>();
    
            for(String s : idListString.split(',')) {
                idList.add((Id)s.trim());
            }
        return idList;
        }
    }


    public PageReference Close(){
        //boolean IsNegInv = IsNegInventory();
        return new PageReference('/' + orderItem.id);
    }

 /*  @RemoteAction
    public  boolean IsNegInventory{
        get {
            if (orderItem.M_Record_Type__c=='DSD from SSR Van')
                {
                system.debug('***********LN True  DSD from SSR Van');       
                List<M_Order_Detail__c> OrderDet = [Select  Id,M_Tentative_Stock_Qty_at_Hand__c from M_Order_Detail__c where M_Order__c =:orderItem.Id and M_Tentative_Stock_Qty_at_Hand__c < 0 ]; 
      
                 if (OrderDet.size()> 0) 
                  {
                   system.debug('***********LN True  DSD from SSR Van' + OrderDet[0].M_Tentative_Stock_Qty_at_Hand__c); 
                   return true;
                  }
                 else
                    return false;
            }
            return false; 
        }
        private set;
}*/

}