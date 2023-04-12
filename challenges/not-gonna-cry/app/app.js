const zlib = require('zlib');
const { Readable } = require("stream");

const net = require('net');

const hostname = '0.0.0.0';
const port = 1024;

const msg = {
    addr: '0x8986CD75B4720D181c836C9981875e693f472077',
    net: 'goerli',
    amt: '1.337',
    com: ['irc', 'http'],
    nodes: 73,
    id: '7B5FED5E-84DC-4823-B6C1-3E672089627F',
};
// encode as base64
const buff = Buffer.from(JSON.stringify(msg), 'utf-8').toString('base64');

const server = net.createServer((socket) => {
    console.log("Client connected");

    socket.on("data", (data) => {
        Readable.from(buff).pipe(zlib.createGzip({chunkSize: 64})).pipe(socket);
    });

    socket.on("end", () => {
        console.log("Client disconnected");
    });

    socket.on("error", (error) => {
        console.log(`Socket Error: ${error.message}`);
    });
});

server.on("error", (error) => {
    console.log(`Server Error: ${error.message}`);
});

server.listen(port, () => {
    console.log(`TCP socket server is running on port: ${port}`);
});
