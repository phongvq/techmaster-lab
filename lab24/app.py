import os

from flask import Flask, jsonify, request, g
import sqlite3


app = Flask(__name__)

app.config['DATABASE'] = 'todo.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(app.config['DATABASE'])
        db.row_factory = sqlite3.Row
    return db

def query_db(query, args=(), one=False):
    cur = get_db().execute(query, args)
    rv = cur.fetchall()
    cur.close()
    return (rv[0] if rv else None) if one else rv

def init_db():
    with app.app_context():
        db = get_db()
        db.execute('''
            CREATE TABLE IF NOT EXISTS todos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                task TEXT NOT NULL,
                done BOOLEAN NOT NULL CHECK (done IN (0, 1))
            )
        ''')
        db.commit()

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

@app.route('/todos', methods=['GET'])
def get_todos():
    todos = query_db('SELECT * FROM todos')
    return jsonify([dict(id=row['id'], task=row['task'], done=bool(row['done'])) for row in todos])

@app.route('/todo/<int:todo_id>', methods=['GET'])
def get_todo(todo_id):
    todo = query_db('SELECT * FROM todos WHERE id = ?', [todo_id], one=True)
    if todo:
        return jsonify(dict(id=todo['id'], task=todo['task'], done=bool(todo['done'])))
    return jsonify({'error': 'Todo not found'}), 404

@app.route('/todo', methods=['POST'])
def add_todo():
    new_task = request.json.get('task', '')
    if new_task:
        db = get_db()
        db.execute('INSERT INTO todos (task, done) VALUES (?, ?)', [new_task, False])
        db.commit()
        return jsonify({'message': 'Todo added successfully'}), 201
    return jsonify({'error': 'Task is required'}), 400

@app.route('/todo/<int:todo_id>', methods=['PUT'])
def update_todo(todo_id):
    db = get_db()
    todo = query_db('SELECT * FROM todos WHERE id = ?', [todo_id], one=True)
    if todo:
        new_task = request.json.get('task', todo['task'])
        done = request.json.get('done', todo['done'])
        db.execute('UPDATE todos SET task = ?, done = ? WHERE id = ?', [new_task, done, todo_id])
        db.commit()
        return jsonify({'message': 'Todo updated successfully'})
    return jsonify({'error': 'Todo not found'}), 404

@app.route('/todo/<int:todo_id>', methods=['DELETE'])
def delete_todo(todo_id):
    db = get_db()
    todo = query_db('SELECT * FROM todos WHERE id = ?', [todo_id], one=True)
    if todo:
        db.execute('DELETE FROM todos WHERE id = ?', [todo_id])
        db.commit()
        return jsonify({'message': 'Todo deleted successfully'})
    return jsonify({'error': 'Todo not found'}), 404

if __name__ == '__main__':
    init_db()  # Initialize the database

    host = os.getenv('HOST', '0.0.0.0')
    port = int(os.getenv('PORT', 3333))

    app.run(debug=True, host=host, port=port)

