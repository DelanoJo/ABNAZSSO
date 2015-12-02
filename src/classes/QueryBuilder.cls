public with sharing class QueryBuilder {
    
    private static final String DG_ROLE_AND_SUBORDINATES = 'Portal Role And Subordinates';
        
    private static final String ROLE_AND_SUBORDINATES = 'RoleAndSubordinates';
        
    private static final String DG_PORTAL_ROLE = 'Portal Role';
        
    private static final String ROLE = 'Role';
        
    public static final String DG_PARTNER_PORTAL = 'Partner Portal';
        
    private static final String PARTNER_PORTAL = 'Partner';
        
    public static final String DG_CUSTOMER_PORTAL = 'Customer Portal';
    
    private static final String CUSTOMER_PORTAL = 'CustomerPortal';
    
    private static final String DG_USER = 'User';
    
    private static final String WORKER = 'Worker';
    

    private Permission_Set_Assignment_Rules__c dg;
    private Meta mdata;
//  private static final String PARTNER_USER = 'isPartner = true And ';

    public QueryBuilder(Permission_Set_Assignment_Rules__c dg) {
        this.dg = dg;
        this.mdata = new Meta('Contact');
        System.debug('mdata = ' + mdata);
    }
    
    /*public String getUserRoleQuery(final String[] accountList) {
        //Rohit - 01192010
        //String query = 'SELECT u.PortalType, u.PortalAccountId, u.Name, u.PortalRole, u.Id FROM UserRole u WHERE ';
        String query = 'SELECT u.PortalType, u.PortalAccountId, u.Name, u.Id FROM UserRole u WHERE ';
        
        String nameCondition = '';
        String[] levels = dg.Role_Level__c.split(';');
        for(String level : levels) {
            if(level.trim().equals('')) {
                continue;
            }
            if(nameCondition.length() > 0) {
                nameCondition += ' OR ';
            }
            //Rohit - 01192010
            //nameCondition += 'PortalRole = \'' + convertDGFieldValue(level) + '\'';
            nameCondition += 'Name like \'%' + convertDGFieldValue(level) + '\'';
        }
        nameCondition = '(' + nameCondition + ')';
        query += nameCondition;
        query += ' AND ';
        
        String portalCondition = '';
        String[] portalTypes = dg.Apply_To_Portal__c.split(';');
        for(String pType : portalTypes) {
            if(pType.trim().equals('')) {
                continue;
            }
            if(portalCondition.length() > 0) {
                portalCondition += ' or ';
            }
            portalCondition += 'PortalType=\'' + convertDGFieldValue(pType) + '\'';
        }
        portalCondition = '(' + portalCondition + ')';
        query += portalCondition;
        query += ' AND PortalAccountId IN ';
        
        String accountCondition = '(';
        for(String accountId : accountList) {
            if(accountCondition.length() > 1) {
                accountCondition += ', ';
            }
            accountCondition += '\'' + accountId + '\'';
        }
        accountCondition += ')';
        
        query += accountCondition;
        System.debug('getUserRoleQuery(): query = ' + query);
        return query;
    }*/
    

    public String getQuery() {
        String criteria = '';
        for (String s : getQueryParams()) {
            if (! criteria.equals('')) criteria += ' And ';
            criteria += s;
        }
        String query = 'Select Id, User__c from Contact'; //***Added User__c
        if ( criteria.length() > 0 ) {
            query += ' where '  + criteria;
        }
        System.debug(LOGGINGLevel.Info,'query:'+ query);
        return query;
    }
    
    private Set<String> getQueryParams() {
        Set<String> queryParams = new Set<String>();
        
        for (Group_Rule__c rule : [Select Record_Field__c, Operator__c, Value__c from Group_Rule__c where Assignment_Rule__c = :dg.Id]) {
            String queryParam = '';
            Operators.Logical operator = Operators.getInstance(rule.Operator__c);
            System.debug('getQueryParams().rule = ' + rule);
            try {
                Schema.DescribeFieldResult f = mdata.getFieldDescribe(rule.Record_Field__c);
            
                if (rule.Value__c == null) {
                    if (rule.Operator__c == Operators.CNTN){
                        queryParam = rule.Record_Field__c + ' ' + operator.getSymbol() + '(\' \')';
                    } else {
                        queryParam = rule.Record_Field__c + ' ' + operator.getSymbol() + '\' \'';
                    }
                } else {
                    String value = '';
                    if (f.getType() == DisplayType.Boolean) {
                        value = escape(rule.Value__c);
                    } else if (f.getType() == DisplayType.Double || f.getType() == DisplayType.Currency || f.getType() == DisplayType.Integer) {
                        value = escape(rule.Value__c);
                    } else if (f.getType() == DisplayType.Date || f.getType() == DisplayType.DateTime) {
                        value = escape(rule.Value__c);
                    } else if (f.getType() == DisplayType.MultiPicklist) {
                        for (String s : rule.Value__c.split(',')) {
                            if (! value.equals('')) value += ', ';
                            value += ('\'' + escape(s.trim()) + '\'');
                        }
                        value = '(' + value + ')';
                    } 
                     
                    else {
                        System.debug('getQueryParams().In Else value = ' + value);
                        /*if (rule.Value__c.startsWith('"') && rule.Value__c.endsWith('"') && rule.Value__c.length() > 1) {
                            value = rule.Value__c.substring(1, rule.Value__c.length()-1);
                        } else {
                            value = rule.Value__c;
                        }*/
                        for (String s : rule.Value__c.split(',')) {
                            if (! value.equals('')) value += ', ';
                            value += ('\'' + escape(s.trim()) + '\'');
                        }
                        value = '(' + value + ')';
                        //value = ' \'' + escape(value) + '\'';


                        System.debug('getQueryParams().Out ELse value = ' + value);
                    }
                    queryParam = rule.Record_Field__c + ' ' + operator.getSymbol() + ' ' + value;
                    System.debug('queryParam = ' + queryParam);
                }
            
                queryParams.add(queryParam);
                //add the isPartner or isCustomer
                /*if (dg.Apply_To_Portal__c.equalsIgnoreCase('Partner Portal')) {
                    queryParams.add('isPartner = TRUE');
                } else {
                    queryParams.add('isCustomerPortal = TRUE');
                }*/
                System.debug('QueryParms: ' + queryParams);
            } catch(System.NullPointerException e){
                break;
            }                   
        }
        return queryParams;
    }
    
    private static String escape(final String str) {
        return String.escapeSingleQuotes(str);
    }
    
    public static String convertDGFieldValue(final String value) {
        if(value.equals(DG_ROLE_AND_SUBORDINATES)) {
            return ROLE_AND_SUBORDINATES;
        }
        if(value.equals(DG_PORTAL_ROLE)) {
            return ROLE;
        }
        if(value.equals(DG_PARTNER_PORTAL)) {
            return PARTNER_PORTAL;
        }
        if(value.equals(DG_CUSTOMER_PORTAL)) {
            return CUSTOMER_PORTAL;
        }
       /* if(value.equals(DG_USER)) {
            return WORKER;
        }*/
        return value;
    }
    
    public class Meta {
        String objectName;
        Map<String, Schema.SObjectField> fields;
        
        public Meta(String name) {
            this.objectName = name;
            Schema.SObjectType ot = Schema.getGlobalDescribe().get(objectName);
            fields = ot.getDescribe().fields.getMap();
        }
        
        public Schema.DescribeFieldResult getFieldDescribe(String recordField) {
            return fields.get(recordField).getDescribe() ;
        }
    }
}