package scopart.raven
{
	import com.adobe.serialization.json.JSON;

	import flash.utils.ByteArray;

	/**
	 * @author Alexis Couronne
	 */
	public class RavenClient
	{
		private var _config : RavenConfig;
		private var _sender : RavenMessageSender;
		private var _lastID : String;
		
		public static const DEBUG : uint = 10;
		public static const INFO : uint = 20;
		public static const WARN : uint = 30;
		public static const ERROR : uint = 40;
		public static const FATAL : uint = 50;
		
		public static const VERSION : String = '0.1';
		public static const NAME : String = 'raven-as3/' + VERSION;

		public function RavenClient(sentryDSN : String)
		{
			if (sentryDSN == null || sentryDSN.length == 0)
			{
				throw new ArgumentError("You must provide a DSN to RavenClient");
			}
			_config = new RavenConfig(sentryDSN);
			_sender = new RavenMessageSender(_config);
		}

		public function captureMessage(message : String, logger : String = 'root', level : int = ERROR, culprit : String = null) : String
		{
			var now : Date = new Date();
			var messageBody : String = buildMessage(message, RavenUtils.formatTimestamp(now), logger, level, culprit, null);
			_sender.send(messageBody, now.time);
			return _lastID;
		}

		public function captureException(error : Error, message : String = null, logger : String = 'root', level : int = ERROR, culprit : String = null) : String
		{
			var now : Date = new Date();
			var messageBody : String = buildMessage(message || error.message, RavenUtils.formatTimestamp(now), logger, level, culprit, error);
			_sender.send(messageBody, now.time);
			return _lastID;
		}

		private function buildMessage(message : String, timeStamp : String, logger : String, level : int, culprit : String, error : Error) : String
		{
			var json : String = buildJSON(message, timeStamp, logger, level, culprit, error);
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(json, 'iso-8859-1');
			return RavenBase64.encode(byteArray);
		}

		private function buildJSON(message : String, timeStamp : String, logger : String, level : int, culprit : String, error : Error) : String
		{
			_lastID = RavenUtils.uuid4();
			var object : Object = new Object();
			object['message'] = message;
			object['event_id'] = _lastID;
			if (error == null)
			{
				object['culprit'] = culprit;
			}
			else
			{
				object['culprit'] = determineCulprit(error);
				object['sentry.interfaces.Exception'] = buildException(error);
				object['sentry.interfaces.Stacktrace'] = buildStacktrace(error);
			}
			object['timestamp'] = timeStamp;
			object['project'] = _config.projectID;
			object['level'] = level;
			object['logger'] = logger;
			object['server_name'] = RavenUtils.getHostname();
			return JSON.encode(object);
		}

		private function buildException(error : Error) : Object
		{
			var object : Object = new Object();
			object['type'] = RavenUtils.getClassName(error);
			object['value'] = error.message;
			object['module'] = RavenUtils.getModuleName(error);
			return object;
		}

		private function buildStacktrace(error : Error) : Object
		{
			var result : Object = new Object();
			result['frames'] = RavenUtils.parseStackTrace(error);
			return result;
		}

		private function determineCulprit(error : Error) : String
		{
			return error.getStackTrace().split('\n')[0];
		}
	}
}
