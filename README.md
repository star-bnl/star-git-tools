# Git for STAR users

This collection of tools is provided to the users of the STAR experiment with
the hope to help them overcome difficulties caused by the migration of the
codebase to Git.


## Installing star-git-tools

Obtain the star-git-tools source by cloning [its GitHub
repo](https://github.com/star-bnl/star-git-tools.git). Then install it by doing
`make install` from the source tree.

```bash
$ git clone https://github.com/star-bnl/star-git-tools.git
$ cd star-git-tools
$ [sudo] make install
```

By default, star-git-tools is installed under `/usr/local`. To install it at
an alternate location, specify a `PREFIX` when calling `make`. Then make sure
`PREFIX` is in the `PATH`.

```bash
# Non-root users can install under their home directory
make install PREFIX=$HOME/some/path

# For third-party software kept under /opt/star
make install PREFIX=/opt/star

# Add `PREFIX` to the `PATH`. E.g. bash users can add to their ~/.bashrc file
export PATH+=":$HOME/some/path"
```


## Commands

A basic usage and examples 

### git-star-checkout

Do a partial clone followed by a sparse checkout of specified directories

```bash
$ git star-checkout StRoot/StPicoEvent StRoot/StMuDSTMaker
```
