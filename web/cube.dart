import 'dart:html';
import 'dart:math';
import 'dart:async';

void main() {
  CanvasElement canvas = querySelector("#canvas");
  InputElement fov = querySelector("#fov");
  Cube c = new Cube(canvas, fov.valueAsNumber, 1);
  Cube d = new Cube(canvas, 500, 2);
  //scheduleMicrotask(c.start);
  scheduleMicrotask(d.start);
}

class Space {
  
  List<Cube> cubes;
  
  num numberOfCubes;
  
  
  Space(this.numberOfCubes) {
    for (var i=0; i<numberOfCubes; i++) {
      //cubes.add(new Cube(canvas, fov, location))
    }
  }
  
}

class Cube {

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  Rectangle view;
  num fov;
  num location;
  
  var vertices = [new Point3D(-1, 1, -1),
                  new Point3D(1, 1, -1),
                  new Point3D(1, -1, -1),
                  new Point3D(-1, -1, -1),
                  new Point3D(-1, 1, 1),
                  new Point3D(1, 1, 1),
                  new Point3D(1, -1, 1),
                  new Point3D(-1, -1, 1)];

  var faces = [[0,1,2,3],
               [1,5,6,2],
               [5,4,7,6],
               [4,0,3,7],
               [0,4,5,1],
               [3,2,6,7]];
  

  var colors = [[241, 238, 246],
                [208, 209, 230],
                [166, 189, 219],
                [116, 169, 207],
                [43, 140, 190],
                [4, 90, 141]];

  num angle = 0.0;

  Cube(this.canvas, this.fov, this.location) {
    this.view = canvas.client;
  }
  
  start() {
    requestRedraw();
  }
  
  void draw(num _) {
    var context = canvas.context2D;
    drawBackground(context);
    loop(context);
    requestRedraw();
  }

  void drawBackground(CanvasRenderingContext2D context) {
    context.clearRect(0, 0, view.width, view.height);
  }
  
  void requestRedraw() {
    window.requestAnimationFrame(draw);
  }
  
  String arrayToRgb(arr) {
    if (arr.length == 3) {
      return 'rgb(${arr[0].toString()}, ${arr[1].toString()} , ${arr[2].toString()})';
    }
    return "rgb(0,0,0)";
  }
  
  void loop(CanvasRenderingContext2D ctx) {
    InputElement fov = querySelector("#fov");
    InputElement viewDistance = querySelector("#view-distance");
    var t = new List(vertices.length);
  
    for (var i=0; i < vertices.length; i++) {
      Point3D v = vertices[i];
      Point3D r = v.rotateX(angle).rotateY(angle).rotateZ(angle);
      var p = r.project(view.width/location, view.height/location, fov.valueAsNumber, viewDistance.valueAsNumber);
      t[i] = p;
    }
  
    var avg_z = new List(faces.length);
  
    for (var i=0; i < faces.length; i++) {
      var f = faces[i];
      var z = (t[f[0]].z + t[f[1]].z + t[f[2]].z + t[f[3]].z) / 4.0;
      avg_z[i] = {"index":i, "z":z};
    }
  
    avg_z.sort((a,b) => b['z'] - a['z']);
   
    for (var i=0; i < faces.length; i++) {
      var f = faces[avg_z[i]['index']];
      ctx..fillStyle = arrayToRgb(colors[avg_z[i]['index']])
         ..beginPath()
         ..moveTo(t[f[0]].x, t[f[0]].y)
         ..lineTo(t[f[1]].x, t[f[1]].y)
         ..lineTo(t[f[2]].x, t[f[2]].y)
         ..lineTo(t[f[3]].x, t[f[3]].y)
         ..closePath()
         ..fill();
    }
    angle += 0.03;
  }
}

class Point3D {
  var x,y,z;
  
  Point3D(this.x, this.y, this.z);
  
  Point3D rotateX(angle) {
    num rad, cosa, sina, _y, _z;
    rad = angle * PI / 180;
    cosa = cos(angle);
    sina = sin(angle);
    _y = this.y * cosa - this.z * sina;
    _z = this.y * sina + this.z * cosa;
    return new Point3D(this.x, _y, _z);
  }
 
  Point3D rotateY(angle) {
    num rad, cosa, sina, _x, _z;
    rad = angle * PI / 180;
    cosa = cos(rad);
    sina = sin(rad);
    _z = this.z * cosa - this.x * sina;
    _x = this.z * sina + this.x * cosa;
    return new Point3D(_x,this.y, _z);
 }
 
  Point3D rotateZ(angle) {
    num rad, cosa, sina, _x, _y;
    rad = angle * PI / 180;
    cosa = cos(rad);
    sina = sin(rad);
    _x = this.x * cosa - this.y * sina;
    _y = this.x * sina + this.y * cosa;
    return new Point3D(_x, _y, this.z);
  }
 
  Point3D project(viewHeight, viewWidth, fov, viewDistance) {
    num factor, _x, _y;
    factor = fov / (viewDistance + this.z);
    _x = this.x * factor + viewWidth / 2;
    _y = this.y * factor + viewHeight / 2;
    return new Point3D(_x, _y, this.z);
  }
}   