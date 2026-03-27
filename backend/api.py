from flask import Flask, request, json
import os

app = Flask(__name__)

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')

# Load workout data at startup
with open(os.path.join(DATA_DIR, 'workout-data.json'), 'r') as f:
    workout_data = json.load(f)

with open(os.path.join(DATA_DIR, 'workout-attributes.json'), 'r') as f:
    workout_attributes = json.load(f)


@app.route('/')
def home():
    return app.response_class(
        response=json.dumps({'message': 'Muscle Wiki API'}),
        mimetype='application/json',
        status=200,
    )


@app.route('/exercises')
def get_exercises():
    muscle = request.args.get('muscle')
    name = request.args.get('name')
    category = request.args.get('category')
    difficulty = request.args.get('difficulty')
    force = request.args.get('force')

    filtered = []
    for exercise in workout_data:
        if muscle and not any(muscle in lst for lst in exercise['target'].values()):
            continue
        if name and name.lower() not in exercise['exercise_name'].lower():
            continue
        if category and category.lower() != exercise['Category'].lower():
            continue
        if difficulty and difficulty.lower() != exercise['Difficulty'].lower():
            continue
        if force and 'Force' not in exercise:
            continue
        if force and force.lower() != exercise['Force'].lower():
            continue
        filtered.append(exercise)

    return app.response_class(
        response=json.dumps(filtered),
        mimetype='application/json',
        status=200,
    )


@app.route('/exercises/attributes')
def get_exercise_attributes():
    return app.response_class(
        response=json.dumps(workout_attributes),
        mimetype='application/json',
        status=200,
    )


@app.route('/exercises/<int:exercise_id>')
def get_exercise_by_id(exercise_id):
    for exercise in workout_data:
        if exercise['id'] == exercise_id:
            return app.response_class(
                response=json.dumps(exercise),
                mimetype='application/json',
                status=200,
            )
    return app.response_class(
        response=json.dumps({'error': 'Exercise not found'}),
        mimetype='application/json',
        status=404,
    )


if __name__ == '__main__':
    app.run(debug=True)
