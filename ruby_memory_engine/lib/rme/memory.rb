module RME
  class Memory
    attr_reader :id, :content, :memory_type, :importance, :tags, :created_at, :updated_at

    def initialize(row)
      @id = row["id"]
      @content = row["content"]
      @memory_type = row["memory_type"]
      @importance = row["importance"].to_i
      @tags = row["tags"].to_s.split(",").reject(&:empty?)
      @created_at = row["created_at"]
      @updated_at = row["updated_at"]
    end
  end
end
