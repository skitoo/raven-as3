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
	import flash.system.Security;

	/**
	 * @author Alexis Couronne
	 */
	public class RavenMessageSender
	{
		private var _config : RavenConfig;
        private var _errorCallback : Function;

		public function RavenMessageSender(config : RavenConfig, errorCallback : Function)
		{
			_config = config;
            _errorCallback = errorCallback;

			Security.loadPolicyFile(_config.uri + 'api/' + _config.projectID + '/crossdomain.xml');
		}

		public function send(message : String, timestamp : Number) : void
		{
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);

			var request : URLRequest = new URLRequest(_config.uri + 'api/' + _config.projectID + '/store/');
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(new URLRequestHeader('X-Sentry-Auth', buildAuthHeader(timestamp)));
			request.requestHeaders.push(new URLRequestHeader('Content-Type', 'application/octet-stream'));
			request.data = message;
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		private function buildAuthHeader(timestamp : Number) : String
		{
			var header : String = 'Sentry sentry_version=7';
			header += ', sentry_timestamp=';
			header += timestamp;
            header += ', sentry_client=';
            header += RavenClient.NAME + "/" + RavenClient.VERSION;
            header += ', sentry_key=';
			header += _config.publicKey;
			if (_config.privateKey)
				header += ', sentry_secret=' + _config.privateKey;
			return header;
		}

		/**
		 * @private
		 */
		private function onLoadFail(event : IOErrorEvent) : void
		{
			var loader : URLLoader = URLLoader(event.target);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
            if(_errorCallback != null)
                _errorCallback("Error reporting Sentry error : " + event.text + ' : ' + loader.data, event);
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
