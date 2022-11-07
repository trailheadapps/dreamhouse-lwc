<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>copado__Deployment_Completed_email_alert</fullName>
        <description>Deployment Completed email alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>copado__Copado_Deployer/copado__NewDeploymentResultSummary</template>
    </alerts>
    <fieldUpdates>
        <fullName>copado__Send_deployment_command</fullName>
        <field>copado__Deployment_command_sent__c</field>
        <formula>now()</formula>
        <name>Send deployment command</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>copado__Deployment Completed</fullName>
        <actions>
            <name>copado__Deployment_Completed_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>copado__Deployment__c.copado__Send_Deployment_Complete_email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Deployment__c.copado__Status__c</field>
            <operation>equals</operation>
            <value>Completed Successfully,Completed with Errors,Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>notEqual</operation>
            <value>Automated Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Deployment__c.copado__Platform__c</field>
            <operation>equals</operation>
            <value>Salesforce</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Deployment__c.copado__Platform__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>copado__Deployment Time</fullName>
        <active>false</active>
        <criteriaItems>
            <field>copado__Deployment__c.copado__Status__c</field>
            <operation>equals</operation>
            <value>Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Deployment__c.copado__Schedule__c</field>
            <operation>equals</operation>
            <value>Deploy later</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>copado__Deployment_scheduled</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>copado__Deployment__c.copado__Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Deployment scheduled</subject>
    </tasks>
</Workflow>
