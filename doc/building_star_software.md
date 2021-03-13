This is a basic set of instructions for STAR users who are not familiar with
Git. In the following we assume that the `git` version is at least 2.26.2 just
like the one installed on RACF for STAR users. We also use the `star-sw` name
for the Git repository and the remote location at
https://github.com/star-bnl/star-sw.git  which is likely to change.


## How to get the STAR code from the Git repository

The easiest way to get a local copy of the entire codebase with the history of
changes is to do:

    $ git clone https://github.com/star-bnl/star-sw.git

Then `cd` into the newly created directory, look around, and browse the history
with one of the popular utilities, e.g. `gitk` or `tig` (usualy available along
with `git`):

    $ cd star-sw
    $ ls -a
    .  ..  asps  .git  kumacs  mgr  OnlTools  pams  StarDb  StarVMC  StDb  StRoot
    $ git status
    On branch master
    Your branch is up to date with 'origin/master'.

    nothing to commit, working tree clean
    $ tig
