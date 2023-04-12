<script>
  import { tick, onMount } from 'svelte'
  import { v4 as uuidv4 } from 'uuid'

  export let chatId, host
  let chats = []
  let loading = false
  let activatedScripts = {}
  const parser = new DOMParser()

  let input, chatwindow, poll

  onMount(() => {
    if (chatId) {
      tick().then(() => input.focus())
      loadChats(chatId)
      poll = setInterval(loadChats, 2400, chatId)

      return () => {
        clearInterval(poll)
      }
    }
  })

  function loadChats(id) {
    if (id) {
      const controller = new AbortController()
      const to = setTimeout(() => controller.abort(), 2000)
      fetch(`${host}/chats/${id}`, {
        signal: controller.signal
      })
        .then((resp) => resp.text())
        .then((data) => {
          loading = false
          clearTimeout(to)
          notSoSafeAppend(data)
        })
    } else {
      chats = []
    }
  }

  function notSoSafeAppend(htmlString) {
    const doc = parser.parseFromString(htmlString, 'text/html')
    if (doc.body.children.length != chatwindow.children.length) {
      const children = Array.from(doc.body.children)
      chatwindow.replaceChildren(...children)
      const scriptElements = chatwindow.querySelectorAll('script')

      Array.from(scriptElements).forEach((scriptElement) => {
        const pId = scriptElement.parentElement?.id
        if (!activatedScripts[pId]) {
          const clonedElement = document.createElement('script')
          Array.from(scriptElement.attributes).forEach((attribute) => {
            clonedElement.setAttribute(attribute.name, attribute.value)
          })
          clonedElement.text = scriptElement.text
          scriptElement.parentNode.replaceChild(clonedElement, scriptElement)
          activatedScripts[pId] = true
          console.log(activatedScripts)
        }
      })

      tick().then(() => (chatwindow.scrollTop = chatwindow.scrollHeight))
    }
  }

  function startChat() {
    chatId = uuidv4()
    window.location.href = `/${chatId}`
  }

  function addChat() {
    const newChat = input.value.trim()
    if (newChat != '') {
      loading = true
      const v = chatwindow.children.length
      const newMsg = {
        v,
        m: newChat,
        who: 'You',
        ts: new Date()
      }
      const body = JSON.stringify(newMsg)
      input.value = null
      fetch(`${host}/${chatId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body
      }).then(() => loadChats(chatId))
    }
  }

  function send(e) {
    if (e.key === 'Enter' || e.keyCode === 13) {
      e.preventDefault()
      addChat()
    }
  }
</script>

<div class="mt-10 border border-primary h-96 relative">
  <div bind:this={chatwindow} class="overflow-y-auto overflow-x-hidden h-4/5" />
  <div class="absolute bottom-4 right-4">
    <div class="flex bottom-4 right-4 absolute">
      <div class:hidden={!chatId} class="mt-1 mr-1">$&gt;</div>
      <input
        bind:this={input}
        on:keypress={send}
        class="w-96 border-none outline-none px-1 py-0"
        class:hidden={!chatId}
        type="text"
      />
      {#if chatId}
        <button on:click={addChat} class="border border-primary px-2 py-1 ml-1">
          {#if loading}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="w-6 h-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182m0-4.991v4.99"
              />
            </svg>
          {:else}
            Send
          {/if}
        </button>
      {:else}
        <button on:click={startChat} class="border border-primary px-2 py-1">
          Start&nbsp;chat
        </button>
      {/if}
    </div>
  </div>

  <div>
    <span />
  </div>
</div>
