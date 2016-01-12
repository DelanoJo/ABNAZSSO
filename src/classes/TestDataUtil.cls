/***
-Author: Delano (Perficient)
***/
@isTest
public with sharing class  TestDataUtil {
    
    
    //create Users
    public static List<User> createUsers(Integer numToInsert,Boolean doInsert,Map<String, Object> nameValue) {
        List<User> users = new List<User>();
        for( Integer i = 0; i < numToInsert; i++ ) {
            User u = new User();
            for(String key : nameValue.keySet()){
                u.put(key, nameValue.get(key));
            }
            users.add(u);
        }
        
        if( doInsert ) {
            insert users;
        }
        return users;
    }

    //create Accounts 
    public static List<Account> createAccounts(Integer numToInsert,Boolean doInsert,Map<String, Object> nameValue) {
        List<Account> accounts = new List<Account>();
        for( Integer i = 0; i < numToInsert; i++ ) {
            Account a = new Account( Name='Consumer' );
            for(String key : nameValue.keySet()){
                a.put(key, nameValue.get(key));
            }
            accounts.add(a);
        }
        
        if( doInsert ) {
            insert accounts;
        }
        return accounts;
    }
    

    //create contacts
    public static List<Contact> createContacts(Integer numToInsert,Boolean doInsert,Map<String, Object> nameValue) {
        List<Contact> contacts = new List<Contact>();
        for( Integer i = 0; i < numToInsert; i++ ) {
            Contact a = new Contact( LastName='TestContact' );
            for(String key : nameValue.keySet()){
                a.put(key, nameValue.get(key));
            }
            contacts.add(a);
        }           
        if( doInsert ) {
            insert contacts;
        }
        return contacts;
    }

}