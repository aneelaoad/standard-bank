/**
 * @description Test class for TRH_Resourcing
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
@IsTest
public with sharing class TRH_Resourcing_TEST {

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testBeforeInsert(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DMN_Resourcing resourcingDomainMock = (DMN_Resourcing) mocks.mock(DMN_Resourcing.class);
        fflib_InOrder inOrder = new fflib_InOrder(mocks, new List<Object>{
           resourcingDomainMock
        });
        mocks.startStubbing();
        mocks.when(resourcingDomainMock.sObjectType())
                .thenReturn(Resourcing__c.SObjectType);
        mocks.stopStubbing();
        ORG_Application.domain.setMock((fflib_ISObjectDomain)resourcingDomainMock);

        TRH_Resourcing handler = (TRH_Resourcing)TRH_Resourcing.class.newInstance();
        handler.resourcingDomain = resourcingDomainMock;
        handler.handleBeforeInsert();

        //Assertions are present in the following methods
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).sObjectType();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).setResource();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).setOwner();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).checkIfResourceIsTeamMember();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).checkIfUserCanAssignRecordsToOtherUsers();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).populateCompoundKeys();
    }

    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testBeforeUpdate(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        DMN_Resourcing resourcingDomainMock = (DMN_Resourcing) mocks.mock(DMN_Resourcing.class);
        fflib_InOrder inOrder = new fflib_InOrder(mocks, new List<Object>{
                resourcingDomainMock
        });
        mocks.startStubbing();
        mocks.when(resourcingDomainMock.sObjectType())
                .thenReturn(Resourcing__c.SObjectType);
        mocks.stopStubbing();
        ORG_Application.domain.setMock((fflib_ISObjectDomain)resourcingDomainMock);

        TRH_Resourcing handler = (TRH_Resourcing)TRH_Resourcing.class.newInstance();
        handler.resourcingDomain = resourcingDomainMock;
        handler.handleBeforeUpdate();

        //Assertions are present in the following methods
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).sObjectType();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).setResource();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).setOwner();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).checkIfResourceIsTeamMember();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).checkIfUserCanAssignRecordsToOtherUsers();
        ((DMN_Resourcing)inOrder.verify(resourcingDomainMock, mocks.calls(1))).populateCompoundKeys();
    }
}