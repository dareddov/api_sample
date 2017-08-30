class ErrorSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def to_json(_options = {})
    { errors:
      object.errors.messages.flat_map do |field, errors|
        errors.flat_map do |error_message|
          {
            status: '422',
            source: {pointer: "/data/attributes/#{field}"},
            detail: error_message
            }
        end
      end
    }.to_json
  end
end