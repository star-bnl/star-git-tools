git-star-checkout(1) -- Partial clone and sparse checkout from STAR repo
========================================================================

## SYNOPSIS

`git-star-checkout`
`git-star-checkout` &lt;path1&gt; [&lt;path2&gt; ...]

## DESCRIPTION

Check out specified subdirectories from the STAR repository. A partial clone is
performed prior to the checkout if the local directory is not a previously
cloned repository

## OPTIONS

&lt;pathN&gt;

The path to a subdirectory in the STAR repository to check out

## EXAMPLES

Checking out a single subdirectory

    $ git star-checkout StRoot/StMuDSTMaker

Checking out multiple subdirectories

    $ git star-checkout StRoot/macros StarDb/Calibrations/tpc

## REPORTING BUGS

&lt;<https://github.com/star-bnl/star-git-tools/issues>&gt;

## SEE ALSO

&lt;<https://github.com/star-bnl/star-git-tools>&gt;
