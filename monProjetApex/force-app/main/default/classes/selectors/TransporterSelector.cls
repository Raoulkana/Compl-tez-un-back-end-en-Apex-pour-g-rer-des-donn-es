public with sharing class TransporterSelector {

    public static List<Transporteur__c> getByClientType(String typeClient) {
        return [
            SELECT Id, Name, TypeClient__c
            FROM Transporteur__c
            WHERE TypeClient__c = :typeClient
            AND IsActive__c = true
        ];
    }
}