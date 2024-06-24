@isTest(isParallel = true)
private class Uuid_Test {

	@isTest
	private static void shouldCheckUuidValidity() {
		Test.startTest();
		System.assert(!Uuid.isValid(''));
		System.assert(!Uuid.isValid('1234567-1234-1234-1234-1234567890abc'));
		System.assert(Uuid.isValid('5a030194-4f53-47f2-9d18-bb88aa651895'));
		Test.stopTest();
	}

	@isTest
	private static void shouldValidateWhenCreateUniqueUuid() {
		Test.startTest();
		System.assert(Uuid.isValid(new Uuid().getValue()));
		Test.stopTest();
	}

	@isTest
	private static void shouldCreateUniqueValuesWhenCalledTwice() {
		Test.startTest();
		String uuid1 = new Uuid().getValue();
		String uuid2 = new Uuid().getValue();
		System.assertNotEquals(uuid1, uuid2);
		Test.stopTest();
	}

	@isTest
	private static void shouldCorrectValue() {
		Test.startTest();
		System.assertEquals('12345678-1234-1234-1234-1234567890ab', Uuid.formatValue('12345678-1234-1234-1234-1234567890AB'));
		System.assertEquals('12345678-1234-1234-1234-1234567890ab', Uuid.formatValue('123456781234123412341234567890AB'));
		System.assertEquals('12345678-1234-1234-1234-1234567890ab', Uuid.valueOf('123456781234123412341234567890AB').getValue());
		Test.stopTest();
	}
}