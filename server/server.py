import time

from flask import Flask, request,jsonify
from flask_socketio import SocketIO,emit
from flask_cors import CORS

from ashabot import get_response


app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
CORS(app,resources={r"/*":{"origins":"*"}})
socketio = SocketIO(
    app,
    cors_allowed_origins="*",
    async_mode='threading',
    logger=True,
    engineio_logger=True
)


@app.route("/http-call")
def http_call():
    """return JSON with string data as the value"""
    data = {'data':'This text was fetched using an HTTP call to server on render'}
    return jsonify(data)

@socketio.on("connect")
def connected():
    """event listener when client connects to the server"""
    print(request.sid)
    print("client has connected")
    return True

@socketio.on('message')
def handle_message(data):
    """event listener when client types a message"""
    try:
        print("data from the front end: ",str(data))
        response_message = get_response(data['message'])
        emit("message",{'message':response_message,'id':request.sid},broadcast=True)
        return True
    except Exception as e:
        print(f"Error handling message: {e}")
        return False

@socketio.on("disconnect")
def disconnected():
    """event listener when client disconnects to the server"""
    print("user disconnected")
    emit("disconnect",f"user {request.sid} disconnected",broadcast=True)
    return True

if __name__ == '__main__':
    socketio.run(app, debug=True,port=5001)