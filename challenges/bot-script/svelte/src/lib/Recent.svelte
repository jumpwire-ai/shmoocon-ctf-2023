<script>
  import { onMount } from 'svelte'
  import Cookies from 'js-cookie'

  export let chatId, host

  const cookies = Cookies.withConverter({
    read: (value, _name) => {
      try {
        return new Set(JSON.parse(value))
      } catch (e) {
        return new Set()
      }
    },
    write: (value, _name) => {
      return JSON.stringify(Array.from(value))
    }
  })

  let recent = cookies.get('chats') || new Set()
  let display = []
  $: display = Array.from(recent).filter((cid) => cid != chatId)

  onMount(() => {
    if (chatId) {
      recent.add(chatId)
      cookies.set('chats', recent)
    }
  })
</script>

<div class="mt-6 text-lg">Recent chats</div>
<div class="border border-primary h-32 relative">
  <div class="overflow-y-auto overflow-x-hidden">
    {#each display as cid}
      <a class="block underline cursor-pointer px-1" href={`${host}/${cid}`}>{`${host}/${cid}`}</a>
    {:else}
      <div class="italic">No recent chats</div>
    {/each}
  </div>
</div>
