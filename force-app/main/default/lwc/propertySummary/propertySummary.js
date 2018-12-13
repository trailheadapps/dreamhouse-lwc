import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import NAME_FIELD from '@salesforce/schema/Property__c.Name';
import BED_FIELD from '@salesforce/schema/Property__c.Beds__c';
import BATH_FIELD from '@salesforce/schema/Property__c.Baths__c';
import PRICE_FIELD from '@salesforce/schema/Property__c.Price__c';
import BROKER_FIELD from '@salesforce/schema/Property__c.Broker__c';
import PICTURE_FIELD from '@salesforce/schema/Property__c.Picture__c';

export default class PropertySummary extends NavigationMixin(LightningElement) {
    @api recordId;
    @track propertyFields = [BED_FIELD, BATH_FIELD, PRICE_FIELD, BROKER_FIELD];

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD, PICTURE_FIELD],
    })
    property;

    get propertyName() {
        return getFieldValue(this.property.data, NAME_FIELD);
    }

    get pictureURL() {
        return getFieldValue(this.property.data, PICTURE_FIELD);
    }

    connectedCallback() {
        registerListener(
            'dreamhouse__propertySelected',
            this.handlePropertySelected,
            this,
        );
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handlePropertySelected(propertyId) {
        this.recordId = propertyId;
    }

    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Property__c',
                actionName: 'view',
            },
        });
    }
}
