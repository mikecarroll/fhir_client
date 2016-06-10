module FHIR
  class Model
    class << self
      cattr_accessor :client
    end

    def client
      @client || self.class.client
    end

    def client=(client)
      @client = client

      # Ensure the client-setting cascades to all child models
      instance_values.each do |_key, values|
        Array.wrap(values).each do |value|
          next unless value.is_a?(FHIR::Model)
          next if value.client == client
          value.client = client
        end
      end
    end

    def self.read(id, client = self.client)
      client.read(self, id).resource
    end

    def self.read_with_summary(id, summary, client = self.client)
      client.read(self, id, client.default_format, summary).resource
    end

    def self.search(params = {}, client = self.client)
      client.search(self, search: { parameters: params }).resource
    end

    def self.create(model, client = self.client)
      model = new(model) unless model.is_a?(self)
      client.create(model).resource
    end

    def self.conditional_create(model, params, client = self.client)
      model = new(model) unless model.is_a?(self)
      client.conditional_create(model, params)
    end

    def create
      client.create(self).resource
    end

    def conditional_create(params)
      client.conditional_create(self, params)
    end

    def update
      client.update(self, id).resource
    end

    def conditional_update(params)
      client.conditional_update(self, self.id, params).resource
    end

    def destroy
      client.destroy(self.class, id) unless id.nil?
      nil
    end
  end
end