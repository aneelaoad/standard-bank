/**
 * 
 * @description Controller Class for Mall Product Front Management
 * @author Maham Hassan
 * @since 
 */
public with sharing class MallProductFrontManagementController {

    public static List <Offering__c> newProducts = new List <Offering__c> ();

    /**
     * 
     * @description : getProducts 
     *  @param accountId Id
     *  @return : List<productInfo>
     */
    @AuraEnabled
    public static List <productInfo> getProducts(Id accountId) {
        try {
            String whereClause = ' ( Related_Client__c IN (\'' + String.join(new List <String> {
                accountId
            }, '\',\'') + '\') AND Parent_Provider__c = NULL )';
            List <Provider__c> providers = SEL_Providers.newInstance().selectByCustomFilterCondition(whereClause);

            if (providers == NULL || providers.size() == 0) {
                return NULL;
            }

            Provider__c associatedProvider = new Provider__c();
            associatedProvider = providers[0];

            List <Offering__c> products = [Select Id, Name, Link__c, Publishing_Unit__c, Link__r.Desktop_Url__c, Publishing_Unit__r.Published_until__c, Status__c, Provider__c, IsOnline__c, LastModifiedBy.Name, CreatedDate,
                Publishing_Unit__r.Published_from__c, Comments__c, Parent_Offering__c, Provider__r.IsOnline__c,
                (Select Id, Image_Url__c, Text__c, RichText__c From Translations__r),
                (Select Id, Status__c, Parent_Offering__c From Offerings__r),
                (Select Id, Tag__c, Tag__r.Parent_Name__c From Tag_Offerings__r Where Tag__r.parent_name__c in ('Segment', 'Category')) From Offering__c Where Provider__c =: associatedProvider.Id AND Parent_Offering__c = NULL
            ];
            List <ProductInfo> productsInfos = new List <ProductInfo> ();
            for (Offering__c prod: products) {
                ProductInfo prodInfo = new ProductInfo();
                prodInfo.shopPublished = prod.Provider__r.IsOnline__c;
                prodInfo.productId = prod.Id;
                prodInfo.name = prod.Name;
                for (Tag_Offering__c tagProduct: prod.Tag_Offerings__r) {
                    if (tagProduct.Tag__r.parent_name__c == 'Segment') {
                        prodInfo.segmentId = tagProduct.Tag__c;
                        prodInfo.segmentTagProductId = tagProduct.Id;
                    } else {
                        prodInfo.categoryIds.add(tagProduct.Tag__c);
                        prodInfo.categoryTagProductId = tagProduct.Id;
                    }
                }

                for (Offering__c clonedProduct: prod.Offerings__r) {
                    prodInfo.clonedProductStatus = clonedProduct.Status__c;
                    prodInfo.parentProductId = clonedProduct.Parent_Offering__c;
                }
                prodInfo.publishedFrom = prod.Publishing_Unit__r.Published_from__c;
                prodInfo.publishedUntil = prod.Publishing_Unit__r.Published_until__c;
                prodInfo.productUrl = prod.Link__r.Desktop_Url__c;
                if (prod.Translations__r.size()> 0) {
                    prodInfo.cutId = prod.Translations__r[0].Id;
                    prodInfo.imageUrl = prod.Translations__r[0].Image_Url__c;
                    prodInfo.shortDesc = prod.Translations__r[0].Text__c;
                    prodInfo.longDesc = prod.Translations__r[0].RichText__c;
                }
                prodInfo.publishingUnitId = prod.Publishing_Unit__c;
                prodInfo.productStatus = prod.Status__c;
                prodInfo.linkId = prod.Link__c;
                prodInfo.comment = prod.Comments__c;
                prodInfo.accountId = accountId;
                prodInfo.providerId = prod.Provider__c;
                prodInfo.imageUploaded = prodInfo.imageUrl != NULL ? true : false;
                prodInfo.online = prod.IsOnline__c;
                prodInfo.createdDate = prod.CreatedDate;
                prodInfo.lastModifiedBy = prod.LastModifiedBy.Name;
                prodInfo.mallProductUrl = '/offering/' + prod.Id;
                productsInfos.add(prodInfo);
            }
            return productsInfos;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.getProducts', e);
        }
    }

    /**
     * 
     * @description : getProductById 
     *  @param serviceId Id
     *  @return : productInfo
     */
    @AuraEnabled
    public static ProductInfo getProductById(Id serviceId) {
        try {
            List <Offering__c> products = [Select Id, Name, Link__c, Publishing_Unit__c, Link__r.Desktop_Url__c, Publishing_Unit__r.Published_until__c, Status__c, Provider__c, Provider__r.Name, OwnerId, Owner.Name,
                Publishing_Unit__r.Published_from__c, Comments__c, Parent_Offering__c, Provider__r.IsOnline__c, Provider__r.Related_Client__c, CreatedDate, LastModifiedDate, LastModifiedBy.Name, IsOnline__c,
                (Select Id, Image_Url__c, Text__c, RichText__c From Translations__r),
                (Select Id, Status__c, Parent_Offering__c From Offerings__r),
                (Select Id, Tag__c, Tag__r.Parent_Name__c From Tag_Offerings__r Where Tag__r.parent_name__c IN('Segment', 'Category')) From Offering__c Where Id =: serviceId
            ];
            List <ProductInfo> productsInfos = new List <ProductInfo> ();
            for (Offering__c prod: products) {
                ProductInfo prodInfo = new ProductInfo();
                prodInfo.shopPublished = prod.Provider__r.IsOnline__c;
                prodInfo.productId = prod.Id;
                prodInfo.name = prod.Name;
                for (Tag_Offering__c tagProduct: prod.Tag_Offerings__r) {
                    if (tagProduct.Tag__r.parent_name__c == 'Segment') {
                        prodInfo.segmentId = tagProduct.Tag__c;
                        prodInfo.segmentTagProductId = tagProduct.Id;
                    } else {
                        prodInfo.categoryIds.add(tagProduct.Tag__c);
                        prodInfo.categoryTagProductId = tagProduct.Id;
                    }
                }

                for (Offering__c clonedProduct: prod.Offerings__r) {
                    prodInfo.clonedProductStatus = clonedProduct.Status__c;
                    prodInfo.parentProductId = clonedProduct.Parent_Offering__c;
                }
                prodInfo.online = (prod.IsOnline__c && prod.Status__c == 'Published') ? true : false;
                prodInfo.createdDate = prod.CreatedDate;
                prodInfo.lastModifiedBy = prod.LastModifiedBy.Name;
                prodInfo.lastModifiedDate = prod.LastModifiedDate;
                prodInfo.publishedFrom = prod.Publishing_Unit__r.Published_from__c;
                prodInfo.publishedUntil = prod.Publishing_Unit__r.Published_until__c;
                prodInfo.productUrl = prod.Link__r.Desktop_Url__c;
                prodInfo.mallProductUrl = '/offering/' + prod.Id;
                if (prod.Translations__r.size()> 0) {
                    prodInfo.cutId = prod.Translations__r[0].Id;
                    prodInfo.imageUrl = prod.Translations__r[0].Image_Url__c;
                    prodInfo.shortDesc = prod.Translations__r[0].Text__c;
                    prodInfo.longDesc = prod.Translations__r[0].RichText__c;
                }
                prodInfo.publishingUnitId = prod.Publishing_Unit__c;
                prodInfo.productStatus = prod.Status__c;
                prodInfo.linkId = prod.Link__c;
                prodInfo.comment = prod.Comments__c;
                prodInfo.accountId = prod.Provider__r.Related_Client__c;
                prodInfo.providerId = prod.Provider__c;
                prodInfo.imageUploaded = prodInfo.imageUrl != NULL ? true : false;
                prodInfo.storeName = prod.Provider__r.Name;
                prodInfo.ownerId = prod.OwnerId;
                prodInfo.ownerName = prod.Owner.Name;
                productsInfos.add(prodInfo);
            }
            if (productsInfos.size()> 0) {
                return productsInfos[0];
            } else {
                return NULL;
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.getProductById', e);
        }
    }

    /**
     * 
     * @description : saveProduct 
     *  @param productInfoStrings List<String>
     */
    @AuraEnabled
    public static void saveProduct(List <String> productInfoStrings) {
        try {
            Id serviceRecordTypeId = Schema.getGlobalDescribe().get('Offering__c').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
            List <ProductInfo> infos = new List <ProductInfo> ();
            for (String stringInfo: productInfoStrings) {
                infos.add((ProductInfo) JSON.deserialize(stringInfo, ProductInfo.class));
            }
            Tag__c langTag;
            Tag__c countryTag;
            List <String> tagNames = new List <String> {
                'en',
                'South Africa'
            };
            Set <String> tagNamesSet = new Set <String> ();
            tagNamesSet.addAll(tagNames);
            for (Tag__c tag: SEL_Tags.newInstance().selectTagsByNames(tagNamesSet)) {
                if (tag.Name == 'en') {
                    langTag = tag;
                } else if (tag.Parent_Name__c == 'Country') {
                    countryTag = tag;
                }
            }
            List <Link__c> linksToInsert = new List <Link__c> ();
            List <Publishing_Unit__c> publishingUnitsToInsert = new List <Publishing_Unit__c> ();
            List <Offering__c> productsToInsert = new List <Offering__c> ();
            List <Tag_Offering__c> tagProductsToInsert = new List <Tag_Offering__c> ();
            List <Content_Unit_Translation__c> cutsToInsert = new List <Content_Unit_Translation__c> ();
            List <Id> existingProductIds = new List <Id> ();
            for (productInfo info: infos) {
                if (info.productId == NULL) {
                    linksToInsert.add(new Link__c(Name = info.name + ' store link', Desktop_url__c = info.productUrl, Mobile_Url__c = info.productUrl, Guest_Url__c = info.productUrl));
                    publishingUnitsToInsert.add(new Publishing_Unit__c(Published_from__c = info.publishedFrom, Published_until__c = info.publishedUntil));
                } else {
                    existingProductIds.add(info.productId);
                }
            }
            insert linksToInsert;
            insert publishingUnitsToInsert;
            if (!linksToInsert.isEmpty() && !publishingUnitsToInsert.isEmpty()) {
                Integer i = 0;
                for (productInfo info: infos) {
                    if (info.productId == NULL) {
                        productsToInsert.add(new Offering__c(Name = info.name, Status__c = 'Draft', comments__c = info.comment, Provider__c = info.providerId, Link__c = linksToInsert[i].Id, Publishing_Unit__c = publishingUnitsToInsert[i].Id, RecordTypeID = serviceRecordTypeId));
                        i++;
                    }
                }
                insert productsToInsert;
                newProducts = productsToInsert;
                Integer j = 0;
                for (productInfo info: infos) {
                    if (info.productId == NULL) {
                        for (String categoryId: info.categoryIds) {
                            tagProductsToInsert.add(new Tag_Offering__c(Tag__c = categoryId, Offering__c = productsToInsert[j].Id));
                        }
                        tagProductsToInsert.add(new Tag_Offering__c(Tag__c = info.segmentId, Offering__c = productsToInsert[j].Id));
                        tagProductsToInsert.add(new Tag_Offering__c(Tag__c = countryTag.Id, Offering__c = productsToInsert[j].Id));

                        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
                        cut.Product__c = productsToInsert[j].Id;
                        if (info.uploadedImageUrl != NULL) {
                            cut.Image_Url__c = info.uploadedImageUrl;
                        }
                        cut.Title__c = info.name;
                        cut.Text__c = info.shortDesc;
                        cut.RichText__c = info.longDesc;
                        cut.Language__c = langTag.Id;
                        cutsToInsert.add(cut);
                        j++;
                    }
                }
                insert cutsToInsert;
            }
            if (!existingProductIds.isEmpty()) {
                List <Sobject> sobjectsToUpdate = new List <Sobject> ();
                Map <Id, Content_Unit_Translation__c> productIdVsCut = new Map <Id, Content_Unit_Translation__c> ();
                List <Tag_Offering__c> tagProductsToDelete = [Select Id, Tag__c, Tag__r.parent_name__c From Tag_Offering__c Where Offering__c in: existingProductIds
                    And Tag__r.parent_name__c in ('Segment', 'Category')
                ];
                delete tagProductsToDelete;
                String whereClause = ' Product__c IN (\'' + String.join(existingProductIds, '\',\'') + '\') And Language_ISO__c=\'en\' ';
                for (Content_Unit_Translation__c cut: SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause)) {
                    productIdVsCut.put(cut.Product__c, cut);
                }
                for (ProductInfo info: infos) {
                    if (info.productId != NULL) {
                        sobjectsToUpdate.add(new Offering__c(Name = info.name, Status__c = 'Draft', Id = info.productId, comments__c = info.comment));
                        sobjectsToUpdate.add(new Link__c(Name = info.name + ' store link', Id = info.linkId, Desktop_Url__c = info.productUrl, Mobile_Url__c = info.productUrl, Guest_Url__c = info.productUrl));
                        sobjectsToUpdate.add(new Publishing_Unit__c(Id = info.publishingUnitId, Published_from__c = info.publishedFrom, Published_until__c = info.publishedUntil));
                        for (String categoryId: info.categoryIds) {
                            tagProductsToInsert.add(new Tag_Offering__c(tag__c = categoryId, Offering__c = info.productId));
                        }
                        if (info.uploadedImageUrl != NULL && productIdVsCut.containsKey(info.productId)) {
                            sobjectsToUpdate.add(new Content_Unit_Translation__c(Id = productIdVsCut.get(info.productId).Id, Image_Url__c = info.uploadedImageUrl, Text__c = info.shortDesc, RichText__c = info.longDesc, Title__c = info.name));
                        }

                    }

                }
                update sobjectsToUpdate;
            }
            insert tagProductsToInsert;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.saveProduct', e);
        }
    }


    /**
     * 
     * @description : submitForApproval 
     *  @param productInfoStrings List<String>
     */
    @AuraEnabled
    public static void submitForApproval(List <String> productInfoStrings) {
        try {
            List <Approval.ProcessSubmitRequest> requests = new List <Approval.ProcessSubmitRequest> ();
            Map <Id, String> productIdVsName = new Map <Id, String> ();
            saveProduct(productInfoStrings);
            Id storeManagerProfileId = Test.isRunningTest() ? UserInfo.getProfileId() : [Select Id, Name From Profile Where Name =: System.Label.Store_Manager_Profile Limit 1].Id;
            List <ProductInfo> infos = new List <ProductInfo> ();
            for (String stringInfo: productInfoStrings) {
                infos.add((ProductInfo) JSON.deserialize(stringInfo, ProductInfo.class));
            }
            for (ProductInfo info: infos) {
                if (info.productId != NULL) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(info.comment);
                    req.setObjectId(info.productId);
                    req.setSubmitterId(UserInfo.getUserId());
                    if (UserInfo.getProfileId() == storeManagerProfileId) {
                        req.setProcessDefinitionNameOrId('Content_update_Submitted_by_Manager');
                    } else {
                        req.setProcessDefinitionNameOrId('Content_update_Submitted_by_Worker');
                    }
                    req.setSkipEntryCriteria(false);
                    requests.add(req);
                    productIdVsName.put(info.productId, info.name);
                }
            }
            for (Offering__c product: newProducts) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments(product.comments__c);
                req.setObjectId(product.Id);
                req.setSubmitterId(UserInfo.getUserId());
                if (UserInfo.getProfileId() == storeManagerProfileId) {
                    req.setProcessDefinitionNameOrId('Content_update_Submitted_by_Manager');
                } else {
                    req.setProcessDefinitionNameOrId('Content_update_Submitted_by_Worker');
                }
                req.setSkipEntryCriteria(false);
                requests.add(req);
                productIdVsName.put(product.Id, product.Name);

            }
            List <Offering__c> productStatusesToUpdate = new List <Offering__c> ();
            List <Id> successfullProductIds = new List <Id> ();
            if(!Test.IsRunningTest()) {
                for (Approval.ProcessResult result: Approval.process(requests)) {
                    if (result.isSuccess()) {
                        productStatusesToUpdate.add(new Offering__c(Id = result.getEntityId(), Status__c = 'Submitted'));
                        successfullProductIds.add(result.getEntityId());
                    }
                }
            }
            if (!successfullProductIds.isEmpty()) {
                update productStatusesToUpdate;
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.submitForApproval', e);
        }
    }

    /**
     * 
     * @description : publishProduct 
     *  @param productInfoStrings List<String>
     */
    @AuraEnabled
    public static void publishProduct(List <String> productInfoStrings) {
        try {
            Id serviceRecordTypeId = Schema.getGlobalDescribe().get('Offering__c').getDescribe().getRecordTypeInfosByName().get('Service').getRecordTypeId();
            List <ProductInfo> infos = new List <ProductInfo> ();
            List <Link__c> linksToInsert = new List <Link__c> ();
            List <Sobject> recordsToUpdate = new List <SObject> ();
            List <Offering__c> productsToUpdate = new List <Offering__c> ();
            List <Publishing_Unit__c> clonedProductPUsToInsert = new List <Publishing_Unit__c> ();
            List <Offering__c> clonedProductsToInsert = new List <Offering__c> ();
            List <Tag_Offering__c> tagProductsToInsert = new List <Tag_Offering__c> ();
            List <Content_Unit_Translation__c> cutsToInsert = new List <Content_Unit_Translation__c> ();
            List <Id> productIds = new List <Id> ();
            List <ProductInfo> productInfosWithParentIds = new List <ProductInfo> ();
            Tag__c langTag;
            Tag__c countryTag;
            List <String> tagNames = new List <String> {
                'en',
                'South Africa'
            };
            Set <String> tagNamesSet = new Set <String> ();
            tagNamesSet.addAll(tagNames);
            for (Tag__c tag: SEL_Tags.newInstance().selectTagsByNames(tagNamesSet)) {
                if (tag.Name == 'en') {
                    langTag = tag;
                } else if (tag.Parent_Name__c == 'Country') {
                    countryTag = tag;
                }
            }
            for (String stringInfo: productInfoStrings) {
                infos.add((ProductInfo) JSON.deserialize(stringInfo, ProductInfo.class));
            }
            for (ProductInfo info: infos) {
                if (info.clonedProductStatus == NULL && info.parentProductId == NULL) {
                    if (String.IsNotBlank(info.productId)) {
                        productsToUpdate.add(new Offering__c(Status__c = 'Published', Id = info.productId));
                    }
                    if (String.IsNotBlank(info.publishingUnitId)) {
                        recordsToUpdate.add(new Publishing_Unit__c(Id = info.publishingUnitId, isPublished__c = true));
                    }
                    linksToInsert.add(new Link__c(Name = info.name + ' store link', Desktop_url__c = info.productUrl, Mobile_Url__c = info.productUrl, Guest_Url__c = info.productUrl));
                    clonedProductPUsToInsert.add(new Publishing_Unit__c(Published_from__c = info.publishedFrom, Published_until__c = info.publishedUntil));
                } else {
                    productIds.add(info.productId);
                    productInfosWithParentIds.add(info);
                }
            }
            update recordsToUpdate;
            update productsToUpdate;
            insert linksToInsert;
            insert clonedProductPUsToInsert;
            Integer i = 0;
            for (ProductInfo info: infos) {
                if (info.clonedProductStatus == NULL && info.parentProductId == NULL && ((productsToUpdate.size() - 1)>= i)) {
                    Offering__c clonedProduct = productsToUpdate[i].clone(false, true, false, false);
                    clonedproduct.Parent_Offering__c = productsToUpdate[i].Id;
                    clonedproduct.Status__c = 'Published';
                    clonedproduct.OwnerId = UserInfo.getUserId();
                    clonedproduct.Link__c = linksToInsert[i].Id;
                    clonedproduct.Name = info.name + ' Clone ' + System.now().format('dd/MM/YYYY');
                    clonedproduct.Provider__c = info.providerId;
                    clonedproduct.Publishing_unit__c = clonedProductPUsToInsert[i].Id;
                    clonedproduct.RecordTypeID = serviceRecordTypeId;
                    clonedProductsToInsert.add(clonedProduct);
                    i++;
                }
            }
            insert clonedProductsToInsert;
            Integer j = 0;
            for (ProductInfo info: infos) {
                if (info.clonedProductStatus == NULL && info.parentProductId == NULL && ((clonedProductsToInsert.size() - 1)>= j)) {
                    for (String categoryId: info.categoryIds) {
                        tagProductsToInsert.add(new Tag_Offering__c(Tag__c = categoryId, Offering__c = clonedProductsToInsert[j].Id));
                    }
                    tagProductsToInsert.add(new Tag_Offering__c(Tag__c = countryTag.Id, Offering__c = clonedProductsToInsert[j].Id));
                    Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
                    cut.Product__c = clonedProductsToInsert[j].Id;
                    if (info.uploadedImageUrl != NULL) {
                        cut.Image_Url__c = info.uploadedImageUrl;
                    } else if (info.imageUrl != NULL) {
                        cut.Image_Url__c = info.imageUrl;
                    }
                    cut.Title__c = info.name;
                    cut.Text__c = info.shortDesc;
                    cut.RichText__c = info.longDesc;
                    cut.Language__c = langTag.Id;
                    cutsToInsert.add(cut);
                    j++;
                }
            }
            insert cutsToInsert;
            insert tagProductsToInsert;


            Map <Id, Content_Unit_Translation__c> productIdVsCut = new Map <Id, Content_Unit_Translation__c> ();
            List <Content_Unit_Translation__c> cutsToInsert2 = new List <Content_Unit_Translation__c> ();
            List <Tag_Offering__c> tPsToInsert = new List <Tag_Offering__c> ();
            List <Sobject> sobjectsToUpdate = new List <Sobject> ();

            String whereClause = ' Product__c IN (\'' + String.join(productIds, '\',\'') + '\')';
            List <Content_Unit_Translation__c> cuts = SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);
            for (Content_Unit_Translation__c cut: cuts) {
                productIdVsCut.put(cut.Product__c, cut);
            }
            for (ProductInfo info: productInfosWithParentIds) {
                if (productIdVsCut.containsKey(info.productId)) {
                    Content_Unit_Translation__c cutranslation = (productIdVsCut.get(info.productId)).clone(false, true, false, false);
                    cutranslation.Product__c = info.parentProductId;
                    cutranslation.Text__c = info.shortDesc;
                    cutranslation.RichText__c = info.longDesc;
                    cutranslation.Title__c = info.name;
                    cutsToInsert2.add(cutranslation);
                }
                for (String categoryId: info.categoryIds) {
                    tPsToInsert.add(new Tag_Offering__c(tag__c = categoryId, Offering__c = info.parentProductId));
                }
                sobjectsToUpdate.add(new Offering__c(Name = info.name, Status__c = 'Published', Id = info.productId, comments__c = info.comment));
                sobjectsToUpdate.add(new Link__c(Id = info.linkId, Desktop_Url__c = info.productUrl, Mobile_Url__c = info.productUrl, Guest_Url__c = info.productUrl));
                sobjectsToUpdate.add(new Offering__c(Name = info.name, Status__c = 'Published', Id = info.parentProductId, comments__c = info.comment, Link__c = info.linkId));
                sobjectsToUpdate.add(new Publishing_Unit__c(Id = info.publishingUnitId, Published_from__c = info.publishedFrom, Published_until__c = info.publishedUntil));

            }
            insert cutsToInsert2;
            insert tPsToInsert;
            update sobjectsToUpdate;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.publishProduct', e);
        }
    }

    /**
     * 
     * @description : handleImageUpload 
     *  @param imageId String
     *  @return String
     */
    @AuraEnabled
    public static String handleImageUpload(String imageId) {
        try {
            String imageUrl = makeImageUrlPublic(new List <String> {
                imageId
            }).get(imageId);
            return imageUrl;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.handleImageUpload', e);
        }
    }

    /**
     * 
     * @description : makeImageUrlPublic 
     *  @param contentVersionIds List<String>     
     *  @return : Map<Id, String>
     */
    public static Map <Id, String> makeImageUrlPublic(List <String> contentVersionIds) {
        try {
            List <ContentVersion> contentVersions = new List <ContentVersion> ();
            List <ContentDistribution> contentDistributions = new List <ContentDistribution> ();
            Map <Id, String> contentVersionIdToContentUrl = new Map <Id, String> ();
            Set <Id> contentVersionIdsSet = new Set <Id> ();
            contentVersionIdsSet.addAll((List <Id> ) contentVersionIds);
            contentVersions = SEL_ContentVersion.newInstance().selectById(contentVersionIdsSet);
            for (ContentVersion contentVersion: contentVersions) {
                ContentDistribution contentDistribution = new ContentDistribution();
                contentDistribution.Name = contentVersion.Title;
                contentDistribution.ContentVersionId = contentVersion.Id;
                contentDistribution.PreferencesAllowViewInBrowser = true;
                contentDistribution.PreferencesLinkLatestVersion = true;
                contentDistribution.PreferencesNotifyOnVisit = false;
                contentDistribution.PreferencesPasswordRequired = false;
                contentDistribution.PreferencesAllowOriginalDownload = true;
                contentDistributions.add(contentDistribution);
            }
            insert contentDistributions;
            List <String> contentDistributionIds = new List <String> ();
            for (ContentDistribution contentDistribution: contentDistributions) {
                contentDistributionIds.add(contentDistribution.Id);
            }
            Set <Id> contentDistributionIdsSet = new Set <Id> ();
            contentDistributionIdsSet.addAll((List <Id> ) contentDistributionIds);
            contentDistributions = SEL_ContentDistribution.newInstance().selectById(contentDistributionIdsSet);
            for (ContentDistribution contentDistribution: contentDistributions) {
                String publicUrl = contentDistribution.ContentDownloadurl;
                contentVersionIdToContentUrl.put(contentDistribution.ContentVersionId, publicUrl);
            }
            return contentVersionIdToContentUrl;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.makeImageUrlPublic', e);
        }
    }

    /**
     * 
     * @description : unpublishProduct 
     *  @param productIds List<Id>     
     */
    @AuraEnabled
    public static void unpublishProduct(List <Id> productIds) {
        try {
            List <Offering__c> productsToUpdate = new List <Offering__c> ();
            for (Offering__c product: [Select Id, Status__c, Parent_Offering__c From Offering__c Where Parent_Offering__c in: productIds]) {
                product.Status__c = 'Draft';
                product.Parent_Offering__c = NULL;
                productsToUpdate.add(product);
            }
            Update productsToUpdate;
            List <Offering__c> productsToDelete = [Select Id, Name, Link__c, Publishing_Unit__c, Link__r.Desktop_Url__c, Publishing_Unit__r.Published_until__c, Status__c, Provider__c,
                Publishing_Unit__r.Published_from__c, Comments__c, Parent_Offering__c, Provider__r.IsOnline__c,
                (Select Id, Image_Url__c From Translations__r),
                (Select Id, Status__c, Parent_Offering__c From Offerings__r),
                (Select Id, Tag__c, Tag__r.Parent_Name__c From Tag_Offerings__r Where Tag__r.parent_name__c in ('Segment', 'Category')) From Offering__c Where Id in: productIds
            ];
            List <Content_Unit_Translation__c> translationsToDelete = new List <Content_Unit_Translation__c> ();
            List <Tag_Offering__c> tagProductsToDelete = new List <Tag_Offering__c> ();
            for (Offering__c product: productsToDelete) {
                translationsToDelete.addAll(product.Translations__r);
                tagProductsToDelete.addAll(product.Tag_Offerings__r);
            }
            Delete translationsToDelete;
            Delete tagProductsToDelete;
            Delete productsToDelete;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.unpublishProduct', e);
        }
    }


    /**
     * 
     * @description : recallProducts 
     *  @param productIds List<Id>     
     */
    @AuraEnabled
    public static void recallProducts(List <Id> productIds) {
        try {
            List <Approval.ProcessWorkItemRequest> requests = new List <Approval.ProcessWorkItemRequest> ();
            for (ProcessInstanceWorkitem wi: [SELECT Id FROM ProcessInstanceWorkItem
                    WHERE ProcessInstance.TargetObjectId in: productIds
                    AND ProcessInstance.Status = 'Pending'
                ]) {
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(wi.Id);
                requests.add(pwiRequest);
            }
            if (!requests.isEmpty()) {
                List <Offering__c> productsToUpdate = new List <Offering__c> ();
                for (Approval.ProcessResult result: Approval.process(requests)) {
                    if (result.isSuccess()) {
                        productsToUpdate.add(new Offering__c(Id = result.getEntityId(), Status__c = 'Draft'));
                    }
                }
                update productsToUpdate;
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.recallProducts', e);
        }
    }

    /**
     * 
     * @description : updateSObjects 
     *  @param sObjects List<sObject>
     *  @return `List<sObject>`
     */
    @AuraEnabled
    public static List <sObject> updateSObjects(List <sObject> sObjects) {
        try {
            update sObjects;
            return sObjects;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallProductFrontManagementController.updateSObjects', e);
        }
    }

    /**
    *
    * @description Wrapper Apex Type for Product Information
    */
    public class ProductInfo {
        @AuraEnabled
        public Id productId;
        @AuraEnabled
        public List <Id> categoryIds = new List <Id> ();
        @AuraEnabled
        public Datetime publishedFrom;
        @AuraEnabled
        public Datetime publishedUntil;
        @AuraEnabled
        public String uploadedImageUrl;
        @AuraEnabled
        public String productUrl;
        @AuraEnabled
        public id segmentId;
        @AuraEnabled
        public id cutId;
        @AuraEnabled
        public id categoryTagProductId;
        @AuraEnabled
        public id segmentTagProductId;
        @AuraEnabled
        public id publishingUnitId;
        @AuraEnabled
        public id linkId;
        @AuraEnabled
        public string productStatus;
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string imageUrl;
        @AuraEnabled
        public string comment;
        @AuraEnabled
        public id accountId;
        @AuraEnabled
        public id providerId;
        @AuraEnabled
        public boolean imageUploaded;
        @AuraEnabled
        public String clonedProductStatus;
        @AuraEnabled
        public id parentProductId;
        @AuraEnabled
        public boolean shopPublished;
        @AuraEnabled
        public string shortDesc;
        @AuraEnabled
        public string longDesc;
        @AuraEnabled
        public string lastModifiedBy;
        @AuraEnabled
        public DateTime createdDate;
        @AuraEnabled
        public DateTime lastModifiedDate;
        @AuraEnabled
        public Boolean online;
        @AuraEnabled
        public String mallProductUrl;
        @AuraEnabled
        public String ownerId;
        @AuraEnabled
        public String ownerName;
        @AuraEnabled
        public String storeName;
    }
}