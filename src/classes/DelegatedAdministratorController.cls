public without sharing class DelegatedAdministratorController {

	public Contact[] contacts {get;set;}
    public Contact newContact {get;set;}
    public String conEmail {get;set;}
    private Map<Id, User> contactIdToUserMap {get; set;}
    public String contactIdToModify {get;set;}
    private Id userId {private set; private get;}
    public contactUserInfo[] contactUsers {get;set;}
    private user u = new User();

    public DelegatedAdministratorController() {
    }

    public void init(){
        newContact = new Contact();
        contactIdToModify = null;
        userId = UserInfo.getUserId();
        conEmail = '';
        u = [Select Contact.AccountId, Contact.OwnerId FROM User WHERE Id =: userId];
        User[] users = [SELECT Id, Name, Contact.FirstName, 
                        Contact.LastName, Contact.AccountId, ContactId,
                        IsActive, Username
                        FROM User
                        WHERE Contact.AccountId =: u.Contact.AccountId];
        Contact[] contacts = [SELECT Id, FirstName, LastName, Email, Name FROM Contact WHERE AccountId =:u.Contact.AccountId];
        if(!users.isEmpty()){
            createContactIdToUserMap(users);
        }
        if(!contacts.isEmpty()){
            createContactUsers(contacts, users);
        }
    }
    private void createContactUsers(Contact[] cons, User[] users) {

        contactUsers = new List<contactUserInfo>();

        for(Contact con : cons){
            Boolean userMatch = false;
            Boolean active = false;
            String name = '';
            for(User u : users){
                if(u.ContactId == con.Id){
                    userMatch = true;
                    name = u.Username;
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
            }
            cui.con = new Contact(FirstName = con.FirstName,
                                  LastName = con.LastName,
                                  Id = con.Id
                                  );
            cui.isActive = active;
            contactUsers.add(cui);
        }
        
    }

    private void createContactIdToUserMap(User[] users) {
        contactIdToUserMap = new Map<Id, User>();
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

        if(u.IsActive){
            u.IsActive = false;
        }else{
            u.IsActive = true;
        }

        try{
            update u;
            init();
        }catch(DmlException e){
            Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Error, e.getMessage()));
        }
    }

    public void createContact(){
        system.debug('$$$conEmail' + conEmail);
        conEmail = 'contact.3@wholesalera.com';
        String emailRegex = '[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(conEmail);

        if (myMatcher.matches()){ 
            try{
                newContact.OwnerId = u.Contact.OwnerId;
                newContact.AccountId = u.Contact.AccountId;
                newContact.Email = conEmail;
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
            }catch(DmlException e){
                Apexpages.addMessage( new ApexPages.Message( Apexpages.Severity.Error, e.getMessage()));
            }

        }
    }
}