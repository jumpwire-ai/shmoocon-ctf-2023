<script>
  import Chatbox from "./lib/Chatbox.svelte";
  import Recent from "./lib/Recent.svelte";

  const app = document.getElementById("app");
  let chatId = app.dataset.chatId;
  let host = app.dataset.host;

</script>

<main class="font-mono text-primary h-full">
  <div class="max-w-4xl mx-auto">
    <div class="text-4xl py-8">EDPB Chat Room</div>
    <div class="text-xl p-4 border border-dashed border-primary">
      Welcome to the <span class="font-extrabold">European Data Protection Board</span> live chat center. Please
      click the button below to begin a chat session. Before speaking directly
      with a data protection officer, our chat bot will attempt to answer your
      questions.
      <div class="text-sm">Please note that chats may expire after some time</div>
    </div>

      <Chatbox {chatId} {host} />
      <Recent {chatId} {host} />
  </div>
</main>
