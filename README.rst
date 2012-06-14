Raven-AS3
=========

Raven-java is a Flash/AS3 client for `Sentry <http://github.com/dcramer/sentry>`_. 

::

    // Instantiate a new client with a compatible DSN
    var client : RavenClient = new RavenClient('http://public:secret@example.com/1');

    // Capture a message
    client.captureMessage('my log message');

    // Capture an exception
    try
    {
      throw new Error("an error");
    }
    catch(e : Error)
    {
      client.captureException(e);
    }
    

Installation
------------

To install the source code:

::

    $ git clone git://github.com/skitoo/raven-as3.git
    
Include it in your class path.


Resources
---------

* `Bug Tracker <http://github.com/skitoo/raven-as3/issues>`_
* `Code <http://github.com/skitoo/raven-as3>`_   
   
