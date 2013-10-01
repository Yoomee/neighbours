class MessageThread < ActiveRecord::Base

  include YmMessages::MessageThread

  has_many :flags, :as => :resource, :dependent => :destroy

  def to_s
    "messages between #{users.collect(&:to_s).to_sentence}"
  end

end