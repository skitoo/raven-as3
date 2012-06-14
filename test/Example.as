package
{
	import scopart.raven.RavenClient;

	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.system.Security;

	/**
	 * @author Alexis Couronne
	 */
	public class Example extends Sprite
	{
		public function Example()
		{
			// RavenUtils.parseStackTrace("pwet");

			Security.loadPolicyFile("http://127.0.0.1:9000/_static/crossdomain.xml");

			var c : RavenClient = new RavenClient('http://f06a5067814644309e3b709db51c8740:a0c20d2cf4ab4a76a38b6ac16e8edd57@127.0.0.1:9000/1');
			c.captureMessage('azeazeazeae', 'root', RavenClient.WARN);

			try
			{
				throw new IllegalOperationError("Mon cul c'est du poulet");
			}
			catch(e : Error)
			{
				c.captureException(e);
			}
		}
	}
}
