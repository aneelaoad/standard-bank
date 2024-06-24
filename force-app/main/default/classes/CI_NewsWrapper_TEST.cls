/**
 * Test class for CI_NewsWrapper
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		January 2021
*/
@IsTest
public class CI_NewsWrapper_TEST {
    private static final String DEF_STRING = 'Test String for all values in wrapper';
    private static final Integer DEF_INTEGER = 0;

    @IsTest
    public static void shouldCreateCiNewsWrapper() {
        CI_NewsWrapper ciNews = new CI_NewsWrapper();

        Test.startTest();
        ciNews.An = DEF_STRING;
        ciNews.Publication_Date = System.now();
        ciNews.Publisher_Name = DEF_STRING;
        ciNews.Title = DEF_STRING;
        ciNews.Snippet = DEF_STRING;
        ciNews.Pred = DEF_INTEGER;
        ciNews.High_Prob_Clients = DEF_STRING;
        ciNews.Medium_Prob_Clients = DEF_STRING;
        ciNews.Low_Prob_Clients = DEF_STRING;
        ciNews.Regions = DEF_STRING;
        ciNews.Sb_Group_Sectors = DEF_STRING;
        ciNews.Sb_Sub_Sectors = DEF_STRING;
        ciNews.Index = DEF_INTEGER;
        ciNews.Is_china_africa = new CI_NewsWrapper.IsChinaAfrica();
        ciNews.Is_china_africa.m_value = DEF_INTEGER;
        ciNews.Is_top_100 = new CI_NewsWrapper.IsTop100();
        ciNews.Is_top_100.m_value = DEF_INTEGER;
        ciNews.Is_nbfi = new CI_NewsWrapper.IsNbfi();
        ciNews.Is_nbfi.m_value = DEF_INTEGER;
        ciNews.China_africa_clients_in_article = DEF_STRING;
        ciNews.Top_100_clients_in_article = DEF_STRING;
        Test.stopTest();

        System.assertEquals(DEF_STRING, ciNews.An);
        System.assertEquals(DEF_STRING, ciNews.Publisher_Name);
        System.assertEquals(DEF_STRING, ciNews.Title);
        System.assertEquals(DEF_STRING, ciNews.Snippet);
        System.assertEquals(DEF_STRING, ciNews.High_Prob_Clients);
        System.assertEquals(DEF_STRING, ciNews.Medium_Prob_Clients);
        System.assertEquals(DEF_STRING, ciNews.Low_Prob_Clients);
        System.assertEquals(DEF_STRING, ciNews.Regions);
        System.assertEquals(DEF_STRING, ciNews.Sb_Group_Sectors);
        System.assertEquals(DEF_STRING, ciNews.Sb_Sub_Sectors);
        System.assertEquals(DEF_STRING, ciNews.China_africa_clients_in_article);
        System.assertEquals(DEF_STRING, ciNews.Top_100_clients_in_article);

        System.assertEquals(DEF_INTEGER, ciNews.Index);
        System.assertEquals(DEF_INTEGER, ciNews.Pred);
        System.assertEquals(DEF_INTEGER, ciNews.Is_nbfi.m_value);
        System.assertEquals(DEF_INTEGER, ciNews.Is_top_100.m_value);
        System.assertEquals(DEF_INTEGER, ciNews.Is_china_africa.m_value);
    }
    
}