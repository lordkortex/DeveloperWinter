public without sharing class AccountsController {
      @AuraEnabled
      public static List <Account> getAccounts() {
        return [SELECT Id, name, industry, Type, NumberOfEmployees, TickerSymbol, Phone FROM Account ORDER BY createdDate ASC];
      }
    
        @AuraEnabled
      public static List <Account> getAccountsListName() {
        return [SELECT Id, name, industry, Type, NumberOfEmployees, TickerSymbol, Phone FROM Account ORDER BY createdDate ASC];
      }
    
    
       
     
    @AuraEnabled
     public static boolean manualShareRead(Id recordId){
      List<AccountShare> share = new List<AccountShare>();
           
    
          System.debug(' 2222 AAAA User Debug: BBBB  UAT Other chaneg' + UserInfo.getUserId());
          System.debug('XXXX');
         //Comentario feature PRE 2
             AccountShare accountShare = new AccountShare();
                  accountShare.AccountId = recordId;
                  accountShare.UserOrGroupId = UserInfo.getUserId();
                  accountShare.AccountAccessLevel = 'Edit';
                  //accountShare.ContactAccessLevel = 'Edit';
                  accountShare.CaseAccessLevel = 'Edit';
                  accountShare.OpportunityAccessLevel = 'Edit';
             share.add(accountShare);

     List<Database.SaveResult> sr = Database.insert(share,false);
        List<Database.SaveResult> sr1 = Database.insert(share,false);

        //return true;

      if(sr.get(0).isSuccess()){
         return true;
      }
      else {
           return false;
         /*Database.Error err = sr.getErrors()[0];
         
         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                  err.getMessage().contains('AccessLevel')){
            return true;
         }
         else{
            return false;
         }*/
       }
   }

    @AuraEnabled
    public static List <Account> getAccountsOtherMethod() {
        return [SELECT Id, name, industry, Type, NumberOfEmployees, TickerSymbol, Phone FROM Account ORDER BY createdDate ASC];
    }

}