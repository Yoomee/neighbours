class MessageThread < ActiveRecord::Base

  include YmMessages::MessageThread

  has_many :flags, :as => :resource, :dependent => :destroy

  def to_s
    "messages between #{users.collect(&:full_name).to_sentence}"
  end

end