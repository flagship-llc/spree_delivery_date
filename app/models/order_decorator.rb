Spree::Order.class_eval do
  require 'date'
  require 'spree/order/checkout'

  attr_accessible :delivery_date

  validate :delivery_date, :presence => true, :allow_nil => false
  validate :delivery_date_specific_validation

  # Ensure that a delivery date is set. We don't want to run these validations until it is
  # Only run the delivery date validations if we are on that step or past.
  def delivery_date_specific_validation
    if !delivery_date.blank? && ['payment', 'confirm', 'complete'].include?(state)
      delivery_limited_products = products.select { |e| !e.earliest_shipping_date.nil? or !e.latest_shipping_date.nil? }

      d = Date.today
      d += 3

      if delivery_date < d
        errors.add(:base, "配送日には本日の4日後以降の日付を指定してください")
      end

      delivery_limited_products.each do |product|
        if product.earliest_shipping_date and product.earliest_shipping_date > delivery_date
          errors.add(:base, "#{ product.name }の配送は#{ I18n.l product.earliest_shipping_date, format: :prod_shipping_short }からとなります。")
        end
        if product.latest_shipping_date and delivery_date > product.latest_shipping_date
          errors.add(:base, "#{ product.name }の配送は#{ I18n.l product.latest_shipping_date, format: :prod_shipping_short }までとなります。")
        end
      end
    end
  end
end
