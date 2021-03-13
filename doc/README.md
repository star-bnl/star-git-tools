
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
