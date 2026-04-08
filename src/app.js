const express = require('express');
const { exec } = require('child_process');
const RateLimit = require('express-rate-limit');
const shellQuote = require('shell-quote');
const fs = require('fs');
const util = require('util');
const execPromise = util.promisify(exec);

let limiter = RateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
});

const app = express();
app.set('trust proxy', 1);
app.use(limiter);
const port = 8000;

app.use(express.json());

app.get('/api/cbr/fin_org/get_full_info', (req, res) => {
  // Validate input
  const type = shellQuote.parse(req.query.type)[0];
  const data = shellQuote.parse(req.query.data)[0];
  const output = shellQuote.parse(req.query.output)[0];

  // Execute shell command
  exec(
    `./cbr/fin_org/get_full_info.sh "${type}" "${data}" "${output}"`,
    (error, stdout, stderr) => {
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
      console.info(
        `[INFO] - Remote IP: ${remoteIp}, Request type: get_full_info, Request details: "${type}" "${data}" "${output}"`,
      );
      res.setHeader('Content-Type', `text/${output}`);
      res.send(stdout);
    },
  );
});

app.get('/api/cbr/fin_org/search', (req, res) => {
  // Validate input
  const query = shellQuote.parse(req.query.query);
  const output = shellQuote.parse(req.query.output)[0];

  // Execute shell command
  let queryString = query.join(' ');

  exec(
    `./cbr/fin_org/search.sh "${queryString}" "${output}"`,
    (error, stdout, stderr) => {
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
      console.info(
        `[INFO] - Remote IP: ${remoteIp}, Request type: search, Request details: "${queryString}" "${output}"`,
      );
      res.setHeader('Content-Type', `text/${output}`);
      res.send(stdout);
    },
  );
});

app.get('/api/cbr/currency/get_daily_rates', (req, res) => {
  // Validate input
  const date = shellQuote.parse(req.query.date)[0];
  const output = shellQuote.parse(req.query.output)[0];

  // Execute shell command
  exec(
    `./cbr/currency/get_daily_rates.sh "${date}" "${output}"`,
    (error, stdout, stderr) => {
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
      console.info(
        `[INFO] - Remote IP: ${remoteIp}, Request type: get_daily_rates, Request details: "${date}" "${output}"`,
      );
      res.setHeader('Content-Type', `text/${output}`);
      res.send(stdout);
    },
  );
});

app.get('/api/cbr/daily_info/all_data_info', (req, res) => {
  // Validate input
  const output = shellQuote.parse(req.query.output)[0];

  // Execute shell command
  exec(
    `./cbr/daily_info/all_data_info.sh "${output}"`,
    (error, stdout, stderr) => {
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
      console.info(
        `[INFO] - Remote IP: ${remoteIp}, Request type: get_all_data, Request details: "${output}"`,
      );

      res.setHeader('Content-Type', `text/${output}`);
      res.send(stdout);
    },
  );
});

app.get('/api/cbr/healthz', (req, res) => res.status(200).json({ status: 'ok' }));

app.get('/api/cbr/readyz', async (req, res) => {
  try {
    const scripts = {
      get_full_info: './cbr/fin_org/get_full_info.sh',
      search: './cbr/fin_org/search.sh',
      get_daily_rates: './cbr/currency/get_daily_rates.sh',
    };

    // Check if all scripts exist
    for (const [name, path] of Object.entries(scripts)) {
      if (!fs.existsSync(path)) {
        console.error(`[ERROR] - Method ${path} not found`);
        return res.status(503).json({
          status: 'not ready',
          error: `Required method ${name} not found`,
        });
      }

      // Check if scripts are executable
      try {
        fs.accessSync(path, fs.constants.X_OK);
      } catch (err) {
        console.error(`[ERROR] - Method ${path} is not accessable`);
        return res.status(503).json({
          status: 'not ready',
          error: `Method ${name} is not accessable`,
        });
      }
    }
    res.status(200).json({
      status: 'ready',
      checks: {
        methods_present: true,
        methods_accessable: true
      },
    });
  } catch (err) {
    console.error(`[ERROR] - Readiness check failed: ${err.message}`);
    res.status(503).json({
      status: 'not ready',
      error: 'Internal readiness check error',
    });
  }
});

app.listen(port, () => {
  console.info(`[INFO] - Server is running on port ${port}`);
});
