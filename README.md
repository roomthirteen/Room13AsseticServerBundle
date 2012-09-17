Room13AsseticServerBundle
=========================

*Work in progress*

A standalone asset server to replace the tardy *./bin/console assetic:dump --watch* command.

It comes with a standalone server written in nodejs who will load and serve assets on demand.
Changed and newly added assets will be made available on the server instantly.



Installation & Configuration
-------------------------
Install the bundle through git submodules or composer and add it to your kernel.
Afterwards open your config.yml and add the following bundle configuration:

    room13_assetic_server:
      # port to run the server on, defaults to 8124
      port: 1234
      # location of the document root from symfony, defaults to web
      documentRoot: web/frontend
      # name of the console command to be used to communicate with symfony, defaults to ./bin/console
      consoleCommand: ./frontend/console

Now we need to configure assetic configuration to it will output a url directing to the assetserver instead
of directing to the normal webserver. Change the following lines in your config.yml accordingly:

framework:
    templating:
        engines: [twig]
        assets_base_urls:
            # server and port of the assetic server
            http: [http://localhost:8124/]

Usage
-------------------------

After successfully configurating the bundle you can verify it's communication with symfony works by executing
the following command

    ./bin/console room13:assetic-server:list-assets


If this prints out a large list of asset groups and files, everything is properly configured
and you can proceed to start the asset server by running the following command:

    ./bin/console room13:assetic-server:run

Now you asset server is running and you can reload your symfony app in the browser. The assets should now
be loaded from the asset server. The first run will take some time because the server loads the resources
on demand, in contrast to the *assetic:dump* command wich dumps all assets at the same time.

The next reloads should go much faster because all assets are now in memory and the server uses
advanced caching by serving etags and 302 Not Modified responses.

If you now change an asset, the change should be immediatly available without a freezing of your computer
(this happend with the *assetic:dump --watch* command because it regenerates all assets.


Help me
-------------------------
Any suggestions are welcome. Fork and Pull please to help this project to become a success ;)