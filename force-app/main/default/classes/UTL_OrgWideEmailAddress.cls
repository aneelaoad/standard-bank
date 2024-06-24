/**
 * Utility class to retrieve and cache OrgWideEmailAddress records
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date May 2020
 */
public without sharing class UTL_OrgWideEmailAddress {

    private static Map<String, OrgWideEmailAddress> address2Record {
        get {
            if (address2Record == null) {
                address2Record = new Map<String, OrgWideEmailAddress>();
                List<OrgWideEmailAddress> addresses = [
                    SELECT Address,
                        DisplayName,
                        IsAllowAllProfiles
                    FROM OrgWideEmailAddress
                ];
                for (Integer i = 0, j = addresses.size(); i < j; i++) {
                    OrgWideEmailAddress address = addresses[i];
                    address2Record.put(address.Address, address);
                }
            }
            return address2Record;
        }
        set;
    }

    /**
     * @param address Desired email address
     *
     * @return Id of OrgWideEmailAddress record
     */
    public static Id getAddressId(String address) {
        return getAddressRecord(address).Id;
    }

    /**
     * @param address Desired email address
     *
     * @return Address, DisplayName, IsAllowAllProfiles fields from OrgWideEmailAddress
     */
    public static OrgWideEmailAddress getAddressRecord(String address) {
        OrgWideEmailAddress addressRecord = address2Record.get(address);
        if (addressRecord == null) {
            throw new OrgWideEmailAddressException('There is no Org Wide Email Address record with Address: ' + address);
        }
        return addressRecord;
    }

    public class OrgWideEmailAddressException extends Exception {}

}