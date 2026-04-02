@IsTest
public class DeliveryOrderServiceTest {

    @TestSetup
    static void setupData() {
        // Créer un compte
        Account acc = new Account(Name='Compte Test');
        insert acc;

        // Créer une commande activée
        Order ord = new Order(
            Name = 'Commande Test',
            AccountId = acc.Id,
            Status = 'Activated',
            Pays__c = 'France',
            Account_Type__c = 'Particulier'
        );
        insert ord;

        // Transporteur
        Transporteur__c t = new Transporteur__c(Name='Chronopost', TypeClient__c='Particulier');
        insert t;

        // Tarif livraison
        TarifLivraison__c tarif = new TarifLivraison__c(
            Transporteur__c = t.Id,
            Pays__c = 'France',
            TypeClient__c = 'Particulier',
            Prix__c = 100,
            Delai__c = 2
        );
        insert tarif;
    }

    @IsTest
    static void testCreateByOrderIds() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        Map<Id, Id> selectedTarifIds = new Map<Id, Id>{ ord.Id => tarif.Id };

        Test.startTest();
        Map<Id, Id> result = DeliveryOrderService.createByOrderIds(new List<Id>{ord.Id}, selectedTarifIds);
        Test.stopTest();

        System.assert(result.containsKey(ord.Id), 'Le résultat doit contenir l Id de la commande');
        System.assertNotEquals(null, result.get(ord.Id), 'L Id de la livraison ne doit pas être null');
    }

    @IsTest
    static void testGetByOrderIds() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        // Créer une livraison pour tester la récupération
        Id livId = LivraisonManager.createLivraison(ord.Id, tarif.Id);

        Test.startTest();
        Map<Id, List<Livraison__c>> result = DeliveryOrderService.getByOrderIds(new List<Id>{ord.Id});
        Test.stopTest();

        System.assert(result.containsKey(ord.Id), 'Doit contenir la commande');
        System.assertEquals(1, result.get(ord.Id).size(), 'Doit y avoir une livraison');
        System.assertEquals(livId, result.get(ord.Id)[0].Id, 'L Id correspond à la livraison créée');
    }

    @IsTest
    static void testUpdateByIds() {
        Order ord = [SELECT Id FROM Order LIMIT 1];
        TarifLivraison__c tarif1 = [SELECT Id FROM TarifLivraison__c LIMIT 1];

        // Créer une livraison
        Id livId = LivraisonManager.createLivraison(ord.Id, tarif1.Id);

        // Nouveau tarif
        Transporteur__c t2 = new Transporteur__c(Name='DHL', TypeClient__c='Particulier');
        insert t2;

        TarifLivraison__c tarif2 = new TarifLivraison__c(
            Transporteur__c = t2.Id,
            Pays__c = 'France',
            TypeClient__c = 'Particulier',
            Prix__c = 120,
            Delai__c = 1
        );
        insert tarif2;

        Map<Id, Id> newTarifIds = new Map<Id, Id>{ livId => tarif2.Id };

        Test.startTest();
        DeliveryOrderService.updateByIds(new List<Id>{livId}, newTarifIds);
        Test.stopTest();

        Livraison__c livUpdated = [SELECT Tarif__c FROM Livraison__c WHERE Id = :livId];
        System.assertEquals(tarif2.Id, livUpdated.Tarif__c, 'Le tarif doit être mis à jour');
    }
}