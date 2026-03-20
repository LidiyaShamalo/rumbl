defmodule Rumbl.Accounts.User do

  @type t() :: {String.t(), String.t(), String.t()}

  defstruct [:id, :name, :username]
end
