# 为 coobjc 贡献代码

我们鼓励使用者为 coobjc 项目做出贡献，贡献代码的规则可以参考下面的条例。

如果你碰见了一些不明白的问题或者是需要和开发组人员交流，可以打开一个新的 [ISSUE](https://github.com/alibaba/coobjc/issues/new/choose) 来跟踪你的疑问。
## 目录

<!-- TOC -->

- [为 coobjc 贡献代码](#为-coobjc-贡献代码)
  - [快速入手](#快速入手)
  - [创建 Pull Requests](#创建-pull-requests)
  - [提问](#提问)
  - [报告 Issues](#报告-ISSUE)
    - [参考信息](#参考信息)

<!-- /TOC -->

## 快速入手

为了给 coobjc 贡献代码，你应该打开一个终端

1. 首先 fork 本项目，然后 clone 到本地的工作目录。

   `$ git clone https://github.com/YOUR_GITHUB_ID/git@github.com:alibaba/coobjc.git `

2. 通常一次 Pull Request 是为了解决一个 ISSUE， 已有的 ISSUE 列表可以在 [这里](https://github.com/alibaba/coobjc/issues) 找到。

   如果没有相关联的 ISSUE， 可以开启一个 [新特性 ISSUE](https://github.com/alibaba/coobjc/issues/new?assignees=&labels=&template=feature_request.md&title=)，我们将会与你讨论这次贡献。

3. coobjc 项目使用 Apache License 2.0 协议发布。因此每个文件头部信息必须带上相关协议版权信息。对于一个新文件可以通过以下链接 [License](./docs/common/Copyright.txt) 找到这个模板，将其复制在新文件的顶部即可。
<!--
TODOS: 
4. 创建新的 PR 前应该保证所有的测试用例是通过的，并且测试用例的覆盖率要大于之前的。如果你对项目添加了新的功能，相应的也需要补充对应的测试用例。
5. codeStyle 
-->
4. 提交信息要遵守如下模板 [commit message templates](./docs/common/commentformat.txt)。

65 如果以上步骤都满足，就可以创建你的 PR 了。

## 创建 Pull Requests

<!--
**注意:** 创建 PR 前一定要确保所有的测试用例通过并且测试用例的覆盖率要大于或等于之前。

coobjc 使用 [持续集成](https://en.wikipedia.org/wiki/Continuous_integration). 因此你可能在你的 PR 中看到 [Travis CI](https://travis-ci.com/) 相关的评论. Travis CI 是一个外部工具，我们使用这个工具检查每个 PR 然后测试对应的测试用例，如果测试用例失败了 这个 PR 不能合入到 master 分支。使用 Travis CI 工具可以确保每次提交代码的稳定性。
-->
当你创建一个PR时，请检查如下要求

1. 请在本地做相关的 diff 确保无关的代码风格没有发生改变，如果你认为代码风格有问题，创建一个单独的 PR 来修改这个问题。
2. 提交代码前使用 `git diff --check` 命令检查下是否有多余的空白字符和换行。
3. 在特性分支上，请将所有的 commit 合并为一个，以便保持 master 分支的清晰。

## 提问

如果你有其他方面的疑惑或者需要和开发人员沟通, 可以打开一个新的 ISSUE.

## 报告 ISSUE

如果有 ISSUE 需要提出，请遵守此 [模板](.github/ISSUE_TEMPLATE/)。

---

### 参考信息

- [GitHub 帮助页面](https://help.github.com)
- [如何创建一个拉取请求](https://help.github.com/articles/creating-a-pull-request/)