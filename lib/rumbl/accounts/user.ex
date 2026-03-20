defmodule Rumbl.Accounts.User do

  @type t() :: {String.t(), Srting.t(), String.t()}
  
  defstruct [:id, :name, :username]
end
