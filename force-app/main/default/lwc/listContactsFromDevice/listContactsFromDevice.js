import { LightningElement } from 'lwc';
import { getContactsService } from 'lightning/mobileCapabilities';

export default class ListContactsFromDevice extends LightningElement {
    contactsService;
    deviceContacts;
    error;

    async connectedCallback() {
        this.contactsService = getContactsService();
        if (this.contactsService.isAvailable()) {
            await this.retrieveDeviceContacts();
        } else {
            this.error = { message: 'Contact service not available' };
        }
    }

    async retrieveDeviceContacts() {
        const options = {
            permissionRationaleText:
                'Allow access to your contacts to enable contacts processing.'
        };

        try {
            this.deviceContacts =
                await this.contactsService.getContacts(options);
        } catch (error) {
            this.error = error;
        }
    }
}
