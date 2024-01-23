public with sharing class EinsteinGenerativeGatewayService {
    /*
     * Invokes the Generative Generative API to generate a response for a prompt (/einstein/llm/generations)
     * Eg: System.debug(EinsteinGenerativeGatewayService.generateResponseFromPrompt('Give me information about Salesforce\'s Dreamhouse sample app', null, null));
     */
    public static String generateResponseFromPrompt(
        String prompt,
        String llmProvider,
        String model
    ) {
        // Create the input
        ConnectApi.EinsteinLlmGenerationsInput generationsInput = new ConnectApi.EinsteinLlmGenerationsInput();
        generationsInput.promptTextorId = prompt;
        generationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        generationsInput.additionalConfig.maxTokens = 512;
        generationsInput.additionalConfig.enablePiiMasking = true;
        if (llmProvider != null) {
            generationsInput.provider = llmProvider;
            if (model != null) {
                generationsInput.additionalConfig.model = model;
            }
        }

        // Call the service
        ConnectApi.EinsteinLLMGenerationsOutput generationsOutput = ConnectApi.EinsteinLLM.generateMessages(
            generationsInput
        );

        // Consume response
        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
        return response.text;
    }

    /*
     * Invokes the Generative Generative API to generate an embedding (/einstein/llm/embeddings)
     * Embeddings are vector mathematical representations that measure the relatedness of text strings.
     * They are commonly used for semantic search, recommendations, classification and more.
     * Eg: System.debug(EinsteinGenerativeGatewayService.generateEmbeddingsFromPrompts(new List<String>{'run','sprint','race','dart', 'rush'}, null, null));
     */
    public static ConnectApi.EinsteinLLMEmbeddingsOutput generateEmbeddingsFromPrompts(
        List<String> prompts,
        String llmProvider,
        String model
    ) {
        // Create input
        ConnectApi.EinsteinLlmEmbeddingsInput embeddingsInput = new ConnectApi.EinsteinLlmEmbeddingsInput();
        embeddingsInput.prompts = prompts;
        embeddingsInput.additionalConfig = new ConnectApi.EinsteinLlmEmbeddingsAdditionalConfigInput();
        embeddingsInput.additionalConfig.enablePiiMasking = true;
        if (llmProvider != null) {
            embeddingsInput.provider = llmProvider;
            if (model != null) {
                embeddingsInput.additionalConfig.model = model;
            }
        }

        // Call the service
        return ConnectApi.EinsteinLLM.createEmbeddings(embeddingsInput);
    }
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
     * Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, Object>();
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
     * System.debug(EinsteinGenerativeGatewayService.generateResponseFromPromptTemplate('0hfHr000000XZLUIA4', inputParams, null, null));
     */
    public static String generateResponseFromPromptTemplate(
        String promptTemplateDeveloperName,
        Map<String, ConnectApi.WrappedValue> inputParams,
        String llmProvider,
        String model
    ) {
        // Create input
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.enablePiiMasking = true;

        if (llmProvider != null) {
            executeTemplateInput.provider = llmProvider;
            if (model != null) {
                executeTemplateInput.additionalConfig.model = model;
            }
        }

        // Set additional values
        executeTemplateInput.isPreview = false;
        executeTemplateInput.inputParams = inputParams;

        // Call the service
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
            promptTemplateDeveloperName,
            executeTemplateInput
        );

        // Consume response
        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
        return response.text;
    }

    /*
     * Invokes the Generative Generative API to generate feedback for a generated response
     * Eg: Having a ConnectApi.EinsteinLLMGenerationItemOutput response:
     *
     * ConnectApi.EinsteinLlmFeedbackInput feedbackInput = new ConnectApi.EinsteinLlmFeedbackInput();
     * feedbackInput.id = 'connect-api-feedback-1';
     * feedbackInput.generationId = responseId;
     * feedbackInput.feedbackText = 'This is feedback text';
     * feedbackInput.source = 'HUMAN';
     *
     * System.debug(EinsteinGenerativeGatewayService.giveFeedbackForResponse(response.responseId, feedbackInput));
     */
    // public static String giveFeedbackForResponse(String responseId, ConnectApi.EinsteinLlmFeedbackInput feedbackInput) {
    //     // Create feedback input

    //     // Create `appFeedback` map (within feedback input)
    //     Map<String, ConnectApi.WrappedValue> appFeedback = new Map<String, ConnectApi.WrappedValue>();

    //     // Create `feedack_detail` map (within appFeedback)
    //     ConnectApi.WrappedValue feedbackDetail = new ConnectApi.WrappedValue();
    //     Map<String, String> detailValue = new Map<String, String>{'action' => 'thumbs-up'};
    //     feedbackDetail.value = detailValue;

    //     // Add `feedback_detail` to appFeedback
    //     appFeedback.put('feedback_detail', feedbackDetail);
    //     feedbackInput.appFeedback = appFeedback;

    //     // Consume feedback response
    //     ConnectApi.InlineResponse202 feedbackOutput = ConnectApi.EinsteinLLM.feedback(feedbackInput);
    //     return feedbackOutput.message;
    // }
}
