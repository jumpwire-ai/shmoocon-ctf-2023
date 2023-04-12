# Create a bunch of fake users

alias Reflection.{User, Repo}

wordlist = :code.priv_dir(:reflection)
|> Path.join("passwords-large.txt")
|> File.read!()
|> String.split("\n", trim: true)

for _ <- 1..1337 do
    user = %{
      email: Faker.Internet.email(),
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      password: Enum.random(wordlist),
    }
    User.create!(user)
end

admin = %{
  email: Faker.Internet.email(),
  first_name: Faker.Person.first_name(),
  last_name: Faker.Person.last_name(),
  password: Enum.random(wordlist),
}
User.changeset(admin)
|> Ecto.Changeset.put_change(:is_admin, true)
|> Repo.insert!()
