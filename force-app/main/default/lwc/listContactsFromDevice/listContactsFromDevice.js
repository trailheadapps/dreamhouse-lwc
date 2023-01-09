import { LightningElement } from 'lwc';
import { getContactsService } from 'lightning/mobileCapabilities';

export default class ListContactsFromDevice extends LightningElement {
    async connectedCallback() {
        const myContactsService = getContactsService();
        if (myContactsService.isAvailable()) {
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
            this.deviceContacts = await this.myContactsService.getContacts(
                options
            );
        } catch (error) {
            this.error = error;
        }
    }
}
