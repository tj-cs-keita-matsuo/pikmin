# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :pikmin, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:pikmin, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
config :pikmin,
  :redmine,
    base_url: "http://localhost:3000/",
    api_key: "d0933da2d13a11aca7b97923b17eeb6edd2b44c4"

config :pikmin,
  :slack,
    base_url: "https://slack.com/api/",
    token: "xoxp-281894998599-280820758002-287294215424-5e75c14102b151c0ddaff286a9277750"

config :pikmin, Pikmin.Scheduler,
  jobs: [
    redmine_to_slack: [
      schedule: { :extended, "*/5" }, # Runs every two seconds
      task: { Pikmin.Manager, :run, [] }
    ]
  ]
