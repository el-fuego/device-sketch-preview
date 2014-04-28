
(function () {

window.addEventListener("load", function() {
	// canvas要素
	var canvas = document.getElementById("canvas");
	var ctx = canvas.getContext('2d');
	// 変形画像貼り付け用Canvas
	var canvas1 = document.createElement('canvas');
	canvas1.width = canvas.width;
	canvas1.height = canvas.height;
	var ctx1 = canvas1.getContext('2d');
	// 補助線貼り付け用Canvas
	var canvas2 = document.createElement('canvas');
	canvas2.width = canvas.width;
	canvas2.height = canvas.height;
	var ctx2 = canvas2.getContext('2d');
	ctx.antialias = ctx1.antialias = ctx2.antialias = antialias || 'none';
	ctx.patternQuality = ctx1.patternQuality = ctx2.patternQuality = patternQuality || 'fast';
	//
	var op = null;
	var points = splitPoints(transformPoints.innerHTML);

	console.log(points)
	// img要素

	img = new Image();
	img.src = sourceImagePath;

	setInterval(function(){
		transformPoints.innerHTML = joinPoints(points);
	}, 1000)

	function redraw () {
		ctx.clearRect(0, 0, canvas.width, canvas.height);
		ctx1.clearRect(0, 0, canvas.width, canvas.height);
		op.draw(points);
		prepare_lines(ctx2, points);
		draw_canvas(ctx, ctx1, ctx2);
	};

	img.onload = function() {
		op = new html5jp.perspective(ctx1, img);
		redraw();
	};


	// canvas要素にマウス関連イベントのリスナーをセット
	var drag = lastDragged = null;
	canvas.addEventListener("mousedown", function(event) {
		event.preventDefault();
		var p = get_mouse_position(event);
		for( var i=0; i<4; i++ ) {
			var x = points[i][0];
			var y = points[i][1];
			if( p.x < x + 10 && p.x > x - 10 && p.y < y + 10 && p.y > y - 10 ) {
				drag = i;
				break;
			}
		}
		lastDragged = drag;
	}, false);
	canvas.addEventListener("mousemove", function(event) {
		event.preventDefault();
		if(drag == null) { return; }
		var p = get_mouse_position(event);
		points[drag][0] = p.x;
		points[drag][1] = p.y;

		redraw();
	}, false);
	canvas.addEventListener("mouseup", function(event) {
		event.preventDefault();
		if(drag == null) { return; }
		var p = get_mouse_position(event);
		points[drag][0] = p.x;
		points[drag][1] = p.y;

		redraw();
		drag = null;
	}, false);
	canvas.addEventListener("mouseout", function(event) {
		event.preventDefault();
		drag = null;
	}, false);
	canvas.addEventListener("mouseenter", function(event) {
		event.preventDefault();
		drag = null;
	}, false);

	document.addEventListener("keydown", function(event) {
		event.preventDefault();

		if (!lastDragged || [37, 38, 39, 40].indexOf(event.keyCode) == -1) {
			return;
		}

		switch (event.keyCode) {
			case 38: // up
				points[lastDragged][1] += -1; // Y
			break;
			case 40: // down
				points[lastDragged][1] += 1; // Y
			break;
			case 37: // left
				points[lastDragged][0] += -1; // X
			break;
			case 39: // right
				points[lastDragged][0] += 1; // X
			break;
		}
		redraw();
		
	}, false);

}, false);

function splitPoints (str) {
	return str.split(' ').map(function(point) {
		return point.split(',').map(function(val){
			return +val;
		});
	})
}
function joinPoints (points) {
	return points.map(function(point) {
		return point.join(',');
	}).join(' ')
}

function prepare_lines(ctx, p) {
	ctx.save();
	ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

	for( var i=0; i<4; i++ ) {
		ctx.fillStyle = lastDragged == i ? "green" : "red";
		ctx.beginPath();
		ctx.arc(p[i][0], p[i][1], 4, 0, Math.PI*2, true);
		ctx.fill();
	}
	//
	ctx.restore();
}

function draw_canvas(ctx, ctx1, ctx2) {
	ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
	ctx.drawImage(ctx1.canvas, 0, 0);
	ctx.drawImage(ctx2.canvas, 0, 0);
}

function get_mouse_position(event) {
	var rect = event.target.getBoundingClientRect() ;
	return {
		x: event.clientX - rect.left,
		y: event.clientY - rect.top
	};
}

})();