const express = require('express');
const { exec } = require('child_process');
const RateLimit = require('express-rate-limit');
const shellQuote = require('shell-quote');

let limiter = RateLimit({
    windowMs: 15 * 60 * 1000,
    max: 1000
});

const app = express();
app.set('trust proxy', 1);
app.use(limiter);
const port = 8000;

app.use(express.json());

app.get('/api/cbr/fin_org/get_full_info', (req, res) => {    
    // Validate input
    const type = shellQuote.parse(req.query.type)[0]
    const data = shellQuote.parse(req.query.data)[0]
    const output = shellQuote.parse(req.query.output)[0]

    // Execute shell command
    exec(`./cbr/fin_org/get_full_info.sh ${type} ${data} ${output}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`[ERROR] - Error executing script: ${error}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(500).send(`Error executing script: ${error}`);
            return;
        }

        if (stderr) {
            console.error(`[ERROR] - Script encountered an error: ${stderr}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(400).send(`Script encountered an error: ${stderr}`);
            return;
        }
        
        const remoteIp = req.ip || req.connection.remoteAddress;
        console.info(`[INFO] - Remote IP: ${remoteIp}, Request details: ${type} ${data} ${output}`);
        res.setHeader('Content-Type', `text/${output}`);
        res.send(stdout);
    });
});

app.get('/api/cbr/fin_org/search', (req, res) => {    
    // Validate input
    const query = shellQuote.parse(req.query.query)[0]
    const output = shellQuote.parse(req.query.output)[0]

    // Execute shell command
    exec(`./cbr/fin_org/search.sh ${query} ${output}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`[ERROR] - Error executing script: ${error}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(500).send(`Error executing script: ${error}`);
            return;
        }

        if (stderr) {
            console.error(`[ERROR] - Script encountered an error: ${stderr}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(400).send(`Script encountered an error: ${stderr}`);
            return;
        }
        
        const remoteIp = req.ip || req.connection.remoteAddress;
        console.info(`[INFO] - Remote IP: ${remoteIp}, Request details: ${query} ${output}`);
        res.setHeader('Content-Type', `text/${output}`);
        res.send(stdout);
    });
});

app.get('/api/cbr/currency/get_daily_rates', (req, res) => {    
    // Validate input
    const date = shellQuote.parse(req.query.date)[0]
    const output = shellQuote.parse(req.query.output)[0]

    // Execute shell command
    exec(`./cbr/currency/get_daily_rates.sh ${date} ${output}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`[ERROR] - Error executing script: ${error}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(500).send(`Error executing script: ${error}`);
            return;
        }

        if (stderr) {
            console.error(`[ERROR] - Script encountered an error: ${stderr}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(400).send(`Script encountered an error: ${stderr}`);
            return;
        }
        
        const remoteIp = req.ip || req.connection.remoteAddress;
        console.info(`[INFO] - Remote IP: ${remoteIp}, Request details: ${date} ${output}`);
        res.setHeader('Content-Type', `text/${output}`);
        res.send(stdout);
    });
});

app.listen(port, () => {
    console.info(`[INFO] - Server is running on port ${port}`);
});