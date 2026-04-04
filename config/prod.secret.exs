use Mix.Config

wolfram_app_id =
  System.get_env("Y43323LU43") ||
  raise """
    переменная окружения WOLFRAM_APP_ID отсутствует.
  """

  config :info_sys, :wolfram, app_id: wolfram_app_id
