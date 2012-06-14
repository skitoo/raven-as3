/**
 * This file is part of Raven AS3 client.
 *
 * (c) Alexis Couronne
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
package
{
	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	import org.flexunit.runner.FlexUnitCore;

	import flash.display.Sprite;

	/**
	 * @author Alexis Couronne
	 */
	public class RavenTestRunner extends Sprite
	{
		public function RavenTestRunner()
		{
			var core : FlexUnitCore = new FlexUnitCore();
            core.addListener(new CIListener());
            core.addListener(new TraceListener());
            core.run(RavenTestSuite);
		}
	}
}
