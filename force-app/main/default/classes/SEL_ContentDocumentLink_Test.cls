/**
 * @description       :
 * @author            : silva.macaneta@standardbank.co.za
 * @group             :
 * @last modified on  : 10-06-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
@isTest
public class SEL_ContentDocumentLink_Test {
  @TestSetup
  static void createData() {
    final Account a = new Account();
    a.Name = 'test';
    insert a;

    final contentversion conVer = new contentversion();
    conVer.Title = 'test';
    conVer.PathOnClient = 'test';
    conVer.VersionData = Blob.valueOf('test');
    insert conVer;

    final ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :conVer.Id
    ]
    .ContentDocumentId;
    cdl.LinkedEntityId = a.Id;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;
  }

  @isTest
  static void testSelectByLinkedEntityId() {
    final ContentDocumentLink cdl = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (SELECT Id FROM Account)
      LIMIT 1
    ];
    final SEL_ContentDocumentLink selector = SEL_ContentDocumentLink.newInstance();
    final List<ContentDocumentLink> result = selector.selectByLinkedEntityId(
      new Set<Id>{ cdl.LinkedEntityId }
    );
    final fflib_QueryFactory lastQuery = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      lastQuery.getCondition()
        .containsIgnoreCase('LinkedEntityId IN: linkedEntityId'),
      'Expected condition to contain "LinkedEntityId IN :linkedEntityIds"'
    );
  }
  @isTest
  static void testSelectByLinkedEntityIdAllFields() {
    final ContentDocumentLink cdl = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (SELECT Id FROM Account)
      LIMIT 1
    ];
    final SEL_ContentDocumentLink selector = SEL_ContentDocumentLink.newInstance();
    final List<ContentDocumentLink> result = selector.selectByLinkedEntityIdAllFields(
      new Set<Id>{ cdl.LinkedEntityId }
    );
    final fflib_QueryFactory lastQuery = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      lastQuery.getCondition()
        .containsIgnoreCase('LinkedEntityId IN: linkedEntityId'),
      'Expected condition to contain "LinkedEntityId IN :linkedEntityIds"'
    );
  }
  @isTest
  static void testSelectByContentDocumentId() {
    final ContentDocumentLink cdl = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (SELECT Id FROM Account)
      LIMIT 1
    ];
    final SEL_ContentDocumentLink selector = SEL_ContentDocumentLink.newInstance();
    final List<ContentDocumentLink> result = selector.selectByContentDocumentId(
      new Set<Id>{ cdl.ContentDocumentId }
    );
    final fflib_QueryFactory lastQuery = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      lastQuery.getCondition()
        .containsIgnoreCase('ContentDocumentId IN: contentDocumentId'),
      'Expected condition to contain "ContentDocumentId IN: contentDocumentId"'
    );
  }
  @isTest
  static void testSelectRecordByContentDocumentId() {
    final ContentDocumentLink cdl = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (SELECT Id FROM Account)
      LIMIT 1
    ];
    final SEL_ContentDocumentLink selector = SEL_ContentDocumentLink.newInstance();
    final List<ContentDocumentLink> result = selector.selectRecordByContentDocumentId(
      cdl.ContentDocumentId
    );
    final fflib_QueryFactory lastQuery = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      lastQuery.getCondition()
        .containsIgnoreCase('ContentDocumentId =: contentDocumentId'),
      'Expected condition to contain "ContentDocumentId =: contentDocumentId"'
    );
  }
  @isTest
  static void testSelectByStringLinkEntityId() {
    final ContentDocumentLink cdl = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (SELECT Id FROM Account)
      LIMIT 1
    ];
    final SEL_ContentDocumentLink selector = SEL_ContentDocumentLink.newInstance();
    final List<ContentDocumentLink> result = selector.selectByStringLinkEntityId(
      cdl.LinkedEntityId
    );
    final fflib_QueryFactory lastQuery = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      lastQuery.getCondition()
        .containsIgnoreCase('LinkedEntityId =: linkedEntityId'),
      'Expected condition to contain "LinkedEntityId =: linkedEntityId"'
    );
  }
  @isTest
  static void testSelectByListLinkEntityId() {
    final ContentDocumentLink cdl = [
      SELECT Id, LinkedEntityId, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN (SELECT Id FROM Account)
      LIMIT 1
    ];
    final SEL_ContentDocumentLink selector = SEL_ContentDocumentLink.newInstance();
    final List<ContentDocumentLink> result = selector.selectByListLinkEntityId(
      new List<Id>{ cdl.LinkedEntityId }
    );
    final fflib_QueryFactory lastQuery = fflib_QueryFactory.lastQueryFactory;
    Assert.areEqual(
      true,
      lastQuery.getCondition()
        .containsIgnoreCase('LinkedEntityId =: recordIds'),
      'Expected condition to contain "LinkedEntityId =: recordIds"'
    );
  }
}