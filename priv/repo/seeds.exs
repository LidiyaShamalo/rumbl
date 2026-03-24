# Скрипт для заполнения базы данных. Вы можете запустить его следующим образом:
#
# mix run priv/repo/seeds.exs
#
# Внутри скрипта вы можете читать и записывать данные в любой из ваших
# репозиториев напрямую:
#
# Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# Мы рекомендуем использовать функции с восклицательным знаком (`insert!`, `update!`
# и так далее), так как они завершатся с ошибкой, если что-то пойдет не так.

alias Rumbl.Multimedia

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Multimedia.create_category!(category)
end
