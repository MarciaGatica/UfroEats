import usuarioModel from '../models/usuario.model.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import {
	JWT_SECRET
} from '../config/environment.js';

async function login(req, res) {
	const email = req.body.email;
	const clave = req.body.clave;
	console.log('req.body:', req.body);
	console.log('req.body:', email);

	const user = await usuarioModel
		.findOne({
			email: email.toLowerCase()
		})
		.select('+clave');

	if (!user) {
		return res.status(400).send({
			error: 'Usuario no encontrado'
		});
	}

	const match = await bcrypt.compare(clave, user.clave);

	if (!match) {
		return res.status(400).send({
			error: 'Contrasena no corresponde'
		});
	}

	const token = jwt.sign({
		userId: user._id
	}, JWT_SECRET);



	return res.status(200).send({
		user,
		token
	});
}

async function register(req, res) {
	const nombre_usuario = req.body.nombre_usuario;
	const clave = req.body.clave;
	const email = req.body.email;
	const telefono = req.body.telefono;
	const foto_usuario = req.body.foto_usuario;
	const isAdmin=req.body.isAdmin;

	console.log('req.body:', req.body);
	const user = await usuarioModel.findOne({
		email: email.toLowerCase()
	});

	if (user) {
		return res.status(400).send({
			error: 'Email ya utilizado'
		});
	}

	const passwordHash = await bcrypt.hash(clave, 10);

	const userSaved = await usuarioModel.create({
		nombre_usuario,
		email,
		telefono,
		foto_usuario,
		clave: passwordHash,
		isAdmin,
	});

	return res.status(200).send({
		userSaved
	});
}






export {
	login,
	register
};