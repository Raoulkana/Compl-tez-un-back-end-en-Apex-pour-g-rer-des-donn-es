@IsTest
public class TarifLivraisonServiceTest {

    @TestSetup
    static void setupData() {

        // ---------- Account ----------
        Account acc = new Account(
            Name = 'Client Test',
            Type = 'Particulier'
        );
        insert acc;

        // ---------- Orders ----------
        Order ord1 = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pays__c = 'France',
            Account_Type__c = 'Particulier'
        );
        insert ord1;

        Order ord2 = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pays__c = 'Espagne',
            Account_Type__c = 'Particulier'
        );
        insert ord2;

        // ---------- Transporteurs ----------
        Transporteur__c t1 = new Transporteur__c(
            Name = 'DHL',
            TypeClient__c = 'Particulier'
        );
        Transporteur__c t2 = new Transporteur__c(
            Name = 'Chronopost',
            TypeClient__c = 'Particulier'
        );
        insert new List<Transporteur__c>{ t1, t2 };

        // ---------- Tarifs Livraison ----------
        TarifLivraison__c tarif1 = new TarifLivraison__c(
            Name = 'Tarif DHL',
            Transporteur__c = t1.Id,
            Pays__c = 'France',
            TypeClient__c = 'Particulier',
            Prix__c = 20,
            Delai__c = 2
        );

        TarifLivraison__c tarif2 = new TarifLivraison__c(
            Name = 'Tarif Chronopost',
            Transporteur__c = t2.Id,
            Pays__c = 'France',
            TypeClient__c = 'Particulier',
            Prix__c = 10,
            Delai__c = 3
        );

        insert new List<TarifLivraison__c>{ tarif1, tarif2 };
    }

    // ===================================
    // TEST récupération des tarifs existants
    // ===================================
    @IsTest
    static void testGetTarifLivraison() {
        Order ord = [SELECT Id FROM Order WHERE Pays__c='France' LIMIT 1];

        Test.startTest();
        List<TarifLivraison__c> tarifs = TarifLivraisonService.getTarifLivraison(ord.Id);
        Test.stopTest();

        // Requête pour récupérer tous les champs nécessaires
        List<TarifLivraison__c> tarifsWithFields = [
            SELECT Id, Pays__c, TypeClient__c, Transporteur__r.Id, Transporteur__r.Name, Prix__c
            FROM TarifLivraison__c
            WHERE Id IN :tarifs
        ];

        // Vérifications
        System.assertNotEquals(null, tarifsWithFields, 'La liste de tarifs ne doit pas être null');
        System.assertEquals(2, tarifsWithFields.size(), 'Deux tarifs doivent être retournés');

        // Vérifier tri par prix ASC
        System.assert(tarifsWithFields[0].Prix__c <= tarifsWithFields[1].Prix__c,
            'Les tarifs doivent être triés par prix asc');

        // Vérifier champs clés
        for(TarifLivraison__c t : tarifsWithFields){
            System.assertEquals('France', t.Pays__c, 'Pays correct');
            System.assertEquals('Particulier', t.TypeClient__c, 'Type client correct');
            System.assertNotEquals(null, t.Transporteur__r.Id, 'Transporteur présent');
            System.assertNotEquals(null, t.Transporteur__r.Name, 'Nom du transporteur présent');
        }
    }

    // ===================================
    // TEST aucun tarif trouvé
    // ===================================
    @IsTest
    static void testNoTarifFound() {
        Order ord = [SELECT Id FROM Order WHERE Pays__c='Espagne' LIMIT 1];

        Test.startTest();
        List<TarifLivraison__c> tarifs = TarifLivraisonService.getTarifLivraison(ord.Id);
        Test.stopTest();

        System.assertEquals(0, tarifs.size(),
            'Aucun tarif ne doit être retourné pour Espagne/Particulier');
    }

    // ===================================
    // TEST orderId null
    // ===================================
    @IsTest
    static void testOrderIdNull() {
        try {
            Test.startTest();
            List<TarifLivraison__c> tarifs = TarifLivraisonService.getTarifLivraison(null);
            Test.stopTest();
            System.assert(false, 'Une exception devrait être levée pour orderId null');
        } catch (QueryException e) {
            System.assert(e.getMessage().contains('List has no rows'), 'Exception attendue pour null');
        }
    }
} 