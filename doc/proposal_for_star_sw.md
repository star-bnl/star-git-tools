# Proposal for Improving the Software Development Infrastructure in STAR

As of mid 2020, the STAR collaboration still uses CVS to manage changes in its
source codebase. CVS is an old centralized version control system (VCS) while
distributed version control systems (DVCS) such as Git are being very popular
nowadays. Git is accepted as a standard VCS by the vast majority of the
developer's community. The principal difference between CVS and Git is usually
regarded as the ability of each developer to have the full control offered by
the DVCS over a local copy of the entire code revision history.

## Why Git?

- Git is widely accepted by software developers owing to its usability and
  performance

- Git has powerful branching capabilities. Developing new features on a new
branch ensures that the master branch is not affected

- Free Github and Gitlab services offer easy auditing of branches and code
  merges

  - Excellent interfaces for new code integration, peer reviews, and issue
    follow-ups

- Among other nuclear and particle physics experiments, STAR is probably the
  only active experiment that has not switched to Git. See public software
  repositories of ALICE, ATLAS, CMS, DUNE, EIC, sPHENIX, etc.

## Phase 1. Converting CVS to Git

Below we outline a few steps to convert the code from CVS to Git. Based on the
experience of the BNL's NPPS group we recommend to host the central copy of the
new Git repository on Github.

### Step 1. Conversion

- We propose to use the `cvs2git` utility to do a CVS to Git conversion of
  select CVS directories **once**. An example illustrating the use of `cvs2git`
  can be found in this bash script
  [cvs2git_cron.sh](https://github.com/star-bnl/star-sw/blob/master/scripts/cvs2git_cron.sh)

  - Directories not containing the source code or relevant scripts (i.e. paper
    drafts and analyses codes) can be excluded from the conversion, e.g. see
    file
    [cvs2git_paths.txt](https://github.com/star-bnl/star-sw/blob/master/scripts/cvs2git_paths.txt)

  - The top-level directories in the CVS repository essential for event
    reconstruction and simulation are:

        asps/
        kumacs/
        mgr/
        OnlTools/
        pams/
        StarDb/
        StarVMC/
        StDb/
        StRoot/

- A Git mirror of the STAR CVS repository has been created with the
  aforementioned scripts. It is available for review at
  [https://github.com/star-bnl/star-cvs](https://github.com/star-bnl/star-cvs)

- TODO: It is possible to preserve the original author name of a commit by
  providing a mapping between the RACF login account and the corresponding
  user's name and email. In Git committers are identified by their email

- **Timescale**: Everything is available to perform the conversion now

### Step 2. Verification

- To make sure the source code is identical after the conversion from CVS to Git
  we propose to run `diff` recursively over all extracted directories for all or
  selected tagged releases. TODO: A script performing this task

- **Timescale**: One week

### Step 3. Integration

- Setup nightly tests to pull changes from the remote Git repository

  - At this stage the code can be compiled using `cons` and tested as usual

- Establish procedure for users submitting modifications to the code base

  - The widely accepted workflow of pull requests should be sufficient

  - The respective software coordinators should sign-off on submitted code
    changes

- Prohibit commits to the CVS repository

- **Timescale**: One week to setup nightly tests to pull code from a Git
  repository. A weekend to disable access to the transferred code in CVS

## Phase 2. Building libraries with CMake

TBC
