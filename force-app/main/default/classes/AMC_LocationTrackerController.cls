public without sharing class AMC_LocationTrackerController {

    @AuraEnabled
    public static WPUbicacion getUbicacion(String idOrder){
        WPUbicacion wpU = new WPUbicacion();
        System.debug('Order number: ' + idOrder);
        Order orden = [Select Id, CreatedDate, TotalAmount, Status From Order Where OrderNumber =: idOrder LIMIT 1];
        System.debug('Order: ' + orden);
        WorkOrder ordenTrabajo = [SELECT Id, WorkOrderNumber, ANSA_Order__c FROM WorkOrder WHERE ANSA_Order__c =: orden.Id limit 1];
        System.System.debug('orden de trabajo:' + ordenTrabajo);
        wpU.OrderStatus = orden.Status != null ? String.valueOf(orden.Status) : null;
        wpU.OrderTotal = orden.totalAmount != null ? String.valueOf(orden.totalAmount) : null;
        wpu.OrderCreationDate = orden.CreatedDate != null ? String.valueOf(orden.CreatedDate) : null;
        for(AssignedResource recursoAsignado : [SELECT Id, ServiceAppointmentId, ServiceAppointment.Status, 
                                                ServiceResource.Name, ServiceResource.LastKnownLatitude, ServiceResource.LastKnownLongitude, 
                                                ServiceAppointment.ParentRecordId, ServiceAppointment.ParentRecordType FROM AssignedResource 
                                                WHERE ServiceAppointment.ParentRecordId =: ordenTrabajo.Id AND ServiceAppointment.Status =: 'In Progress']){
            wpU.Latitude = recursoAsignado.ServiceResource.LastKnownLatitude != null ? String.valueOf(recursoAsignado.ServiceResource.LastKnownLatitude) : null;
            wpU.Longitude = recursoAsignado.ServiceResource.LastKnownLongitude != null ? String.valueOf(recursoAsignado.ServiceResource.LastKnownLongitude) : null;
            wpU.ResourceName = recursoAsignado.ServiceResource.Name != null ? String.valueOf(recursoAsignado.ServiceResource.Name) : null;
        }
        return wpU;
    }

    public class WPUbicacion{
        @AuraEnabled public String Latitude {get;set;}
        @AuraEnabled public String Longitude {get;set;}
        @AuraEnabled public String OrderStatus {get;set;}
        @AuraEnabled public String OrderTotal {get;set;}
        @AuraEnabled public String OrderCreationDate {get;set;}
        @AuraEnabled public String ResourceName {get;set;}
    }
}