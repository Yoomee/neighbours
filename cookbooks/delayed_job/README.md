# Delayed Job recipe for EY Cloud

This cookbook can serve as a good starting point for setting up Delayed Job support in your application. 
In this recipe your Delayed Job workers will be set up to run under monit. The number of workers will
vary based on the size of the instance running Delayed Job.

This recipe will setup `delayed_job` on a Solo instance environment or on named Utility instances in a cluster environment. 

Name your Utility instances with prefixes: `dj`, `delayed_job`, `delayedjob`. For example, `dj1`, `delayedjob4`.

If you want `delayed_job` to run on App instances instead of Utility, you will need to modify the recipe.

TODO: if no corresponding dj|delayed_job|delayedjob named Utility instances, then install DJ on the app instances.

## How many workers do I get?

The number of parallel workers is based on the instance type.

Solo instances allocate a single Delayed Job worker because the instance is primarily for running the Application and its database.

For each `dj` utility instance the number of workers is determined by the `delayed_job_worker_count` library helper:

``` ruby
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
```

To learn more about each instance type, see the [AWS EC2 Instance Type](http://aws.amazon.com/ec2/instance-types/ "Amazon EC2 Instance Types") page.

## Installation

This recipe must be installed as `delayed_job` and not `eycloud-recipe-delayed_job`.

## Simple Installation

To add this recipe to your collection of recipes, or as your first recipe, you can use the helpful `ey-recipes` command line tool:

    cd myapp
    gem install engineyard engineyard-recipes
    ey-recipes init
    ey-recipes clone git://github.com/engineyard/eycloud-recipe-delayed_job.git -n delayed_job
    ey recipes upload --apply

If you want to have your recipes run during deploy (rather than the separate `ey recipes upload --apply` step):

    ey-recipes init -d
    ey-recipes clone git://github.com/engineyard/eycloud-recipe-delayed_job.git -n delayed_job
    git add .; git commit -m "added delayed job recipe"; git push origin master
    ey deploy

## Manual Installation

Clone/copy this repository into a `cookbooks/delayed_job` folder (such that you have a `cookbooks/delayed_job/recipes/default.rb` file).

Then add the following to `cookbooks/main/recipes/default.rb`:

    require_recipe "delayed_job"
    
Make sure this and any customizations to the recipe are committed to your own fork of this 
repository.

Then to upload and apply to EY Cloud for a given environment:

    ey recipes upload --apply -e target-environment

## Restarting your workers

This recipe does NOT restart your workers. The reason for this is that shipping your application and
rebuilding your instances (i.e. running chef) are not always done at the same time. It is best to 
restart your Delayed Job workers when you ship (deploy) your application code. To do this, add a
deploy hook to perform the following:

    sudo "monit -g dj_<app_name> restart all"
    
Make sure to replace <app_name> with the name of your application. You likely want to use the
after_restart hook for this. See our [Deploy Hook](http://docs.engineyard.com/appcloud/howtos/deployment/use-deploy-hooks-with-engine-yard-appcloud) documentation
for more information on using deploy hooks.

