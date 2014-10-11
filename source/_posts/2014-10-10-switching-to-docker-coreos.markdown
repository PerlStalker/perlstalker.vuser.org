---
layout: post
title: "Switching to Docker and CoreOS"
date: 2014-10-10
comments: true
categories:
- docker
- coreos
---

I learned about [Docker](http://www.docker.com/) over the summer at
ApacheCon in Denver. While Docker, itself, wasn't on the program, it
came up several times as various people were talking about PaaS
systems. Once I started to dig into it, I understood why people were
so excited. After playing with it more on my own, I was hooked. I
decided that I wanted to move this site to Docker.

In this post I'll tell you a bit about what I did, how I did it and
why. What I'm not going to do is explain the full workings of
Docker. If you want that, check out the
[Docker documentation](https://docs.docker.com/).

What is Docker?
---------------

Solomon Hykes, on [the Docker site](https://docker.com/whatisdocker/),
describes Docker thusly, "Docker is an open platform for developers
and sysadmins to build, ship, and run distributed applications." In
other words, it's a really convenient way to wrap up an application
and everything it needs in one nice neat little package and run
everything from within that package.

One of the things I like about it is that individual pieces can be
isolated. For example, I write a lot of Perl and, as much as I like
it, doing a lot with CPAN on a server can make a real mess. That's
especially true if you have multiple Perl apps using lots of different
libraries. Keep all of that up-to-date and making sure a needed
upgrade for one app doesn't break another is time consuming and,
frankly, not very fun. Docker allows you to keep each piece as
separate form each other one as you want.

On top of all of that goodness, Dockers can be reliably replicated. I
know that if I build a container and fully test it out on my laptop,
that it work exactly the same when it's deployed. That consistency is
great when it comes to the whole DevOps thing.

Converting to Docker
--------------------

Originally, this site was running on Nginx on an Ubuntu server in my
living room. The web server worked fine (it's a simple site after all)
but the apps would sometimes freak out.

I use Octopress to generate the site and I have a couple of Perl
scripts that do other things for me. That worked alright but Octopress
is written is Ruby and the gem system is even more fussy than the
CPAN. I don't know how many times updates broke because something
changed with a Ruby gem. Even worse was when I checked out the site
from git on another box I have some sort of problem get the deploy
step to work.

I had a great opportunity because I needed to move my site off of my
home server. I decided to set up shop at
[Digital Ocean](https://www.digitalocean.com/?refcode=7495d0eec1c9). DO
is a great place to run your own virtual private server and they make
it very easy to run certain applications like Wordpress and, more
importantly for me, Docker out of the box. Their Docker application
installs Docker on Ubuntu and is all ready to host Docker
containers. Docker installs easily on Ubuntu even without their app
but, hey, I'm all for making things easier on myself.

The first thing I needed to do was break down my site into pieces to
Dockerize. The current Docker best practice is to have a each
container do a single task. It this case, it was pretty simple to pick
out those tasks. I would need four containers. The first container I'd
need is nginx. Number two was for Octopress and three and four were
for my Perl scripts.

I took a little bit of working with Docker files to make sure all of
the needed libraries were installed for each app but that wasn't
hard. The real head scratcher was Octopress. You see, Octopress is
designed to deploy the generated pages via rsync to a remote
server. The rsync part is fine but I wasn't going to running ssh or an
rsync server in the nginx container just to publish
updates. I had to hack on Octopress a little to allow to publish to a
local directory and I was golden.

Now, let's dig into the containers.

### Nginx

This is the easiest of the bunch. On my first pass, I created a
Dockerfile which used the
[official nginx repository](https://registry.hub.docker.com/_/nginx/)
from the [Docker Hub Registry](https://registry.hub.docker.com/). The
only thing it changed was the location of the document root to match
what was on my server. It turns out that that was a bad idea. It was
easier to use the nginx repo unchanged and change apps to look to the
new document root. It's one less container for me to maintain and,
thanks to other magic I'll get to when I talk about CoreOS, it's
automatically updated.

I run the container with the following command: `/usr/bin/docker run
--rm --name perlstalker_web-server -v /var/www:/usr/share/nginx/html
-p 80:80 nginx`. There's one piece of special magic in that I map
`/var/www` to the default nginx doc root `/usr/share/nginx/html`. This
keeps the site data persistent even though the container is deleted
after every run and provides a nice hook for the other containers.

### Octopress

One of the first things I did to prep for this move (after I fixed my
rsync issue) was to move my
[repo](https://github.com/PerlStalker/perlstalker.vuser.org) up to
github. Now I had an easy way to get my site onto the server. The next
step was to build the container.

Below is the Dockerfile.

``` plain Octopress Dockerfile https://github.com/PerlStalker/perlstalker.vuser.org-containers/blob/master/deploy/Dockerfile Docker file on GitHub
FROM ubuntu:trusty
MAINTAINER Randall Smith <perlstalker@gmail.com>

RUN apt-get update

RUN apt-get install -y git ruby ruby-dev gems rbenv ruby-redcloth build-essential python-pygments nodejs

WORKDIR /usr/local/src
RUN git clone https://github.com/PerlStalker/perlstalker.vuser.org.git perlstalker.vuser.org
WORKDIR perlstalker.vuser.org
RUN gem install bundler
RUN rbenv rehash
RUN bundle install

ENTRYPOINT git pull && rake generate && rake deploy
```

When you run `docker build` against this Dockerfile, it will install
all of the necessary requirements, clones the site from github and
then finishes the install. Once that's complete, running the container
will pull the latest updates from github, generate the static pages
and deploy the site into the doc root.

The cool thing is that this container can be built once and run as
often as required. (I know. I'm easily amused.) The running containers
can even be removed on completion (with the `--rm` flag to `docker
run`) and re-run.

The other trick is to mount the document root from the nginx container
so that the generated files from Octopress get put in the right
place. Use the `--volumes-from` flag like so: `/usr/bin/docker run
--rm --name perlstalker_deploy --volumes-from perlstalker_web-server
perlstalker/sysadmin-deploy`.

### Scriptures Feed

One of the scripts I use on my site generates a RDF feed for my daily
scripture study. The code, including the Dockerfile, is up on
[github](https://github.com/PerlStalker/scripture-feed). I'm not going
to go into details. You can check out the Dockerfile for
yourself. Again, the trick is that it mounts the doc root from nginx
container.

## CoreOS

I ran on Ubuntu for a while but ran into an annoying problem when it
came to updates. You seen, Digital Ocean used an external kernel when
starting Ubuntu VMs. It's great, in one way, because it's really fast
to start up. On the other hand, it causes no end of problems when
working with Docker. I frequently ran into issues where I would forget
to change the kernel I was booting with to match what was just
installed by apt. Sometimes the VM wouldn't boot, other times docker
refused to start.

The other catch is that, to be honest, I got really tired of applying
patches to an OS that isn't really doing anything. All of the fun
stuff happens in Docker. I didn't exactly want to have to worry about
Ubuntu.

Fortunately, Digital Ocean rolled out the option to create
[CoreOS](https://coreos.com/) VMs. I decided to get in on that
action despite the beta status.

The big problem converting to CoreOS is that I had to learn
systemd. That was annoying but wasn't too bad. I'd like to share a
couple of the units to show the magic.

The first is the main web server.

``` plain perlstalker.service
[Unit]
Description=perlstalker.vuser.org web server
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/mkdir /var/www
ExecStartPre=/usr/bin/docker pull nginx
ExecStart=/usr/bin/docker run --rm --name perlstalker_web-server -v /var/www:/usr/share/nginx/html -p 80:80 nginx

[Install]
WantedBy=multi-user.target
```

I want to draw your attention to the `ExecStartPre` lines. The first
one creates the persistent storage for the web site pages. The `-`
prefix tells to systemd to ignore errors like, for example, the
directory already exists.

It's the second one that's interesting. Every time the service
restarts, it pulls an updated nginx image. That means that every time
my server reboots or the service is restarted, I get a fully updated,
patched and, theoretically, secure web server.

The next big piece is the Octopress deployment.

``` plain deploy.service
[Unit]
Description=Generate and deploy site
After=perlstalker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
RemainAfterExit=no
Type=simple
ExecStartPre=/usr/bin/docker pull perlstalker/sysadmin-deploy
ExecStart=/usr/bin/docker run --rm --name perlstalker_deploy --volumes-from perlstalker_web-server perlstalker/sysadmin-deploy
```

Now, every time I run ```systemctl start deploy```, the Octopress
Docker updates the site.

I want to show you two last systemd units which trigger the update of
my scriptures feed, in part, because I want to remember to crazy way
systemd replaces cron.

Every cron needs to two units. One is the `.service` file which
defines what actually happens.

``` plain scriptures.service
[Unit]
Description=Generate scriptures feed
After=perlstalker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
RemainAfterExit=no
Type=simple
ExecStartPre=/usr/bin/docker pull perlstalker/scripture-feed
ExecStart=/usr/bin/docker run --rm --name perlstalker_scriptures --volumes-from perlstalker_web-server perlstalker/scripture-feed
```

The second one is a `.timer` file which sets the schedule.

``` plain scriptures.service
[Unit]
Description=Generate scriptures feed
        
[Timer]
OnBootSec=25min
OnCalendar=*-*-* 04:30:00
Persistent=true
        
[Install]
WantedBy=timers.target
```

Make sure that you run `systemd enable scriptures.timer` and `systemd
start scriptures.timer`. I forgot to do that then wondered why my feed
didn't update. :-)

I want to make a point here that may have been lost in my digression
into systemd mazes. I didn't have to change any of containers. I
simply plugged them into the systemd on CoreOS and my site was flying
again. If at some point, I decide to move to some other service such
as GCE or EC2, I can drop my containers in, easy peasy.

Anyway, the point of this little screed is to show how a few building
blocks or, shall I say, containers, can be stacked together to build
whatever you need. Even if it's something as trivial as my little
site.
