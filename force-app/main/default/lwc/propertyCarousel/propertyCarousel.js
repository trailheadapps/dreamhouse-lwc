import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getPictures from '@salesforce/apex/PropertyController.getPictures';

import ADDRESS_FIELD from '@salesforce/schema/Property__c.Address__c';
import CITY_FIELD from '@salesforce/schema/Property__c.City__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Property__c.Description__c';

const FIELDS = [ADDRESS_FIELD, CITY_FIELD, DESCRIPTION_FIELD];

export default class PropertyCarousel extends LightningElement {
    @api recordId;

    urls;

    pictures;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    property;

    @wire(getPictures, { propertyId: '$recordId' })
    wiredPictures(pictures) {
        this.pictures = pictures;
        if (pictures.data) {
            const files = pictures.data;
            if (Array.isArray(files) && files.length) {
                this.urls = files.map(
                    (file) =>
                        '/sfc/servlet.shepherd/version/download/' + file.Id
                );
            } else {
                this.urls = null;
            }
        }
    }

    get address() {
        return getFieldValue(this.property.data, ADDRESS_FIELD);
    }

    get city() {
        return getFieldValue(this.property.data, CITY_FIELD);
    }

    get description() {
        return getFieldValue(this.property.data, DESCRIPTION_FIELD);
    }

    get errors() {
        const errors = [this.property.error, this.pictures.error].filter(
            (error) => error
        );
        return errors.length ? errors : null;
    }

    handleUploadFinished() {
        refreshApex(this.pictures);
    }
}
