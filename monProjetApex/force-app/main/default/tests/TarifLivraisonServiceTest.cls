@isTest
private class TarifLivraisonServiceTest {

    @isTest
    static void testGetTarifs(){

        Account acc = new Account(Name='Test');
        insert acc;

        Order ord = new Order(
            AccountId = acc.Id,
            Status='Activated',
            EffectiveDate=Date.today(),
            Pays__c='France',
            Account_Type__c='Particulier'
        );

        insert ord;

        Test.startTest();

        List<TarifLivraison__c> tarifs = TarifLivraisonService.getTarifs(ord.Id);

        Test.stopTest();

        System.assertNotEquals(null,tarifs);

    }
}