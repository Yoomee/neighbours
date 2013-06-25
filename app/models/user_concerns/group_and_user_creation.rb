module UserConcerns::GroupAndUserCreation

  def self.included(base)
    base.send(:boolean_accessor, :in_group_and_user_creation)
    base.send(:attr_writer, :current_group_step)
  end

  def current_group_step
    @current_group_step || group_steps.first
  end

  def group_steps
    %w{group you}
  end

  def method_missing(method_name, *args)
    if method_name =~ /^current_group_step_(\w+)\?$/
      if group_steps.include?($1)
        current_group_step == $1
      else
        super
      end
    else
      super
    end
  end

end