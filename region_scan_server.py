from flask import Flask, request, jsonify, json, make_response
app = Flask(__name__)
@app.route("/mode", methods=['GET', 'POST'])
def scanningMode():
    data = request.get_json()
    state = open("state.json", "r")
    contents = json.load(state)
    return {
        'Mode': contents.Mode
    }
@app.route("/submit", methods=['Get', 'Post'])
def submitData():
    data = request.get_json()
    scanType = None
    if data.Bodies:
        scanType = "Bodies"
    if data.Systems:
        scanType = "Systems"
    if scanType == None:
        return {}
    universe = open("systems.json", "a")
    universe.write(jsonify(data[scanType]))
    coordinates = ", ".split(data.Location)
    x = float(coordinates[0])
    y = float(coordinates[1])
    x += 21
    if x > 100:
        y += 21
        x = -90
    if y > 100:
        return{
            'Finished': True
        }
    return {
        'NextCoordinates': x+", "+y+", 0, 0, false"
    }
