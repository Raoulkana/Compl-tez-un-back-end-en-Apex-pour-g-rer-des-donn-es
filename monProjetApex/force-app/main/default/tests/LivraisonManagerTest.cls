@IsTest
public class LivraisonManagerTest {

    @TestSetup
    static void setupData() {
        // Compte
        Account acc = new Account(Name='Test Account');
        insert acc;

        // Commande activée
        Order ord = new Order(
            Name = 'Commande Test',
            AccountId = acc.Id,
            Status = 'Activated',
            Pays__c = 'France',
            Account_Type__c = 'VIP'
        );
        insert ord;

        // Transporteur
        Transporteur__c t = new Transporteur__c(Name='Chronopost', TypeClient__c='VIP');
        insert t;

        // Tarif livraison
        TarifLivraison__c tarif = new TarifLivraison__c(
            Transporteur__c = t.Id,
            Pays__c = 'France',
            TypeClient__c = 'VIP',
            Prix__c = 100,
            Delai__c = 2
        );
        insert tarif;
    }

    @IsTest
    static void testCreateLivraison() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Test.startTest();
        Id livId = LivraisonManager.createLivraison(ord.Id, tarif.Id);
        Test.stopTest();

        Livraison__c liv = [SELECT Id, Order__c, Tarif__c FROM Livraison__c WHERE Id = :livId];
        System.assertNotEquals(null, liv.Id, 'Livraison créée');
        System.assertEquals(ord.Id, liv.Order__c, 'OrderId doit correspondre');
        System.assertEquals(tarif.Id, liv.Tarif__c, 'TarifId doit correspondre');
    }

    @IsTest
    static void testUpdateLivraison() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Livraison__c liv = new Livraison__c(
            Order__c = ord.Id,
            Tarif__c = tarif.Id
        );
        insert liv;

        // Nouveau tarif
        TarifLivraison__c newTarif = new TarifLivraison__c(
            Transporteur__c = [SELECT Id FROM Transporteur__c LIMIT 1].Id,
            Pays__c = 'France',
            TypeClient__c = 'VIP',
            Prix__c = 120,
            Delai__c = 1
        );
        insert newTarif;

        Test.startTest();
        LivraisonManager.updateLivraison(liv.Id, newTarif.Id);
        Test.stopTest();

        Livraison__c livUpdated = [SELECT Tarif__c FROM Livraison__c WHERE Id = :liv.Id];
        System.assertEquals(newTarif.Id, livUpdated.Tarif__c, 'Tarif doit être mis à jour');
    }
}