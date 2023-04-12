# self reflection

https://excalidraw.com/#json=_ywEIwQmpF_kT9DXbAwc4,3rTMYX3tTv4DgZybO_PtnA

Multi step challenge.

The server has a login and registration page. Creating a new account takes you to a profile page, with
the ID (UUID) of your user in the URL. A relead button triggers a graphql call in JS to a public endpoint.

Putting that endpoint in a [graphql explorer](https://cloud.hasura.io/public/graphiql) let's you use the built-in reflection features to see the full schema for `users`. Interesting fields are `is_admin` and `password`. Filtering the query to return the email and password for an admin can be done with a query like this:

``` graphql
query MyQuery {
  users(where: {is_admin: {_eq: true}}) {
    email
    password
  }
}
```

The password format is a hash from md5crypt. All passwords are from a wordlist, so his can be cracked very quickly with JTR:

```shell
john password-file --wordlist=/usr/share/wordlists/passwords-large.txt
```

Logging back into the website as the admin show the same profile page, but for the admin user. The other interactive feature is generating API tokens. This is a JWT that encodes a hostname for a different server, and a boolean indicating if the user is an admin. Querying that API at `GET /` with a normal user's token will return just an ASCII art flag, but using the admin token returns the actual value.
