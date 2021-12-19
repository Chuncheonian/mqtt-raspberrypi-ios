import os
import torch
from flask import Flask, jsonify, url_for, render_template, request, redirect, send_from_directory
from werkzeug.utils import secure_filename
import ssl
from PIL import Image
import uuid

app = Flask(__name__)
model = torch.hub.load('ultralytics/yolov5', 'custom', path='./static/models/best.pt', force_reload=True)# default

# torch model include
model.eval()  # evaluation print
model.conf = 0.25  # confidence threshold (0-1)
model.iou = 0.45  # NMS IoU threshold (0-1)

# image model output save function return results object
def get_prediction(img_bytes):
    # Inference
    results = model(img_bytes, size=640)  # includes NMS
    PATH = 'static/myresults/'
    results.save(PATH)
    return results

object_list = list()  # empty list

def results_img(results):
    object_list.clear()     # make it clear
    global msg              # global variable declaration
    print(results.names)    # print object elements name
    pred = results.pred     # prediction allocation
    for i in pred[0]:       # for loop for predicted objs
        objects = results.names[int(i[-1])]
        object_list.append(objects)
        
    # not e-scooter in photo
    if any('electric_scooter' in i for i in object_list) != True:  
        return '1'                                                                      

    output = any('brailleblock' in i for i in object_list)
    print(output)

    if output:
        return '2'  # why? reference info page
    else:
        return '0'

@app.route('/fileUpload', methods=['POST'])
def upload_file():
    global check_msg
    if request.method == 'POST':  # REST API POST METHOD
        print("DEBUG: ", request.files)
        if 'key' not in request.files:
            print("request.files error")
            return redirect(request.url)  # bad access redirect
        f = request.files['key']  # variable allocate file
        p_name = './static/photos/kick.jpg'
        f.save(p_name)

        image = Image.open(p_name)
        results = get_prediction(image)  # predict
        check_msg = results_img(results)
    return check_msg

if __name__ == '__main__':
    app.run(host='0.0.0.0', port='8000', debug=True)