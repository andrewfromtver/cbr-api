const express = require('express');
const { exec } = require('child_process');

const app = express();
const port = 80;

app.use(express.json());

app.get('/api/cbr/fin_org/get_full_info', (req, res) => {    
    // Validate input
    const type = req.query.type
    const data = req.query.data
    const output = req.query.output

    // Execute shell command
    exec(`./cbr/fin_org/get_full_info.sh ${type} ${data} ${output}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing script: ${error}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(500).send(`Error executing script: ${error}`);
            return;
        }

        if (stderr) {
            console.error(`Script encountered an error: ${stderr}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(400).send(`Script encountered an error: ${stderr}`);
            return;
        }
        
        console.log(`Script output: ${stdout}`);
        res.setHeader('Content-Type', `application/${output}`);
        res.send(stdout);
    });
});

app.get('/api/cbr/currency/get_rates', (req, res) => {    
    // Validate input
    const date = req.query.date
    const output = req.query.output

    // Execute shell command
    exec(`./cbr/currency/get_daily_rates.sh ${date} ${output}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing script: ${error}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(500).send(`Error executing script: ${error}`);
            return;
        }

        if (stderr) {
            console.error(`Script encountered an error: ${stderr}`);
            res.setHeader('Content-Type', 'text/plain');
            res.status(400).send(`Script encountered an error: ${stderr}`);
            return;
        }
        
        console.log(`Script output: ${stdout}`);
        res.setHeader('Content-Type', `application/${output}`);
        res.send(stdout);
    });
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});