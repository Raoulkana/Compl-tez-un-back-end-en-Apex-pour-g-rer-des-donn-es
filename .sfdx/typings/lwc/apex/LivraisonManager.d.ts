declare module "@salesforce/apex/LivraisonManager.createLivraison" {
  export default function createLivraison(param: {orderId: any, tarifId: any}): Promise<any>;
}
declare module "@salesforce/apex/LivraisonManager.updateLivraison" {
  export default function updateLivraison(param: {livraisonId: any, tarifId: any}): Promise<any>;
}
declare module "@salesforce/apex/LivraisonManager.launchDelivery" {
  export default function launchDelivery(param: {orderId: any}): Promise<any>;
}
