require "time"

module RME
  class Engine
    VALID_TYPES = %w[fact preference goal project note].freeze

    def initialize(store = Store.new)
      @store = store
    end

    def remember(content, type: "fact", importance: 5, tags: [])
      content = content.to_s.strip
      raise ArgumentError, "Memory content cannot be empty" if content.empty?
      raise ArgumentError, "Unknown memory type: #{type}" unless VALID_TYPES.include?(type)
      importance = Integer(importance)
      raise ArgumentError, "Importance must be between 1 and 10" unless (1..10).cover?(importance)

      @store.insert(content: content, memory_type: type, importance: importance, tags: Array(tags))
    end

    def recall(query, limit: 5)
      @store.search(query, limit: Integer(limit)).map { |row| Memory.new(row) }
    end

    def list(type: nil, limit: 100)
      @store.all(memory_type: type, limit: Integer(limit)).map { |row| Memory.new(row) }
    end

    def forget(id)
      @store.delete(Integer(id))
    end

    def clear
      @store.clear
    end
  end
end
