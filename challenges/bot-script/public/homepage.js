// public/homepage.js
import { html } from 'html-express-js'

const renderJs = (js) => {
  return js.map((j) => `<script type="module" crossorigin src="/assets/${j}"></script>`).join('\n')
}

const renderCss = (css) => {
  return css.map((c) => `<link rel="stylesheet" href="/assets/${c}" />`).join('\n')
}

export const view = (data, state) => html`
  <!DOCTYPE html>
  <html lang="en">
    <head>
      ${state.includes.head}
      <title>${data.title}</title>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      ${renderJs(data.js)} ${renderCss(data.css)}
    </head>

    <body data-theme="forest">
      <div id="app" data-chat-id="${data.cid}" data-host="${data.host}"></div>
    </body>
  </html>
`
