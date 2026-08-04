module Serializable
  extend ActiveSupport::Concern

  private

  def render_serialized(resource, serializer: nil, status: :ok, **params)
    serializer ||= serializer_for(resource)
    render json: serializer.render(resource, **params), status: status
  end

  def serializer_for(resource)
    model =
      if resource.respond_to?(:klass)
        resource.klass
      elsif resource.is_a?(Array)
        resource.first.class
      else
        resource.class
      end

    "#{model.name}Serializer".constantize
  end
end
