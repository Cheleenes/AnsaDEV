import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUbicacion from '@salesforce/apex/AMC_LocationTrackerController.getUbicacion';

export default class AMC_LocationTracker extends LightningElement {
    tieneUbicacion = true;
    //idOrder = '8013C0000023MgHQAU';
    idOrder;
    mapMarkers;
    zoomLevel = 17;
    orderStatus;
    orderAmount;
    orderCreatedDate;
    ResourceName;

    connectedCallback() {
        this.getLocation();
    }

    getLocation(){
        getUbicacion(
            {
                idOrder: this.idOrder
            }
        ).then(
            resultado => {
                try {
                    console.log('resultado: ' + JSON.stringify(resultado));
                    if(resultado && resultado.Latitude && resultado.Longitude){
                        this.tieneUbicacion = true;
                        console.log('getLocation:if');
                        this.mapMarkers = [
                            {
                                location: {
                                    Latitude: resultado.Latitude,
                                    Longitude: resultado.Longitude,
                                }
                            }
                        ];
                        this.orderStatus = resultado.OrderStatus;
                        this.orderAmount = resultado.OrderTotal;
                        this.orderCreatedDate = resultado.OrderCreationDate;
                        this.ResourceName = resultado.ResourceName;
                    }else{
                        this.showNotification('Sin ubicación', 'No se encontró la ubicación del tecnecio', 'warning');
                        this.tieneUbicacion = false;
                    }
                } catch (error) {
                    this.showNotification('Sin ubicación', 'No se encontró la ubicación del tecnecio', 'warning');
                    console.log('Error: '+ error);
                    this.tieneUbicacion = false;
                }
                
            }
        ).catch(
            error => {
                console.error('Error al obtener la ubicacion');
                this.showNotification('Sin ubicación', 'No se encontró la ubicación del tecnecio', 'warning');
                this.tieneUbicacion = false;
            }
        );
    }

    handleClickGetUbicacion(event) {
        this.getLocation();
    }

    showNotification(t, m, v) {
        const evt = new ShowToastEvent({
            title: t,
            message: m,
            variant: v,
        });
        this.dispatchEvent(evt);
    }

    handleOrderChange(event){
        this.idOrder = event.target.value;
        console.log('order number: ' + this.idOrder);
    } 
}