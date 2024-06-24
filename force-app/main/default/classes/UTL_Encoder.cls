public class UTL_Encoder {
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    public static Integer encodeBase64ToInt(String base64Char) {
        return base64Chars.indexOf(base64Char);
    }
    public static String encodeBase64ToByte(String base64Char) {
        return decimalToBinary(encodeBase64ToInt(base64Char));
    }

    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits.leftPad(8, '0');
    }

}