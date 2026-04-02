import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getOrders from '@salesforce/apex/OrderService.getOrders';
import getTarifLivraison from '@salesforce/apex/TarifLivraisonService.getTarifLivraison';
import getOrderTarifs from '@salesforce/apex/OrderTarifService.getByOrderIds';
import getLivraisonByOrder from '@salesforce/apex/DeliveryOrderService.getByOrderIds';
import createLivraison from '@salesforce/apex/DeliveryOrderService.createByOrderIds';
import updateLivraison from '@salesforce/apex/DeliveryOrderService.updateByIds';
import launchLivraisonManager from '@salesforce/apex/LivraisonManager.launchDelivery';

export default class LaunchLivraison extends LightningElement {

    @api recordId;
    @track orderOptions = [];
    @track selectedOrderId;
    @track tarifs = [];
    @track selectedTarifId;
    @track livraison;
    @track hasLivraison = false;

    connectedCallback() {
        this.loadOrders();
    }

    //  Charger les commandes
    loadOrders() {
        getOrders()
            .then(result => {
                this.orderOptions = result.map(o => ({ label: o.Name, value: o.Id }));
            })
            .catch(error => console.error(error));
    }

    handleOrderChange(event) {
        this.selectedOrderId = event.detail.value;
        this.loadTarifs();
        this.loadExistingLivraison();
    }

    //  Charger les tarifs
    loadTarifs() {
        getOrderTarifs({ orderId: this.selectedOrderId })
            .then(orderTarifs => {
                const tarifsPromises = orderTarifs.map(ot =>
                    getTarifLivraison({ orderId: ot.Order__c, transporterId: ot.Transporteur__c })
                        .then(tarif => ({ ...tarif, OrderId: ot.Order__c }))
                );

                return Promise.all(tarifsPromises);
            })
            .then(allTarifs => {
                let cheapest, fastest;
                allTarifs.forEach(t => {
                    if (!cheapest || t.Prix__c < cheapest.Prix__c) cheapest = t;
                    if (!fastest || t.Delai__c < fastest.Delai__c) fastest = t;
                });

                // Build template-friendly items (no call expressions needed in HTML)
                this.tarifs = allTarifs.map(t => {
                    const rowClass = t.Id === cheapest?.Id ? 'cheapest-row' : (t.Id === fastest?.Id ? 'fastest-row' : '');
                    const isSelected = this.selectedTarifId === t.Id;
                    return {
                        ...t,
                        isCheapest: t.Id === cheapest?.Id,
                        isFastest: t.Id === fastest?.Id,
                        rowClass,
                        isSelected
                    };
                });
            })
            .catch(error => console.error(error));
    }

    //  Vérifier si une livraison existe
    loadExistingLivraison() {
        getLivraisonByOrder({ orderIds: [this.selectedOrderId] })
            .then(result => {
                const livraisons = result[this.selectedOrderId];
                if (livraisons && livraisons.length > 0) {
                    this.livraison = livraisons[0];
                    this.hasLivraison = true;
                } else {
                    this.hasLivraison = false;
                }
            })
            .catch(error => console.error(error));
    }

    handleSelection(event) {
        this.selectedTarifId = event.target.value;

        // Refresh selection flags on tarifs to keep template bindings valid
        this.tarifs = (this.tarifs || []).map(t => ({
            ...t,
            isSelected: t.Id === this.selectedTarifId
        }));
    }

    get isCreateDisabled() { return !this.selectedTarifId; }
    get isUpdateDisabled() { return !this.selectedTarifId; }
    get noTarifs() { return Array.isArray(this.tarifs) ? this.tarifs.length === 0 : true; }

    // Deprecated: keep for reference; class now precomputed into each item as rowClass
    tRowClass(t) {
        return t.isCheapest ? 'cheapest-row' : t.isFastest ? 'fastest-row' : '';
    }

    //  Créer livraison
    handleCreateLivraison() {
        if (!this.selectedTarifId) return;

        createLivraison({
            orderIds: [this.selectedOrderId],
            selectedTarifIds: { [this.selectedOrderId]: this.selectedTarifId }
        })
            .then(result => {
                this.livraison = { Id: result[this.selectedOrderId] };
                this.hasLivraison = true;
                this.selectedTarifId = null;
                this.showToast('Succès', 'Livraison créée avec succès!', 'success');
            })
            .catch(error => this.showToast('Erreur', error.body?.message, 'error'));
    }

    //  Mettre à jour livraison
    handleUpdate() {
        if (!this.selectedTarifId || !this.livraison) return;

        updateLivraison({
            deliveryOrderIds: [this.livraison.Id],
            newTarifIds: { [this.livraison.Id]: this.selectedTarifId }
        })
            .then(() => this.showToast('Succès', 'Livraison mise à jour avec succès!', 'success'))
            .catch(error => this.showToast('Erreur', error.body?.message, 'error'));
    }

    //  Optionnel : lancer toute la gestion via LivraisonManager
    handleLaunchManager() {
        if (!this.selectedOrderId) return;

        launchLivraisonManager({ orderId: this.selectedOrderId })
            .then(() => this.showToast('Succès', 'Livraison gérée via manager!', 'success'))
            .catch(error => this.showToast('Erreur', error.body?.message, 'error'));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

}