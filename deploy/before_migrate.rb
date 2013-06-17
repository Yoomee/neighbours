if release_path =~ /staging/
  
  # change thinking sphinx settings for staging
  ts_yaml_path = "#{release_path}/config/sphinx.yml"
  ts_yaml = YAML.load_file(ts_yaml_path)
  {
    'port' => 9314,
    'config_file' => "#{shared_path}/production.sphinx.conf",
    'searchd_file_path' => "#{shared_path}/sphinx",
    'searchd_log_path' => "#{shared_path}/searchd.log",
    'query_log_file' => "#{shared_path}/searchd.query.log",
    'pid_file' => "#{shared_path}/searchd.production.pid"
  }.each do |k, v|
    ts_yaml[environment][k] = v
  end
  File.open(ts_yaml_path, 'w') do |file|
    file.puts YAML::dump(ts_yaml)
  end

  # change site settings for staging
  stag_settings_yaml_path = "#{release_path}/config/settings/staging.yml"
  prod_settings_yaml_path = "#{release_path}/config/settings/production.yml"
  if File.exists?(stag_settings_yaml_path)
    stag_settings_yaml = YAML.load_file(stag_settings_yaml_path)
    prod_settings_yaml = YAML.load_file(prod_settings_yaml_path)
    stag_settings_yaml.each do |key, value|
      prod_settings_yaml[key] = value
    end
    File.open(prod_settings_yaml_path, 'w') do |file|
      file.puts YAML::dump(prod_settings_yaml)
    end
  end
  
end
