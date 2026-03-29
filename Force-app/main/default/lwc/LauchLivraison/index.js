import { LightningElement, api } from 'lwc';
import createLivraison from '@salesforce/apex/LivraisonManager.createLivraison';

export default class LaunchLivraison extends LightningElement {

    @api recordId;

    handleClick() {
        createLivraison({ orderId: this.recordId })
            .then(() => {
                alert('Livraison créée');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
}