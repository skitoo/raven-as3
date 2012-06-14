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
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	/**
	 * @author Alexis Couronne
	 */
	public class RavenMessageSender
	{
		private var _config : RavenConfig;

		public function RavenMessageSender(config : RavenConfig)
		{
			_config = config;
		}

		public function send(message : String, timestamp : Number) : void
		{
			var signature : String = RavenUtils.getSignature(message, timestamp, _config.privateKey);
			
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);

			var request : URLRequest = new URLRequest(_config.uri + 'api/store/');
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(new URLRequestHeader('X-Sentry-Auth', buildAuthHeader(signature, timestamp)));
			request.requestHeaders.push(new URLRequestHeader('Content-Type', 'application/octet-stream'));
			request.data = message;
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		private function buildAuthHeader(signature : String, timestamp : Number) : String
		{
			var header : String = 'Sentry sentry_version=2.0,sentry_signature=';
			header += signature;
			header += ',sentry_timestamp=';
			header += timestamp;
			header += ',sentry_key=';
			header += _config.publicKey;
			header += ',sentry_client=';
			header += RavenClient.NAME;
			return header;
		}

		/**
		 * @private
		 */
		private function onLoadFail(event : IOErrorEvent) : void
		{
			var loader : URLLoader = URLLoader(event.target);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
		}

		/**
		 * @private
		 */
		private function onLoadComplete(event : Event) : void
		{
			var loader : URLLoader = URLLoader(event.target);
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
		}
	}
}
