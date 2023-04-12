// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'

async function fetchGraphQL(operationsDoc, operationName, variables) {
    const result = await fetch(
        window.api_url,
        {
            method: "POST",
            body: JSON.stringify({
                query: operationsDoc,
                variables: variables,
                operationName: operationName
            })
        }
    )

    return await result.json()
}

const operationsDoc = `
  query User($user_id: uuid) {
    users(where: {id: {_eq: $user_id}}, limit: 1) {
      email
      first_name
      last_name
      id
    }
  }
`;

function fetchUser(user_id) {
    return fetchGraphQL(
        operationsDoc,
        "User",
        {"user_id": user_id}
    );
}

window.loadUser = el => {
    const icon = el.getElementsByTagName('svg')[0]
    const userId = el.dataset.userId
    let minSpin = false
    let queryDone = false

    // spin for at least 1 second
    icon.classList.add('animate-spin')

    maybeStopSpinner = () => {
        if (queryDone && minSpin) {
            icon.classList.remove('animate-spin')
        }
    }

    window.setTimeout(() => {
        minSpin = true
        maybeStopSpinner()
    }, 1000);

    fetchUser(userId).then((response) => {
        if (response.errors) {
            console.error(response)
        }

        if (response.data) {
            const user = response.data.users[0]
            console.log(user)
            document.getElementById('name').innerText = user.first_name + ' ' + user.last_name
            document.getElementById('email').innerText = user.email

            // don't show passwords, that's too insecure
            // document.getElementById('password').innerText = user.password
        }

        queryDone = true
        maybeStopSpinner()
    })
}
