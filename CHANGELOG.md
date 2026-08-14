# Changelog

All notable changes to this project are documented in this file.  
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Added

- Public contract fixtures (`docs/api/fixtures/`) plus CI that runs OpenAPI, Zod, and Go on the same examples.
- Root README, MIT LICENSE, CONTRIBUTING, SECURITY, and changelog for OSS hygiene.
- `archive/` note separating learning materials from the product tree.
- Vitest for `web/` and `admin-web/` schema tests.
- Backend split from a single `main.go` into package-main files.

### Changed

- `quiz.md` aligned with the implemented stack (React 19, Go `net/http`, mock Push Phase A).
