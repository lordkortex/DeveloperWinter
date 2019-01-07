public with sharing class  TestSelector{

      public static List<et4ae5__abTest__c > getABtestList() {
        return [SELECT Id, name,et4ae5__Custom_Object__c  FROM et4ae5__abTest__c ];
      }
}