import { LightningElement } from 'lwc';
import GetRecords from '@salesforce/apex/MercadoPagoBatchMonitorController.GetRecords';
import { NavigationMixin } from "lightning/navigation";

export default class BitForceMercadoPagoBatchMonitor extends NavigationMixin(LightningElement) {
    records = [];
    firstTime = true;
    lastUpdate = new Date().toLocaleString();

    connectedCallback(){
        if(this.firstTime){
            this.firstTime = false;
            this.getLogRecords();
        }
    }

    getLogRecords(){
        setTimeout(() => {
            GetRecords()
            .then((data) => {
                let tempRecs = [];

                data.forEach((d) => {
                    tempRecs.push(new Record(d, this));
                });

                this.records = tempRecs;
            }).finally(() => {
                this.getLogRecords();
                this.lastUpdate = new Date().toLocaleString();
            });
        }, 2000);
    }

    openPayment(recordId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                actionName: "view",
            },
        });
    }
}

class Record{
    data;
    root;
    paymentName = '';

    constructor(data, root){
        this.data = data;
        this.root = root;

        this.paymentName = this.data?.Payment__r?.Name;
    }

    openPayment = () => {
        this.root.openPayment(this.data.Payment__c);
    }
}