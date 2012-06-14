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
	import com.adobe.net.URI;
	
	/**
	 * @author Alexis Couronne
	 */
	public class RavenConfig
	{
		private var _uriObject : URI;
		
		private var _dsn : String;
		private var _uri : String;
		private var _path : String;
		private var _project : String;
		private var _publicKey : String;
		private var _privateKey : String;
		
		public function RavenConfig(dsn : String)
		{
			_dsn = dsn;
			_uriObject = new URI(_dsn);
			parseDSN();
		}
		
		/**
		 * @private
		 */
		private function parseDSN() : void
		{
			_uri = _uriObject.scheme + '://' + _uriObject.authority;
			_uri += _uriObject.port ? (':' + _uriObject.port) : '';
			var rawpath : Array = _uriObject.path.split('/');
			rawpath.shift();
			_path = '';
			if(rawpath.length == 0)
			{
				_project = '';
			}
			else
			{
				_project = rawpath.pop();
				for each(var pathPart : String in rawpath)
				{
					_path += pathPart + '/';
				}
			}
			_uri += '/' + _path;
			_privateKey = _uriObject.password;
			_publicKey = _uriObject.username;
		}
		
		/**
		 * Sentry url path
		 */
		public function get uri() : String
		{
			return _uri;
		}
		
		/**
		 * The Sentry public key
		 */
		public function get publicKey() : String
		{
			return _publicKey;
		}
		
		/**
		 * The Sentry private key
		 */
		public function get privateKey() : String
		{
			return _privateKey;
		}
		
		/**
		 * The Sentry project id
		 */
		public function get projectID() : String
		{
			return _project;
		}

		/**
		 * Sentry dsn
		 */
		public function get dsn() : String
		{
			return _dsn;
		}
	}
}
