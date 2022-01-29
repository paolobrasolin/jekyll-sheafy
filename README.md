# jekyll-sheafy

[![CI tests status badge][build-shield]][build-url]
[![Latest release badge][rubygems-shield]][rubygems-url]
[![License badge][license-shield]][license-url]
[![Maintainability badge][cc-maintainability-shield]][cc-maintainability-url]
[![Test coverage badge][cc-coverage-shield]][cc-coverage-url]

[build-shield]: https://img.shields.io/github/workflow/status/paolobrasolin/jekyll-sheafy/CI/main?label=tests&logo=github
[build-url]: https://github.com/paolobrasolin/jekyll-sheafy/actions/workflows/main.yml "CI tests status"
[rubygems-shield]: https://img.shields.io/gem/v/jekyll-sheafy?logo=ruby
[rubygems-url]: https://rubygems.org/gems/jekyll-sheafy "Latest release"
[license-shield]: https://img.shields.io/github/license/paolobrasolin/jekyll-sheafy
[license-url]: https://github.com/paolobrasolin/jekyll-sheafy/blob/main/LICENSE "License"
[cc-maintainability-shield]: https://img.shields.io/codeclimate/maintainability/paolobrasolin/jekyll-sheafy?logo=codeclimate
[cc-maintainability-url]: https://codeclimate.com/github/paolobrasolin/jekyll-sheafy "Maintainability"
[cc-coverage-shield]: https://img.shields.io/codeclimate/coverage/paolobrasolin/jekyll-sheafy?logo=codeclimate&label=test%20coverage
[cc-coverage-url]: https://codeclimate.com/github/paolobrasolin/jekyll-sheafy/coverage "Test coverage"

`jekyll-sheafy` is a [Jekyll][jekyll-url] plugin inspired by [Gerby][gerby-url] which allows you to setup websites similar to [the Stacks project][stacks-url] and [Kerodon][kerodon-url].

## Getting started

Currently, the state of the art in using `jekyll-sheafy` is represented by [The Nursery][math-url]. Until I write a minimal guide, the bes way to get started is forking it and playing around with it.

## Usage

> TODO: general usage notes.

### Architecture

> TODO: explain the Directed Rooted Forest structure and the taxa mechanism.

### Configuration

> TODO: fill in details for each parameter.

```yaml
sheafy:
  references:
    matchers: [] # ...
  taxa: {} # ...
```

### Node variables

> TODO: fill in details for each variable.

#### General

- `taxon`

#### Layouting

- `layout`
- `sublayout`

#### Dependencies

- `ancestors`
- `parent`
- `subroot`
- `children`

#### References

- `referrers`

#### Numbering

- `clicker`
- `clicks`

## Roadmap

These are the features you can expect in the future:

- Enable `referents` variable w/ nodes references by the current one
- `root` variable w/ root node of the tree
- `siblings` variable or some variant of it to enable navigation between adjacent nodes at the same depth
- Prev/next node navigation
- Variable inheritance from parent/root node
- Search feature

Of course any feedback is welcome!

## Acknowledgements

- Thanks to [@jonsterling](https://github.com/jonsterling) for
  - using [`krater`][krater-url] to setup [The Nursery][math-url],
  - having the "brew your own Kerodon" idea, and
  - letting me collaborate to spin it off into `jekyll-sheafy`.

[jekyll-url]: https://jekyllrb.com/
[krater-url]: https://github.com/paolobrasolin/krater/
[math-url]: https://github.com/jonsterling/math
[gerby-url]: https://gerby-project.github.io/
[stacks-url]: https://stacks.math.columbia.edu/
[kerodon-url]: https://kerodon.net/
