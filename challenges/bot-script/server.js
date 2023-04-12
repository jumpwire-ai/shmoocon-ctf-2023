import express from 'express'
import puppeteer from 'puppeteer'
import cors from 'cors'
import { resolve } from 'path'
import { fetchJoke } from './jokes.js'
import { flag } from './flag.js'
import { v4 as uuidv4 } from 'uuid'
import htmlExpress from 'html-express-js'
import fs from 'fs'

const __dirname = resolve()

function readAssets() {
  const js = fs.readdirSync(`${__dirname}/public/assets`).filter((f) => f.endsWith('.js'))
  const css = fs.readdirSync(`${__dirname}/public/assets`).filter((f) => f.endsWith('.css'))

  return { js, css }
}

const app = express()
const port = process.env.PORT || 3000
const host = process.env.HOST || "http://localhost:3000"
const chats = {}
const secretChats = {}
const bots = {}
let browser = null

app.engine(
  'js',
  htmlExpress({
    includesDir: 'includes'
  })
)

app.set('view engine', 'js')
app.set('views', `${__dirname}/public`)
app.use('/assets', express.static(`${__dirname}/public/assets`))
app.use('/favicon.ico', express.static('public/favicon.ico'))
app.use(express.json())
app.use(cors())

function sanitizeMessage(msg) {
  // msg.m = msg.m.replaceAll('>', '&gt;')
  // msg.m = msg.m.replaceAll('<', '&lt;')
  return msg
}

function botRespond(cid, v) {
  // only respond to last chat
  const msgs = chats[cid]
  if (msgs[msgs.length - 1].v === v) {
    fetchJoke().then((joke) => {
      chats[cid].push({
        v: msgs.length,
        m: joke,
        who: 'Board',
        ts: new Date()
      })
    })
  }
}

async function botCookie(cid) {
  if (bots[cid]) {
    return
  }

  const url = `${host}/${cid}?bot=y`
  const secret = uuidv4()
  secretChats[secret] = true
  let cookie = {
    name: 'chats',
    value: `["${secret}"]`,
    url: host,
    httpOnly: false,
    secure: false
  }

  const context = await browser.createIncognitoBrowserContext()
  const page = await context.newPage()
  await page.setCookie(cookie)
  setTimeout(() => {
    try {
      delete bots[cid]
      page.close()
      context.close()
      console.log(cid, 'Bot done for session')
    } catch (err) {
      console.log(cid, `err: ${err}`)
    }
  }, 90000)
  console.log(cid, 'Launching bot for session')
  page
    .on('pageerror', ({ message }) => console.log(cid, message))
    .on('requestfailed', (request) =>
      console.log(cid, `${request.failure().errorText} ${request.url()}`)
    )
  await page
    .goto(url)
    .catch((e) => console.error(cid, e))
    .then(() => {
      bots[cid] = true
      console.log(cid, 'Bot running for session')
    })
}

app.get('/ping', (_, res) => {
  res.send('Ok')
})

app.post('/:cid', function (req, res) {
  if (typeof req.body === 'object' && req.body !== null) {
    if (req.params.cid && !req.query.bot) {
      botCookie(req.params.cid)
    }

    if (req.params.cid && !Array.isArray(chats[req.params.cid])) {
      chats[req.params.cid] = []
    }

    const sanitized = sanitizeMessage(req.body)
    chats[req.params.cid].push(sanitized)
    setTimeout(botRespond, 333, req.params.cid, sanitized.v)
  }
  res.send('Ok')
})

app.get('/chats/:cid', function (req, res) {
  let cachedchats = []
  if (req.params.cid && secretChats[req.params.cid]) {
    cachedchats = flag
  } else if (req.params.cid && chats[req.params.cid]) {
    cachedchats = chats[req.params.cid]
  } else if (req.params.cid && !Array.isArray(chats[req.params.cid])) {
    chats[req.params.cid] = []
  }

  res.render('messages', { chats: cachedchats })
})

// render HTML in public/homepage.js with data
app.get(['/', '/:cid'], async function (req, res, next) {
  if (req.params.cid && !Array.isArray(chats[req.params.cid])) {
    chats[req.params.cid] = []
  }

  if (req.params.cid && !req.query.bot) {
    botCookie(req.params.cid)
  }

  const { js, css } = readAssets()
  res.render('homepage', {
    title: 'EU Data Protection Board - Chatbot',
    cid: req.params.cid,
    host,
    js,
    css
  })
})

// Capture interrupt signal so that Docker container can gracefully exit
// https://github.com/nodejs/node/issues/4182
process.on('SIGINT', function () {
  console.log('Node app exiting')
  process.exit()
})

app.listen(port, async () => {
  browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] })
  console.log(`Node app listening on port ${port}!`)
})
