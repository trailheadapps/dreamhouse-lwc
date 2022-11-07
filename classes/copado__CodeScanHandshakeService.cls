/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/CodeScanHandshake')
global class CodeScanHandshakeService {
    global CodeScanHandshakeService() {

    }
    @HttpGet
    global static List<copado.CodeScanHandshakeService.CodeScanResponse> handshakeAndReturnEncryptedToken() {
        return null;
    }
global class CodeScanResponse {
    global String errorCode {
        get;
        set;
    }
    global String message {
        get;
        set;
    }
    global CodeScanResponse() {

    }
}
}
