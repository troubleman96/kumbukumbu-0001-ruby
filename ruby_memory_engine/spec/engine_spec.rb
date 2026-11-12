require "minitest/autorun"
require "tmpdir"
require_relative "../lib/rme"

class EngineSpec < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @engine = RME::Engine.new(RME::Store.new(File.join(@dir, "test.sqlite3")))
  end

  def teardown
    FileUtils.remove_entry(@dir) if @dir && Dir.exist?(@dir)
  end

  def test_remember_and_recall
    saved = @engine.remember("I am learning Ruby for AI development", tags: ["ruby", "ai"])
    found = @engine.recall("Ruby AI")
    assert_equal saved.id, found.first.id
  end

  def test_forget
    saved = @engine.remember("Temporary note")
    assert @engine.forget(saved.id)
    assert_empty @engine.list
  end
end
