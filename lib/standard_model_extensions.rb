module StandardModelExtensions
  module InstanceMethods
    def author
      if self.is_a?(User)
        nil
      else
        owner = self.accepted_roles.find_by_name('owner')
        owner.nil? ? nil : owner.user.login.downcase
      end
    end

    def barcode_breakdown
      self.barcode.inject({}) { |h, b| h[b[:type].to_sym] ||= 0; h[b[:type].to_sym] += 1; h }
    end

    def update_karma
      value = self.barcode.inject(0) { |sum, item| sum += self.class::RATINGS[item[:type].to_sym].to_i; sum }

      self.update_attribute(:karma, value)
    end
  end
end
