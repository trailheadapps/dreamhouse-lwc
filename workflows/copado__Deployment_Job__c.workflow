<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>copado__Set_DJ_Status_to_Failed</fullName>
        <field>copado__Status__c</field>
        <literalValue>Failed</literalValue>
        <name>Set DJ Status to Failed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>copado__Set_DJ_Status_to_Success</fullName>
        <field>copado__Status__c</field>
        <literalValue>Success</literalValue>
        <name>Set DJ Status to Success</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>copado__Mark Early Job Completion as Failed</fullName>
        <actions>
            <name>copado__Set_DJ_Status_to_Failed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>copado__Deployment_Job__c.copado__Status__c</field>
            <operation>equals</operation>
            <value>In progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Deployment_Job__c.copado__Early_Completion_Status__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>copado__Mark Early Job Completion as Success</fullName>
        <actions>
            <name>copado__Set_DJ_Status_to_Success</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>copado__Deployment_Job__c.copado__Status__c</field>
            <operation>equals</operation>
            <value>In progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>copado__Deployment_Job__c.copado__Early_Completion_Status__c</field>
            <operation>equals</operation>
            <value>Success</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
