class Chef
  class Recipe
    # If you change this, please copy it back into the README as documentation
    def delayed_job_worker_count(instance_type)
      case instance_type
      when "m1.small"
        3
      when "m1.medium"
        4
      when "m1.large"
        8
      when "m1.xlarge"
        12
      when "m2.xlarge"
        10
      when "m2.2xlarge"
        10
      when "m2.4xlarge"
        24
      when "c1.medium"
        4
      when "c1.xlarge"
        24
      else
        2
      end
    end
  end
end
