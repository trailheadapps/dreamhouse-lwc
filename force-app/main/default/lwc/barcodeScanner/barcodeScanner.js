import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';

export default class BarcodeScanner extends NavigationMixin(LightningElement) {
    myScanner;
    scanButtonEnabled = false;
    scannedQrCode = '';

    // When the component is initialized, determine whether to enable the Scan button
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner?.isAvailable()) {
            this.scanButtonEnabled = true;
        }
    }

    async handleBeginScanClick() {
        // Reset scannedQrCode to empty string before starting a new scan
        this.scannedQrCode = '';

        // Make sure BarcodeScanner is available before trying to use it
        // Scan QR Code button also disabled when scanner unavailable
        if (this.myScanner?.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR],
                instructionText: 'Scan a QR Code',
                successText: 'Scanning complete.'
            };

            // Try starting the scanning process, then using the result to navigate to a property record
            try {
                const captureResult = await this.myScanner.beginCapture(
                    scanningOptions
                );

                // Extract QR code data
                this.scannedQrCode = captureResult.value;

                // Navigate to the records page of the property with extracted ID
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.scannedQrCode,
                        objectApiName: 'Property__c',
                        actionName: 'view'
                    }
                });
            } catch (error) {
                // There was an error while scanning
                // We chose to handle errors with toasts to stay in line with the mobile experience
                // The user canceled the scan
                if (error.code === 'userDismissedScanner') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Scanning Canceled',
                            message: 'Scanning session canceled.',
                            mode: 'sticky'
                        })
                    );
                }

                // There was some other kind of error
                else {
                    // Inform the user we ran into something unexpected
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Barcode Scanner Error',
                            message:
                                'There was a problem scanning the QR code: ' +
                                error.message,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                }
            } finally {
                // Close capture process regardless of whether we completed successfully or had an error
                this.myScanner.endCapture();
            }
        }
    }
}
