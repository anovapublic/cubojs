###
 Anova IT Consulting 2012

This file is licensed under the GPL version 3.
Please refer to the URL http://www.gnu.org/licenses/gpl-3.0.html for details.
###

class CUBE
	gl = null
	program = null
	texture = null
	cube_vertex_position_buffer = null
	cube_vertex_texture_buffer = null
	cube_vertex_index_buffer = null

	x_rot = 0
	y_rot = 0
	z_rot = 0
	last = 0;

	start : (canvas, image) ->
		init_gl(canvas)
		init_texture(image)
		init_shaders()
		init_buffers()

		gl.clearColor(0.0, 0.0, 0.0, 1.0)
		gl.enable(gl.DEPTH_TEST)

		tick()

	animate = ->
		now = new Date().getTime()
		if last
			elapsed = now - last;
			x_rot += (90 * elapsed) / 1000.0
			y_rot += (90 * elapsed) / 1000.0
			z_rot += (90 * elapsed) / 1000.0
		last = now

	tick = ->
		requestAnimFrame(tick)
		draw()
		animate()

	init_gl = (canvas) ->
		gl = WebGLUtils.create3DContext(canvas)
		if not gl
			throw 'Could not initialize WebGL'
		gl.viewportWidth = canvas.width;
		gl.viewportHeight = canvas.height;

	get_shader = (type)  ->
		shader = gl.createShader(type)

		if type == gl.FRAGMENT_SHADER
			gl.shaderSource(shader, sh_fragment)
		else if type == gl.VERTEX_SHADER
			gl.shaderSource(shader, sh_vertex)

		gl.compileShader(shader)

		if not gl.getShaderParameter(shader, gl.COMPILE_STATUS)
			throw gl.getShaderInfoLog(shader)

		shader
	
	init_shaders = ->
		fragment = get_shader(gl.FRAGMENT_SHADER)
		vertex = get_shader(gl.VERTEX_SHADER)
		
		program = gl.createProgram()
		gl.attachShader(program, vertex)
		gl.attachShader(program, fragment)
		gl.linkProgram(program)

		if not gl.getProgramParameter(program, gl.LINK_STATUS)
			throw 'Could not initialize shaders'

		gl.useProgram(program)
		program.vertexPositionAttribute = 
			gl.getAttribLocation(program, 'aVertexPosition')
		gl.enableVertexAttribArray(program.vertexPositionAttribute)

		program.textureCoordAttribute = 
			gl.getAttribLocation(program, 'aTextureCoord')
		gl.enableVertexAttribArray(program.textureCoordAttribute)

		program.pMatrixUniform =  gl.getUniformLocation(program, 'uPMatrix')
		program.mvMatrixUniform = gl.getUniformLocation(program, 'uMVMatrix')
		program.samplerUniform = gl.getUniformLocation(program, 'uSampler')

	init_texture = (image) ->
		texture = gl.createTexture()
		texture.image = image
		texture.image.onload = ->
			gl.bindTexture(gl.TEXTURE_2D, texture)
			gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
			gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA,
				gl.UNSIGNED_BYTE, texture.image)
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER,
				gl.NEAREST)
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER,
				gl.NEAREST)
			gl.bindTexture(gl.TEXTURE_2D, null)
	
	class MATRIX_OP
		mv_matrix = mat4.create()
		p_matrix = mat4.create()

		perspective : (ratio) ->
			mat4.perspective(
				45, ratio, 0.1, 100.0, p_matrix)
			p_matrix
		
		rotate : (x_rot, y_rot, z_rot) ->
			mat4.identity(mv_matrix)
			mat4.translate(mv_matrix, [0.0, 0.0, -5.0])
			mat4.rotate(mv_matrix, deg_rad(x_rot), [1, 0, 0])
			mat4.rotate(mv_matrix, deg_rad(y_rot), [0, 1, 0])
			mat4.rotate(mv_matrix, deg_rad(z_rot), [0, 0, 1])
			mv_matrix

		deg_rad = (degrees) ->
			degrees * Math.PI / 180

	matrix = new MATRIX_OP

	init_buffers = -> 
		cube_vertex_position_buffer = gl.createBuffer()
		gl.bindBuffer(gl.ARRAY_BUFFER, cube_vertex_position_buffer)
		vertices = [
			# Front face
			-1.0, -1.0,  1.0,
			 1.0, -1.0,  1.0,
			 1.0,  1.0,  1.0,
			-1.0,  1.0,  1.0,

			# Back face
			-1.0, -1.0, -1.0,
			-1.0,  1.0, -1.0,
			 1.0,  1.0, -1.0,
			 1.0, -1.0, -1.0,

			# Top face
			-1.0,  1.0, -1.0,
			-1.0,  1.0,  1.0,
			 1.0,  1.0,  1.0,
			 1.0,  1.0, -1.0,

			# Bottom face
			-1.0, -1.0, -1.0,
			 1.0, -1.0, -1.0,
			 1.0, -1.0,  1.0,
			-1.0, -1.0,  1.0,

			# Right face
			 1.0, -1.0, -1.0,
			 1.0,  1.0, -1.0,
			 1.0,  1.0,  1.0,
			 1.0, -1.0,  1.0,

			# Left face
			-1.0, -1.0, -1.0,
			-1.0, -1.0,  1.0,
			-1.0,  1.0,  1.0,
			 1.0,  1.0, -1.0,
		]

		gl.bufferData(
			gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)
		cube_vertex_position_buffer.itemSize = 3
		cube_vertex_position_buffer.numItems = 24

		cube_vertex_texture_buffer = gl.createBuffer()
		gl.bindBuffer(gl.ARRAY_BUFFER, cube_vertex_texture_buffer)
		texture_coords = [
			# Front face
			0.0, 0.0,
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,

			# Back face
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,
			0.0, 0.0,

			# Top face
			0.0, 1.0,
			0.0, 0.0,
			1.0, 0.0,
			1.0, 1.0,

			# Bottom face
			1.0, 1.0,
			0.0, 1.0,
			0.0, 0.0,
			1.0, 0.0,

			# Right face
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,
			0.0, 0.0,

			# Left face
			0.0, 0.0,
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,
		]

		gl.bufferData(
			gl.ARRAY_BUFFER, new Float32Array(texture_coords), gl.STATIC_DRAW)
		cube_vertex_texture_buffer.itemSize = 2
		cube_vertex_texture_buffer.numItems = 24

		cube_vertex_index_buffer = gl.createBuffer()
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cube_vertex_index_buffer)
		vertex_indices = [
			0, 1, 2,      0, 2, 3,    # Front face
			4, 5, 6,      4, 6, 7,    # Back face
			8, 9, 10,     8, 10, 11,  # Top face
			12, 13, 14,   12, 14, 15, # Bottom face
			16, 17, 18,   16, 18, 19, # Right face
			20, 21, 22,   20, 22, 23  # Left face
		]

		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, 
			new Uint16Array(vertex_indices), gl.STATIC_DRAW)
		cube_vertex_index_buffer.itemSize = 1
		cube_vertex_index_buffer.numItems = 36

	draw = ->
		gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		gl.bindBuffer(gl.ARRAY_BUFFER, cube_vertex_position_buffer)
		gl.vertexAttribPointer(
			program.vertexPositionAttribute,
			cube_vertex_position_buffer.itemSize,
			gl.FLOAT, false, 0, 0)
			
		gl.bindBuffer(gl.ARRAY_BUFFER, cube_vertex_texture_buffer)
		gl.vertexAttribPointer(
			program.textureCoordAttribute, 
			cube_vertex_texture_buffer.itemSize,
			gl.FLOAT, false, 0, 0)

		gl.activeTexture(gl.TEXTURE0)
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.uniform1i(program.samplerUniform, 0);

		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cube_vertex_index_buffer)

		p_matrix = matrix.perspective(
			gl.viewportWidth / gl.viewportHeight)
		mv_matrix = matrix.rotate(x_rot, y_rot, z_rot)
		
		gl.uniformMatrix4fv(program.pMatrixUniform, false, p_matrix)
		gl.uniformMatrix4fv(program.mvMatrixUniform, false, mv_matrix)

		gl.drawElements(
			gl.TRIANGLES, 
			cube_vertex_index_buffer.numItems,
			gl.UNSIGNED_SHORT, 0)

	sh_fragment = """
		precision mediump float;
		varying vec2 vTextureCoord;
		uniform sampler2D uSampler;
		void main(void) {
			gl_FragColor = texture2D(uSampler, 
				vec2(vTextureCoord.s, vTextureCoord.t));
		}
	"""

	sh_vertex = """
		attribute vec3 aVertexPosition;
		attribute vec2 aTextureCoord;
		uniform mat4 uMVMatrix;
		uniform mat4 uPMatrix;
		varying vec2 vTextureCoord;
		
		void main(void) {
			gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
			vTextureCoord = aTextureCoord;
		}
	"""

root = exports ? this
root.CUBE = CUBE
