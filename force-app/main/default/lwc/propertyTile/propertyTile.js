import { LightningElement, api } from 'lwc';

export default class PropertyTile extends LightningElement {
    @api property;

    handlePropertySelected() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.property.Id
        });
        this.dispatchEvent(selectedEvent);
    }

    get backgroundImageStyle() {
        return `background-image:url(${this.property.Thumbnail__c})`;
    }
}
