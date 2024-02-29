public with sharing class EinsteinGenerativeGatewayService {
    /*
     * Invokes the Generative Generative API to generate a response based on a prompt template (/einstein/prompt-templates/${promptTemplateDevName}/generations)
     * To execute a prompt template, you need to specify its related records.
     * For Sales Email templates:
     *  - Contact or Lead (the recipient)
     *  - Related object (optional)
     * For Field Generation Template:
     *  - Object
     * Eg: This is an example of inputParams for a Sales Email template that uses the lead Name and its Owner:
     *
     * Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
     * Map<String, Object> lead = new Map<String, Object>();
     * Map<String, Object> owner = new Map<String, Object>();
     * lead.put('Id', '001xxx');
     * lead.put('Name', 'My New Business');
     * owner.put('Id', '003xxx');
     * lead.put('Owner__r', owner);
     *
     * ConnectApi.WrappedValue leadValue = new ConnectApi.WrappedValue();
     * leadValue.value = lead;
     * inputParams.put('lead', lead);
     * ConnectApi.WrappedValue replyEmailIdValue = new ConnectApi.WrappedValue();
     * replyEmailIdValue.value = '00xxxx';
     * inputParams.put('replyEmailId', replyEmailIdValue);
     *
     * System.debug(EinsteinGenerativeGatewayService.generateResponseFromPromptTemplate('0hfHr000000XZLUIA4', inputParams));
     */
    public static String generateResponseFromPromptTemplate(
        String promptTemplateDeveloperName,
        Map<String, ConnectApi.WrappedValue> inputParams
    ) {
        // Create input
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';

        // Set additional values
        executeTemplateInput.isPreview = false;
        executeTemplateInput.inputParams = inputParams;

        try {
            // Call the service
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                promptTemplateDeveloperName,
                executeTemplateInput
            );
            ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
            return response.text;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw e;
        }
    }
}
