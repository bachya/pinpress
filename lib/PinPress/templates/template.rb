module PinPress
  class Template
    TEMPLATE_TYPE_PIN = 1
    TEMPLATE_TYPE_TAG = 2

    attr_accessor :closer
    attr_accessor :item
    attr_accessor :item_separator
    attr_accessor :name
    attr_accessor :opener

    def initialize(params = {})
      params.each { |key, value| send("#{ key }=", value) }
    end
  end
end