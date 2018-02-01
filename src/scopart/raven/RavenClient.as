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
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.utils.ByteArray;

	/**
	 * @author Alexis Couronne
	 */
	public class RavenClient
	{
		private var _config : RavenConfig;
		private var _sender : RavenMessageSender;
		private var _lastID : String;
		private var _tags : Object; // used for injecting tags before request is made
        private var _extras : Object; // used for injecting extras before request is made
        private var _user : Object; // used for injecting user data before request is made
		
		public static const DEBUG : uint = 10;
		public static const INFO : uint = 20;
		public static const WARN : uint = 30;
		public static const ERROR : uint = 40;
		public static const FATAL : uint = 50;

        public static const VERSION : String = '0.2';
        public static const NAME : String = 'raven-as3';

		public function RavenClient(sentryDSN : String, release : String, environment : String, errorCallback : Function = null)
		{
			if (sentryDSN == null || sentryDSN.length == 0)
			{
				throw new ArgumentError("You must provide a DSN to RavenClient");
			}
			_config = new RavenConfig(sentryDSN , release, environment);
			_sender = new RavenMessageSender(_config, errorCallback);
		}

		/*
		 * set tags for the next capture
		 */
		public function setTags(tags:Object=null):void
        {
			_tags = tags;
		}

        /*
		 * set extras for the next capture
		 */
        public function setExtras(extras:Object=null):void
        {
            _extras = extras;
        }

        /*
         * set user info (id, username, email, ip_address)
         */
        public function setUserInfos(user:Object=null):void
        {
            _user = user;
        }
		
		/**
		 * Log a message to sentry
		 */
		public function captureMessage(message : String, logger : String = 'root', level : int = ERROR, culprit : String = null) : String
		{
			var now : Date = new Date();
			var messageBody : String = buildMessage(message, RavenUtils.formatTimestamp(now), logger, level, culprit, null);
			_tags = { }; // reset the provided tags after send
            _extras = { }; // reset the provided extras after send
            _user = { }; // reset the provided user data after send
			_sender.send(messageBody, now.time);
			return _lastID;
		}

		/**
		 * Log an exception to Sentry
		 */
		public function captureException(error : Error, message : String = null, logger : String = 'root', level : int = ERROR, culprit : String = null) : String
		{
			var now : Date = new Date();
			var messageBody : String = buildMessage(message || error.message, RavenUtils.formatTimestamp(now), logger, level, culprit, error);
			_tags = { }; // reset the provided tags before send
            _extras = { }; // reset the provided extras after send
            _user = { }; // reset the provided user data after send
			_sender.send(messageBody, now.time);
			return _lastID;
		}

		/**
		 * @private
		 */
		private function buildMessage(message : String, timeStamp : String, logger : String, level : int, culprit : String, error : Error) : String
		{
			var json : String = buildJSON(message, timeStamp, logger, level, culprit, error);
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(json, 'utf-8');
			return RavenBase64.encode(byteArray);
		}

		/**
		 * @private
		 */
		private function buildJSON(message : String, timeStamp : String, logger : String, level : int, culprit : String, error : Error) : String
		{
			_lastID = RavenUtils.uuid4();
			var object : Object = new Object();
			object['message'] = message;
			object['event_id'] = _lastID;
            object['platform'] = "as3";
            object['sdk'] = { name:NAME, version:VERSION };
            object['environment'] = _config.environment;
            object['release'] = _config.release;
            object['user'] = _user;

            if (error == null)
			{
				object['culprit'] = culprit;
			}
			else
			{
				if(error.getStackTrace())
				{
                    object['culprit'] = determineCulprit(error);
                    object['sentry.interfaces.Stacktrace'] = buildStacktrace(error);
				}
				object['sentry.interfaces.Exception'] = buildException(error, message);
			}
			object['timestamp'] = timeStamp;
			object['project'] = _config.projectID;
			object['level'] = level;
			object['logger'] = logger;
			object['tags'] = _tags;
            object['extra'] = _extras;
			
			var encoder : JSONEncoder = new JSONEncoder(object);
			
			return encoder.getString();
		}

		/**
		 * @private
		 */
		private function buildException(error : Error, message : String) : Object
		{
			var object : Object = new Object();
			object['type'] = RavenUtils.getClassName(error);
			object['value'] = error.message ? error.message : message;
			object['module'] = RavenUtils.getModuleName(error);
			return object;
		}

		/**
		 * @private
		 */
		private function buildStacktrace(error : Error) : Object
		{
			var result : Object = new Object();
			result['frames'] = RavenUtils.parseStackTrace(error);
			return result;
		}

		/**
		 * @private
		 */
		private function determineCulprit(error : Error) : String
		{
			return error.getStackTrace().split('\n')[0];
		}
	}
}
