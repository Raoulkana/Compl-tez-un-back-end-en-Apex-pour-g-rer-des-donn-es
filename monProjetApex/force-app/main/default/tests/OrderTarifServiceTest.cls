@isTest
private class OrderTarifServiceTest {

    @isTest
    static void testGetByOrderIds(){

        Account acc = new Account(Name='Test');
        insert acc;

        Order ord = new Order(
            AccountId = acc.Id,
            Status='Activated',
            EffectiveDate = Date.today(),
            Pays__c = 'France',
            Account_Type__c = 'Particulier'
        );

        insert ord;

        Test.startTest();

        List<TarifLivraison__c> tarifs =
            OrderTarifService.getByOrderIds(ord.Id);

        Test.stopTest();

        System.assertNotEquals(null,tarifs);

    }

}