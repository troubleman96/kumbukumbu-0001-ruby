require "time"
require "sqlite3"
require "fileutils"

module RME
  class Store
    def initialize(path = "data/memories.sqlite3")
      FileUtils.mkdir_p(File.dirname(path))
      @db = SQLite3::Database.new(path)
      @db.results_as_hash = true
      setup
    end

    def setup
      @db.execute <<~SQL
        CREATE TABLE IF NOT EXISTS memories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          memory_type TEXT NOT NULL DEFAULT 'fact',
          importance INTEGER NOT NULL DEFAULT 5,
          tags TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      SQL

      @db.execute <<~SQL
        CREATE VIRTUAL TABLE IF NOT EXISTS memories_fts
        USING fts5(content, tags, content='memories', content_rowid='id')
      SQL

      @db.execute <<~SQL
        CREATE TRIGGER IF NOT EXISTS memories_ai AFTER INSERT ON memories BEGIN
          INSERT INTO memories_fts(rowid, content, tags)
          VALUES (new.id, new.content, new.tags);
        END
      SQL

      @db.execute <<~SQL
        CREATE TRIGGER IF NOT EXISTS memories_ad AFTER DELETE ON memories BEGIN
          INSERT INTO memories_fts(memories_fts, rowid, content, tags)
          VALUES ('delete', old.id, old.content, old.tags);
        END
      SQL

      @db.execute <<~SQL
        CREATE TRIGGER IF NOT EXISTS memories_au AFTER UPDATE ON memories BEGIN
          INSERT INTO memories_fts(memories_fts, rowid, content, tags)
          VALUES ('delete', old.id, old.content, old.tags);
          INSERT INTO memories_fts(rowid, content, tags)
          VALUES (new.id, new.content, new.tags);
        END
      SQL
    end

    def insert(content:, memory_type:, importance:, tags:)
      now = Time.now.utc.iso8601
      @db.execute(
        "INSERT INTO memories (content, memory_type, importance, tags, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
        [content, memory_type, importance, tags.join(","), now, now]
      )
      find(@db.last_insert_row_id)
    end

    def find(id)
      @db.get_first_row("SELECT * FROM memories WHERE id = ?", [id])
    end

    def search(query, limit: 5)
      # FTS5 expects search syntax; quote each term to make ordinary questions safer.
      terms = query.to_s.scan(/[[:alnum:]_]+/)
      return [] if terms.empty?
      expression = terms.map { |term| %("#{term.gsub('"', '""')}") }.join(" OR ")
      @db.execute(
        "SELECT m.*, bm25(memories_fts) AS score FROM memories_fts JOIN memories m ON m.id = memories_fts.rowid WHERE memories_fts MATCH ? ORDER BY score LIMIT ?",
        [expression, limit]
      )
    end

    def all(memory_type: nil, limit: 100)
      if memory_type
        @db.execute("SELECT * FROM memories WHERE memory_type = ? ORDER BY importance DESC, id DESC LIMIT ?", [memory_type, limit])
      else
        @db.execute("SELECT * FROM memories ORDER BY importance DESC, id DESC LIMIT ?", [limit])
      end
    end

    def delete(id)
      @db.execute("DELETE FROM memories WHERE id = ?", [id])
      @db.changes.positive?
    end

    def clear
      @db.execute("DELETE FROM memories")
    end
  end
end
