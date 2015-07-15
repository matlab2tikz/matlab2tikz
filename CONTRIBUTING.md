# Contributing to matlab2tikz

You can contribute in many ways to `matlab2tikz`:
 - report bugs,
 - suggest new features,
 - write documentation,
 - fix some of our bugs and implement new features.

The first part of this document is geared more towards "users" of matlab2tikz.
The latter part is relevant if you want to write some code for `matlab2tikz`.

## How to report a bug or ask for help

 1. Make sure you are using the [latest release](https://github.com/matlab2tikz/matlab2tikz/releases/latest) or even the [development version](https://github.com/matlab2tikz/matlab2tikz/tree/develop) of `matlab2tikz` and check that the problem still exists.
 2. Also make sure you are using a recent version of the required LaTeX packages (especially `pgfplots` and the `TikZ` libraries)
 3. You can submit your bug report or question to our [issue tracker](https://github.com/matlab2tikz/matlab2tikz/issues).
    Please, have a look at "[How to Ask Questions the Smart Way](http://www.catb.org/esr/faqs/smart-questions.html)" and "[Writing Better Bug Reports](http://martiancraft.com/blog/2014/07/good-bug-reports/)" for generic guidelines. Make sure you include the following things:
    - The version of MATLAB/Octave, the operating system, `matlab2tikz`, `pgfplots` and which `LaTeX` compiler you are using.
    - Choose a descriptive title.
    - A short MATLAB code snippet that generates a plot where the problem occurs. Please limit this to what is strictly necessary to show the issue!
    - Explain what is wrong with how the figure is converted (or what error messages you see).
    - Often it can be useful to also include a figure, `TikZ` code, ... to illustrate your point.

## How to request new features

Please check first whether the feature hasn't been [requested](https://github.com/matlab2tikz/matlab2tikz/labels/feature%20request) before and do join the relevant topic in that case or maybe it has already been implemented in the [latest development version](https://github.com/matlab2tikz/matlab2tikz/tree/develop).

If your feature is something new and graphical, please also have a look at the [`pgfplots`](https://www.ctan.org/pkg/pgfplots) manual to see whether what you want is supported by this package.
In some cases it is more constructive to request the feature for `pgfplots` in [their bug tracker](https://sourceforge.net/p/pgfplots/bugs/).

Please submit you feature request as any [bug report](https://github.com/matlab2tikz/matlab2tikz/labels/feature%20request) and make sure that you include enough details in your post, e.g.:
 - What are you trying to do?
 - What should it look like or how should it work?
 - Is there a relevant section in the `pgfplots` or `MATLAB` documentation?

## Submitting pull requests (PRs)
Before you start working on a bug or new feature, you might want to check that nobody else has been assigned to the relevant issue report.
To avoid wasted hours, please just indicate your interest to tackle the issue.

### Recommended workflow
[Our wiki](https://github.com/matlab2tikz/matlab2tikz/wiki/Recommended-git-workflow) contains more elaborate details on this process.
Here is the gist:
 - It is highly recommended to start a feature branch for your work.
 - Once you are finished with the work, please try to run the test suite and report on the outcome in your PR (see below).
 - Make sure that you file your pull request against the `develop` branch and *not* the `master` branch!
 - Once you have filed your PR, the review process starts. Everybody is free to join this discussion.
 - Before a PR is pulled into `develop`, at least one other developer should review the code and signal their approval (often using a thumbs-up `:+1:` ).
 - After all comments have been addressed, a developer will merge your code into the `develop` branch.

If you still feel uncomfortable with `git`, please have a look at [this page](https://github.com/matlab2tikz/matlab2tikz/wiki/Learning-git) for a quick start.

### Running the test suite
We know that at first the test suite can seem a bit intimidating, so we tend to be very lenient during your first few PRs.
However, we strongly recommend you run the test suite on your local computer and report on the results in your PR if any failures pop up.
To run the test suite, please consult its [README](https://github.com/matlab2tikz/matlab2tikz/blob/develop/test/README.md).

## Becoming a member of [matlab2tikz](https://github.com/matlab2tikz)

Once you have submitted your first pull request that is of reasonable quality, you may get invited to join the [Associate Developers](https://github.com/orgs/matlab2tikz/teams/associate-developers) group.
This group comes with *no* responsibility whatsoever and merely serves to make it easier for you to "claim" what features you want to work on.

Once you have gained some experience (with `git`/GitHub, our codebase, ...) and have contributed your fair share of great material, you will get invited to join the [Developers](https://github.com/orgs/matlab2tikz/teams/developers) team.
This status gives you push access to our repository and hence comes with the responsibility to not abuse your push access.

If you feel you should have gotten an invite for a team, feel free to contact one of the [owners](https://github.com/orgs/matlab2tikz/teams/owners).
