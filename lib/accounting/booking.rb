module Accounting
  class Booking < ActiveRecord::Base
    # Validation
    validates_presence_of :debit_account, :credit_account, :title, :amount, :value_date
  
    belongs_to :debit_account, :foreign_key => 'debit_account_id', :class_name => "Account"
    belongs_to :credit_account, :foreign_key => 'credit_account_id', :class_name => "Account"

    # Scoping
    named_scope :by_account, lambda {|account_id|
      { :conditions => ["debit_account_id = :account_id OR credit_account_id = :account_id", {:account_id => account_id}] }
    }

    def self.scope_by_value_date(value_date)
      scoping = self.default_scoping - [@by_value_scope]
      
      @by_value_scope = {:find => {:conditions => {:value_date => value_date}}}
      scoping << @by_value_scope
      
      Thread.current["#{self}_scoped_methods"] = nil
      self.default_scoping = scoping
    end
    
    # Standard methods
    def to_s(format = :default)
      case format
      when :short
        "#{value_date.strftime('%d.%m.%Y')}: #{credit_account.code} / #{debit_account.code} CHF #{amount_as_string} "
      else
        "#{value_date.strftime('%d.%m.%Y')}: #{credit_account.title} (#{credit_account.code}) an #{debit_account.title} (#{debit_account.code}) CHF #{amount_as_string}, #{title} " +
          (comments.blank? ? "" :"(#{comments})")
      end
    end

    # Helpers
    def accounted_amount(account)
      if credit_account == account
        return amount
      elsif debit_account == account
        return -(amount)
      else
        return 0.0
      end
    end

    def amount_as_string
      '%0.2f' % amount.currency_round
    end
    
    def amount_as_string=(value)
      self.amount = value
    end
    
    # Reference
    belongs_to :reference, :polymorphic => true
    after_save :notify_references

    private
    def notify_references
      reference.booking_saved(self) if reference.respond_to?(:booking_saved)
    end
  end
end