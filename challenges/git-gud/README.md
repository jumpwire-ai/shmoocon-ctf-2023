# git gud

This challenge has the flag committed to a repo and then deleted in a later commit. A bunch of noise was generated to make the flag harder to spot, but it can be found by parsing the git log.

The file is `flag` and was committed in `be6a3a2e134d2d8b8873eec8fa8aefba1d62e5a7`

## Setup

Commit messages were generated with ChatGPT!

``` elixir
Mix.install([:faker])

data = ...  # copied from chat gpt
messages = data |> String.split("\n") |> Enum.map(fn x -> String.replace(x, "\"", "") end)

{pre_msgs, post_msgs} = Enum.split(messages, 42)

fake_commit = fn msg ->
    name = Faker.File.file_name(:text)
    content = Faker.Lorem.paragraphs()
    File.write!(name, content)
    System.cmd("git", ["add", name])
    System.cmd("git", ["commit", "-m", msg])
end

Enum.each(pre_msgs, fn m -> fake_commit.(m) end)

System.cmd("git", ["add", "flag"])
System.cmd("git", ["commit", "-m", "Added a new config file"])
System.cmd("git", ["rm", "flag"])
System.cmd("git", ["commit", "-m", "Remove accidentally committed file"])

Enum.each(post_msgs, fn m -> fake_commit.(m) end)
```
