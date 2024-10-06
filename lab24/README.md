# Overview
This is a sample TODO app, which provides REST APIs to manage (CRUD) todo list items.

# Run the app
Follow these step to get the app up & running.
```bash
# optional - create a virtualenv for app dependencies installation
virtualenv venv
. venv/bin/activate

# install dependencies
pip3 install -r requirement.txt

# run the app, by default it's listening on port 3333/tcp, all interfaces (0.0.0.0)
# specify `HOST`, `PORT` to override default host, port respectively
python3 app.py
```

You should see this if app starts properly:
```txt
> python3 app.py;
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:3333
 * Running on http://XXXX:3333
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: XXXX
```

# APIs usage

| Action              | Method | Endpoint       | Example Command                                                                                           |
|---------------------|--------|----------------|-----------------------------------------------------------------------------------------------------------|
| Add a new to-do     | POST   | `/todo`        | `curl -X POST http://localhost:3333/todo -H "Content-Type: application/json" -d '{"task": "Buy groceries"}'`|
| Get all to-dos      | GET    | `/todos`       | `curl -X GET http://localhost:3333/todos`                                                                 |
| Get a specific to-do| GET    | `/todo/<id>`   | `curl -X GET http://localhost:3333/todo/1`                                                                |
| Update a to-do      | PUT    | `/todo/<id>`   | `curl -X PUT http://localhost:3333/todo/1 -H "Content-Type: application/json" -d '{"task": "Buy groceries", "done": true}'` |
| Delete a to-do      | DELETE | `/todo/<id>`   | `curl -X DELETE http://localhost:3333/todo/1`                                                             |

# Run the Unit Test

## Test structure explanation
- `setUp()` Method:
  - Runs before each test to set up the test environment.
  - It clears the `todos` table and adds a sample entry (`"Buy groceries"`) to test with.
  - We use `self.app = app.test_client()` to create a test client that simulates HTTP requests.

- Test Methods:

  - `test_get_all_todos`: Tests the GET `/todos` endpoint, checking the response status and ensuring that it returns a list of todos.
  - `test_get_single_todo`: Tests the GET `/todo/<id>` endpoint to fetch a specific to-do by ID.
  - `test_add_new_todo`: Tests the POST `/todo` endpoint to add a new to-do, then checks whether it was added successfully.
  - `test_update_todo`: Tests the PUT `/todo/<id>` endpoint to update a to-do (marking it as done).
  - `test_delete_todo`: Tests the DELETE `/todo/<id>` endpoint to delete a to-do, and checks if it was actually deleted.

- These UTs use a in-memory database for performance, flexibility purpose.


## Run the Unit Test

Running the Tests

    - Make sure your Flask app (app.py) is running and accessible in the same directory.
    - Run the tests


```bash
python3 -m unittest test_app.py
```

Expected output:

```txt
........
----------------------------------------------------------------------
Ran 8 tests in 0.019s

OK
```

NOTE: the test script will create a temp database at `/tmp/test.db`.
