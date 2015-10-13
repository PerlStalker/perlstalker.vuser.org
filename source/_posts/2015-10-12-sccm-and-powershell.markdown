---
layout: post
title: "SCCM Updates and Powershell"
date: 2015-10-12 16:53:00 -0600
comments: true
categories:
- SCCM
- WMI
- CIM
- powershell
---

Microsoft is doing cool things with Windows Server with what was
originally server core and is now the base version of Windows
Server. Combined with Powershell remoting and there's a lot of power
from the command line. Unfortunately, is surprisingly difficult to
tell if updates are available and to trigger their installation.

If you're not using SCCM, you can run `sconfig.exe` and select option
6 to manage your updates but packages and applications pushed through
SCCM don't show up there.

Now, SCCM has reports so that you can what's pending but sometimes,
it's nice to be able to see what the server sees as pending and to
make sure that it's getting your planned updates. Fortunately, it's
possible to pull that information out of WMI and CIM. The cool thing
about powershell is that it's really easy to pipe this update
information into other tools, if needed.

Without further ado, here are a couple of one-liners for playing with SCCM.

List updates: `gcim -namespace root\ccm\clientsdk -query 'Select * from CCM_SoftwareUpdate'`

Easy, huh. Remember powershell's pipeline is pretty powerful. If all you need is
a count of updates, you can do something like this. `(gcim -namespace root\ccm\clientsdk -query \'Select * from CCM_SoftwareUpdate\' | measure-object).Count`

You can also assign that list of update to a variable like so:
`$updates = gcim -namespace root\ccm\clientsdk -query 'Select * from
CCM_SoftwareUpdate'`. Now you can use `$updates` in other commands
without having to query CMI again.

Now that you've seen the list, you might want to tell the server to
install anything that has a deadline set. `iwmi -namespace root\ccm\clientsdk -Class CCM_SoftwareUpdatesManager -name InstallUpdates([System.Management.MangementObject[]](gwmi -namespace root\ccm\clientsdk -query \'Select * from CCM_SoftwareUpdate\'))`

Now that the updates are installed, you can check to see if the server
needs a reboot by running `(icim -namespace root\ccm\clientsdk
-ClassName CCM_ClientUtilities -Name
DetermineIfRebootPending).RebootPending`.

If you're RDP'd into a host, you can open the Software Center by running `c:\windows\ccm\scclient.exe`.

One last thing, I have
[a plugin for salt](https://github.com/PerlStalker/salt-sccm) that can
run a lot of these things for you across many hosts. It needs some
work to fit better into the salt way of doing things. Contributions welcome.
