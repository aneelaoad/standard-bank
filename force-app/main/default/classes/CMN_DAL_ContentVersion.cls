/**
 * @description Provides Query methods related to ContentVersion object
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_ContentVersion
{
	/**
	 * @description Queries ContentVersion for all the times linked to the given firstPublishLocationId
	 *
	 * @param firstPublishLocationId ID of the location where the version was first published.
	 *
	 * @return List of Content Version; note this only queries for latest version
	 */
	@TestVisible
	private static List<ContentVersion> findByFirstPublishLocationId(Id firstPublishLocationId)
	{
		return
		[
				SELECT
						ContentBodyId,
						ContentDocumentId,
						ContentLocation,
						ContentSize,
						ContentUrl,
						Description,
						FileExtension,
						FileType,
						Id,
						PathOnClient,
						Title,
						VersionData
				FROM ContentVersion
				WHERE FirstPublishLocationId = :firstPublishLocationId
				AND IsLatest = TRUE
		];
	}
}