# pwn

A collection of remote pwnable challenges all running on the same server. Each CGI script spawns in an nsjail environment, which minimizes the abilitity for players to affect each other.

## local dev

``` shell
docker build -t ctf -f Dockerfile.dev .
docker run --name apache -d --name apache \
    -p 8080:80 \
    -v (pwd)/app:/var/www/html \
    -v (pwd)/dbs/search.sqlite:/db.sqlite \
    ctf
```

Since this setup doesn't use nsjail, all flags will be under `/flags/` instead of a single file at `/flag`. Only one sqlite DB can be mounted at a time.

## solutions

### cowsay

The attacker's input is passed to an exec function, intended to call a single command. To make this slightly more challenging, both `&&` and `;` are replaced with whitespace. One way to bypass this filter is to background the ping process:

`& cat /flag`

### song search

SQL injection, the query that executes is:

``` sql
SELECT Name FROM Track WHERE Name LIKE '%" + input + "%';
```

However, there is some blacklisting of characters/keywords in the input to make this more challenging. The blacklist is:

- `union select`
- `;`
- `-`
- `/*`
- `*/`

Multiple spaces are also condensed to a single one.

One good way to approach this is to first try to figure out if there is a SQLi vuln - simply doing a single quote `hello'` returns an error, so we know it is. Then trying to make a valid query such as `hello' OR TRUE;`. This won't work until it has a null byte appended to it. Finally, turning the query into a union select that reveals the flag.

The union select needs to be broken up with a non-space whitespace character (eg \t), and the string can be terminated with a null byte. For example, in Elixir a valid SQLi is:

`"hello' union \t select value from flags" <> <<0>>`


The queries to run (before escaping) are:

```sql
SELECT name from sqlite_master where type ='table';  -- list the tables
SELECT name from PRAGMA_TABLE_INFO('flags'); -- list the columns in the flags table
SELECT value from flags; -- win!
```
