# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.2.0 - 2019-04-26

### Added

- `-[COChan receiveAll]`
- `-[COChan receiveWithCount:]`

### Fixed

- Fix Channel may wrong when send fail

### Changed

- Add CODispatch.m to manager dispatch_queue or thread
- Use channel to implement COProgressPromise
- Remove COChan's `cancel` and `onCancel:` api.
- Add COChan's `cancelForCoroutine:`, `receiveWithOnCancel:`, `send:onCancel`
- `batch_await` use subroutines.

## 1.1.3 - 2019-03-22

### Added

- coswift support co_delay.
- coswift's promise support chained promise.
- coobjc's generator: add nextWithParam

### Fixed

- fix crash cause by co_get_current_queue.

## 1.1.0 - 2019-03-13
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



