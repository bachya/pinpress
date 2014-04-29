module PinPress
  # A template for outputting Pinboard data
  class Template
    # Defines a pin template
    # @return [Fixnum]
    TEMPLATE_TYPE_PIN = 1

    # Defines a tag template
    # @return [Fixnum]
    TEMPLATE_TYPE_TAG = 2

    # Holds the "closer" (the string that
    # should come after all template items
    # are output)
    # @return [String]
    attr_accessor :closer

    # Holds the string that defines what
    # an item should look like.
    # @return [String]
    attr_accessor :item

    # Holds the name of the template.
    # @return [String]
    attr_accessor :name

    # Holds the "opener" (the string that
    # should come before all template items
    # are output)
    # @return [String]
    attr_accessor :opener

    # Initializes this class by ingesting
    # passed parameters.
    # @param [Hash] params
    # @return [void]
    def initialize(params = {})
      params.each { |key, value| send("#{ key }=", value) }
    end
  end
end
