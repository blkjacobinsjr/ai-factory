# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Global agent rules

`.claude/rules/*.md` apply to this repo. To make them apply to every Claude Code session on a machine, link them into the global config once:

```sh
mkdir -p ~/.claude/rules && ln -sf "$PWD/.claude/rules/token-economy.md" ~/.claude/rules/token-economy.md
```
