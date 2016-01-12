public without sharing class DelegatedAdministratorController {

	public Contact[] contacts {get;set;}
    public Contact newContact {get;set;}
    public Account newAccount {get;set;}
    public String conEmail {get;set;}
    public String conLastName {get;set;}
    public String conFirstName {get;set;}
    private Map<Id, User> contactIdToUserMap {get; set;}
    public String contactIdToModify {get;set;}
    private Id userId {private set; private get;}
    public contactUserInfo[] contactUsers {get;set;}
    public List<SelectOption> accOptions {get;set;}
    private user u = new User();
    public String accId {get;set;}


    public DelegatedAdministratorController() {
    }

    public void init(){

        newContact = new Contact();
        contactIdToModify = null;
        userId = UserInfo.getUserId();
        conEmail = '';
        conLastName = '';
        conFirstName = '';
        contactUsers = new List<contactUserInfo>();
        contactIdToUserMap = new Map<Id, User>();
        accOptions = new List<SelectOption>();
        accId = '';
        //newAccount = new Account();

        u = [Select Contact.AccountId, Contact.OwnerId FROM User WHERE Id =: userId];
        Account[] acc = [SELECT Id, Name FROM Account WHERE Id =: u.Contact.AccountId OR ParentId =: u.Contact.AccountId];
        for(Account a :acc){
            //String name = accIdToNameMap.get(i);
            accOptions.add(new SelectOption(a.Id, a.Name));
        }
        User[] users = [SELECT Id, Name, Contact.FirstName, Contact.Account.ParentId,
                        Contact.LastName, Contact.AccountId, ContactId,
                        IsActive, Username, Email, Contact.Account.Name
                        FROM User
                        WHERE Contact.AccountId =: u.Contact.AccountId OR Contact.Account.ParentId =: u.Contact.AccountId
                        ORDER BY Contact.Account.Name, Name];
        Contact[] contacts = [SELECT Id, FirstName, LastName, Email, Name, AccountId, Account.Name FROM Contact WHERE AccountId =:u.Contact.AccountId OR Account.ParentId =:  u.Contact.AccountId
                             ORDER BY Account.Name, Name];
        if(!users.isEmpty()){
            createContactIdToUserMap(users);
        }
        if(!contacts.isEmpty()){
            createContactUsers(contacts, users);
        }
    }

    private void createContactUsers(Contact[] cons, User[] users) {

        Map<Id, String> accIdToNameMap = new Map<Id, String>();
        
        for(Contact con : cons){

            /*if(accIdToNameMap.get(con.Account.Id) == null){
                accIdToNameMap.put(con.Account.Id, con.Account.Name);
            }*/

            Boolean userMatch = false;
            Boolean active = false;
            String name = '';
            String mail = '';
            for(User u : users){
                if(u.ContactId == con.Id){
                    userMatch = true;
                    name = u.Username;
                    mail = u.Email;
                    if(u.isActive == true){
                        active = true;
                    }
                }
            }
            contactUserInfo cui = new contactUserInfo();
            if(userMatch == true){
                cui.userOrContact = 'User';
                cui.isUser = true;
                cui.uName = name;
            }else{
                cui.userOrContact = 'Contact Only';
                cui.isUser = false;
                mail = con.Email;
            }
            cui.accName = con.Account.Name;
            cui.con = new Contact(FirstName = con.FirstName,
                                  LastName = con.LastName,
                                  Id = con.Id,
                                  Email = con.Email
                                  );
            cui.isActive = active;
            cui.uEmail = mail;
            contactUsers.add(cui);
        }

        /*for(Id i :accIdToNameMap.keySet()){
            String name = accIdToNameMap.get(i);
            accOptions.add(new SelectOption(i, name));
        }*/
        
    }

    private void createContactIdToUserMap(User[] users) {
        for(User u : users){
            contactIdToUserMap.put(u.ContactId, u);
        }
    }

    class contactUserInfo{
        public Contact con {get;set;}
        public Boolean isActive {get;set;}
        public String userOrContact {get;set;}
        public Boolean isUser {get;set;}
        public String uName {get;set;}
        public String uEmail {get;set;}
        public String accName {get;set;}

    }

    public void resetUserPassword(){
        system.debug('$$$contactIdToModify: '  + contactIdToModify);

        //if(contactIdToUserMap.get(contactIdToModify) != null){
            User u = contactIdToUserMap.get(contactIdToModify);
            System.resetPassword(u.Id, true);
            init();
            Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Info, u.Name + '\'s Password Successfully Reset. Email Sent.') );
        /*}else{
            Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Info, 'User could not be found. Have they been made an active user?') );
        }*/
    }

    public void changeUserActiveStatus(){
        User u = contactIdToUserMap.get(contactIdToModify);
        String msg  ='';

        if(u.IsActive){
            u.IsActive = false;
            msg = ' deactivated.';
        }else{
            u.IsActive = true;
            msg = 'activated.';
        }

        try{
            update u;
            init();
            Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Info, u.Name + msg));
        }catch(DmlException e){
            Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Error, e.getMessage()));
        }
    }

    public void createContact(){
        system.debug('$$$conEmail' + conEmail);
        //conEmail = 'contact.3@wholesalera.com';
        String emailRegex = '[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}'; 
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(conEmail);

        if (myMatcher.matches()){ 
            try{
                newContact.OwnerId = u.Contact.OwnerId;
                newContact.AccountId = u.Contact.AccountId;
                newContact.Email = conEmail;
                newContact.LastName = conLastName;
                newContact.FirstName = conFirstName;
                newContact.AccountId = accId;
                insert newContact;
                init();
            }catch(DmlException e){
                Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Error, e.getMessage()));
            }
        }else{
            Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Info, 'Email Address Not Valid'));
        }

    }

    public void createUser(){
        if(contactIdToModify != null){
            Contact c = [SELECT Id, Name, FirstName, LastName, AccountId, Email, Account.OwnerId FROM Contact WHERE Id =: contactIdToModify LIMIT 1];
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
            User newUser = new User();
            newUser.FirstName = c.FirstName;
            newUser.LastName = c.LastName;
            newUser.ContactId = c.Id;
            newUser.IsActive = true;
            newUser.Alias = c.FirstName.left(1) + c.LastName.left(4);
            newUser.CommunityNickname = c.LastName.left(3) + String.valueOf(c.Id).right(5);
            newUser.ProfileID = communityProfile.Id;
            newUser.IsActive = true;
            newUser.Username = c.Email + '.AB';
            newUser.Email = c.Email;
            newUser.EmailEncodingKey='UTF-8';
            newUser.LanguageLocaleKey='en_US';
            newUser.LocaleSidKey='en_US';
            newUser.TimeZoneSidKey='America/Los_Angeles';

            try{
                insert newUser;
                init();
                Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Info, newUser.FirstName + ' ' + newUser.LastName + ' created and activated Successfully!'));
            }catch(DmlException e){
                Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Error, e.getMessage()));
            }

        }
    }

    /***
    Uncomment the following to enable new retailer functionality
    ***/
    /*public void createAccount(){

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Retailer'];
        newAccount.ParentId = u.Contact.AccountId;
        newAccount.RecordTypeId = rt.Id;

        try{
            insert newAccount;
            init();
        }catch(DmlException e){
                Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Error, e.getMessage()));
        }
    }*/
}