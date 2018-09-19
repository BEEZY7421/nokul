# frozen_string_literal: true

module DynamicSearch
  extend ActiveSupport::Concern

  class_methods do
    def search_keys(*keys)
      @dynamic_search_keys = keys.flatten
    end

    def dynamic_search_keys
      raise ArgumentError, 'must be defined in search_keys' unless @dynamic_search_keys

      @dynamic_search_keys
    end

    def dynamic_search(params = {})
      raise ArgumentError, 'parameter must be Hash' unless [ActionController::Parameters, Hash].include?(params.class)
      return search(params[:term]) if params[:term].present?

      dynamic_where(params)
    end

    private

    def dynamic_where(params)
      query = build_query_for_dynamic_where(params)
      query.present? ? where(query) : current_scope
    end

    def build_query_for_dynamic_where(params)
      dynamic_search_keys.each_with_object({}) do |key, hash|
        hash[key] = params[key] if params[key].present?
      end
    end
  end
end