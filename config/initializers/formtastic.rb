Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder

module FormtasticBootstrap::Inputs::Base
  
  def help_html
    return "" if options[:help].blank?
    "<i class='icon-question-sign help-icon' title='#{options[:help].gsub(/'/,"&#39;")}'></i>".html_safe
  end  
  
end

module FormtasticBootstrap::Inputs::Base::Wrapping

  def input_div_wrapping(inline_or_block_errors = :inline)
    template.content_tag(:div, :class => "controls") do
      [yield, error_html(inline_or_block_errors), hint_html(inline_or_block_errors)].join("\n").html_safe + help_html
    end
  end
  
end

module FormtasticBootstrap::Inputs::Base::Choices

  def input_div_wrapping(&block)
    template.content_tag(:div, choices_wrapping_html_options) do
      [yield, error_html(:block), hint_html(:block)].join("\n").html_safe + help_html
    end
  end
        
end