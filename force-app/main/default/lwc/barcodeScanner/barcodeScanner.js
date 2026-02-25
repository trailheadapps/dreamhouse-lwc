import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';

export default class BarcodeScanner extends NavigationMixin(LightningElement) {
    myScanner;
    scanButtonEnabled = false;
    scannedQrCode = '';

    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner?.isAvailable()) {
            this.scanButtonEnabled = true;
        }
    }

    disconnectedCallback() {
        if (this.myScanner?.isAvailable()) {
            this.scanButtonEnabled = false;
        }
    }

    async handleBeginScanClick() {
        this.scannedQrCode = '';

        if (this.myScanner?.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR],
                instructionText: 'Scan a QR Code',
                successText: 'Scanning complete.'
            };

            try {
                const captureResult = await this.myScanner.beginCapture(scanningOptions);
                this.scannedQrCode = captureResult.value;

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.scannedQrCode,
                        objectApiName: 'Property__c',
                        actionName: 'view'
                    }
                });
            } catch (error) {
                if (error.code === 'userDismissedScanner') {
                    this.dispatchEvent(
                        new ShowToastEvent({
