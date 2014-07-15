---
layout: post
title: "Endnotes with Org-mode"
date: 2014-07-15 12:00:00 -0600
comments: true
categories:
- emacs
- org-mode
---

I was recently writing an internal peer review for work. Because I'm a
happy emacs user, I wrote the peer review in org-mode and exported it
to PDF using `org-latex-export-to-pdf`. The problem was that our
interal format requires that I use endnotes and emacs exports my
footnotes as, well, footnotes. So, here's the quick and dirty on how I
got the exporter to give me end notes.

First of all, you need to tell LaTeX that you want to use
endnotes. I put it at the begining of my org file with the rest of the
boilerplate.

    #+LaTeX_HEADER: \usepackage{endnotes}
    #+LaTeX_HEADER: \let\footnote=\endnote

The first line loads the endnotes packge and the second says that you
want it to treat your footnotes as if they were endnotes.

Then, at the end of your document, drop this block.

    * Endnotes
    #+LaTeX: \begingroup
    #+LaTeX: \parindent 0pt
    #+LaTeX: \parskip 2ex
    #+LaTeX: \def\enotesize{\normalize}
    #+LaTeX: \theendnotes
    #+LaTeX: \endgroup

That works great except that LaTeX will drop a second heading called
"Notes", by default. Well, I'm using my own heading so that it shows
up nicely in the table of contents. It's possible to make the heading
go away with this line.

    #+LaTeX_HEADER: \renewcommand{\notesname}{}

Unfortunately, it leaves the extra space where the heading would have
been. I'm sure there's a way to get rid of that but I didn't take the
time to figure it out. If you know, drop a comment below.
