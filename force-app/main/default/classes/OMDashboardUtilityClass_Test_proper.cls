/**
    @description Test class for OMDashboardUtilityClass
 */
@isTest
private class OMDashboardUtilityClass_Test_proper {

    @IsTest
    static void testOmOppClosedFrancoView() {
         List<OMDashboardUtilityClass.omOppClosedFrancoView> listOMDashboardUtilityClas =
                 new List<OMDashboardUtilityClass.omOppClosedFrancoView>();
         OMDashboardUtilityClass.omOppClosedFrancoView omOppclass =
                 new OMDashboardUtilityClass.omOppClosedFrancoView('test', 'test', 'test', 'test','test', 2001, 3);
         listOMDashboardUtilityClas.add(omOppclass);
         OMDashboardUtilityClass.omOppClosedFrancoView omOppclass1 =
                 new OMDashboardUtilityClass.omOppClosedFrancoView('test', 'test', 'test', 'test','test', 2002, 3);
        listOMDashboardUtilityClas.add(omOppclass1);
        OMDashboardUtilityClass.omOppClosedFrancoView omOppclass2 =
                new OMDashboardUtilityClass.omOppClosedFrancoView('test', 'test', 'test', 'test','test', 2000, 3);
        listOMDashboardUtilityClas.add(omOppclass2);
        OMDashboardUtilityClass.omOppClosedFrancoView omOppclass3 =
                new OMDashboardUtilityClass.omOppClosedFrancoView('test', 'test', 'test', 'test','test', 2000, 3);
        listOMDashboardUtilityClas.add(omOppclass3);
        listOMDashboardUtilityClas.sort();
        System.assertEquals(2002, listOMDashboardUtilityClas[0].cYearRev);
    }

    @IsTest
    static void testOMOpportunity() {
        try {
            OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
            List<OMDashboardUtilityClass.omOpportunity> listOMOpportunity= new List<OMDashboardUtilityClass.omOpportunity>();
            OMDashboardUtilityClass.omOpportunity testomOpportunity = new OMDashboardUtilityClass.omOpportunity();
            OMDashboardUtilityClass.omOpportunity omOpportunity =
                    new OMDashboardUtilityClass.omOpportunity('test', 0, 0, 0, 0, 0, 0, 0);
            listOMOpportunity.add(omOpportunity);
            OMDashboardUtilityClass.omOpportunity omOpportunity1 =
                    new OMDashboardUtilityClass.omOpportunity('test', 21, 21, 21, 21, 21, 6, 21);
            listOMOpportunity.add(omOpportunity1);
            OMDashboardUtilityClass.omOpportunity omOpportunity2 =
                    new OMDashboardUtilityClass.omOpportunity('test', 0, 0, 0, 0, 0, 0, 0);
            listOMOpportunity.add(omOpportunity2);
            OMDashboardUtilityClass.omOpportunity omOpportunity3 =
                    new OMDashboardUtilityClass.omOpportunity('test', 4, 5, 8, 10, 0, 7, 9);
            listOMOpportunity.add(omOpportunity3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testOmOpportunityDiv() {
        try {
            List<OMDashboardUtilityClass.omOpportunityDiv> listOMOpportunity =
                    new List<OMDashboardUtilityClass.omOpportunityDiv>();
            OMDashboardUtilityClass.omOpportunityDiv omOpportunityDiv =
                    new OMDashboardUtilityClass.omOpportunityDiv('test', 20, 22, 22, 22, 22, 3, 22, 1, 6, 8);
            listOMOpportunity.add(omOpportunityDiv);
            OMDashboardUtilityClass.omOpportunityDiv omOpportunityDiv1
                    = new OMDashboardUtilityClass.omOpportunityDiv('test1', 21, 21, 21, 21, 21, 6, 21, 7, 5, 44);
            listOMOpportunity.add(omOpportunityDiv1);
            OMDashboardUtilityClass.omOpportunityDiv omOpportunityDiv2 =
                    new OMDashboardUtilityClass.omOpportunityDiv('test2', 2, 3, 0, -5, 8, 8, 12, 9, 8, 17);
            listOMOpportunity.add(omOpportunityDiv2);
            OMDashboardUtilityClass.omOpportunityDiv omOpportunityDiv3 =
                    new OMDashboardUtilityClass.omOpportunityDiv('test3', 4, 5, 8, 10, 0, 7, 9, 13, 4, 7);
            listOMOpportunity.add(omOpportunityDiv3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void testOmOpportunityTop() {
        List<OMDashboardUtilityClass.omOpportunityTop > listomOpportunityTop =
                new List<OMDashboardUtilityClass.omOpportunityTop >();
        OMDashboardUtilityClass.omOpportunityTop omOpportunityTop =
                new OMDashboardUtilityClass.omOpportunityTop('test', 'oNametest', 'oldString', 'cNameString', 'cldString', 2001, 2);
        listomOpportunityTop.add(omOpportunityTop);
        OMDashboardUtilityClass.omOpportunityTop omOpportunityTop1 =
                new OMDashboardUtilityClass.omOpportunityTop('test1', 'oNametest1', 'oldString1', 'cNameString1', 'cldString1', 2003, 3);
        listomOpportunityTop.add(omOpportunityTop1);
        OMDashboardUtilityClass.omOpportunityTop omOpportunityTop2 =
                new OMDashboardUtilityClass.omOpportunityTop('test2', 'oNametest2', 'oldString2', 'cNameString2', 'cldString2', 2002, 4);
        listomOpportunityTop.add(omOpportunityTop2);
        OMDashboardUtilityClass.omOpportunityTop omOpportunityTop3 =
                new OMDashboardUtilityClass.omOpportunityTop('test3', 'oNametest3', 'oldString3', 'cNameString3', 'cldString3', 2002, 4);
        listomOpportunityTop.add(omOpportunityTop3);
        listomOpportunityTop.sort();
        System.assertEquals('test1', listomOpportunityTop[0].oppFranco);
    }

    @IsTest
    static void testOmOpportunityClosed() {
        try {
            List<OMDashboardUtilityClass.OmOpportunityClosed > listOmOpportunityClosed =
                    new List<OMDashboardUtilityClass.OmOpportunityClosed >();
            OMDashboardUtilityClass.OmOpportunityClosed testOmOpportunityClosed =
                    new OMDashboardUtilityClass.OmOpportunityClosed();
            OMDashboardUtilityClass.OmOpportunityClosed omOpportunityClosed =
                    new OMDashboardUtilityClass.OmOpportunityClosed('test', 1, 2, 3, 1, 2001, 2);
            listOmOpportunityClosed.add(omOpportunityClosed);
            OMDashboardUtilityClass.OmOpportunityClosed omOpportunityClosed1 =
                    new OMDashboardUtilityClass.OmOpportunityClosed('test1', 0, 0, 0, 0, 0, 0);
            listOmOpportunityClosed.add(omOpportunityClosed1);
            OMDashboardUtilityClass.OmOpportunityClosed omOpportunityClosed2 =
                    new OMDashboardUtilityClass.OmOpportunityClosed('test2', 1, 2, 3, 4, 2002, 4);
            listOmOpportunityClosed.add(omOpportunityClosed2);
            OMDashboardUtilityClass.OmOpportunityClosed omOpportunityClosed3 =
                    new OMDashboardUtilityClass.OmOpportunityClosed('test3', 0, 0, 0, 0, 0, 0);
            listOmOpportunityClosed.add(omOpportunityClosed3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void testOmOpportunitySector() {
        try {
            OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
            List<OMDashboardUtilityClass.omOpportunitySector > listomOpportunitySector =
                    new List<OMDashboardUtilityClass.omOpportunitySector >();
            OMDashboardUtilityClass.omOpportunitySector testOmOpportunitySectorContoller =
                    new OMDashboardUtilityClass.omOpportunitySector();
            OMDashboardUtilityClass.omOpportunitySector testOmOpportunitySector =
                    new OMDashboardUtilityClass.omOpportunitySector('test', 0, 0, 0, 0, 0, 0, 0);
            listomOpportunitySector.add(testOmOpportunitySector);
            OMDashboardUtilityClass.omOpportunitySector testOmOpportunitySector1 =
                    new OMDashboardUtilityClass.omOpportunitySector('test1', 0, 0, 0, 0, 0, 0, 0);
            listomOpportunitySector.add(testOmOpportunitySector1);
            OMDashboardUtilityClass.omOpportunitySector testOmOpportunitySector2 =
                    new OMDashboardUtilityClass.omOpportunitySector('test2', 1, 2, 3, 4, 3, 2002, 4);
            listomOpportunitySector.add(testOmOpportunitySector2);
            OMDashboardUtilityClass.omOpportunitySector testOmOpportunitySector3 =
                    new OMDashboardUtilityClass.omOpportunitySector('test3', 1, 2, 3, 4, 3, 2002, 4);
            listomOpportunitySector.add(testOmOpportunitySector3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testOmOpportunitySecDiv() {
        try {
            OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
            List<OMDashboardUtilityClass.omOpportunitySecDiv> listomOpportunitySecDiv =
                    new List<OMDashboardUtilityClass.omOpportunitySecDiv>();
            OMDashboardUtilityClass.omOpportunitySecDiv omOpportunitySecDiv =
                    new OMDashboardUtilityClass.omOpportunitySecDiv('test', 1, 2, 3, 4, 5, 6, 7, 8, 2001, 2);
            listomOpportunitySecDiv.add(omOpportunitySecDiv);
            OMDashboardUtilityClass.omOpportunitySecDiv omOpportunitySecDiv1 =
                    new OMDashboardUtilityClass.omOpportunitySecDiv('test1', 1, 2, 3, 4, 5, 6, 7, 8, 2003, 3);
            listomOpportunitySecDiv.add(omOpportunitySecDiv1);
            OMDashboardUtilityClass.omOpportunitySecDiv omOpportunitySecDiv2 =
                    new OMDashboardUtilityClass.omOpportunitySecDiv('test2', 1, 2, 3, 4, 5, 6, 7, 8, 2002, 4);
            listomOpportunitySecDiv.add(omOpportunitySecDiv2);
            OMDashboardUtilityClass.omOpportunitySecDiv omOpportunitySecDiv3 =
                    new OMDashboardUtilityClass.omOpportunitySecDiv('test3', 1, 2, 3, 4, 5, 6, 7, 8, 2002, 4);
            listomOpportunitySecDiv.add(omOpportunitySecDiv3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testomOpportunitySecClosed() {
        try {
            OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
            List<OMDashboardUtilityClass.omOpportunitySecClosed > listomOpportunitySecClosed =
                    new List<OMDashboardUtilityClass.omOpportunitySecClosed>();
            OMDashboardUtilityClass.omOpportunitySecClosed omOpportunitySecClosedConroller =
                    new OMDashboardUtilityClass.omOpportunitySecClosed();
            OMDashboardUtilityClass.omOpportunitySecClosed omOpportunitySecClosed =
                    new OMDashboardUtilityClass.omOpportunitySecClosed('test', 1, 2, 3, 4, 5, 6);
            listomOpportunitySecClosed.add(omOpportunitySecClosed);
            OMDashboardUtilityClass.omOpportunitySecClosed omOpportunitySecClosed1 =
                    new OMDashboardUtilityClass.omOpportunitySecClosed('test1', 0, 0, 0, 0, 0, 0);
            listomOpportunitySecClosed.add(omOpportunitySecClosed1);
            OMDashboardUtilityClass.omOpportunitySecClosed omOpportunitySecClosed2 =
                    new OMDashboardUtilityClass.omOpportunitySecClosed('test2', 0, 0, 0, 0, 0, 0);
            listomOpportunitySecClosed.add(omOpportunitySecClosed2);
            OMDashboardUtilityClass.omOpportunitySecClosed omOpportunitySecClosed3 =
                    new OMDashboardUtilityClass.omOpportunitySecClosed('test3', 1, 2, 3, 4, 5, 6);
            listomOpportunitySecClosed.add(omOpportunitySecClosed3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testOmOpportunityClosedFranco() {
        try {
            OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
            list<OMDashboardUtilityClass.omOpportunityClosedFranco> listomOpportunityClosedFranco =
                    new list<OMDashboardUtilityClass.omOpportunityClosedFranco>();
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFrancoController =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco();
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test', 'test', 1, 2, 3, 4);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco);
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco1 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test1', 'test1', 3, 4, 5, 6);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco1);
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco2 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test2', 'test2', 0, 0, 0, 0);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco2);
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco3 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test3', 'test3', 0, 0, 0, 0);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco3);
            list<OMDashboardUtilityClass.omOpportunityClosedFranco> listomOpportunityClosedFranco2 =
                    new list<OMDashboardUtilityClass.omOpportunityClosedFranco>();
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco4 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test', 'test', 1, 2, 3, 4, 5, 6, 7);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco4);
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco5 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test1', 'test1', 3, 4, 5, 6, 5, 7, 9);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco5);
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco6 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test2', 'test2', 0, 0, 0, 0, 0, 0, 0);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco6);
            OMDashboardUtilityClass.omOpportunityClosedFranco omOpportunityClosedFranco7 =
                    new OMDashboardUtilityClass.omOpportunityClosedFranco('test3', 'test3', 0, 0, 0, 0, 0, 0, 0);
            listomOpportunityClosedFranco.add(omOpportunityClosedFranco7);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testomOpportunitySecTop() {
        OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
        List<OMDashboardUtilityClass.omOpportunitySecTop > listomOpportunitySecTop =
                new List<OMDashboardUtilityClass.omOpportunitySecTop>();
        OMDashboardUtilityClass.omOpportunitySecTop omOpportunitySecTop =
                new OMDashboardUtilityClass.omOpportunitySecTop('test', 'test', 'test', 'test', 'test', 2001, 4);
        listomOpportunitySecTop.add(omOpportunitySecTop);
        OMDashboardUtilityClass.omOpportunitySecTop omOpportunitySecTop1 =
                new OMDashboardUtilityClass.omOpportunitySecTop('test1', 'test1', 'test1', 'test1', 'test1', 2000, 6);
        listomOpportunitySecTop.add(omOpportunitySecTop1);
        OMDashboardUtilityClass.omOpportunitySecTop omOpportunitySecTop2 =
                new OMDashboardUtilityClass.omOpportunitySecTop('test2', 'test2', 'test2', 'test2', 'test2', 2002, 6);
        listomOpportunitySecTop.add(omOpportunitySecTop2);
        OMDashboardUtilityClass.omOpportunitySecTop omOpportunitySecTop3 =
                new OMDashboardUtilityClass.omOpportunitySecTop('test3', 'test3', 'test3', 'test3', 'test3', 2001, 6);
        listomOpportunitySecTop.add(omOpportunitySecTop3);
        listomOpportunitySecTop.sort();
        System.assertEquals(2002, listomOpportunitySecTop[0].cYearRev);
    }

    @IsTest
    static void testomOpportunityPipelineFranco() {
        try {
            OMDashboardUtilityClass testOMDashboardUtilityClass = new OMDashboardUtilityClass();
            List<OMDashboardUtilityClass.omOpportunityPipelineFranco > listomOpportunityPipelineFranco =
                    new List<OMDashboardUtilityClass.omOpportunityPipelineFranco>();
            OMDashboardUtilityClass.omOpportunityPipelineFranco omOpportunityPipelineFrancoController =
                    new OMDashboardUtilityClass.omOpportunityPipelineFranco();
            OMDashboardUtilityClass.omOpportunityPipelineFranco omOpportunityPipelineFranco =
                    new OMDashboardUtilityClass.omOpportunityPipelineFranco('test', 'test', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            listomOpportunityPipelineFranco.add(omOpportunityPipelineFranco);
            OMDashboardUtilityClass.omOpportunityPipelineFranco omOpportunityPipelineFranco1 =
                    new OMDashboardUtilityClass.omOpportunityPipelineFranco('test1', 'test1', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            listomOpportunityPipelineFranco.add(omOpportunityPipelineFranco1);
            OMDashboardUtilityClass.omOpportunityPipelineFranco omOpportunityPipelineFranco2 =
                    new OMDashboardUtilityClass.omOpportunityPipelineFranco('test2', 'test2', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            listomOpportunityPipelineFranco.add(omOpportunityPipelineFranco2);
            OMDashboardUtilityClass.omOpportunityPipelineFranco omOpportunityPipelineFranco3 =
                    new OMDashboardUtilityClass.omOpportunityPipelineFranco('test3', 'test3', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            listomOpportunityPipelineFranco.add(omOpportunityPipelineFranco3);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

}