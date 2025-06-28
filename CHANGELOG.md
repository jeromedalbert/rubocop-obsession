## 0.2.3 - 2025-06-28

- Fix `Rails/ServiceName` misbehaving for compact namespaces. Pull request
  [#16](https://github.com/jeromedalbert/rubocop-obsession/pull/16) by Iaroslav
  Kurbatov.

## 0.2.2 - 2025-05-11

- Fix `MethodOrder` uninitialized constant error sometimes happening in source
  code that uses aliases.

## 0.2.1 - 2025-03-25

- Fix `Rspec/EmptyLineAfterFinalLet` uninitialized constant error.

## 0.2.0 - 2025-03-22

- Add new `alphabetical` style to `MethodOrder` cop.
- Make Rubocop Obsession work as a RuboCop plugin.

## 0.1.15 - 2025-02-24

- Add new `step_down` style to `MethodOrder` cop. This style more closely
  aligns with the Stepdown rule from the Clean Code book. Pull request
  [#11](https://github.com/jeromedalbert/rubocop-obsession/pull/11) by Ferran
  Pelayo Monfort.
- Introduce unit tests to the codebase. Pull request
  [#11](https://github.com/jeromedalbert/rubocop-obsession/pull/11) by Ferran
  Pelayo Monfort.

## 0.1.14 - 2025-02-03

- Rename internal helper to avoid conflict with Rubocop.

## 0.1.13 - 2024-12-08

- Fix `Rails/ServicePerformMethod` autocorrect sometimes resulting in infinite
  loops.

## 0.1.12 - 2024-11-26

- Fix `Rspec/DescribePublicMethod` uninitialized constant error sometimes
  happening.

## 0.1.11 - 2024-11-14

- Do not check method order in modules for the time being.

## 0.1.10 - 2024-11-14

- Fix `Rails/SafetyAssuredComment` misbehaving when there are multiple
  comments. Pull request
  [#8](https://github.com/jeromedalbert/rubocop-obsession/pull/8) by Garrett
  Blehm.

## 0.1.9 - 2024-11-05

- Internal cleanups.

## 0.1.8 - 2024-11-04

- Improve cops documentation.

## 0.1.7 - 2024-11-02

- Fix `MethodOrder` autocorrect for Sorbet signatures.
- Fix `MethodOrder` conflicts when there are both protected and private
  methods.

## 0.1.6 - 2024-11-01

- Fix `MethodOrder` autocorrect for methods not separated by new lines.

## 0.1.5 - 2024-10-28

- Make cops inherit from `RuboCop::Cop::Base` instead of deprecated
  `RuboCop::Cop::Cop`.

## 0.1.4 - 2024-10-27

- Improve cops documentation.

## 0.1.2 - 2024-10-27

- Check method order in modules.

## 0.1.1 - 2024-10-27

- Add initial cops.

## 0.1.0 - 2024-10-20

- Initial release.
