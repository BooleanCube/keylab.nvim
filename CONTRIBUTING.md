# Contributing

## Introduction

Thank you so much for your interest in contributing!. All types of contributions are encouraged and valued.

We looks forward to your contributions. 🙌🏾✨

## Project Setup

So you wanna contribute some code! That's great! This project uses GitHub Pull Requests to manage contributions, so [read up on how to fork a GitHub project and file a PR](https://guides.github.com/activities/forking) if you've never done it before.

If this seems like a lot or you aren't able to do all this setup, you might also be able to [edit the files directly](https://help.github.com/articles/editing-files-in-another-user-s-repository/) without having to do any of this setup. Yes, [even code](#contribute-code).

If you want to go the usual route and run the project locally, though:

- [Install Neovim 0.9+](https://neovim.io/)
- [Install Lua](https://www.lua.org/download.html)
- [Fork the project](https://guides.github.com/activities/forking/#fork)

Then in neovim:

- Install the local fork of the repository and configure it to your liking as shown in the [README.md](README.md)

And you should be ready to go!

## Contribute Documentation

Collaborator Category: Committer

Documentation is a super important, critical part of this project. Docs are how we keep track of what we're doing, how, and why. It's how we stay on the same page about our policies. And it's how we tell others everything they need in order to be able to use this project -- or contribute to it. So thank you in advance.

Documentation contributions of any size are welcome! Feel free to file a PR even if you're just rewording a sentence to be more clear, or fixing a spelling mistake!

To contribute documentation:

- [Set up the project](#project-setup).
- Edit or add any relevant documentation.
- Make sure your changes are formatted correctly and consistently with the rest of the documentation.
- Re-read what you wrote, and run a spellchecker on it to make sure you didn't miss anything.
- In your commit message(s), begin the first line with `docs:`. For example: `docs: Adding a doc contrib section to CONTRIBUTING.md`.
- Write clear, concise commit message(s) using [conventional-changelog format](https://github.com/conventional-changelog/conventional-changelog-angular/blob/master/convention.md). Documentation commits should use `docs(<component>): <message>`.
- Go to https://github.com/BooleanCube/keylab.nvim/pulls and open a new pull request with your changes.
- If your PR is connected to an open issue, add a line in your PR's description that says `Fixes: #123`, where `#123` is the number of the issue you're fixing.

## Contribute Code

Collaborator Category: Committer

We like code commits a lot! They're super handy, and they keep the project going and doing the work it needs to do to be useful to others.

Code contributions of just about any size are acceptable!

The main difference between code contributions and documentation contributions is that contributing code requires inclusion of relevant tests for the code being added or changed. Contributions without accompanying tests will be held off until a test is added, unless the maintainers consider the specific tests to be either impossible, or way too much of a burden for such a contribution.

To contribute code:

- [Set up the project](#project-setup).
- Make any necessary changes to the source code.
- Include any [additional documentation](#contribute-documentation) the changes might need.
- Write tests that verify that your contribution works as expected when necessary.
- Make sure all tests passed by command `:PlenaryBustedDirectory tests/` in your neovim.
- Write clear, concise commit message(s) using [conventional-changelog format](https://github.com/conventional-changelog/conventional-changelog-angular/blob/master/convention.md).
- Go to https://github.com/BooleanCube/keylab.nvim/pulls and open a new pull request with your changes.
- If your PR is connected to an open issue, add a line in your PR's description that says `Fixes: #123`, where `#123` is the number of the issue you're fixing.

Once you've filed the PR:

- Barring special circumstances, maintainers will not review PRs until all checks pass (Codecov, etc).
- One or more maintainers will use GitHub's review feature to review your PR.
- If the maintainer asks for any changes, edit your changes, push, and ask for another review. Additional tags (such as `needs-tests`) will be added depending on the review.
- If the maintainer decides not to pass on your PR, they will thank you for the contribution and explain why they won't be accepting the changes. Please don't feel offended. We still really appreciate you taking the time to do it, and we don't take that lightly. 💚
- If your PR gets accepted, it will be marked as such, and merged into the `latest` branch soon after. Your contribution will be distributed to the masses next time the maintainers tag a release

## Provide Support on Issues

Collaborator Category: Issue Tracker

Helping out other users with their questions is a really awesome way of contributing to any community. It's not uncommon for most of the issues on an open source projects being support-related questions by users trying to understand something they ran into, or find their way around a known bug.

Sometimes, the `support` label will be added to things that turn out to actually be other things, like bugs or feature requests. In that case, suss out the details with the person who filed the original issue, add a comment explaining what the bug is, and change the label from `support` to `bug` or `feature`. If you can't do this yourself, @mention a maintainer so they can do it.

In order to help other folks out with their questions:

- Go to the issue tracker and [filter open issues by the `support` label](https://github.com/BooleanCube/keylab.nvim/issues?q=is%3Aopen+is%3Aissue+label%3Asupport).
- Read through the list until you find something that you're familiar enough with to give an answer to.
- Respond to the issue with whatever details are needed to clarify the question, or get more details about what's going on.
- Once the discussion wraps up and things are clarified, either close the issue, or ask the original issue filer (or a maintainer) to close it for you.

Some notes on picking up support issues:

- Avoid responding to issues you don't know you can answer accurately.
- As much as possible, try to refer to past issues with accepted answers. Link to them from your replies with the `#123` format.
- Be kind and patient with users -- often, folks who have run into confusing things might be upset or impatient. This is ok. Try to understand where they're coming from, and if you're too uncomfortable with the tone, feel free to stay away or withdraw from the issue. (note: if the user is outright hostile or is violating the CoC, [refer to the Code of Conduct](CODE_OF_CONDUCT.md) to resolve the conflict).

## Review Pull Requests

Collaborator Category: Issue Tracker

While anyone can comment on a PR, add feedback, etc, PRs are only _approved_ by team members with Issue Tracker or higher permissions.

PR reviews use [GitHub's own review feature](https://help.github.com/articles/about-pull-request-reviews/), which manages comments, approval, and review iteration.

Some notes:

- You may ask for minor changes ("nitpicks"), but consider whether they are really blockers to merging: try to err on the side of "approve, with comments".
- _ALL PULL REQUESTS_ should be covered by a test: either by a previously-failing test, an existing test that covers the entire functionality of the submitted code, or new tests to verify any new/changed behavior. All tests must also pass and follow established conventions. Test coverage should not drop, unless the specific case is considered reasonable by maintainers.
- Please make sure you're familiar with the code or documentation being updated, unless it's a minor change (spellchecking, minor formatting, etc). You may @mention another project member who you think is better suited for the review, but still provide a non-approving review of your own.
- Be extra kind: people who submit code/doc contributions are putting themselves in a pretty vulnerable position, and have put time and care into what they've done (even if that's not obvious to you!) -- always respond with respect, be understanding, but don't feel like you need to sacrifice your standards for their sake, either. Just don't be a jerk about it?
                                                                                                                                                     
