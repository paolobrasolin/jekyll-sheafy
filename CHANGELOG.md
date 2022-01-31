# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `inheritable` config key (array of strings, validated) to define attributes which are inherited from parent node.
- `referents` variable containing list of referents (i.e. the targets of all references in the current node).
- `root` variable containing the root node of the tree the current node belongs to.
- `predecessors`/`successors` variables containing the siblings preceeding/following the current node.

### Changed

- Error message are a bit more rational.
- `taxa` configuration key is now validated; it must be an hash valued in hashes.
- `references.matchers` configuration key is now validated; it must be an array of regexps containing a single named capture "slug".

## [0.2.0] - 2022-01-29

### Added

- Configurable matchers for reference detection.

## [0.1.0] - 2022-01-28

### Added

- Structure to represent directed graphs.
- Topological checks for rooted forests.

[unreleased]: https://github.com/paolobrasolin/jekyll-sheafy/compare/0.1.0...HEAD
[0.1.0]: https://github.com/paolobrasolin/jekyll-sheafy/releases/tag/0.1.0
