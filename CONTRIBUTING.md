# Contributing to coobjc

We love contributions to the coobjc project and request you follow the guidelines below. If you have any questions, or need any help, open an  [ISSUE](https://github.com/alibaba/coobjc/issues/new/choose).

## Table of Contents

<!-- TOC -->

- [Contributing to coobjc](#contributing-to-coobjc)
  - [Getting Started](#getting-started)
  - [Pull Requests](#pull-requests)
  - [Asking Questions](#asking-questions)
  - [Reporting Issues](#reporting-issues)
    - [Additional Resources](#additional-resources)

<!-- /TOC -->

## Getting Started

To get started, you will need to open a Terminal and:

1. Fork this repo and clone it onto your machine.

   `$ git clone https://github.com/YOUR_GITHUB_ID/git@github.com:alibaba/coobjc.git`

2. Make changes to code, usually by tackling an issue. A list of issues can be found [ISSUE](https://github.com/alibaba/coobjc/issues).

   If there aren't any tagged issues, open a [Feature ISSUE](https://github.com/alibaba/coobjc/issues/new?assignees=&labels=&template=feature_request.md&title=).

3. All source code submitted requires an Apache License header at the top of the file. This text can be found [Here](./docs/common/Copyright.txt), just copy and paste it at the top of any new files you're submitting.
<!--
TODOS: 
4. Ensure all tests pass with your changes and test coverage must greater than before. If there is any new functionality introduced by your changes, new test case(s) may be required.

5. codeStyle 
-->
4. Commit message should conform to [commit message templates](./docs/common/commentformat.txt).

5. If the tests all pass, open a Pull Request following the guidelines below.

## Pull Requests

<!--
**Note:** Before opening a Pull Request, please run the tests and check them all pass and keep test coverage greater than or equal before.  

coobjc uses [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration). You may see mentions of [Travis CI](https://travis-ci.com/) in your PR and its comments. Travis is an external service we use that is automatically called on every PR, and runs the test cases on macOS and iPhone simulator to ensure every code change is stable.

To open a new Pull Request, the GitHub website provides the simplest experience for new users. Go to your fork of the repo and click the New pull request button. You will be presented with a page featuring base fork: and base:, then an arrow, and then head fork: compare:. Make sure compare: has **your branch** with your changes selected and base: has **master** selected. When you are ready to open the PR, click the green button at the top called Create pull request.
 -->

When opening a PR, please:

1. Create minimal differences and do not reformat the code. If you feel the codes structure needs changing, open a separate PR.
2. Check for unnecessary white space using `git diff --check` before you commit your code.
3. Squash all commit as one on feature branch.

## Asking Questions

If you have any questions, Comment on existing issues, or raise new ones if you discover something.

## Reporting Issues

See the [issue template](.github/ISSUE_TEMPLATE/).

---

### Additional Resources

- [GitHub Help - Homepage](https://help.github.com)
- [Creating a Pull Request - GitHub Help](https://help.github.com/articles/creating-a-pull-request/)