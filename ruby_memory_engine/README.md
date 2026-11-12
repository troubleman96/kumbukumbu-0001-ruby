# Ruby Memory Engine

A small, local memory system written in Ruby. It stores facts, preferences, goals,
and notes in SQLite, then retrieves relevant memories using SQLite full-text search.

## Requirements

- Ruby 3.1 or newer
- Bundler
- SQLite (the `sqlite3` gem includes what this project needs on most systems)

## Install

```bash
cd ruby_memory_engine
bundle install
```

## Quick start

Remember a fact:

```bash
bundle exec ruby bin/memory remember "The user is learning Ruby for AI development" --type fact --importance 8 --tags ruby,ai
```

Remember a preference:

```bash
bundle exec ruby bin/memory remember "Prefers practical projects and step-by-step explanations" --type preference --importance 7
```

Recall memories:

```bash
bundle exec ruby bin/memory recall "What is the user learning?"
bundle exec ruby bin/memory recall "learning Ruby" --limit 10
```

List all memories:

```bash
bundle exec ruby bin/memory list
bundle exec ruby bin/memory list --type preference
```

Forget one memory by ID:

```bash
bundle exec ruby bin/memory forget 1
```

Clear all memories (asks for confirmation):

```bash
bundle exec ruby bin/memory clear
```

## Project structure

- `lib/rme/store.rb` — SQLite persistence and full-text index
- `lib/rme/memory.rb` — memory object
- `lib/rme/engine.rb` — remember, recall, list, forget operations
- `bin/memory` — command-line interface
- `spec/` — basic tests

## How it works

1. `remember` saves text, type, importance, tags, and timestamps.
2. SQLite FTS5 indexes the memory text and tags.
3. `recall` searches the full-text index and returns ranked matches.
4. `forget` removes a memory from both the database and search index.

This is a learning project, not a production personal-data vault. It does not
automatically extract facts from conversations, call an LLM, create embeddings,
or perform semantic/vector search. Those are good next upgrades.
