/**
  * @author Michal Lipinski
  * @description Contains methods that can be reused around the String object
*/
public without sharing class UTL_String {
	/**
	 * @description Changes any text provided to camelcased words. Example  <u>ANY stateMEnt ProvideD as Input</u> should be changed to <u>Any Statement Provided As Input </u>
	 * @param text Any String
	 * @return String with capitalized words
	 */
	public static String capitalizeWords(String text) {
		if (String.isBlank(text)) { return text; }
		Pattern p = Pattern.compile('\\b[a-z]');
		text = text.toLowerCase();
		Matcher m = p.matcher(text);
		while (m.find()) {
			text = text.substring(0, m.start()) + text.substring(m.start(), m.start() + 1).capitalize() + text.substring(m.end());
		}
		return text;
	}
}