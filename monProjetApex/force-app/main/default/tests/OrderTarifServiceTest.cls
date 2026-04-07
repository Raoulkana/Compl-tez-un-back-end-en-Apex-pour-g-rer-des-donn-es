@IsTest
public class OrderTarifServiceTest {

    @TestSetup
    static void setupData(){

        // ---------- Account ----------
        Account acc = new Account(
            Name = 'Client Test',
            Type = 'Particulier'
        );
        insert acc;

        // ---------- Order ----------
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pays__c = 'France',
            Account_Type__c = 'Particulier'
        );
        insert ord;

        // ---------- Transporteur ----------
        Transporteur__c transporteur = new Transporteur__c(
            Name = 'Chronopost',
            TypeClient__c = 'Particulier'
        );
        insert transporteur;

        // ---------- Tarif Livraison ----------
        TarifLivraison__c tarif = new TarifLivraison__c(
            Name = 'Tarif Standard',
            Transporteur__c = transporteur.Id,
            Pays__c = 'France',
            TypeClient__c = 'Particulier',
            Prix__c = 10,
            Delai__c = 3
        );
        insert tarif;

    }

    // =============================
    // TEST récupération des tarifs
    // =============================
    @IsTest
    static void testGetByOrderIds(){

        Order ord = [
            SELECT Id
            FROM Order
            LIMIT 1
        ];

        Test.startTest();

        List<TarifLivraison__c> tarifs =
            OrderTarifService.getByOrderIds(ord.Id);

        Test.stopTest();

        System.assertNotEquals(null, tarifs, 'La liste ne doit pas être null');
        System.assertEquals(1, tarifs.size(), 'Un tarif doit être retourné');

        TarifLivraison__c tarif = tarifs[0];

        System.assertEquals('France', tarif.Pays__c);
    }

    // =============================
    // TEST aucun tarif disponible
    // =============================
    @IsTest
    static void testNoTarifFound(){

        Account acc = new Account(Name='Autre Client');
        insert acc;

        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pays__c = 'Espagne',
            Account_Type__c = 'Particulier'
        );

        insert ord;

        Test.startTest();

        List<TarifLivraison__c> tarifs =
            OrderTarifService.getByOrderIds(ord.Id);

        Test.stopTest();

        System.assertEquals(
            0,
            tarifs.size(),
            'Aucun tarif ne doit être retourné'
        );
    }

}