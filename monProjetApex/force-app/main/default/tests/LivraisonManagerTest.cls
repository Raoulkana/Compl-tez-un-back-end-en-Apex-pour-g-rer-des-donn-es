@IsTest
public class LivraisonManagerTest {


private static final String DEFAULT_STATUT = 'En préparation';

@TestSetup
static void setupData() {

    // Création d'un compte
    Account acc = new Account(
        Name = 'Compte Test'
    );
    insert acc;

    // Création d'une commande
    Order ord = new Order(
        Name = 'Commande Test',
        AccountId = acc.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pays__c = 'France',
        Account_Type__c = 'Particulier'
    );
    insert ord;

    // Création transporteur
    Transporteur__c transporteur = new Transporteur__c(
        Name = 'Chronopost',
        TypeClient__c = 'Particulier'
    );
    insert transporteur;

    // Création tarif livraison
    TarifLivraison__c tarif = new TarifLivraison__c(
        Name = 'Tarif Standard',
        Transporteur__c = transporteur.Id,
        Pays__c = 'France',
        TypeClient__c = 'Particulier',
        Prix__c = 100,
        Delai__c = 2
    );
    insert tarif;
}

// ===============================
// TEST CREATE LIVRAISON
// ===============================
@IsTest
static void testCreateLivraison() {

    Order ord = [SELECT Id FROM Order LIMIT 1];
    TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

    Test.startTest();

    Id livId = LivraisonManager.createLivraison(ord.Id, tarif.Id);

    Test.stopTest();

    Livraison__c liv = [
        SELECT Id, Order__c, Tarif__c, Statut__c
        FROM Livraison__c
        WHERE Id = :livId
    ];

    System.assertNotEquals(null, liv.Id, 'La livraison doit être créée');
    System.assertEquals(ord.Id, liv.Order__c, 'OrderId incorrect');
    System.assertEquals(tarif.Id, liv.Tarif__c, 'Tarif incorrect');
    System.assertEquals(DEFAULT_STATUT, liv.Statut__c, 'Statut incorrect');
}

// ===============================
// TEST UPDATE LIVRAISON
// ===============================
@IsTest
static void testUpdateLivraison() {

    Order ord = [SELECT Id FROM Order LIMIT 1];
    TarifLivraison__c tarif = [SELECT Id FROM TarifLivraison__c LIMIT 1];

    Livraison__c liv = new Livraison__c(
        Order__c = ord.Id,
        Tarif__c = tarif.Id,
        Statut__c = DEFAULT_STATUT
    );
    insert liv;

    Transporteur__c transporteur = [SELECT Id FROM Transporteur__c LIMIT 1];

    TarifLivraison__c newTarif = new TarifLivraison__c(
        Name = 'Tarif Express',
        Transporteur__c = transporteur.Id,
        Pays__c = 'France',
        TypeClient__c = 'Particulier',
        Prix__c = 150,
        Delai__c = 1
    );
    insert newTarif;

    Test.startTest();

    LivraisonManager.updateLivraison(liv.Id, newTarif.Id);

    Test.stopTest();

    Livraison__c updated = [
        SELECT Tarif__c
        FROM Livraison__c
        WHERE Id = :liv.Id
    ];

    System.assertEquals(newTarif.Id, updated.Tarif__c, 'Le tarif doit être mis à jour');
}

// ===============================
// TEST LAUNCH DELIVERY
// ===============================
@IsTest
static void testLaunchDelivery() {

    Order ord = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();

    Id livraisonId = LivraisonManager.launchDelivery(ord.Id);

    Test.stopTest();

    Livraison__c liv = [
        SELECT Id, Order__c, Statut__c
        FROM Livraison__c
        WHERE Id = :livraisonId
    ];

    System.assertNotEquals(null, liv.Id, 'Livraison doit être créée');
    System.assertEquals(ord.Id, liv.Order__c, 'La livraison doit être liée à la commande');
    System.assertEquals(DEFAULT_STATUT, liv.Statut__c, 'Statut incorrect');
}

// ===============================
// TEST ERREUR CREATE
// ===============================
@IsTest
static void testCreateLivraisonError() {

    Test.startTest();

    try {
        LivraisonManager.createLivraison(null, null);
        System.assert(false, 'Une exception devait être levée');
    }
    catch (AuraHandledException e) {
        System.assert(e.getMessage().contains('OrderId'), 'Message incorrect');
    }

    Test.stopTest();
}

// ===============================
// TEST ERREUR UPDATE
// ===============================
@IsTest
static void testUpdateLivraisonError() {

    Test.startTest();

    try {
        LivraisonManager.updateLivraison(null, null);
        System.assert(false, 'Une exception devait être levée');
    }
    catch (AuraHandledException e) {
        System.assert(e.getMessage().contains('LivraisonId'), 'Message incorrect');
    }

    Test.stopTest();
}

// ===============================
// TEST ERREUR LAUNCH DELIVERY
// ===============================
@IsTest
static void testLaunchDeliveryError() {

    Test.startTest();

    try {
        LivraisonManager.launchDelivery(null);
        System.assert(false, 'Une exception devait être levée');
    }
    catch (AuraHandledException e) {
        System.assert(e.getMessage().contains('OrderId'), 'Message incorrect');
    }

    Test.stopTest();

  }
}