Gravity — A HTML5 conquer game
==============================

Your objective is to conquer all planets on the star system.

## History

You, the greens, was the only species in this star system, living in the blue planet, near (but not so much) the sun, until some outer-space specie comes to colonize this system. You need to colonize all those planets before it varnish you from this existence.

Your specie effort was enough to build only one strong ship, with space for three passengers that you must carry to colonize other planets. This ship also have a missile launcher, but you must wait your crew to reload the weapon for each shot.

Holy shit! The invaders still coming from the outer space on its small capsules. You can see some of they when you fly on the interplanetary space, but you can't shot that small target.

The good new is that the greens can colonize faster because we can grow up and multiply in less time than a reddish.

Lookout! Their planetary defense cannons can shot faster than our ship and its missile are as strong as yours! We can destroy that cannons with a direct shot, but the reddish will rebuild it until you land the planet with some greens.

## Fling

You have three jets: one strong back jet for propulsion, and two lateral for rotation. You must land a planet to release the passengers, so turn your back jet to the planet surface and reduce your velocity.

You can use the arrow keys on keyboard, or the screen buttons on your mobile.

Tip: You have an alignment autopilot, so let it to help you to fine adjust your rotation. The autopilot turns on when you are near to the surface. Yeah, you can use the planet gravity to landing, so do not crazily force the jet against the planet.

## Weapon usage

Shot pressing the space bar or touching the weapon button, when it is visible on the screen.

The missile has mass, so its trajectory will be influenced by the star and planets gravity.

The strong missile explosion is a good strategy for clean up enemy planets.

Lookout! Your missile will not explode on your ship, but can explode on your planets. Also you can't visually distinguish between yours and your enemy's missiles.

## Damages and repair

Missiles and wrong planetary approximation can damage your ship. Your auto-repair system can fill up your life any time any where, but if you land a green planet, you will get a better 

## Radar map

Your scientists succeed to build a real time radar for all this star system, where you can see your ship position, all planets colorized with its status, and all fling missiles.

Planet status colors:
- gray: uncolonized
- green: your planet
- red: enemy planet
- magenta: conflict, undefined ownership

## Miscellanea

Press `P` to toggle pause;

The small button at the right opens the configure dialog, where you can toggle audio and graphics quality.

See some gameplay videos at http://ripe.ufba.br/aurium/gravity

Technical Information
======================

## Copping the source
```bash
$ git clone https://github.com/aurium/gravity.git
```

## Building
```bash
$ cd gravity # enter on the cloned game dir.
$ ./build.sh
```
The builder script still running waiting for some modification to rebuild.
To stop it, press `Ctrl+C`.

A file called `gravity.zip` will be created on your `/tmp`.

If you want to debug, run:
```bash
$ DEBUG=on ./build.sh
```
So the builder will not remove the log calls, and will provide a readable javascript for the browser trace.

## Running the game
Open the `index.html` on your browser.
You don't need to open the zip file.
That is only for the js13k submission.

## Screencasting

```bash
v=game$(date +%F_%H-%M-%S).ogg; sleep 2; avconv -f alsa -ac 1 -i default -f x11grab -s 800x600 -r 25 -i $DISPLAY -b:a 64k -b:v 1400k -f ogg -acodec libvorbis -vcodec libtheora $v; test -n "$(head $v)" && vlc $v; ls -lh $v
```
`Ctrl+C` to stop.
