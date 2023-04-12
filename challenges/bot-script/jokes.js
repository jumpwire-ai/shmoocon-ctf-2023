const cachedJokes = []

export function fetchJoke() {
  return fetch('https://icanhazdadjoke.com/', {
    headers: {
      Accept: 'application/json'
    }
  })
    .then((resp) => {
      if (resp.ok) {
        return resp.json()
      } else {
        console.log(resp)
        return Promise.resolve({})
      }
    })
    .then((joke) => {
      if (joke?.joke) {
        if (cachedJokes.length > 100) {
          cachedJokes.shift()
        }
        cachedJokes.push(joke.joke)
        return Promise.resolve(joke.joke)
      } else if (cachedJokes.length > 0) {
        const rj = cachedJokes[Math.floor(Math.random() * cachedJokes.length)]
        return Promise.resolve(rj)
      } else {
        return Promise.reject()
      }
    })
}
