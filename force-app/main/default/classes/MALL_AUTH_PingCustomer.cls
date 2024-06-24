/**
 * @description MALL_AUTH_PingCustomer
 * 
 * @author Ankit Kumar
 *
 * @date October 2023
 */
public with sharing class MALL_AUTH_PingCustomer {
    private static final String EMPTY = '';
    private static final String PROVIDER_NAME = 'mall_ping_custom';

    /**
     * @description DTO_Access
     * @param access_token, token_type, expires_in, refresh_token, id_token, expires
     * @return data
     */
    public class DTO_Access {
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String refresh_token;
        public String id_token;
        public Long expires;
    }

    /**
     * @description user info received from ping
     */
    public class DTO_UserInfo {
        public String sub; /* enterprise id email */
        public String email;
        public String employee_number; /* c-number */
        public Long nbf; /* not before claim (JWT) */
        public Long iat; /* issued at claim (JWT) */
        public String id;
        public String bpId;
        public String bpidguid;
    }

    /**
     * @description transient dto used to hold the user names i.e. firstname, last name and full name from the sub
     * variable returned as the enterprise id / email
     */
    public class UserNames {
        public String firstName;
        public String lastName;
        public String fullName;
    }

    /**
     * @description convert token string to dto
     *
     * @param jsonString as input
     *
     * @return access token dto
     */
    public static DTO_Access tokenStringToDto(String jsonString) {
        return (DTO_Access) JSON.deserialize(jsonString, DTO_Access.class);
    }

    /**
     * @description getAccessToken
     *
     * @return access token string
     */
    public static String getAccessToken() {
        return MALL_OAuth_Util.getUserAccessToken(PROVIDER_NAME);
    }
}