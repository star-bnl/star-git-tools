This is a basic set of instructions for STAR users who are not familiar with
Git. In the following we assume that the `git` version is at least 2.17.0 just
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


## How to checkout only one or a few packages/subdirectories

This is called a sparse checkout. In this case you start by cloning the bare
repository

    $ git clone --no-checkout https://github.com/star-bnl/star-sw.git
    $ ls -a star-sw/
    .  ..  .git

Note that the above command will still create a local copy of the entire
history in `.git` so you can switch between different versions later (There is
also a way to limit the amount of cloned history). Let `git` know that you want
to work with a limited number of modules

    $ cd star-sw/
    $ git config core.sparseCheckout true

Now create and modify the `.git/info/sparse-checkout` file to include a list of
packages/subdirectories you want to work with locally. The contents of the file
may look like this

    $ cat .git/info/sparse-checkout
    StRoot/Sti

or like this

    $ cat .git/info/sparse-checkout
    StRoot/StTofCalibMaker
    StRoot/StTofHitMaker
    StRoot/StTofMaker

wild cards are also possible to use

    $ cat .git/info/sparse-checkout
    StRoot/StPico*

Finally, ask `git` to checkout the selected subdirectories

    $ git checkout SL20a
    $ ls -a StRoot/
    .  ..  StPicoDstMaker  StPicoEvent

Assuming the default STAR environment on a RACF interactive node the code can be
compiled as usual with the `cons` command.


## How to build a release

A decision was made not to migrate the MC event generators (MCEG) originally
present in the STAR CVS repository into the primary Git repository
[`star-sw`](https://github.com/star-bnl/star-sw). Instead the event
generators were moved into a separate Git repository
[`star-mcgen`](https://github.com/star-bnl/star-mcgen). This separation
underlines the external nature of the MCEGs to the rest of the STAR codebase
and allows to build these libraries independently only when necessary.
Meanwhile, in order to build a release with all the libraries one can merge the
code from the two repositories into a single local directory and proceed as
usual. For example, to get the code corresponding to the `SL20a` tag do

    mkdir release-SL20a && cd release-SL20a
    curl -sL https://github.com/star-bnl/star-sw/archive/SL20a.tar.gz | tar -xz  --strip-components 1
    curl -sL https://github.com/star-bnl/star-mcgen/archive/SL20a.tar.gz | tar -xz  --strip-components 1

At this point the code can be compiled as usual, e.g. by running `cons`.
Similarly, to get the most recent code for the "DEV" release replace `SL20a`
with `master` in the above example.
