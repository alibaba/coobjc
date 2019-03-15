# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## 1.1.x - 2019-03-13
### Added

- Coswift support generator
- Subroutine should cancel when it's parent cancel.
- Support Carthage in 1.1.1
- Support macosx
    - coobjc@1.1.0
    - coswift@1.1.2

### Changed

- Split coobjc to cocore and coobjc, coswift depend on cocore.
- Drag fishhook in project
- Yield change to macro defined.
- Change COPromise's @sync to NSLock

### Fixed
- Fix custom stack calculate error.
- Fix batch await
- Fix c++ compile error
- Fix coswift bugs.

## 1.0.0 - 2019-02-27

### Features

* add all source code ([a2c08bd](https://github.com/alibaba/coobjc/commit/a2c08bd))



