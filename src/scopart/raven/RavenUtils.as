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
	import com.adobe.utils.StringUtil;

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
			result += zeroPad(randInt(0, 0xffff));
			result += zeroPad(randInt(0, 0xffff));

			result += zeroPad(randInt(0, 0xffff));

			result += zeroPad((randInt(0, 0x0fff) | 0x4000));

			result += zeroPad((randInt(0, 0x3fff) | 0x8000));

			result += zeroPad(randInt(0, 0xffff));
			result += zeroPad(randInt(0, 0xffff));
			result += zeroPad(randInt(0, 0xffff));

			return result;
		}

        public static function zeroPad (number:Number):String
        {
            return ("0000" + number.toString(16)).substr(-4, 4);
        }

		/**
		 * Generate a random int between min and max passed-in values.
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

			var causedClass : String = RavenUtils.getClassName(error);
			if(causedClass) {
				var causedFrame : Object = new Object();
				causedFrame['filename'] = 'Caused by ' + causedClass + '(' + error.message + ')';
				result.push(causedFrame);
			}

			for each(var element : String in elements)
			{
				var frame : Object = new Object();

				var subelements		: Array		= element.split('[');

				frame['function']	= StringUtil.trim(subelements[0]).substr(3); // trim 'at ' from start

				if(subelements.length > 1)
                {
					var fileAndLine		: String	= String(subelements[1]);
					var separator		: int		= fileAndLine.lastIndexOf(":");

					frame['filename']	= fileAndLine.substr(0, separator);
					frame['lineno']		= parseInt(fileAndLine.substr(separator + 1)); // also trims ']' from end
				}

				result.push(frame);
			}
            result.reverse();
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
