import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getOrders from '@salesforce/apex/OrderService.getOrders';
import getOrderDetails from '@salesforce/apex/OrderService.getOrderDetails';

import getOrderTarifs from '@salesforce/apex/OrderTarifService.getByOrderIds';
import getLivraisonByOrder from '@salesforce/apex/DeliveryOrderService.getByOrderIds';
import createLivraison from '@salesforce/apex/DeliveryOrderService.createByOrderIds';
import updateLivraison from '@salesforce/apex/DeliveryOrderService.updateByIds';

export default class LaunchLivraison extends LightningElement {

    @api recordId;

    @track orderOptions = [];
    @track selectedOrderId;

    @track orderDetails;

    @track tarifs = [];
    @track selectedTarifId;

    @track livraison;
    @track hasLivraison = false;

    connectedCallback() {
        this.loadOrders();
    }

    // Charger commandes
    loadOrders(){

        getOrders()
            .then(result => {

                this.orderOptions = result.map(o => ({
                    label: o.OrderNumber,
                    value: o.Id
                }));

            })
            .catch(error => {
                console.error('Erreur commandes', error);
            });

    }

    // Changement commande
    handleOrderChange(event){

        this.selectedOrderId = event.detail.value;

        this.selectedTarifId = null;
        this.tarifs = [];
        this.orderDetails = null;

        this.loadOrderDetails();
        this.loadTarifs();
        this.loadExistingLivraison();

    }

    // Charger détails commande
    loadOrderDetails(){

        getOrderDetails({ orderId: this.selectedOrderId })
            .then(result => {
                this.orderDetails = result;
            })
            .catch(error => {
                console.error('Erreur détails commande', error);
            });

    }

    // Charger tarifs
    loadTarifs(){

        getOrderTarifs({ orderId: this.selectedOrderId })

            .then(data => {

                if(!data || data.length === 0){
                    this.tarifs = [];
                    return;
                }

                let cheapest;
                let fastest;

                data.forEach(t => {

                    if(!cheapest || t.Prix__c < cheapest.Prix__c){
                        cheapest = t;
                    }

                    if(!fastest || t.Delai__c < fastest.Delai__c){
                        fastest = t;
                    }

                });

                this.tarifs = data.map(t => {

                    const rowClass =
                        t.Id === cheapest?.Id
                            ? 'cheapest-row'
                            : t.Id === fastest?.Id
                            ? 'fastest-row'
                            : '';

                    return {
                        ...t,
                        rowClass,
                        isCheapest: t.Id === cheapest?.Id,
                        isFastest: t.Id === fastest?.Id,
                        isSelected: this.selectedTarifId === t.Id
                    };

                });

            })

            .catch(error => {
                console.error('Erreur tarifs', error);
            });

    }

    // Charger livraison existante
    loadExistingLivraison(){

        getLivraisonByOrder({ orderIds: [this.selectedOrderId] })

            .then(result => {

                const livraisons = result?.[this.selectedOrderId];

                if(livraisons && livraisons.length > 0){

                    this.livraison = livraisons[0];
                    this.hasLivraison = true;

                }else{

                    this.livraison = null;
                    this.hasLivraison = false;

                }

            })
            .catch(error => {
                console.error('Erreur livraison', error);
            });

    }

    // Sélection tarif
    handleSelection(event){

        this.selectedTarifId = event.target.value;

        this.tarifs = this.tarifs.map(t => ({
            ...t,
            isSelected: t.Id === this.selectedTarifId
        }));

    }

    get isCreateDisabled(){
        return !this.selectedTarifId;
    }

    get isUpdateDisabled(){
        return !this.selectedTarifId;
    }

    get noTarifs(){
        return !this.tarifs || this.tarifs.length === 0;
    }

    // Créer livraison
    handleCreateLivraison(){

        if(!this.selectedTarifId) return;

        createLivraison({
            orderIds:[this.selectedOrderId],
            selectedTarifIds:{ [this.selectedOrderId]: this.selectedTarifId }
        })

        .then(result => {

            this.livraison = { Id: result[this.selectedOrderId] };
            this.hasLivraison = true;

            this.showToast(
                'Succès',
                'Livraison créée',
                'success'
            );

        })
        .catch(error => {

            this.showToast(
                'Erreur',
                error.body?.message,
                'error'
            );

        });

    }

    // Modifier livraison
    handleUpdate(){

        if(!this.selectedTarifId || !this.livraison) return;

        updateLivraison({
            deliveryOrderIds:[this.livraison.Id],
            newTarifIds:{ [this.livraison.Id]: this.selectedTarifId }
        })

        .then(() => {

            this.showToast(
                'Succès',
                'Livraison mise à jour',
                'success'
            );

        })
        .catch(error => {

            this.showToast(
                'Erreur',
                error.body?.message,
                'error'
            );

        });

    }

    showToast(title, message, variant){

        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );

    }

}