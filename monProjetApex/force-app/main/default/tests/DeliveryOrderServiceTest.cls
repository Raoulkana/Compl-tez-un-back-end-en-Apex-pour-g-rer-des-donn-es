@isTest
private class DeliveryOrderServiceTest {

    @isTest
    static void testCreateLivraison(){

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

        TarifLivraison__c tarif = new TarifLivraison__c(
            Name='Test Tarif',
            Prix__c=10,
            Delai__c=2,
            Pays__c='France',
            TypeClient__c='Particulier'
        );
        insert tarif;

        Map<Id,Id> selectedTarifs = new Map<Id,Id>();
        selectedTarifs.put(ord.Id,tarif.Id);

        Test.startTest();

        Map<Id,Id> result = DeliveryOrderService.createByOrderIds(
            new List<Id>{ord.Id},
            selectedTarifs
        );

        Test.stopTest();

        System.assert(result.containsKey(ord.Id));

    }

}