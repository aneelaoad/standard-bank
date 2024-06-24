@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel = true)
private without sharing class UTL_String_Test {

    @IsTest
	private static void shouldCoverAllCapitalizeCases() {
		Test.startTest();
		validateCapitalize(null, null);
		validateCapitalize('', '');
		validateCapitalize('ANY WORD', 'Any Word');
		validateCapitalize('any word', 'Any Word');
		validateCapitalize('aNY wORD', 'Any Word');
		validateCapitalize('AnY WOrD', 'Any Word');
		validateCapitalize('anY worD', 'Any Word');
		validateCapitalize('Any Word', 'Any Word');
		validateCapitalize('', '');
		Test.stopTest();
	}

	private static void validateCapitalize(String input, String expected) {
		String actual;
		actual = UTL_String.capitalizeWords(input);
		System.assertEquals(expected, actual);
	}
}