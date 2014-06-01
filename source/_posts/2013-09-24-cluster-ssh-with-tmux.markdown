---
layout: post
title: "Cluster SSH with tmux"
date: 2013-09-24 17:00
comments: true
categories: "tmux"
---

<p>
I was working today and, as I glanced at #lopsa, I saw this little
gem.
</p>

<blockquote>
<p>
13:50 &lt;geekosaur&gt; tmux has a broadcast-to-all-terminals thing
</p>
</blockquote>

<p>
Wait, what?! I had to check it out. It turns out that tmux has a
window option called <code>synchronize-panes</code> which lets you "Duplicate
input to any pane to all other panes in the same window."
</p>

<p>
I've been using <a href="http://sourceforge.net/projects/clusterssh/">cluster ssh</a> to occasionally log into a bunch of my
boxes at once and run the same command on all of them at the same
time. It's really nice for troubleshooting checking on the same thing
on a bunch of servers all at once. It works pretty well but has the
drawback that it depends on having X available. That's a concern if I
have to bridge through my machine and work and want to talk to a cluster.
</p>

<p>
I played around a bit and came up with a way for me to replicate when
I was doing with cssh. The first bit is the following script which is
based on <a href="http://www.christoph-egger.org/weblog/entry/33">this example</a>.
</p>

<div class="org-src-container">

<pre class="src src-sh"><span style="color: #ff7f24;">#</span><span style="color: #ff7f24;">!/bin/</span><span style="color: #00ffff;">bash</span>
<span style="color: #eedd82;">HOSTS</span>=

<span style="color: #00ffff;">if</span> [ $<span style="color: #eedd82;">1</span> = <span style="color: #ffa07a;">'cluster1'</span> ]; <span style="color: #00ffff;">then</span>
    <span style="color: #eedd82;">HOSTS</span>=<span style="color: #ffa07a;">"host1 host2 host3"</span>
<span style="color: #00ffff;">elif</span> [ $<span style="color: #eedd82;">1</span> = <span style="color: #ffa07a;">'cluster2'</span> ]; <span style="color: #00ffff;">then</span>
    <span style="color: #eedd82;">HOSTS</span>=<span style="color: #ffa07a;">"hostA hostB hostC hostD hostE hostF"</span>
<span style="color: #00ffff;">else</span>
    <span style="color: #00ffff;">exit</span>
<span style="color: #00ffff;">fi</span>

<span style="color: #00ffff;">for</span> host<span style="color: #00ffff;"> in</span> $<span style="color: #eedd82;">HOSTS</span>
<span style="color: #00ffff;">do</span>
    tmux splitw <span style="color: #ffa07a;">"ssh $host"</span>
    tmux select-layout tiled
<span style="color: #00ffff;">done</span>
tmux set-window-option synchronize-panes on
</pre>
</div>

<p>
Tmux can be controlled completely from the command line or from a
script. This script takes a cluster name on the command line and opens
a ssh session to each host in the list in a new pane. The last line is
the magic. It turns on the synchronization so what gets typed in one
pane is echoed to the others as well.
</p>

<p>
Now, this isn't perfect. Unfortunately, the tiling doesn't end up
right when I use more than three or four servers. A quick <code>C-z M-5</code>
takes care of it but it's annoying. (Note: I changed <code>send-prefix</code>
from the default of <code>C-b</code> to <code>C-z</code>. Adjust your thinking accordingly.)
</p>

<p>
I've made the following changes to <code>~/.tmux.conf</code> to make this easier
to use.
</p>

<pre class="example">
bind-key M-s command-prompt -p "cluster" "new-window -n %1 'tssh %1'"
bind-key M-a set-window-option synchronize-panes
</pre>

<p>
The first line maps <code>C-z M-s</code> so that it prompts me for a cluster name
then opens a new window with all of the connections.
</p>

<p>
The second line provides an easy way to toggle the synchronization on
and off. That makes it nice for ad hoc cluster views. Sometimes, I'm
looking at a couple of servers and I want to perform a few commands on
them both to check things. A quick <code>C-z M-a</code> and I can issue the
commands to both servers. Hitting <code>C-z M-a</code> turns it off again.
</p>

<p>
There you go. A quick and easy way to get work on many servers all at
once without the need for X.
</p>
