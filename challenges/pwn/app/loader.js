const respEl = document.getElementById('form-response')

document.getElementById('form').addEventListener('submit', async (e) => {
    e.preventDefault()
    const form = e.target

    const data = new FormData(form)

    const resp = await fetch(form.action, {
        method: 'post',
        body: data,
    })
    respEl.innerHTML = await resp.text()
})
