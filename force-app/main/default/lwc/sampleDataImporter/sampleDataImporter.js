import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import importSampleData from '@salesforce/apex/SampleDataController.importSampleData';

export default class SampleDataImporter extends LightningElement {
    handleImportSampleData() {
        importSampleData()
            .then(() => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Sample data successfully imported',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            })
            .catch((e) => {
                const evt = new ShowToastEvent({
                    title: 'Error while importing data',
                    message: e.message,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            });
    }
}
