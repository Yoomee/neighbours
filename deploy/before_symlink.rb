FileUtils::mkdir_p "#{shared_path}/dragonfly"
FileUtils::mkdir_p "#{release_path}/data"
run "ln -s #{shared_path}/dragonfly #{release_path}/data/dragonfly"

# Setup sphinx
run "rm -rf #{release_path}/db/sphinx"
run "mkdir -p #{shared_path}/sphinx"
run "ln -nfs #{shared_path}/sphinx #{release_path}/db/sphinx"
run "ln -nfs #{shared_path}/production.sphinx.conf #{release_path}/config/production.sphinx.conf"