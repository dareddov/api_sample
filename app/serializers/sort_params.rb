module SortParams
  def self.sorted_fields(sort)
    fields = sort.to_s.split(',')
    ordered_fields = convert_to_ordered_hash(fields)

    ordered_fields
  end

  def self.convert_to_ordered_hash(fields)
    fields.each_with_object({}) do |field, hash|
      if field.start_with?('-')
        field = field.gsub('-', '')
        hash[field] = :desc
      else
        hash[field] = :asc
      end
    end
  end
end