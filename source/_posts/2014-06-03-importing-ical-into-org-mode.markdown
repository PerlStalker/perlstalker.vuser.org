---
layout: post
title: "Importing iCal Into Org-mode"
date: 2014-06-03 20:59:28 -0600
comments: true
categories:
- ical
- emacs
- org-mode
---

I've been using emacs and [org-mode](http://orgmode.org) for some time
to manage my tasks. Org-mode has a great feature which shows and
agenda view which includes upcoming scheduled items and deadlines. One
of the things that was missing was the ability to view my calendar
(which is in Google Calendar) in the agenda.

There are a couple of ways of dealing the syncing the calendar
data. One of the ways I tried was
[org-caldav](https://github.com/dengste/org-caldav). It kind of
worked. Sort of. It did import the caledar but it failed spectaculary
with repeating tasks set in Google by me or others. Since most of the
things on my calendar are repeating events, this was a problem.

Alright, so org-caldav didn't work for me. I could have looked for
something else that did two-way sync but, in the end, it wasn't that
important to me. So, I worked up a way to do pull the iCal feed from
Google and convert it into an org-mode file.

The first is a pretty simple script that pulls down the iCal files and
pumps it through the translation script. I run this from cron every
ten minutes.

{% include_code fetch-calendars.pl lang:perl fetch-calendars.pl %}

The fun part is in ical2org.pl.

{% include_code ical2org.pl lang:perl ical2org.pl %}

I let Data::ICal parse the feed and DataTime::Format::ICal do the
heavy lifting of parsing the date and time information from each
entry. (Have I mentioned how cool the CPAN is?)

Most of the code is just reformating the iCal entry into org-mode
syntax so that emacs can pull it into the agenda.

There's one bit of magic I'm not showing here. In my .emacs config, I
have this little gem.

{% codeblock %}
(add-hook 'org-mode-hook 'auto-revert-mode)
{% endcodeblock %}

That tells emacs to automatically revert (reload) any org-mode file
that changes on disk while the buffer is open. Since I drop the
converted files in a directory scanned by org-mode, emacs opens each
converted calendar file in a buffer when the agenda view is first
run. When the files are updated by the scripts above, emacs sees the
changes and reverts the buffers. Anytime I regenerate the agenda view,
emacs uses the updated buffers and the view is up-to-date.

Once again, this is a one way sync. I can't edit the generated
org-mode files and see the changes reflected in the Google
calendars. If I want to make changes to my calendar, I have to do it
through Google's web interface. This actually works out for the best
because Google provides all of the scheduling hooks to make sure
others who I've invited to meetings can attend. I can't get that,
easily, in emacs.

So, there you go. A relatively pain free way to pull any iCal calendar
into emacs.

*Update 2016-01-21*: I've incorporated a suggestion from Anders
Johansson that prevents ical2org.pl from syncing old events. I set the
default to two weeks in the past. To get the old behavior set
`$syncweeksback` to 0.
