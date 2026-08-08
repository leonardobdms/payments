class ApplicationSerializer
  include Alba::Resource

  class << self
    def render(object, **params)
      new(object, params: params).to_h
    end
  end
end
