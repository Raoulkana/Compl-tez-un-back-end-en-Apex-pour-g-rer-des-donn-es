public with sharing class DeliveryOrderService {

    @AuraEnabled
    public static Map<Id, Id> createByOrderIds(List<Id> orderIds, Map<Id, Id> selectedTarifIds){

        Map<Id, Id> result = new Map<Id, Id>();

        for(Id orderId : orderIds){

            Id tarifId = selectedTarifIds.get(orderId);

            Id livraisonId = LivraisonManager.createLivraison(orderId, tarifId);

            result.put(orderId, livraisonId);

        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<Livraison__c>> getByOrderIds(List<Id> orderIds){

        Map<Id, List<Livraison__c>> result = new Map<Id, List<Livraison__c>>();

        List<Livraison__c> livraisons = [
            SELECT Id, Order__c, Tarif__c
            FROM Livraison__c
            WHERE Order__c IN :orderIds
        ];

        for(Livraison__c liv : livraisons){

            if(!result.containsKey(liv.Order__c)){

                result.put(liv.Order__c, new List<Livraison__c>());

            }

            result.get(liv.Order__c).add(liv);

        }

        return result;
    }

    @AuraEnabled
    public static void updateByIds(List<Id> deliveryOrderIds, Map<Id, Id> newTarifIds){

        for(Id livId : deliveryOrderIds){

            Id tarifId = newTarifIds.get(livId);

            LivraisonManager.updateLivraison(livId, tarifId);

        }

    }

}