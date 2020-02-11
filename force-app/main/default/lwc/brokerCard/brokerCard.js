import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import BROKER_FIELD from '@salesforce/schema/Property__c.Broker__c';
import NAME_FIELD from '@salesforce/schema/Broker__c.Name';
import PHONE_FIELD from '@salesforce/schema/Broker__c.Phone__c';
import MOBILE_PHONE_FIELD from '@salesforce/schema/Broker__c.Mobile_Phone__c';
import EMAIL_FIELD from '@salesforce/schema/Broker__c.Email__c';

const PROPERTY_FIELDS = [BROKER_FIELD];
const BROKER_FIELDS = [
    NAME_FIELD,
    PHONE_FIELD,
    MOBILE_PHONE_FIELD,
    EMAIL_FIELD
];

export default class BrokerCard extends NavigationMixin(LightningElement) {
    @api recordId;

    brokerFields = BROKER_FIELDS;

    @wire(getRecord, { recordId: '$recordId', fields: PROPERTY_FIELDS })
    property;

    get brokerId() {
        return getFieldValue(this.property.data, BROKER_FIELD);
    }

    handleNavigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.brokerId,
                objectApiName: 'Property__c',
                actionName: 'view'
            }
        });
    }
}
