import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';

export default class BarcodeScannerExample extends NavigationMixin(
    LightningElement
) {
    myScanner;
    scanButtonDisabled = true;
    scannedQrCode = '';

    // When component is initialized, detect whether to enable Scan button
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner || this.myScanner.isAvailable()) {
            this.scanButtonDisabled = false;
        }
    }

    handleBeginScanClick() {
        // Reset scannedQrCode to empty string before starting new scan
        this.scannedQrCode = '';

        // Make sure BarcodeScanner is available before trying to use it
        // Note: We _also_ disable the Scan button if there's no BarcodeScanner
        if (this.myScanner && this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR],
                instructionText: 'Scan a QR Code',
                successText: 'Scanning complete.'
            };

            // TODO: Now that it's async await I'm getting a linter warning that the function is not returning anything? Do I disable it?
            // eslint-disable-next-line consistent-return
            (async () => {
                try {
                    const captureResult = await this.myScanner.beginCapture(
                        scanningOptions
                    );

                    // Extract QR Code data
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

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Successful Scan',
                            message: 'Property QR code scanned successfully.',
                            variant: 'success'
                        })
                    );

                    return captureResult;
                } catch (error) {
                    console.error(error);

                    if (error.code === 'userDismissedScanner') {
                        // User clicked Cancel
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Scanning Cancelled',
                                message: 'You cancelled the scanning session.',
                                mode: 'sticky'
                            })
                        );
                    } else {
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
                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                }

                return 1;
            })();
        } else {
            // BarcodeScanner is not available
            // Not running on hardware with a camera, or some other context issue
            // Let user know they need to use a mobile phone with a camera
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'QR Code Scanner Is Not Available',
                    message:
                        'Try again from the Salesforce app on a mobile device.',
                    variant: 'error'
                })
            );
        }
    }
}
