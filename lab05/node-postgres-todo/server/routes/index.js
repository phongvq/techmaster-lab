const express = require('express');
const router = express.Router();
const pg = require('pg');
const path = require('path');
const connectionString = process.env.DATABASE_URL || 'postgres://localhost:5432/todo';

const pool = new pg.Pool({connectionString: connectionString})

router.get('/', (req, res, next) => {
  res.sendFile(path.join(
    __dirname, '..', '..', 'client', 'views', 'index.html'));
});

router.get('/api/v1/todos', (req, res, next) => {
  const results = [];
  // Get a Postgres client from the connection pool
  pool.connect(async (err, client, done) => {
    // Handle connection errors
    if(err) {
      done();
      console.log(err);
      return res.status(500).json({success: false, data: err});
    }
    // SQL Query > Select Data
    const result = await client.query('SELECT * FROM items ORDER BY id ASC;');
    // Stream results back one row at a time
    // query.on('row', (row) => {
    //   results.push(row);
    // });
    // After all data is returned, close connection and return results
    // query.on('end', () => {
    //   done();
    //   return res.json(results);
    // });
    result.rows.forEach(row => results.push(row));

    return res.json(results);
  });
});

router.post('/api/v1/todos', (req, res, next) => {
  const results = [];
  // Grab data from http request
  const data = {text: req.body.text, complete: false};
  // Get a Postgres client from the connection pool
  pool.connect(async (err, client, done) => {
    // Handle connection errors
    if(err) {
      done();
      console.log(err);
      return res.status(500).json({success: false, data: err});
    }
    // SQL Query > Insert Data
    await client.query('INSERT INTO items(text, complete) values($1, $2)',
    [data.text, data.complete]);
    // SQL Query > Select Data
    const query = await client.query('SELECT * FROM items ORDER BY id ASC');
    // Stream results back one row at a time
    query.rows.forEach(row => results.push(row));

    return res.json(results);
  });
});

router.put('/api/v1/todos/:todo_id', (req, res, next) => {
  const results = [];
  // Grab data from the URL parameters
  const id = req.params.todo_id;
  // Grab data from http request
  const data = {text: req.body.text, complete: req.body.complete};
  // Get a Postgres client from the connection pool
  pool.connect(async (err, client, done) => {
    // Handle connection errors
    if(err) {
      done();
      console.log(err);
      return res.status(500).json({success: false, data: err});
    }
    // SQL Query > Update Data
    await client.query('UPDATE items SET text=($1), complete=($2) WHERE id=($3)',
    [data.text, data.complete, id]);
    // SQL Query > Select Data
    const query = await client.query("SELECT * FROM items ORDER BY id ASC");
    // Stream results back one row at a time
    query.rows.forEach(row => results.push(row));

    return res.json(results);

  });
});

router.delete('/api/v1/todos/:todo_id', (req, res, next) => {
  const results = [];
  // Grab data from the URL parameters
  const id = req.params.todo_id;
  // Get a Postgres client from the connection pool
  pool.connect(async (err, client, done) => {
    // Handle connection errors
    if(err) {
      done();
      console.log(err);
      return res.status(500).json({success: false, data: err});
    }
    // SQL Query > Delete Data
    await client.query('DELETE FROM items WHERE id=($1)', [id]);
    // SQL Query > Select Data
    var query = await client.query('SELECT * FROM items ORDER BY id ASC');
    // Stream results back one row at a time
    query.rows.forEach(row => results.push(row));

    return res.json(results);

  });
});

module.exports = router;
