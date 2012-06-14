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
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.SHA1;

	import flash.utils.getQualifiedClassName;

	/**
	 * @author Alexis Couronne
	 */
	public class RavenUtils
	{
		/**
		 * Generate an uuid4 value
		 */
		public static function uuid4() : String
		{
			var result : String = '';
			result += randInt(0, 0xffff).toString(16).substr(0, 4);
			result += randInt(0, 0xffff).toString(16).substr(0, 4);

			result += randInt(0, 0xffff).toString(16).substr(0, 4);

			result += (randInt(0, 0x0fff) | 0x4000).toString(16).substr(0, 4);

			result += (randInt(0, 0x3fff) | 0x8000).toString(16).substr(0, 4);

			result += randInt(0, 0xffff).toString(16).substr(0, 4);
			result += randInt(0, 0xffff).toString(16).substr(0, 4);
			result += randInt(0, 0xffff).toString(16).substr(0, 4);

			return result;
		}

		public static function getHostname() : String
		{
			return "test";
		}

		/**
		 * Generate message signature
		 */
		public static function getSignature(messageBody : String, timestamp : Number, secretKey : String) : String
		{
			return HMAC.hash(secretKey, timestamp + ' ' + messageBody, SHA1);
		}

		/**
		 * Generate a randon int between min and max passed-in values.
		 */
		public static function randInt(min : int, max : int) : int
		{
			return Math.round(min + Math.random() * (max - min));
		}

		public static function parseStackTrace(error : Error) : Array
		{
			var result : Array = new Array();
			var elements : Array = error.getStackTrace().split('\n');
			elements.shift();
			for (var i : int = 0 ; i < elements.length ; i++)
			{
				if (i == 0)
				{
					var causedFrame : Object = new Object();
					causedFrame['filename'] = 'Caused by ' + RavenUtils.getClassName(error) + '(' + error.message + ')';
					causedFrame['lineno'] = -1;
					result.push(causedFrame);
				}
				var element : String = elements[i];
				var subelements : Array = element.substr(3, element.length - 4).split('[');
				var fileAndLine : Array = String(subelements[1]).split(':');
				var frame : Object = new Object();
				frame['filename'] = fileAndLine[0];
				frame['lineno'] = fileAndLine[1];
				frame['function'] = subelements[0];
				result.push(frame);
			}
			return result;
		}

		public static function getClassName(object : Object) : String
		{
			var fullClassName : String = getQualifiedClassName(object);
			var splittedClassName : Array = fullClassName.split('::');
			return splittedClassName[1];
		}

		public static function getModuleName(object : Object) : String
		{
			var fullClassName : String = getQualifiedClassName(object);
			var splittedClassName : Array = fullClassName.split('::');
			return splittedClassName[0];
		}
		
		public static function formatTimestamp(date : Date) : String
		{
			var result : String = '';
			var month : int = date.monthUTC + 1;
			
			result += date.fullYearUTC + '-';
			result += month < 10 ? ('0' + month + '-') : (month + '-');
			result += date.dateUTC + 'T';
			result += date.hoursUTC + ':';
			result += date.minutesUTC + ':';
			result += date.secondsUTC;
			return result;
		}
	}
}
