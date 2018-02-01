/**
 * This file is part of Raven AS3 client.
 *
 * (c) Alexis Couronne
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package scopart.raven
{
	import org.flexunit.asserts.assertEquals;

	/**
	 * @author Alexis Couronne
	 */
	public class TestRavenConfig
	{
		private var _configWithoutPort : RavenConfig;
		private var _configWithPort : RavenConfig;
		
		[Before]
		public function setUp() : void
		{
			_configWithoutPort = new RavenConfig('http://public:secret@example.com/sentry/default', "1.0", "production");
			_configWithPort = new RavenConfig('http://public:secret@example.com:8080/sentry/default', "1.0", "production");
		}
		
		[Test]
		public function testParseDSN() : void
		{
			assertEquals('http://public:secret@example.com/sentry/default', _configWithoutPort.dsn);
			assertEquals('http://public:secret@example.com:8080/sentry/default', _configWithPort.dsn);
		}
		
		[Test]
		public function testParseURI() : void
		{
			assertEquals('http://example.com/sentry/', _configWithoutPort.uri);
			assertEquals('http://example.com:8080/sentry/', _configWithPort.uri);
		}
		
		[Test]
		public function testParseProject() : void
		{
			assertEquals('default', _configWithoutPort.projectID);
			assertEquals('default', _configWithPort.projectID);
		}
		
		[Test]
		public function testParsePrivateKey() : void
		{
			assertEquals('secret', _configWithoutPort.privateKey);
			assertEquals('secret', _configWithPort.privateKey);
		}
		
		[Test]
		public function testParsePublicKey() : void
		{
			assertEquals('public', _configWithoutPort.publicKey);
			assertEquals('public', _configWithPort.publicKey);
		}

        [Test]
        public function testRelease() : void
        {
            assertEquals('1.0', _configWithoutPort.release);
            assertEquals('1.0', _configWithPort.release);
        }

        [Test]
        public function testEnvironment() : void
        {
            assertEquals('production', _configWithoutPort.environment);
            assertEquals('production', _configWithPort.environment);
        }
	}
}
