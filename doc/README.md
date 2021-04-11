In this document we collect information and instructions to help the
collaborators of the STAR experiment at BNL with their use of the software.

- [Where is the source code?](#where-is-the-source-code%3F)
- [How to access STAR repository hosted on GitHub](#how-to-access-star-repository-hosted-on-github)
  - [Using HTTPS](#using-https)
  - [Using SSH](#using-ssh)
  - [Creating SSH tunnel](#creating-ssh-tunnel)
- [How to checkout only one or a few packages/subdirectories](#how-to-checkout-only-one-or-a-few-packages%2Fsubdirectories)
- [Workflow with STAR Git repositories](#workflow-with-star-git-repositories)
- [How to build a release](#how-to-build-a-release)
- [Equivalent commands for Git and CVS](#equivalent-commands-for-git-and-cvs)

<hr width=80%>


## Where is the source code?

The primary repositories containing the STAR code and other support packages are
hosted on GitHub:

- https://github.com/star-bnl/star-sw  &mdash; Contains the code need to
  reconstruct raw data collected by the experiment

- https://github.com/star-bnl/star-mcgen &mdash; Contains Monte-Carlo generators
  and the respective interfaces for simulating detector data


## How to access STAR repository hosted on GitHub

### Using HTTPS

The easiest way to get a local copy of the entire `star-sw` repository with the
history of all changes is to do:

    $ git clone https://github.com/<YOUR-USERNAME>/star-sw.git

Then `cd` into the newly created directory, look around, and browse the history
with one of the popular utilities, e.g. `gitk`, `tig` (usualy available along
with `git`), or simply use the `git log` command:

    $ cd star-sw
    $ ls -a
    .  ..  asps  .git  kumacs  mgr  OnlTools  pams  StarDb  StarVMC  StDb  StRoot
    $ git status
    On branch main
    Your branch is up to date with 'origin/main'.

    nothing to commit, working tree clean
    $ git log

The above example shows how to clone the `star-sw` repository via `https://`
protocol. When you `git clone`, `git fetch`, `git pull`, or `git push` to the
remote repository the server will ask for your GitHub username and password. The
password is actually your personal access token that you need to create under
your account settings. For more information, see "[Creating a personal access
token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)."

Some may find it inconvenient to enter credentials every time you issue
a command to communicate with the remote repository. It is possible to avoid
such prompts by [Caching your GitHub credentials in
Git](https://docs.github.com/en/github/using-git/caching-your-github-credentials-in-git).
Alternatively, one can use the SSH keypair mechanism in combination with
`ssh-agent` to let Git authenticate without distracting the user.


### Using SSH

To work with your STAR repository via SSH you must first generate an SSH keypair
on your computer and then add the **public** key to your GitHub account. For
more information, see "[Connecting to GitHub with
SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)."
Once the public key is uploaded to GiHub you can add the private key to the
`ssh-agent` running in the background. This setup should completely eliminate
the need to enter credentials when working with the remote.

The command to clone your repository via SSH will look like this:

    $ git clone git@github.com:<YOUR-USERNAME>/star-sw.git


### Creating SSH tunnel

In case a direct communication to GitHub's SSH service is not possible one can
set up an SSH tunnel. Let's say you create a tunnel to map the remote server to
your local port 7777 via a gateway:

    $ ssh -f -N -L 7777:github.com:22 login@gateway

then you should be able to clone the repo using the following command:

    $ git clone ssh://git@localhost:7777/<YOUR-USERNAME>/star-sw.git

Note the addition of the `ssh://` prefix. It helps Git to recognize the general
URL syntax specifying the port number.


## How to checkout only one or a few packages/subdirectories

This is called a sparse checkout. In this case you start by cloning the bare
repository

    $ git clone --no-checkout https://github.com/<YOUR-USERNAME>/star-sw.git
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


## Workflow with STAR Git repositories

We adopt a very common workflow typical for many projects hosting a central
repository on GitHub. It can be summarized in a few steps outlined below:

1. **Fork the repo.** A "copy" of the central repository is created under your
  GitHub account

2. **Clone your fork.** A local "copy" of the repository is created on your
   machine by using a Git command similar to this:

   ```shell
   $ git clone git@github.com:&lt;YOUR-USERNAME&gt;/star-sw.git
   ```

3. **Make changes locally.** The code is modified and commits with informative
   log messages created

4. **Push to your fork.** The changes are sent to your fork hosted on GitHub

   ```shell
   $ git push
   ```

5. **Create a pull request.** Let others know that you want to merge your
  changes into the central repository


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
with `main` in the above example.


## Equivalent commands for Git and CVS

Here is a small table with equivalent commands for Git and CVS repositories.

Description                                    | CVS               | GIT
---                                            | ---               | ---
Show status of repository                      | `cvs status`      | `git status                                `
Add new files to repository                    | `cvs add <files>` | `git add <files>                           `
Commit changes in existing files to repository | `cvs commit`      | `git add -u <files> && git commit && git push`
Retrieve changes from repository               | `cvs update`      | `git pull                                  `
Show log of changes to a file                  | `cvs log <file>`  | `git log <file>                            `
Show changes in commit/revision                |                   | `git show commit                           `
Resolve conflicts in files                     |                   | `git mergetool                             `
