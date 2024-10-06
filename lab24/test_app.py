import unittest
import sqlite3
import json
from app import app, init_db, get_db

class TodoAppTestCase(unittest.TestCase):

    def setUp(self):
        # Set up the app in testing mode
        app.config['TESTING'] = True
        app.config['DATABASE'] = '/tmp/test.db'  # Use an in-memory database
        self.client = app.test_client()

        # Initialize the database and create the todos table
        with app.app_context():
            init_db()  # Create the table in the in-memory database

    def tearDown(self):
        # Clean up and close the connection after each test
        with app.app_context():
            db = get_db()
            db.execute('DROP TABLE IF EXISTS todos')
            db.commit()

    def test_get_empty_todos(self):
        # Test GET /todos when no todos exist
        response = self.client.get('/todos')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, [])

    def test_add_todo(self):
        # Test POST /todo to add a new todo
        new_todo = {'task': 'Buy groceries'}
        response = self.client.post('/todo', json=new_todo)
        self.assertEqual(response.status_code, 201)
        self.assertIn('message', response.json)

        # Verify the todo is now in the database
        response = self.client.get('/todos')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json), 1)
        self.assertEqual(response.json[0]['task'], 'Buy groceries')
        self.assertFalse(response.json[0]['done'])

    def test_get_todo(self):
        # Add a todo and fetch it by ID
        new_todo = {'task': 'Do homework'}
        self.client.post('/todo', json=new_todo)

        response = self.client.get('/todo/1')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['task'], 'Do homework')
        self.assertFalse(response.json['done'])

    def test_update_todo(self):
        # Add a todo and update it
        self.client.post('/todo', json={'task': 'Finish project'})

        updated_todo = {'task': 'Finish project v2', 'done': True}
        response = self.client.put('/todo/1', json=updated_todo)
        self.assertEqual(response.status_code, 200)
        self.assertIn('message', response.json)

        # Verify the todo was updated
        response = self.client.get('/todo/1')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json['task'], 'Finish project v2')
        self.assertTrue(response.json['done'])

    def test_delete_todo(self):
        # Add a todo and delete it
        self.client.post('/todo', json={'task': 'Water plants'})
        
        response = self.client.delete('/todo/1')
        self.assertEqual(response.status_code, 200)
        self.assertIn('message', response.json)

        # Verify the todo is no longer in the database
        response = self.client.get('/todo/1')
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', response.json)

    def test_get_nonexistent_todo(self):
        # Test GET /todo/<id> when the todo doesn't exist
        response = self.client.get('/todo/999')
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', response.json)

    def test_update_nonexistent_todo(self):
        # Test PUT /todo/<id> when the todo doesn't exist
        updated_todo = {'task': 'Nonexistent task', 'done': True}
        response = self.client.put('/todo/999', json=updated_todo)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', response.json)

    def test_delete_nonexistent_todo(self):
        # Test DELETE /todo/<id> when the todo doesn't exist
        response = self.client.delete('/todo/999')
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', response.json)

if __name__ == '__main__':
    unittest.main()

