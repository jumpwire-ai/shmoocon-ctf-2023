// public/message.js
import { html } from 'html-express-js'

export const view = ({ chats }) => {
  const divs = chats.map((c) => `<div id="chat-${c.v}" class="p-1">${c.who}: ${c.m}</div>`).join('')
  return html`${divs}`
}
