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
    #  cutoff = Time.zone.now.change(:hour => 16, :min => 00) # Gets 4pm in EST time zone (config.time_zone)

    #  if [0, 1, 7].include?(delivery_date.wday)
    #    errors.add(:base, "cannot be a Sunday or Monday.")
    #  end
      
      d = Date.today
      d += 3
      
      if delivery_date < d
        errors.add(:base, "配送日には本日の4日後以降の日付を指定してください")
      end
    end
  end
end
