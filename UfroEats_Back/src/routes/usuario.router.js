import express from 'express';
import {
    obtenerUnUsuario,
    listarUsuarios,
    crearUsuario,
    borrarUsuario,
    editarUsuario,
    agregarFavorito,
    eliminarFavorito,
    iniciarSesion
} from '../controllers/usuario.controller.js';



const usuarioRouter = express.Router();

usuarioRouter.get('/', listarUsuarios);
usuarioRouter.get('/:usuarioId', obtenerUnUsuario);
usuarioRouter.post('/', crearUsuario);
usuarioRouter.delete('/:usuarioId', borrarUsuario);
usuarioRouter.put('/:usuarioId', editarUsuario);
usuarioRouter.post('/:usuarioId/favoritos', agregarFavorito);
usuarioRouter.delete('/:usuarioId/favoritos', eliminarFavorito);
usuarioRouter.post('/login', iniciarSesion); // Ruta para inicio de sesión

export default usuarioRouter;
